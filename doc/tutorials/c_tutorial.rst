================================================================================
C tutorial
================================================================================

Here is one C tutorial:
:ref:`C stored procedures <f_c_tutorial-c_stored_procedures>`.

.. _f_c_tutorial-c_stored_procedures:

--------------------------------------------------------------------------------
C stored procedures
--------------------------------------------------------------------------------

Tarantool can call C code with :ref:`modules <app_server-modules>`,
or with :ref:`ffi <cookbook-ffi_printf>`,
or with C stored procedures.
This tutorial only is about the third option, C stored procedures.
In fact the routines are always "C functions" but the phrase
"stored procedure" is commonly used for historical reasons.

In this tutorial, which can be followed by anyone with a Tarantool
development package and a C compiler, there are five tasks:

(1) :ref:`easy.c <f_c_tutorial-easy>` -- prints "hello world";
(2) :ref:`harder.c <f_c_tutorial-harder>` -- decodes a passed parameter value;
(3) :ref:`hardest.c <f_c_tutorial-hardest>` -- uses the C API to do a DBMS insert;
(4) :ref:`read.c <f_c_tutorial-read>` -- uses the C API to do a DBMS select;
(5) :ref:`write.c <f_c_tutorial-write>` -- uses the C API to do a DBMS replace.

After following the instructions, and seeing that the results
are what is described here, users should feel confident about
writing their own stored procedures.

**Preparation**

Check that these items exist on the computer:

* Tarantool 1.10
* A gcc compiler, any modern version should work
* ``module.h`` and files #included in it
* ``msgpuck.h``
* ``libmsgpuck.a`` (only for some recent msgpuck versions)

The ``module.h`` file will exist if Tarantool was installed from source.
Otherwise Tarantool's "developer" package must be installed.
For example on Ubuntu say:

.. code-block:: console

    $ sudo apt-get install tarantool-dev

or on Fedora say:

.. code-block:: console

    $ dnf -y install tarantool-devel

The ``msgpuck.h`` file will exist if Tarantool was installed from source.
Otherwise the "msgpuck" package must be installed from
`https://github.com/tarantool/msgpuck <https://github.com/tarantool/msgpuck>`_.

Both ``module.h`` and ``msgpuck.h`` must be on the include path for the
C compiler to see them.
For example, if ``module.h`` address is ``/usr/local/include/tarantool/module.h``,
and ``msgpuck.h`` address is ``/usr/local/include/msgpuck/msgpuck.h``,
and they are not currently on the include path, say:

.. code-block:: console

    $ export CPATH=/usr/local/include/tarantool:/usr/local/include/msgpuck

The ``libmsgpuck.a`` static library is necessary with msgpuck versions
produced after February 2017. If and only if you encounter linking
problems when using the gcc statements in the examples for this tutorial, you should
put ``libmsgpuck.a`` on the path (``libmsgpuck.a`` is produced from both msgpuck
and Tarantool source downloads so it should be easy to find). For
example, instead of ":code:`gcc -shared -o harder.so -fPIC harder.c`"
for the second example below, you will need to say
":code:`gcc -shared -o harder.so -fPIC harder.c libmsgpuck.a`".

Requests will be done using Tarantool as a
:ref:`client <admin-using_tarantool_as_a_client>`.
Start Tarantool, and enter these requests.

.. code-block:: lua

    box.cfg{listen=3306}
    box.schema.space.create('capi_test')
    box.space.capi_test:create_index('primary')
    net_box = require('net.box')
    capi_connection = net_box:new(3306)

In plainer language: create a space named ``capi_test``,
and make a connection to self named ``capi_connection``.

Leave the client running. It will be necessary to enter more requests later.

.. _f_c_tutorial-easy:

**easy.c**

Start another shell. Change directory (``cd``) so that it is
the same as the directory that the client is running on.

Create a file. Name it ``easy.c``. Put these six lines in it.

.. code-block:: c

    #include "module.h"
    int easy(box_function_ctx_t *ctx, const char *args, const char *args_end)
    {
      printf("hello world\n");
      return 0;
    }
    int easy2(box_function_ctx_t *ctx, const char *args, const char *args_end)
    {
      printf("hello world -- easy2\n");
      return 0;
    }


Compile the program, producing a library file named ``easy.so``:

.. code-block:: console

    $ gcc -shared -o easy.so -fPIC easy.c

