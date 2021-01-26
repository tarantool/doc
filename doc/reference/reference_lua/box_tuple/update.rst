
.. _box_tuple-update:

================================================================================
tuple_object:update()
================================================================================

.. class:: tuple_object

    .. method:: update({{operator, field_no, value}, ...})

        Update a tuple.

        This function updates a tuple which is not in a space. Compare the function
        :extsamp:`box.space.{*{space-name}*}:update({*{key}*}, {{{*{format}*}, {*{field_no}*}, {*{value}*}}, ...})`
        which updates a tuple in a space.

        For details: see the description for ``operator``, ``field_no``, and
        ``value`` in the section :ref:`box.space.space-name:update{key, format,
        {field_number, value}...) <box_space-update>`.

        If the original tuple comes from a space that has been formatted with a
        :ref:`format clause <box_space-format>`, the formatting will be
        preserved for the result tuple.

        :param string  operator: operation type represented in string (e.g.
                                 '``=``' for 'assign new value')
        :param number  field_no: what field the operation will apply to. The
                                 field number can be negative, meaning the
                                 position from the end of tuple.
                                 (#tuple + negative field number + 1)
        :param lua_value  value: what value will be applied

        :return: new tuple
        :rtype:  tuple

        In the following example, a tuple named ``t`` is created and then its
        second field is updated to equal 'B'.

        .. code-block:: tarantoolsession

            tarantool> t = box.tuple.new{'Fld#1', 'Fld#2', 'Fld#3', 'Fld#4', 'Fld#5'}
            ---
            ...
            tarantool> t:update({{'=', 2, 'B'}})
            ---
            - ['Fld#1', 'B', 'Fld#3', 'Fld#4', 'Fld#5']
            ...

        Since Tarantool 2.3 a tuple can also be updated via :ref:`JSON paths<json_paths-module>`.
