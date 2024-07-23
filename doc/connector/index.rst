..  _index-box_connectors:
..  _getting_started_connectors:
..  _connectors-community-supported:

Connectors
==========

Connectors are APIs that allow using Tarantool with various programming languages.

Connectors can be divided into two groups -- those maintained by the Tarantool team
and those supported by the community.
The Tarantool team maintains the following connectors:

-   :ref:`Go <index_connector_go>`
-   :ref:`Java <index_connector_java>`
-   :ref:`high-level C API <index_connector_c>`
-   :ref:`synchronous Python connector <index_connector_py>`

All other connectors are community-supported, which means that support for new Tarantool features may be delayed.
Find all the available connectors on the `Connectors <https://www.tarantool.io/en/download/connectors>`_ page.

This section documents APIs for various programming languages:

..  toctree::
    :maxdepth: 1
    :hidden:

    go
    java
    c
    python
    tntcxx

Protocol
--------

Tarantool's binary protocol was designed with a focus on asynchronous I/O and
easy integration with proxies. Each client request starts with a variable-length
binary header, containing request id, request type, instance id, log sequence
number, and so on.

The mandatory length, present in request header simplifies client or proxy I/O.
A response to a request is sent to the client as soon as it is ready. It always
carries in its header the same type and id as in the request. The id makes it
possible to match a request to a response, even if the latter arrived out of
order.

Unless implementing a client driver, you needn't concern yourself with the
complications of the binary protocol. Language-specific drivers provide a
friendly way to store domain language data structures in Tarantool. A complete
description of the binary protocol is maintained in annotated Backus-Naur form
in the source tree. For detailed examples and diagrams of all binary-protocol
requests and responses, see
:ref:`Tarantool's binary protocol <box_protocol-iproto_protocol>`.


Packet example
--------------

The Tarantool API exists so that a client program can send a request packet to
a server instance, and receive a response. Here is an example of a what the client
would send for ``box.space[513]:insert{'A', 'BB'}``. The BNF description of
the components is on the page about
:ref:`Tarantool's binary protocol <box_protocol-iproto_protocol>`.

.. _Language-specific drivers: `Connectors`_

.. container:: table

    .. rst-class:: left-align-column-1
    .. rst-class:: right-align-column-2
    .. rst-class:: right-align-column-3
    .. rst-class:: right-align-column-4

    +---------------------------------+---------+---------+---------+---------+
    | Component                       | Byte #0 | Byte #1 | Byte #2 | Byte #3 |
    +=================================+=========+=========+=========+=========+
    | code for insert                 |   02    |         |         |         |
    +---------------------------------+---------+---------+---------+---------+
    | rest of header                  |   ...   |   ...   |   ...   |   ...   |
    +---------------------------------+---------+---------+---------+---------+
    | 2-digit number: space id        |   cd    |   02    |   01    |         |
    +---------------------------------+---------+---------+---------+---------+
    | code for tuple                  |   21    |         |         |         |
    +---------------------------------+---------+---------+---------+---------+
    | 1-digit number: field count = 2 |   92    |         |         |         |
    +---------------------------------+---------+---------+---------+---------+
    | 1-character string: field[1]    |   a1    |   41    |         |         |
    +---------------------------------+---------+---------+---------+---------+
    | 2-character string: field[2]    |   a2    |   42    |   42    |         |
    +---------------------------------+---------+---------+---------+---------+

Now, you could send that packet to the Tarantool instance, and interpret the
response (the page about
:ref:`Tarantool's binary protocol <box_protocol-iproto_protocol>` has a
description of the packet format for responses as well as requests). But it
would be easier, and less error-prone, if you could invoke a routine that
formats the packet according to typed parameters. Something like
``response = tarantool_routine("insert", 513, "A", "B");``. And that is why APIs
exist for drivers for Perl, Python, PHP, and so on.

.. _index-connector_setting:

Setting up the server for connector examples
--------------------------------------------

This chapter has examples that show how to connect to a Tarantool instance via
the Perl, PHP, Python, node.js, and C connectors. The examples contain hard code that
will work if and only if the following conditions are met:

* the Tarantool instance (tarantool) is running on localhost (127.0.0.1) and is listening on
  port 3301 (``box.cfg.listen = '3301'``),

