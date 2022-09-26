.. _box_space-pairs:

===============================================================================
space_object:pairs()
===============================================================================

.. class:: space_object

    .. method:: pairs([key [, iterator]])

        Search for a tuple or a set of tuples in the given space, and allow
        iterating over one tuple at a time.

        :param space_object space_object: an :ref:`object reference
                                          <app_server-object_reference>`
        :param scalar/table key: value to be matched against the index key,
                                 which may be multi-part
        :param         iterator: see :doc:`/reference/reference_lua/box_index/pairs`

        :return: `iterator <https://www.lua.org/pil/7.1.html>`_ which can be
                 used in a for/end loop or with `totable()
                 <https://luafun.github.io/reducing.html#fun.totable>`_

        **Possible errors:**

        *    No such space.
        *    Wrong type.
        *   :errcode:`ER_TRANSACTION_CONFLICT` if a transaction conflict in detected in the
            :ref:`MVCC transaction mode <txn_mode_transaction-manager>`.


        **Complexity factors:** Index size, Index type.

        For examples of complex ``pairs`` requests, where one can specify which
        index to search and what condition to use (for example "greater than"
        instead of "equal to"), see the later section
        :doc:`/reference/reference_lua/box_index/pairs`.

        For information about iterators' internal structures see the
        `"Lua Functional library" <https://luafun.github.io/index.html>`_
        documentation.

        **Example:**

        .. code-block:: tarantoolsession

            tarantool> s = box.schema.space.create('space33')
            ---
            ...
            tarantool> -- index 'X' has default parts {1, 'unsigned'}
            tarantool> s:create_index('X', {})
            ---
            ...
            tarantool> s:insert{0, 'Hello my '}, s:insert{1, 'Lua world'}
            ---
            - [0, 'Hello my ']
            - [1, 'Lua world']
            ...
            tarantool> tmp = ''
            ---
            ...
            tarantool> for k, v in s:pairs() do
                     >   tmp = tmp .. v[2]
                     > end
            ---
            ...
            tarantool> tmp
            ---
            - Hello my Lua world
            ...
