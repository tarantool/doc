.. _box_space-pairs:

===============================================================================
space_object:pairs()
===============================================================================

.. class:: space_object

    .. method:: pairs([key [, iterator]])

        Search for a tuple or a set of tuples in the given space, and allow
        iterating over one tuple at a time.
        To search by the specific index, use the :ref:`box_index-pairs` method.

        :param space_object space_object: an :ref:`object reference
                                          <app_server-object_reference>`
        :param scalar/table key: value to be matched against the index key,
                                 which may be multi-part
        :param         iterator: the :ref:`iterator type <box_index-iterator-types>`. The default iterator type is 'EQ'
        :param after: a tuple, after which ``pairs`` continues searching

        :return: `iterator <https://www.lua.org/pil/7.1.html>`_ which can be
                 used in a for/end loop or with `totable()
                 <https://luafun.github.io/reducing.html#fun.totable>`_

        **Possible errors:**

        *    No such space.
        *    Wrong type.
        *   :errcode:`ER_TRANSACTION_CONFLICT` if a transaction conflict is detected in the
            :ref:`MVCC transaction mode <txn_mode_transaction-manager>`.


        **Complexity factors:** Index size, Index type.

        For information about iterators' internal structures see the
        `"Lua Functional library" <https://luafun.github.io/index.html>`_
        documentation.


        **Examples:**

        Below are few examples of using ``pairs`` with different parameters.
        To try out these examples, you need to bootstrap a Tarantool instance
        as described in :ref:`Using data operations <box_space-operations-detailed-examples>`.

        ..  code-block:: tarantoolsession

            -- Insert test data --
            tarantool> bands:insert{1, 'Roxette', 1986}
                       bands:insert{2, 'Scorpions', 1965}
                       bands:insert{3, 'Ace of Base', 1987}
                       bands:insert{4, 'The Beatles', 1960}
                       bands:insert{5, 'Pink Floyd', 1965}
                       bands:insert{6, 'The Rolling Stones', 1962}
                       bands:insert{7, 'The Doors', 1965}
                       bands:insert{8, 'Nirvana', 1987}
                       bands:insert{9, 'Led Zeppelin', 1968}
                       bands:insert{10, 'Queen', 1970}
            ---
            ...

            -- Select all tuples by the primary index --
            tarantool> for _, tuple in bands:pairs() do
                           print(tuple)
                       end
            [1, 'Roxette', 1986]
            [2, 'Scorpions', 1965]
            [3, 'Ace of Base', 1987]
            [4, 'The Beatles', 1960]
            [5, 'Pink Floyd', 1965]
            [6, 'The Rolling Stones', 1962]
            [7, 'The Doors', 1965]
            [8, 'Nirvana', 1987]
            [9, 'Led Zeppelin', 1968]
            [10, 'Queen', 1970]
            ---
            ...

            -- Select all tuples whose key values are between 3 and 6 --
            tarantool> for _, tuple in bands.index.year:pairs(3, {iterator = "GE"}) do
                         if (tuple[1] > 6) then break end
                         print(tuple)
                       end
            [3, 'Ace of Base', 1987]
            [4, 'The Beatles', 1960]
            [5, 'Pink Floyd', 1965]
            [6, 'The Rolling Stones', 1962]
            ---
            ...

            -- Select all tuples after the specified tuple --
            tarantool> for _, tuple in bands:pairs({}, {after={7, 'The Doors', 1965}}) do
                           print(tuple)
                       end
            [8, 'Nirvana', 1987]
            [9, 'Led Zeppelin', 1968]
            [10, 'Queen', 1970]
            ---
            ...
