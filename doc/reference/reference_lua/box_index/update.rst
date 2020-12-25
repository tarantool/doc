.. _box_index-update:

===============================================================================
index_object:update()
===============================================================================

.. module:: box.index

.. class:: index_object

    .. method:: update(key, {{operator, field_no, value}, ...})

        Update a tuple.

        Same as :ref:`box.space...update() <box_space-update>`,
        but key is searched in this index instead of primary key.
        This index ought to be unique.

        :param index_object index_object: an :ref:`object reference
                                          <app_server-object_reference>`.
        :param scalar/table key: values to be matched against the index key
        :param string  operator: operation type represented in string
        :param number  field_no: what field the operation will apply to. The
                                 field number can be negative, meaning the
                                 position from the end of tuple.
                                 (#tuple + negative field number + 1)
        :param lua_value  value: what value will be applied

        :return: * the updated tuple
                 * nil if the key is not found
        :rtype:  tuple or nil
