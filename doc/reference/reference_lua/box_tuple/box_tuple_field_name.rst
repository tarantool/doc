
.. _box_tuple-field_name:

================================================================================
tuple_object[field-name]
================================================================================

.. module:: box.tuple

.. class:: tuple_object

    .. operator:: tuple_object[field-name]

        If ``t`` is a tuple instance, ``t['field-name']`` will return the field
        named 'field-name' in the tuple. Fields have names if the tuple has
        been retrieved from a space that has an associated :ref:`format <box_space-format>`.

        :return: field value.
        :rtype:  lua-value

        In the following example, a tuple named ``t`` is returned from ``replace``
        and then the second field in ``t`` named 'field2' is returned.

        .. code-block:: tarantoolsession

            tarantool> format = {}
            ---
            ...
            tarantool> format[1] = {name = 'field1', type = 'unsigned'}
            ---
            ...
            tarantool> format[2] = {name = 'field2', type = 'string'}
            ---
            ...
            tarantool> s = box.schema.space.create('test', {format = format})
            ---
            ...
            tarantool> pk = s:create_index('pk')
            ---
            ...
            tarantool> t = s:replace{1, 'Я'}
            ---
            ...
            tarantool> t['field2']
            ---
            - Я
            ...
