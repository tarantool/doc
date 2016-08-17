-------------------------------------------------------------------------------
                        Appendix F. C tutorial
-------------------------------------------------------------------------------

There is one C tutorial:
:ref:`C stored procedures <f_c_tutorial-c_stored_procedures>`.

.. _f_c_tutorial-c_stored_procedures:

=====================================================================
       C stored procedures
=====================================================================

Tarantool can call C code with :ref:`modules <modules-example_c>`,
or with :ref:`ffi <e_cookbook-ffi_printf>`,
or with C stored procedures.
This tutorial only is about the third option, C stored procedures.
In fact the routines are always "C functions" but the phrase
"stored procedure" is commonly used for historical reasons.

In this tutorial, which can be followed by anyone with a Tarantool
development package and a C compiler, there are three tasks.
The first -- :code:`easy.c` -- prints "hello world".
The second -- :code:`harder.c` -- decodes a passed parameter value.
The third -- :code:`hardest.c` -- uses the C API to do DBMS work.

After following the instructions, and seeing that the results
are what is described here, users should feel confident about
writing their own stored procedures.

**Preparation**

Check that these items exist on the computer: |br|
* Tarantool 1.7 |br|
* A gcc compiler, any modern version should work |br|
* "module.h" |br|
* "msgpuck.h" |br|

The "module.h" file will exist if Tarantool 1.7 was installed from source.
Otherwise Tarantool's "developer" package must be installed.
For example on Ubuntu say |br|
:code:`sudo apt-get install tarantool-dev` |br|
or on Fedora say |br|
:code:`dnf -y install tarantool-devel`

The "msgpuck.h" file will exist if Tarantool 1.7 was installed from source.
Otherwise the "msgpuck" package must be installed from
`https://github.com/rtsisyk/msgpuck <https://github.com/rtsisyk/msgpuck>`_.

Both module.h and msgpuck.h must be on the include path for the C compiler to see them.
For example, if module.h address is /usr/local/include/tarantool/module.h,
and msgpuck.h address is /usr/local/include/msgpuck/msgpuck.h,
and they are not currently on the include path, say |br|
:code:`export CPATH=/usr/local/include/tarantool:/usr/local/include/msgpuck`

Requests will be done using tarantool as a :ref:`client <administration-using_tarantool_as_a_client>`.
Start tarantool, and enter these requests.

.. code-block:: none

    box.cfg{listen=3306}
    box.schema.space.create('capi_test')
    box.space.capi_test:create_index('primary')
    net_box = require('net.box')
    capi_connection = net_box:new(3306)

In plainer language: create a space named capi_test,
and make a connection to self named capi_connection.

Leave the client running. It will be necessary to enter more requests later.

**easy.c**

Start another shell. Change directory (cd) so that it is
the same as the directory that the client is running on.

Create a file. Name it easy.c. Put these six lines in it.

.. code-block:: none

    #include "module.h"
    int easy(box_function_ctx_t *ctx, const char *args, const char *args_end)
    {
      printf("hello world\n");
      return 0;
    }

Compile the program, producing a library file named easy.so: |br|
:code:`gcc -shared -o easy.so -fPIC easy.c`

Now go back to the client and execute these requests:

.. code-block:: none

    box.schema.func.create('easy', {language = 'C'})
    box.schema.user.grant('guest', 'execute', 'function', 'easy')
    capi_connection:call('easy')

If these requests appear unfamiliar,
re-read the descriptions of
:ref:`box.schema.func.create <box_schema-func_create>`
and :ref:`box.schema.user.grant <box_schema-user_grant>`
and :ref:`conn:call <net_box-call>`.

The function that matters is capi_connection:call('easy').

Its first job is to find the 'easy' function, which should
be easy because by default Tarantool looks on the current
directory for a file named easy.so.

Its second job is to call the 'easy' function.
Since the easy() function in easy.c begins with :code:`printf("hello world\n")`,
the words "hello world" will appear on the screen.

Its third job is to check that the call was successful.
Since the easy() function in easy.c ends with :code:`return 0`,
there is no error message to display and the request is over.

The result should look like this:

.. code-block:: none

    tarantool> capi_connection:call('easy')
    hello world
    ---
    - []
    ...

Conclusion: calling a C function is easy.

**harder.c**

Go back to the shell where the easy.c program was created.

Create a file. Name it harder.c. Put these 17 lines in it:

.. code-block:: none

    #include "module.h"
    #include "msgpuck.h"
    int harder(box_function_ctx_t *ctx, const char *args, const char *args_end)
    {
      uint32_t arg_count = mp_decode_array(&args);
      printf("arg_count = %d\n", arg_count);
      uint32_t field_count = mp_decode_array(&args);
      printf("field_count = %d\n", field_count);
      uint32_t val;
      int i;
      for (i = 0; i < field_count; ++i)
      {
        val = mp_decode_uint(&args);
        printf("val=%d.\n", val);
      }
      return 0;
    }

