.. _buffer-module:

-------------------------------------------------------------------------------
                            Module `buffer`
-------------------------------------------------------------------------------

The ``buffer`` module returns a dynamically resizable buffer which is solely
for optional use by methods of the :ref:`net.box module <net_box-module>`
or the :ref:`msgpack module <msgpack-module>`.

Ordinarily the ``net.box`` methods return a Lua table.
If a ``buffer`` option is used, then the ``net.box`` methods return a
:ref:`raw MsgPack string <msgpack-definitions>`.
This saves time on the server, if the client application has
its own routine for decoding raw MsgPack strings.

.. module:: buffer

.. _buffer-ibuf:

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
    To show this, we will use
    :ref:`msgpack.decode_unchecked() <msgpack-decode_unchecked_c_style_string_pointer>`
    on ``ibuf.rpos`` (the "read position" of the buffer).
    Thus we do not decode on the remote server, but we do
    decode on the local server.

    .. code-block:: lua

        box.cfg{listen=3302}
        buffer = require('buffer')
        ibuf = buffer.ibuf()
        net_box = require('net.box')
        conn = net_box.connect('farhost:3301')
        buffer = require('buffer')
        conn.space.T:select({},{buffer=ibuf})
        msgpack = require('msgpack')
        msgpack.decode_unchecked(ibuf.rpos)

    The result of the final request looks like this:

    .. code-block:: tarantoolsession

        tarantool> msgpack.decode_unchecked(ibuf.rpos)
        ---
        - {48: [['ABCDE', 12345]]}
        - 'cdata<char *>: 0x7f97ba10c041'
        ...

    .. NOTE::

        Before Tarantool version 1.7.7, the function to use for
        this case is ``msgpack.ibuf_decode(ibuf.rpos)``. Starting
        with Tarantool version 1.7.7, ``ibuf_decode`` is deprecated.


.. _buffer-module_and_skip_header:

**Module buffer and skip_header**

The example in the previous section

.. code-block:: tarantoolsession

    tarantool> msgpack.decode_unchecked(ibuf.rpos)
    ---
    - {48: [['ABCDE', 12345]]}
    - 'cdata<char *>: 0x7f97ba10c041'
    ...

showed that, ordinarily, the response from net.box includes a header --
48 (hexadecimal 30) is the :ref:`key <internals-unified_packet_structure>`
for IPROTO_DATA. But in some situations,
for example when passing the buffer to a C function
that expects a MsgPack byte array without a header,
the header can be skipped. This is done by specifying
``skip_header=true`` as an option to
:ref:`conn.space.space-name:select{...} <conn-select>` or
:ref:`conn.space.space-name:insert{...} <conn-insert>` or
:ref:`conn.space.space-name:replace{...} <conn-replace>` or
:ref:`conn.space.space-name:update{...} <conn-update>` or
:ref:`conn.space.space-name:upsert{...} <conn-upsert>` or
:ref:`conn.space.space-name:delete{...} <conn-delete>`.
The default is ``skip_header=false``.

Now here is the same example, except that ``skip_header=true`` is used.

.. code-block:: lua

    box.cfg{listen=3302}
    buffer = require('buffer')
    ibuf = buffer.ibuf()
    net_box = require('net.box')
    conn = net_box.connect('farhost:3301')
    buffer = require('buffer')
    conn.space.T:select({},{buffer=ibuf, skip_header=true})
    msgpack = require('msgpack')
    msgpack.decode_unchecked(ibuf.rpos)

The result of the final request looks like this:

.. code-block:: tarantoolsession

    tarantool>         msgpack.decode_unchecked(ibuf.rpos)
    ---
    - [['ABCDE', 12345]]
    - 'cdata<char *>: 0x7f8fd102803f'
    ...

Notice that the IPROTO_DATA header (48) is gone.

The result is still inside an array, as is clear from the fact
that it is shown inside square brackets. It is possible to skip
the array header too, with
:ref:`msgpack.decode_array_header() <msgpack-decode_array_header>`.

.. _MsgPack: http://msgpack.org/
