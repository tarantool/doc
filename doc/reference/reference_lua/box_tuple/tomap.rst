
.. _box_tuple-tomap:

================================================================================
tuple_object:tomap()
================================================================================

.. module:: box.tuple

.. class:: tuple_object

    .. method:: tomap([options])

        A `Lua table <https://www.lua.org/pil/2.5.html>`_ can have indexed values,
        also called key:value pairs.
        For example, here:

        .. code-block:: lua

            a = {}; a['field1'] = 10; a['field2'] = 20

        ``a`` is a table with "field1: 10" and "field2: 20".

        The :doc:`/reference/reference_lua/box_tuple/totable`
        function only returns a table containing the values.
        But the ``tuple_object:tomap()`` function returns a table containing
        not only the values, but also the key:value pairs.

        This only works if the tuple comes from a space that has
        been formatted with a :ref:`format clause <box_space-format>`.

        :param table options: the only possible option is ``names_only``.

                              If ``names_only`` is false or omitted (default),
                              then all the fields will appear twice,
                              first with numeric headings and
                              second with name headings.

                              If ``names_only`` is true, then all the
                              fields will appear only once, with
                              name headings.

        :return: field-number:value pair(s) and key:value pair(s) from the tuple
        :rtype:  lua-table

        In the following example, a tuple named ``t1`` is returned
        from a space that has been formatted, then tables named ``t1map1``
        and ``t1map2`` are produced from ``t1``.

        .. code-block:: lua

            format = {{'field1', 'unsigned'}, {'field2', 'unsigned'}}
            s = box.schema.space.create('test', {format = format})
            s:create_index('pk',{parts={1,'unsigned',2,'unsigned'}})
            t1 = s:insert{10, 20}
            t1map = t1:tomap()
            t1map_names_only = t1:tomap({names_only=true})

        ``t1map`` will contain "1: 10", "2: 20", "field1: 10", "field2: 20".

        ``t1map_names_only`` will contain "field1: 10", "field2: 20".
