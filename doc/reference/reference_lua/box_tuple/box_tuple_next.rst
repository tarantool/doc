
.. _box_tuple-next:

================================================================================
tuple_object:next()
================================================================================

.. module:: box.tuple

.. class:: tuple_object

    .. method:: next(tuple[, pos])

        An analogue of the Lua ``next()`` function, but for a tuple object.
        When called without arguments, ``tuple:next()`` returns the first field
        from a tuple. Otherwise, it returns the field next to the indicated position.

        However ``tuple:next()`` is not really efficient, and it is better
        to use :ref:`tuple:pairs()/ipairs() <box_tuple-pairs>`.

        :return: field number and field value
        :rtype:  number and field type

        .. code-block:: tarantoolsession

            tarantool> tuple = box.tuple.new({5, 4, 3, 2, 0})
            ---
            ...

            tarantool> tuple:next()
            ---
            - 1
            - 5
            ...

            tarantool> tuple:next(1)
            ---
            - 2
            - 4
            ...

            tarantool> ctx, field = tuple:next()
            ---
            ...

            tarantool> while field do
                     > print(field)
                     > ctx, field = tuple:next(ctx)
                     > end
            5
            4
            3
            2
            0
            ---
            ...