Now go back to the client and execute these requests:

.. code-block:: lua

    box.schema.func.create('easy', {language = 'C'})
    box.schema.user.grant('guest', 'execute', 'function', 'easy')
    capi_connection:call('easy')

If these requests appear unfamiliar,
re-read the descriptions of
:ref:`box.schema.func.create() <box_schema-func_create>`,
:ref:`box.schema.user.grant() <box_schema-user_grant>`
and :ref:`conn:call() <net_box-call>`.

The function that matters is ``capi_connection:call('easy')``.

Its first job is to find the 'easy' function, which should
be easy because by default Tarantool looks on the current
directory for a file named ``easy.so``.

Its second job is to call the 'easy' function.
Since the ``easy()`` function in ``easy.c`` begins with ``printf("hello world\n")``,
the words "hello world" will appear on the screen.

Its third job is to check that the call was successful.
Since the ``easy()`` function in ``easy.c`` ends with :code:`return 0`,
there is no error message to display and the request is over.

The result should look like this:

.. code-block:: tarantoolsession

    tarantool> capi_connection:call('easy')
    hello world
    ---
    - []
    ...

Now let's call the other function in easy.c -- ``easy2()``.
This is almost the same as the ``easy()`` function, but there's a detail:
when the file name is not the same as the function name,
then we have to specify
:samp:`{file-name}.{function-name}`.

.. code-block:: lua

    box.schema.func.create('easy.easy2', {language = 'C'})
    box.schema.user.grant('guest', 'execute', 'function', 'easy.easy2')
    capi_connection:call('easy.easy2')

... and this time the result will be "hello world -- easy2".

Conclusion: calling a C function is easy.

.. _f_c_tutorial-harder:

**harder.c**

Go back to the shell where the ``easy.c`` program was created.

Create a file. Name it ``harder.c``. Put these 17 lines in it:

.. code-block:: c

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

Compile the program, producing a library file named ``harder.so``:

.. code-block:: console

    $ gcc -shared -o harder.so -fPIC harder.c

Now go back to the client and execute these requests:

.. code-block:: lua

    box.schema.func.create('harder', {language = 'C'})
    box.schema.user.grant('guest', 'execute', 'function', 'harder')
    passable_table = {}
    table.insert(passable_table, 1)
    table.insert(passable_table, 2)
    table.insert(passable_table, 3)
    capi_connection:call('harder', passable_table)

This time the call is passing a Lua table (``passable_table``)
to the ``harder()`` function. The ``harder()`` function will see it,
it's in the :code:`char *args` parameter.

At this point the ``harder()`` function will start using functions
defined in `msgpuck.h <https://github.com/tarantool/msgpuck>`_.
The routines that begin with "mp" are msgpuck functions that
handle data formatted according to the MsgPack_ specification.
Passes and returns are always done with this format so
one must become acquainted with msgpuck
to become proficient with the C API.

For now, though, it's enough to know that ``mp_decode_array()``
returns the number of elements in an array, and ``mp_decode_uint``
returns an unsigned integer, from :code:`args`. And there's a side
effect: when the decoding finishes, :code:`args` has changed
and is now pointing to the next element.

Therefore the first displayed line will be "arg_count = 1"
because there was only one item passed: ``passable_table``. |br|
The second displayed line will be "field_count = 3"
because there are three items in the table. |br|
The next three lines will be "1" and "2" and "3"
because those are the values in the items in the table.

And now the screen looks like this:

.. code-block:: tarantoolsession

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

.. _f_c_tutorial-hardest:

**hardest.c**

Go back to the shell where the ``easy.c``
and the ``harder.c`` programs were created.

Create a file. Name it ``hardest.c``. Put these 13 lines in it:

.. code-block:: c

    #include "module.h"
    #include "msgpuck.h"
    int hardest(box_function_ctx_t *ctx, const char *args, const char *args_end)
    {
      uint32_t space_id = box_space_id_by_name("capi_test", strlen("capi_test"));
      char tuple[1024]; /* Must be big enough for mp_encode results */
      char *tuple_pointer = tuple;
      tuple_pointer = mp_encode_array(tuple_pointer, 2);
      tuple_pointer = mp_encode_uint(tuple_pointer, 10000);
      tuple_pointer = mp_encode_str(tuple_pointer, "String 2", 8);
      int n = box_insert(space_id, tuple, tuple_pointer, NULL);
      return n;
    }

