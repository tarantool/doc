.. _box_tuple-format:

tuple_object:format()
=====================

.. class:: tuple_object

    .. method:: format()

        Get the format of a tuple. The resulting table lists the fields of a tuple
        (their names and types) if the ``format`` option was specified during the tuple
        creation. Otherwise, the return value is empty.

        :return: the tuple format.
        :rtype:  table

        .. note::

            ``tuple_object.format()`` is equivalent to ``box.tuple.format(tuple_object)``.

        Example:

        *   A formatted tuple:

            .. code-block:: tarantoolsession

                tarantool> f = box.tuple.format.new({{'id', 'number'}, {'name', 'string'}})
                ---
                ...

                tarantool> ftuple = box.tuple.new({1, 'Bob'}, {format = f})
                ---
                ...

                tarantool> ftuple:format()
                ---
                - [{'name': 'id', 'type': 'number'}, {'name': 'name', 'type': 'string'}]
                ...

                tarantool> box.tuple.format(ftuple)
                ---
                - [{'name': 'id', 'type': 'number'}, {'name': 'name', 'type': 'string'}]
                ...

        *   A tuple without a format:

            .. code-block:: tarantoolsession

                tarantool> tuple1 = box.tuple.new({1, 'Bob'}) -- no format
                ---
                ...

                tarantool> tuple1:format()
                ---
                - []
                ...

                tarantool> box.tuple.format(tuple1)
                ---
                - []
                ...
