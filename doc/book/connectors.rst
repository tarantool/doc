.. _index-box_connectors:

-------------------------------------------------------------------------------
                            Connectors
-------------------------------------------------------------------------------

Connectors are APIs that allow using Tarantool with various programming languages.

Connectors can be divided into two groups -- those maintained by the Tarantool team
and those supported by the community.
The Tarantool team maintains the :ref:`high-level C API <index_connector_c>`, the :ref:`Go <index_connector_go>`
and :ref:`Java <index_connector_java>` connectors, and a synchronous :ref:`Python <index_connector_py>` connector.
All other connectors are community-supported, which means that support for new Tarantool features may be delayed.
Besides, the Tarantool support team cannot prioritize issues that arise while working through these connectors.

This chapter documents the following connectors:

* :doc:`C++ <connectors/cxx/tntcxx_api>`
* :ref:`Java <index_connector_java>`
* :ref:`Go <index_connector_go>`
* :ref:`R <index_connector_r>`
* :ref:`Erlang <index_connector_erlang>`
* :ref:`Perl <index_connector_perl>`
* :ref:`PHP <index_connector_php>`
* :ref:`Python <index_connector_py>`
* :ref:`Node.js <index_connector_nodejs>`
* :ref:`C# <index_connector_csharp>`
* :ref:`C <index_connector_c>`

..  toctree::
    :hidden:

    C++ <connectors/cxx/tntcxx_api>

=====================================================================
                            Protocol
=====================================================================

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

====================================================================
                          Packet example
====================================================================

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

====================================================================
          Setting up the server for connector examples
====================================================================

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

.. _index_connector_java:

.. include:: connectors/__java.rst

.. _index_connector_go:

.. include:: connectors/__go.rst

.. _index_connector_r:

.. include:: connectors/__r.rst

.. _index_connector_erlang:

.. include:: connectors/__erlang.rst

.. _index_connector_perl:

.. include:: connectors/__perl.rst

.. _index_connector_php:

.. include:: connectors/__php.rst

.. _index_connector_py:

.. include:: connectors/__python.rst

.. _index_connector_nodejs:

.. include:: connectors/__nodejs.rst

.. _index_connector_csharp:

.. include:: connectors/__csharp.rst

.. _index_connector_c:

.. include:: connectors/__c.rst

.. include:: connectors/__results.rst
