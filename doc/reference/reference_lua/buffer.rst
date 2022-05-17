.. _buffer-module:

-------------------------------------------------------------------------------
                            Module buffer
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

The buffer uses four pointers to manage its capacity:

* ``buf`` -- a pointer to the beginning of the buffer
* ``rpos`` -- a pointer to the beginning of the range; available for reading data ("read position")
* ``wpos`` -- a pointer to the end of the range; available for reading data, and to the
  beginning of the range for writing new data ("write position")
* ``epos`` -- a pointer to the end of the range; available for writing new data ("end position")

.. _buffer-ibuf:

.. function:: ibuf()

    Create a new buffer.

    **Example:**

    In this example we will show that using buffer allows you to keep the data
    in the format that you get from the server. So if you get the data only for
    sending it somewhere else, buffer fastens this a lot.

    .. code-block:: lua

        box.cfg{listen = 3301}
        buffer = require('buffer')
        net_box = require('net.box')
        msgpack = require('msgpack')

        box.schema.space.create('tester')
        box.space.tester:create_index('primary')
        box.space.tester:insert({1, 'ABCDE', 12345})

        box.schema.user.create('usr1', {password = 'pwd1'})
        box.schema.user.grant('usr1', 'read,write,execute', 'space', 'tester')

        ibuf = buffer.ibuf()

        conn = net_box.connect('usr1:pwd1@localhost:3301')
        conn.space.tester:select({}, {buffer=ibuf})

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

        Allocate ``size`` bytes for ``buffer_object``.

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

        Return the size of the range occupied by data.

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
48 (hexadecimal 30) that is the :ref:`key <internals-unified_packet_structure>`
for IPROTO_DATA. But in some situations, for example when passing the buffer to
a C function that expects a MsgPack byte array without a header, the header can
be skipped. This is done by specifying ``skip_header=true`` as an option to
:ref:`conn.space.space-name:select{...} <conn-select>` or
:ref:`conn.space.space-name:insert{...} <conn-insert>` or
:ref:`conn.space.space-name:replace{...} <conn-replace>` or
:ref:`conn.space.space-name:update{...} <conn-update>` or
:ref:`conn.space.space-name:upsert{...} <conn-upsert>` or
:ref:`conn.space.space-name:delete{...} <conn-delete>`.
The default is ``skip_header=false``.

Now here is the end of the same example, except that ``skip_header=true`` is used.

.. code-block:: lua

        ibuf = buffer.ibuf()

        conn = net_box.connect('usr1:pwd1@localhost:3301')
        conn.space.tester:select({}, {buffer=ibuf, skip_header=true})

        msgpack.decode_unchecked(ibuf.rpos)

The result of the final request looks like this:

.. code-block:: tarantoolsession

    tarantool> msgpack.decode_unchecked(ibuf.rpos)
    ---
    - [['ABCDE', 12345]]
    - 'cdata<char *>: 0x7f8fd102803f'
    ...

Notice that the IPROTO_DATA header (48) is gone.

The result is still inside an array, as is clear from the fact that it is shown
inside square brackets. It is possible to skip the array header too, with
:ref:`msgpack.decode_array_header() <msgpack-decode_array_header>`.
