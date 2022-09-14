
.. _box_tuple-field_path:

================================================================================
tuple_object[field-path]
================================================================================

.. class:: tuple_object

    .. operator:: tuple_object[field-path]

        If ``t`` is a tuple instance, ``t['path']`` will return the field
        or subset of fields that are in ``path``. ``path`` must be a well
        formed JSON specification. ``path`` may contain field names if the tuple has
        been retrieved from a space that has an associated :ref:`format <box_space-format>`.

        To prevent ambiguity, Tarantool first tries to interpret the
        request as :doc:`/reference/reference_lua/box_tuple/field_number`
        or :doc:`/reference/reference_lua/box_tuple/field_name`.
        If and only if that fails, Tarantool tries to interpret the request
        as ``tuple_object[field-path]``.

        The path must be a well formed JSON specification, but it may be
        preceded by '.'. The '.' is a signal that the path acts as a suffix
        for the tuple.

        The advantage of specifying a path is that Tarantool will use it to
        search through a tuple body and get only the tuple part, or parts,
        that are actually necessary.

        In the following example, a tuple named ``t`` is returned from ``replace``
        and then only the relevant part (in this case, matching a name)
        of a relevant field is returned. Namely: the second field, its
        third item, the value following 'key='.

        .. code-block:: tarantoolsession

            tarantool> format = {}
            ---
            ...
            tarantool> format[1] = {name = 'field1', type = 'unsigned'}
            ---
            ...
            tarantool> format[2] = {name = 'field2', type = 'array'}
            ---
            ...
            tarantool> s = box.schema.space.create('test', {format = format})
            ---
            ...
            tarantool> pk = s:create_index('pk')
            ---
            ...
            tarantool> field2_value = {1, "ABC", {key="Hello", value="world"}}
            ---
            ...
            tarantool> t = s:replace{1, field2_value}
            ---
            ...
            tarantool> t["[2][3]['key']"]
            ---
            - Hello
            ...