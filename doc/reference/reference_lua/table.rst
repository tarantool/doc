.. _table-module:

-------------------------------------------------------------------------------
                            Module `table`
-------------------------------------------------------------------------------

.. module:: table

The :code:`table` module has everything in the
`standard Lua table library <https://www.lua.org/pil/19.html>`_,
and some Tarantool extensions.

You can see this by saying "table": you will see this list of functions:
``clear`` (LuaJIT extension = erase all elements),
`concat <https://www.lua.org/manual/5.1/manual.html#pdf-table.concat>`_ (concatenate),
``copy`` (make a copy of an array),
``deepcopy`` (see description below),
``foreach``,
``foreachi``,
`getn <https://www.lua.org/pil/19.1.html>`_ (get the number of elements in an array),
`insert <https://www.lua.org/manual/5.1/manual.html#pdf-table.insert>`_ (insert an element into an array),
`maxn <https://www.lua.org/manual/5.1/manual.html#pdf-table.maxn>`_ (get largest index)
`move <https://www.lua.org/manual/5.3/manual.html#pdf-table.move>`_ (move elements between tables),
``new`` (LuaJIT extension = return a new table with pre-allocated elements),
`remove <https://www.lua.org/manual/5.1/manual.html#pdf-table.remove>`_ (remove an element from an array),
`sort <https://www.lua.org/manual/5.1/manual.html#pdf-table.sort>`_ (sort the elements of an array).

In this section we only discuss the additional function
that the Tarantool developers have added: ``deepcopy``.

.. _table-deepcopy:

.. function:: deepcopy(input-table)

    Return a "deep" copy of the table -- a copy which follows
    nested structures to any depth and does not depend on pointers,
    it copies the contents.

    :param input-table: (table) the table to copy

    :Return: the copy of the table
    :Rtype: table

    **Example:**

    .. code-block:: tarantoolsession

        tarantool> input_table = {1,{'a','b'}}
        ---
        ...

        tarantool> output_table = table.deepcopy(input_table)
        ---
        ...

        tarantool> output_table
        ---
        - - 1
          - - a
            - b
        ...

.. _table-sort:

.. function:: sort(input-table [, comparison-function])

    Put the input-table contents in sorted order.

    The `basic Lua table.sort <https://www.lua.org/manual/5.1/manual.html#pdf-table.sort>`_
    has a default comparison-function: :code:`function (a, b) return a < b end`.

    That is efficient and standard. However, sometimes Tarantool users
    will want an equivalent to ``table.sort`` which has any of these features:

    (1) If the table contains nils, except nils at the end, the results must still be correct.
    That is not the case with the default tarantool_sort, and it cannot
    be fixed by making a comparison that checks whether a and b are nil.
    (Before trying certain Internet suggestions, test with
    {1, nil, 2, -1, 44, 1e308, nil, 2, nil, nil, 0}.

    (2) If strings are to be sorted in a language-aware way, there must be a
    parameter for collation.

    (3) If the table has a mix of types, then they must be sorted as
    booleans, then numbers, then strings, then byte arrays.

    Since all those features are available in Tarantool spaces,
    the solution for Tarantool is simple: make a temporary Tarantool
    space, put the table contents into it, retrieve the tuples from it
    in order, and overwrite the table.

    Here then is ``tarantool_sort()`` which does the same thing as
    ``table.sort`` but has those extra features. It is not fast and
    it requires a database privilege, so it should only be used if the
    extra features are necessary.

    .. code-block:: none

        function tarantool_sort(input_table, collation)
            local c = collation or 'binary'
            local tmp_name = 'Temporary_for_tarantool_sort'
            pcall(function() box.space[tmp_name]:drop() end)
            box.schema.space.create(tmp_name, {temporary = true})
            box.space[tmp_name]:create_index('I')
            box.space[tmp_name]:create_index('I2',
                                             {unique = false,
                                              type='tree',
                                              parts={{2, 'scalar',
                                                      collation = c,
                                                      is_nullable = true}}})
            for i = 1, table.maxn(input_table) do
                box.space[tmp_name]:insert{i, input_table[i]}
            end
            local t = box.space[tmp_name].index.I2:select()
            for i = 1, table.maxn(input_table) do
                input_table[i] = t[i][2]
            end
            box.space[tmp_name]:drop()
          end

      For example, suppose table t = {1, 'A', -88.3, nil, true, 'b', 'B', nil, 'À'}.
      After tarantool_sort(t, 'unicode_ci') t contains {nil, nil, true, -88.3, 1, 'A', 'À', 'b', 'B'}.