* space ``examples`` has id = 999 (``box.space.examples.id = 999``) and has
  a primary-key index for a numeric field
  (``box.space[999].index[0].parts[1].type = "unsigned"``),

* user 'guest' has privileges for reading and writing.

It is easy to meet all the conditions by starting the instance and executing this
script:

.. code-block:: lua

    box.cfg{listen=3301}
    box.schema.space.create('examples',{id=999})
    box.space.examples:create_index('primary', {type = 'hash', parts = {1, 'unsigned'}})
    box.schema.user.grant('guest','read,write','space','examples')
    box.schema.user.grant('guest','read','space','_space')


Interpreting function return values
-----------------------------------

For all connectors, calling a function via Tarantool causes a return in the
MsgPack format. If the function is called using the connector's API, some
conversions may occur. All scalar values are returned as tuples (with a MsgPack
type-identifier followed by a value); all non-scalar values are returned as a
group of tuples (with a MsgPack array-identifier followed by the scalar values).
If the function is called via the binary protocol command layer -- "eval" --
rather than via the connector's API, no conversions occur.

In the following example, a Lua function will be created. Since it will be
accessed externally by a :ref:`'guest' user<box_space-user>`, a
:doc:`grant </reference/reference_lua/box_schema/user_grant>` of an execute privilege will
be necessary. The function returns an empty array, a scalar string, two booleans,
and a short integer. The values are the ones described in the table
:ref:`Common Types and MsgPack Encodings <msgpack-common_types_and_msgpack_encodings>`.

..  code-block:: tarantoolsession

    tarantool> box.cfg{listen=3301}
    2016-03-03 18:45:52.802 [27381] main/101/interactive I> ready to accept requests
    ---
    ...
    tarantool> function f() return {},'a',false,true,127; end
    ---
    ...
    tarantool> box.schema.func.create('f')
    ---
    ...
    tarantool> box.schema.user.grant('guest','execute','function','f')
    ---
    ...

Here is a C program which calls the function. Although C is being used for the
example, the result would be precisely the same if the calling program was
written in Perl, PHP, Python, Go, or Java.

..  code-block:: c

    #include <stdio.h>
    #include <stdlib.h>
    #include <tarantool/tarantool.h>
    #include <tarantool/tnt_net.h>
    #include <tarantool/tnt_opt.h>
    void main() {
      struct tnt_stream *tnt = tnt_net(NULL);              /* SETUP */
      tnt_set(tnt, TNT_OPT_URI, "localhost:3301");
       if (tnt_connect(tnt) < 0) {                         /* CONNECT */
           printf("Connection refused\n");
           exit(-1);
       }
       struct tnt_stream *arg; arg = tnt_object(NULL);     /* MAKE REQUEST */
       tnt_object_add_array(arg, 0);
       struct tnt_request *req1 = tnt_request_call(NULL);  /* CALL function f() */
       tnt_request_set_funcz(req1, "f");
       uint64_t sync1 = tnt_request_compile(tnt, req1);
       tnt_flush(tnt);                                     /* SEND REQUEST */
       struct tnt_reply reply;  tnt_reply_init(&reply);    /* GET REPLY */
       tnt->read_reply(tnt, &reply);
       if (reply.code != 0) {
         printf("Call failed %lu.\n", reply.code);
         exit(-1);
       }
       const unsigned char *p= (unsigned char*)reply.data; /* PRINT REPLY */
       while (p < (unsigned char *) reply.data_end)
       {
         printf("%x ", *p);
         ++p;
       }
       printf("\n");
       tnt_close(tnt);                                     /* TEARDOWN */
       tnt_stream_free(arg);
       tnt_stream_free(tnt);
    }

When this program is executed, it will print:

..  code-block:: console

    dd 0 0 0 5 90 91 a1 61 91 c2 91 c3 91 7f

The first five bytes -- ``dd 0 0 0 5`` -- are the MsgPack encoding for
"32-bit array header with value 5" (see
`MsgPack specification <http://github.com/msgpack/msgpack/blob/master/spec.md>`__).
The rest are as described in the
table :ref:`Common Types and MsgPack Encodings <msgpack-common_types_and_msgpack_encodings>`.
