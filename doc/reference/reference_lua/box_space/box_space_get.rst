.. _box_space-get:

===============================================================================
space_object:get()
===============================================================================

.. module:: box.space

.. class:: space_object

    .. method:: get(key)

        Search for a tuple in the given space.

        :param space_object space_object: an :ref:`object reference
                                          <app_server-object_reference>`
        :param scalar/table          key: value to be matched against the index
                                          key, which may be multi-part.

        :return: the tuple whose index key matches ``key``, or ``nil``.
        :rtype:  tuple

        **Possible errors:** ``space_object`` does not exist.

        **Complexity factors:** Index size, Index type, Number of indexes
        accessed, WAL settings.

        The ``box.space...select`` function returns a set of tuples as a Lua
        table; the ``box.space...get`` function returns at most a single tuple.
        And it is possible to get the first tuple in a space by appending
        ``[1]``. Therefore ``box.space.tester:get{1}`` has the same effect as
        ``box.space.tester:select{1}[1]``, if exactly one tuple is found.

        **Example:**

        .. code-block:: lua

            box.space.tester:get{1}

        .. _box_space-get_field_names:

        **Using field names instead of field numbers:** `get()` can use field names
        described by the optional :ref:`space_object:format() <box_space-format>` clause.
        This is similar to a standard Lua feature, where a component can be referenced
        by its name instead of its number.
        For example, we can format the `tester` space
        with a field named `x` and use the name `x` in the index definition:

        .. code-block:: lua

            box.space.tester:format({{name='x',type='scalar'}})
            box.space.tester:create_index('I',{parts={'x'}})

        Then, if ``get`` or ``select`` retrieve a single tuple,
        we can reference the field 'x' in the tuple by its name:

        .. code-block:: lua

            box.space.tester:get{1}['x']
            box.space.tester:select{1}[1]['x']
