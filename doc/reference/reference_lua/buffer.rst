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

Buffer uses four pointers to manage its capacity:

* buf -- a pointer to the beginning of the buffer
* rpos -- a pointer to the beginning of the range, available for reading data ("read position")
* wpos -- a pointer to the end of the range, available for reading data, and to the
  beginning of the range for writing new data ("write position")
* epos -- a pointer to the end of the range, available for writing new data ("end position")

.. _buffer-ibuf:

.. function:: ibuf()

    Create a new buffer.

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
    on ``ibuf.rpos``.
    Thus we do not decode on the remote server, but we do
    decode on the local server.

    .. code-block:: lua

        box.cfg{listen = 3302}
        buffer = require('buffer')
        ibuf = buffer.ibuf()
        net_box = require('net.box')
        conn = net_box.connect('farhost:3301')
        buffer = require('buffer')
        conn.space.T:select({}, {buffer=ibuf})
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

.. class:: buffer_object

    .. _buffer-alloc:

    .. method:: alloc(size)

        :param number size: memory in bytes to allocate
        :return: ``wpos``


    .. _buffer-capacity:

    .. method:: capacity()

        Return the capacity of the ``buffer_object``.

        :return: ``epos - buf``


    .. _buffer-checksize:

    .. method:: checksize(size)

        Check if ``size`` bytes are available for reading in ``buffer_object``.

        :param number size: memory in bytes to check
        :return: ``rpos``


    .. _buffer-pos:

    .. method:: pos()

        :return: ``rpos - buf``


    .. _buffer-read:

    .. method:: read(size)

        Read ``size`` bytes from buffer.


    .. _buffer-recycle:

    .. method:: recycle()

        Clear the memory slots allocated by ``buffer_object``.

        .. code-block:: tarantoolsession

          tarantool> ibuf:recycle()
          ---
          ...
          tarantool> ibuf.buf, ibuf.rpos, ibuf.wpos, ibuf.epos
          ---
          - 'cdata<char *>: NULL'
          - 'cdata<char *>: NULL'
          - 'cdata<char *>: NULL'
          - 'cdata<char *>: NULL'
          ...


    .. _buffer-reset:

    .. method:: reset()

        Clear the memory slots used by ``buffer_object``. This method allows to
        keep the buffer but remove data from it. It is useful when you want to
        use the buffer further.

        .. code-block:: tarantoolsession

          tarantool> ibuf:reset()
          ---
          ...
          tarantool> ibuf.buf, ibuf.rpos, ibuf.wpos, ibuf.epos
          ---
          - 'cdata<char *>: 0x010cc28030'
          - 'cdata<char *>: 0x010cc28030'
          - 'cdata<char *>: 0x010cc28030'
          - 'cdata<char *>: 0x010cc2c000'
          ...


    .. _buffer-reserve:

    .. method:: reserve(size)

        Reserve memory for ``buffer_object``. Check if there is enough memory to
        write ``size`` bytes after ``wpos``. If not, ``epos`` shifts until ``size``
        bytes will be available.

    .. _buffer-size:

    .. method:: size()

        Return a range, available for reading data.

        :return: ``wpos - rpos``


    .. _buffer-unused:

    .. method:: unused()

        Return a range for writing data.

        :return: ``epos - wpos``



