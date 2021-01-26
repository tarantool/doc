.. _box_index-update:

===============================================================================
index_object:update()
===============================================================================

.. class:: index_object

    .. method:: update(key, {{operator, field_identifier, value}, ...})

        Update a tuple.

        Same as :ref:`box.space...update() <box_space-update>`,
        but key is searched in this index instead of primary key.
        This index should be unique.

        :param index_object index_object: an :ref:`object reference
                                          <app_server-object_reference>`.
        :param scalar/table key: values to be matched against the index key
        :param string  operator: operation type represented in string
        :param field-or-string field_identifier: what field the operation will apply to. The
                                                 field number can be negative, meaning the
                                                 position from the end of tuple.
                                                 (#tuple + negative field number + 1)
        :param lua_value  value: what value will be applied

        :return: * the updated tuple
                 * nil if the key is not found
        :rtype:  tuple or nil

        Since Tarantool 2.3 a tuple can also be updated via :ref:`JSON paths<json_paths-module>`.