Compile the program, producing a library file named ``hardest.so``:

.. code-block:: console

    $ gcc -shared -o hardest.so -fPIC hardest.c

Now go back to the client and execute these requests:

.. code-block:: lua

    box.schema.func.create('hardest', {language = "C"})
    box.schema.user.grant('guest', 'execute', 'function', 'hardest')
    box.schema.user.grant('guest', 'read,write', 'space', 'capi_test')
    capi_connection:call('hardest')

This time the C function is doing three things:

(1) finding the numeric identifier of the ``capi_test`` space
    by calling ``box_space_id_by_name()``;
(2) formatting a tuple using more ``msgpuck.h`` functions;
(3) inserting a tuple using ``box_insert()``.

.. WARNING::

    ``char tuple[1024];`` is used here as just a quick way
    of saying "allocate more than enough bytes". For serious
    programs the developer must be careful to allow enough space for
    all the bytes that the ``mp_encode`` routines will use up.

Now, still on the client, execute this request:

.. code-block:: lua

    box.space.capi_test:select()

The result should look like this:

.. code-block:: tarantoolsession

    tarantool> box.space.capi_test:select()
    ---
    - - [10000, 'String 2']
    ...

This proves that the ``hardest()`` function succeeded, but
where did :ref:`box_space_id_by_name() <box-box_space_id_by_name>` and
:ref:`box_insert() <box-box_insert>` come from?
Answer: the :ref:`C API <index-c_api_reference>`.

.. _f_c_tutorial-read:

**read.c**

Go back to the shell where the ``easy.c``
and the ``harder.c`` and the ``hardest.c`` programs were created.

Create a file. Name it ``read.c``. Put these 43 lines in it:

.. code-block:: c

    #include "module.h"
    #include <msgpuck.h>
    int read(box_function_ctx_t *ctx, const char *args, const char *args_end)
    {
      char tuple_buf[1024];      /* where the raw MsgPack tuple will be stored */
      uint32_t space_id = box_space_id_by_name("capi_test", strlen("capi_test"));
      uint32_t index_id = 0;     /* The number of the space's first index */
      uint32_t key = 10000;      /* The key value that box_insert() used */
      mp_encode_array(tuple_buf, 0); /* clear */
      box_tuple_format_t *fmt = box_tuple_format_default();
      box_tuple_t *tuple = box_tuple_new(fmt, tuple_buf, tuple_buf+512);
      assert(tuple != NULL);
      char key_buf[16];          /* Pass key_buf = encoded key = 1000 */
      char *key_end = key_buf;
      key_end = mp_encode_array(key_end, 1);
      key_end = mp_encode_uint(key_end, key);
      assert(key_end < key_buf + sizeof(key_buf));
      /* Get the tuple. There's no box_select() but there's this. */
      int r = box_index_get(space_id, index_id, key_buf, key_end, &tuple);
      assert(r == 0);
      assert(tuple != NULL);
      /* Get each field of the tuple + display what you get. */
      int field_no;             /* The first field number is 0. */
      for (field_no = 0; field_no < 2; ++field_no)
      {
        const char *field = box_tuple_field(tuple, field_no);
        assert(field != NULL);
        assert(mp_typeof(*field) == MP_STR || mp_typeof(*field) == MP_UINT);
        if (mp_typeof(*field) == MP_UINT)
        {
          uint32_t uint_value = mp_decode_uint(&field);
          printf("uint value=%u.\n", uint_value);
        }
        else /* if (mp_typeof(*field) == MP_STR) */
        {
          const char *str_value;
          uint32_t str_value_length;
          str_value = mp_decode_str(&field, &str_value_length);
          printf("string value=%.*s.\n", str_value_length, str_value);
        }
      }
      return 0;
    }

Compile the program, producing a library file named ``read.so``:

.. code-block:: console

    $ gcc -shared -o read.so -fPIC read.c

Now go back to the client and execute these requests:

.. code-block:: lua

    box.schema.func.create('read', {language = "C"})
    box.schema.user.grant('guest', 'execute', 'function', 'read')
    box.schema.user.grant('guest', 'read,write', 'space', 'capi_test')
    capi_connection:call('read')

This time the C function is doing four things:

