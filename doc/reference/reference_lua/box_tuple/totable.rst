
.. _box_tuple-totable:

================================================================================
tuple_object:totable()
================================================================================

.. class:: tuple_object

    .. method:: totable([start-field-number [, end-field-number]])

        If ``t`` is a tuple instance, ``t:totable()`` will return all fields,
        ``t:totable(1)`` will return all fields starting with field number 1,
        ``t:totable(1,5)`` will return all fields between field number 1 and field number 5.

        It is preferable to use ``t:totable()`` rather than ``t:unpack()``.

        :return: field(s) from the tuple
        :rtype:  lua-table

        In the following example, a tuple named ``t`` is created, then all
        its fields are selected, then the result is returned.

        .. code-block:: tarantoolsession

            tarantool> t = box.tuple.new{'Fld#1', 'Fld#2', 'Fld#3', 'Fld#4', 'Fld#5'}
            ---
            ...
            tarantool> t:totable()
            ---
            - ['Fld#1', 'Fld#2', 'Fld#3', 'Fld#4', 'Fld#5']
            ...
