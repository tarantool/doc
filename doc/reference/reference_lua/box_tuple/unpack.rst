
.. _box_tuple-unpack:

================================================================================
tuple_object:unpack()
================================================================================

.. class:: tuple_object

    .. method:: unpack([start-field-number [, end-field-number]])

        If ``t`` is a tuple instance, ``t:unpack()`` will return all fields,
        ``t:unpack(1)`` will return all fields starting with field number 1,
        ``t:unpack(1,5)`` will return all fields between field number 1 and field number 5.

        :return: field(s) from the tuple.
        :rtype:  lua-value(s)

        In the following example, a tuple named ``t`` is created and then all
        its fields are selected, then the result is returned.

        .. code-block:: tarantoolsession

            tarantool> t = box.tuple.new{'Fld#1', 'Fld#2', 'Fld#3', 'Fld#4', 'Fld#5'}
            ---
            ...
            tarantool> t:unpack()
            ---
            - Fld#1
            - Fld#2
            - Fld#3
            - Fld#4
            - Fld#5
            ...
