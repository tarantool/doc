.. _table-module:

-------------------------------------------------------------------------------
                            Module `table`
-------------------------------------------------------------------------------

.. module:: table

The :code:`table` module has everything in the
`standard Lua table library <https://www.lua.org/pil/19.html>`_,
and some Tarantool extensions.

You can see this by saying "table":

    .. code-block:: tarantoolsession

        tarantool> table
        ---
        - maxn: 'function: builtin#90'
          copy: 'function: 0x41e9d300'
          new: 'function: builtin#94'
          clear: 'function: builtin#95'
          move: 'function: 0x41e918e0'
          foreach: 'function: 0x41e91588'
          sort: 'function: builtin#93'
          remove: 'function: 0x41e917c8'
          foreachi: 'function: 0x41e914b8'
          deepcopy: 'function: 0x41e9d2e0'
          getn: 'function: 0x41e91620'
          concat: 'function: builtin#92'
          insert: 'function: builtin#91'
        ...

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
