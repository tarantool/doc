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
``foreach1``,
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
