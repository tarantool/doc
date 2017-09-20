.. _buffer-module:

-------------------------------------------------------------------------------
                            Module `buffer`
-------------------------------------------------------------------------------

The ``buffer`` module returns a dynamically resizable buffer which is solely
for use as an option for methods of the :ref:`net.box module <net_box-module>`.

Ordinarily the ``net.box`` methods return a Lua table.
If a ``buffer`` option is used, then the ``net.box`` methods return a
raw MsgPack_ string.
This saves time on the server, if the client application has
its own routine for decoding MsgPack strings.

.. module:: buffer

.. function:: ibuf()

    :return: a descriptor of a buffer.
    :rtype: cdata

    **Example:**

    Assume a Tarantool server is listening on farhost:3301.
    Assume it has a space ``T`` with one tuple: ``'ABCDE', 12345``.
    In this example we start up a server on localhost:3302
    and then use ``net.box`` routines to connect to farhost.
    Then we create a buffer, and use it as an option
    for a ``conn.space...select()`` call.
    The result will be in MsgPack_ format.
    To show this, we will use ``msgpack.ibuf_decode()``
    on ``ibuf.rpos`` (the "read position" of the buffer).
    Thus we do not decode on the remote server, but we do
    decode on the local server.

    .. code-block:: lua

        box.cfg{listen=3302}
        ibuf = buffer.ibuf()
        net_box = require('net.box')
        conn = net_box.connect('farhost:3301')
        buffer = require('buffer')
        conn.space.T:select({},{buffer=ibuf})
        msgpack = require('msgpack')
        msgpack.ibuf_decode(ibuf.rpos)

    The result of the final request looks like this:

    .. code-block:: tarantoolsession

        tarantool> msgpack.ibuf_decode(ibuf.rpos)
        ---
        - 'cdata<char *>: 0x7f97ba10c041'
        - {48: [['ABCDE', 12345]]}
        ...

.. _MsgPack: http://msgpack.org/