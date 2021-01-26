
.. _box_tuple-upsert:

================================================================================
tuple_object:upsert()
================================================================================

.. class:: tuple_object

    .. method:: upsert({{operator, field_no, value}, ...})

        The same as ``tuple_object:update()``, but ignores errors. In case
        of an error the tuple is left intact, but an error message is
        printed. Only client errors are ignored, such as a bad field type,
        or wrong field index/name. System errors, such as OOM, are not
        ignored and raised just like with a normal ``update()``. Note that
        only bad operations are ignored. All correct operations are
        applied.

        :param string  operator: operation type represented as a string (e.g.
                                 '``=``' for 'assign new value')
        :param number  field_no: the field to which the operation will be applied. The
                                 field number can be negative, meaning the
                                 position from the end of tuple.
                                 (#tuple + negative field number + 1)
        :param lua_value  value: the value which will be applied

        :return: new tuple
        :rtype:  tuple

        See the following example where one operation is applied, and one is not.

        .. code-block:: tarantoolsession

            tarantool> t = box.tuple.new({1, 2, 3})
            tarantool> t2 = t:upsert({{'=', 5, 100}})
            UPSERT operation failed:
            ER_NO_SUCH_FIELD_NO: Field 5 was not found in the tuple
            ---
            ...

            tarantool> t
            ---
            - [1, 2, 3]
            ...

            tarantool> t2
            ---
            - [1, 2, 3]
            ...

            tarantool> t2 = t:upsert({{'=', 5, 100}, {'+', 1, 3}})
            UPSERT operation failed:
            ER_NO_SUCH_FIELD_NO: Field 5 was not found in the tuple
            ---
            ...

            tarantool> t
            ---
            - [1, 2, 3]
            ...

            tarantool> t2
            ---
            - [4, 2, 3]
            ...