(1) once again, finding the numeric identifier of the ``capi_test`` space
    by calling ``box_space_id_by_name()``;
(2) formatting a search key = 10000 using more ``msgpuck.h`` functions;
(3) getting a tuple using ``box_index_get()``;
(4) going through the tuple's fields with ``box_tuple_get()`` and then
    decoding each field depending on its type. In this case, since
    what we are getting is the tuple that we inserted with ``hardest.c``,
    we know in advance that the type is either MP_UINT or MP_STR;
    however, it's very common to have a case statement here with one
    option for each possible type.

The result of ``capi_connection:call('read')`` should look like this:

.. code-block:: tarantoolsession

    tarantool> capi_connection:call('read')
    uint value=10000.
    string value=String 2.
    ---
    - []
    ...

This proves that the ``read()`` function succeeded.
Once again the important functions that start with `box`
-- :ref:`box_index_get() <c_api-box_index-box_index_get>` and
:ref:`box_tuple_field() <c_api-tuple-box_tuple_field>` --
came from the :ref:`C API <index-c_api_reference>`.

.. _f_c_tutorial-write:

**write.c**

Go back to the shell where the programs ``easy.c``, ``harder.c``, ``hardest.c``
and ``read.c`` were created.

Create a file. Name it ``write.c``. Put these 24 lines in it:

.. code-block:: c

    #include "module.h"
    #include <msgpuck.h>
    int write(box_function_ctx_t *ctx, const char *args, const char *args_end)
    {
      static const char *space = "capi_test";
      char tuple_buf[1024]; /* Must be big enough for mp_encode results */
      uint32_t space_id = box_space_id_by_name(space, strlen(space));
      if (space_id == BOX_ID_NIL) {
        return box_error_set(__FILE__, __LINE__, ER_PROC_C,
        "Can't find space %s", "capi_test");
      }
      char *tuple_end = tuple_buf;
      tuple_end = mp_encode_array(tuple_end, 2);
      tuple_end = mp_encode_uint(tuple_end, 1);
      tuple_end = mp_encode_uint(tuple_end, 22);
      box_txn_begin();
      if (box_replace(space_id, tuple_buf, tuple_end, NULL) != 0)
        return -1;
      box_txn_commit();
      fiber_sleep(0.001);
      struct tuple *tuple = box_tuple_new(box_tuple_format_default(),
                                          tuple_buf, tuple_end);
      return box_return_tuple(ctx, tuple);
    }

Compile the program, producing a library file named ``write.so``:

.. code-block:: console

    $ gcc -shared -o write.so -fPIC write.c

Now go back to the client and execute these requests:

.. code-block:: lua

    box.schema.func.create('write', {language = "C"})
    box.schema.user.grant('guest', 'execute', 'function', 'write')
    box.schema.user.grant('guest', 'read,write', 'space', 'capi_test')
    capi_connection:call('write')

This time the C function is doing six things:

(1) once again, finding the numeric identifier of the ``capi_test`` space
    by calling ``box_space_id_by_name()``;
(2) making a new tuple;
(3) starting a transaction;
(4) replacing a tuple in ``box.space.capi_test``
(5) ending a transaction;
(6) the final line is a replacement for the loop in ``read.c`` --
    instead of getting each field and printing it, use the
    ``box_return_tuple(...)`` function to return the entire tuple
    to the caller and let the caller display it.

The result of ``capi_connection:call('write')`` should look like this:

.. code-block:: tarantoolsession

    tarantool> capi_connection:call('write')
    ---
    - [[1, 22]]
    ...

This proves that the ``write()`` function succeeded.
Once again the important functions that start with `box`
-- :ref:`box_txn_begin() <txn-box_txn_begin>`,
:ref:`box_txn_commit() <txn-box_txn_commit>` and
:ref:`box_return_tuple() <box-box_return_tuple>` --
came from the :ref:`C API <index-c_api_reference>`.

Conclusion: the long description of the whole C API is
there for a good reason.
All of the functions in it can be called from C functions
which are called from Lua.
So C "stored procedures" have full access to the database.

**Cleaning up**

* Get rid of each of the function tuples with
  :ref:`box.schema.func.drop <box_schema-func_drop>`.
* Get rid of the ``capi_test`` space with
  :ref:`box.schema.capi_test:drop() <box_space-drop>`.
* Remove the ``.c`` and ``.so`` files that were created for this
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

