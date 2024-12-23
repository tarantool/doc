
.. _box_tuple-bsize:

================================================================================
tuple_object.bsize()
================================================================================

.. class:: tuple_object

    .. method:: bsize()

        If ``t`` is a tuple instance, ``t:bsize()`` will return the number of
        bytes in the tuple. With both the memtx storage engine and the vinyl
        storage engine the default maximum is one megabyte
        (:ref:`memtx_max_tuple_size <cfg_storage-memtx_max_tuple_size>` or
        :ref:`vinyl_max_tuple_size <cfg_storage-vinyl_max_tuple_size>`). Every
        field has one or more "length" bytes preceding the actual contents, so
        ``bsize()`` returns a value which is slightly greater than the sum of
        the lengths of the contents.

        The value does not include the size of "struct tuple" (for the current
        size of this structure look in the
        `tuple.h <https://github.com/tarantool/tarantool/blob/1.10/src/box/tuple.h>`_
        file in Tarantool's source code).

        :return: number of bytes
        :rtype: number

        In the following example, a tuple named ``t`` is created which has
        three fields, and for each field it takes one byte to store the length
        and three bytes to store the contents, and then there is one more byte
        to store a count of the number of fields, so ``bsize()`` returns
        ``3*(1+3)+1``. This is the same as the size of the string that
        :ref:`msgpack.encode({'aaa','bbb','ccc'}) <msgpack-encode_lua_value>`
        would return.

        .. code-block:: tarantoolsession

            tarantool> t = box.tuple.new{'aaa', 'bbb', 'ccc'}
            ---
            ...
            tarantool> t:bsize()
            ---
            - 13
            ...