Compile the program, producing a library file named harder.so: |br|
:code:`gcc -shared -o harder.so -fPIC harder.c`

Now go back to the client and execute these requests:

.. code-block:: none

    box.schema.func.create('harder', {language = 'C'})
    box.schema.user.grant('guest', 'execute', 'function', 'harder')
    passable_table = {}
    table.insert(passable_table, 1)
    table.insert(passable_table, 2)
    table.insert(passable_table, 3)
    capi_connection:call('harder', passable_table)

This time the call is passing a Lua table (passable_table)
to the harder() function. The harder() function will see it,
it's in the :code:`char *args` parameter.

At this point the harder() function will start using functions
defined in msgpuck.h, which are documented in
`http://rtsisyk.github.io/msgpuck <http://rtsisyk.github.io/msgpuck>`_.
The routines that begin with "mp" are msgpuck functions that
handle data formatted according to the MsgPack_ specification.
Passes and returns are always done with this format so
one must become acquainted with msgpuck
to become proficient with the C API.

For now, though, it's enough to know that mp_decode_array()
returns the number of elements in an array, and mp_decode_uint
returns an unsigned integer, from :code:`args`. And there's a side
effect: when the decoding finishes, :code:`args` has changed
and is now pointing to the next element.

Therefore the first displayed line will be "arg_count = 1"
because there was only one item passed: passable_table. |br|
The second displayed line will be "field_count = 3"
because there are three items in the table. |br|
The next three lines will be "1" and "2" and "3"
because those are the values in the items in the table.

And now the screen looks like this:

.. code-block:: none

    tarantool> capi_connection:call('harder', passable_table)
    arg_count = 1
    field_count = 3
    val=1.
    val=2.
    val=3.
    ---
    - []
    ...

Conclusion: decoding parameter values passed to a
C function is not easy at first, but there are routines
to do the job, and they're documented, and there aren't
very many of them.

**hardest.c**

Go back to the shell where the easy.c
and the harder.c programs were created.

Create a file. Name it hardest.c. Put these 13 lines in it:

.. code-block:: none

    #include "module.h"
    #include "msgpuck.h"
    int hardest(box_function_ctx_t *ctx, const char *args, const char *args_end)
    {
      uint32_t space_id = box_space_id_by_name("capi_test", strlen("capi_test"));
      char tuple[1024];
      char *tuple_pointer = tuple;
      tuple_pointer = mp_encode_array(tuple_pointer, 2);
      tuple_pointer = mp_encode_uint(tuple_pointer, 10000);
      tuple_pointer = mp_encode_str(tuple_pointer, "String 2", 8);
      int n = box_insert(space_id, tuple, tuple_pointer, NULL);
      return n;
    }

Compile the program, producing a library file named hardest.so: |br|
:code:`gcc -shared -o hardest.so -fPIC hardest.c`

Now go back to the client and execute these requests:

.. code-block:: none

    box.schema.func.create('hardest', {language = "C"})
    box.schema.user.grant('guest', 'execute', 'function', 'hardest')
    box.schema.user.grant('guest', 'read,write', 'space', 'capi_test')
    capi_connection:call('hardest')

This time the C function is doing three things:
(1) finding the numeric identifier of the "capi_test" space
by calling box_space_id_by_name(); |br|
(2) formatting a tuple using more msgpuck.h functions; |br|
(3) inserting a row using box_insert.

Now, still on the client, execute this request: |br|
:code:`box.space.capi_test:select()`

The result should look like this:

.. code-block:: none

    tarantool> box.space.capi_test:select()
    ---
    - - [10000, 'String 2']
    ...

This proves that the hardest() function succeeded, but
where did box_space_id_by_name() and box_insert() come from?
Answer: the C API. The whole C API is documented :ref:`here <index-c_api_reference>`.
The function box_space_id_by_name() is documented :ref:`here <box-box_space_id_by_name>`.
The function box_insert() is documented :ref:`here <box-box_insert>`.

Conclusion: the long description of the C API is
there for a good reason.
All of the functions in it can be called from C functions
which are called from Lua.
So C "stored procedures" have full access to the database.

**Cleaning up**

Get rid of each of the function tuples with :ref:`box.schema.func.drop <box_schema-func_drop>`,
and get rid of the capi_test space with :ref:`box.schema.capi_test:drop() <box_space-drop>`,
and remove the .c and .so files that were created for this
tutorial.

**An example in the test suite**

Download the source code of Tarantool. Look in a subdirectory
:code:`test/box`. Notice that there is a file named
:code:`tuple_bench.test.lua` and another file named
:code:`tuple_bench.c`. Examine the Lua file and observe
that it is calling a function in the C file, using the
same techniques that this tutorial has shown.

Conclusion: parts of the standard test suite
use C stored procedures, and they must work,
because releases don't happen if Tarantool doesn't pass the tests.

.. _MsgPack: http://msgpack.org/

