.. _box_space-select:

===============================================================================
space_object:select()
===============================================================================

.. class:: space_object

    .. method:: select([key [,, options]])

        Search for a tuple or a set of tuples in the given space by the primary key.
        This method doesn't yield (for details, see :ref:`Cooperative multitasking <app-cooperative_multitasking>`).

        :param space_object space_object: an :ref:`object reference
                                          <app_server-object_reference>`
        :param scalar/table          key: value to be matched against the index
                                          key, which may be multi-part.
        :param table/nil         options: none, any or all of the same options that
                                          :doc:`/reference/reference_lua/box_index/select`
                                          allows:

                                          * ``options.iterator`` the :ref:`type of iterator <box_index-iterator-types>`
                                          * ``options.limit`` the maximum number of tuples
                                          * ``options.offset`` the number of tuples to skip
                                          * ``options.after`` a tuple or a tuple's position, after which ``select`` continues searching
                                          * ``options.fetch_pos`` if **true**, the ``select`` method returns the position of the last selected tuple as the second returned value

        :return: *   the tuples whose primary-key fields are equal to the fields of
                 the passed key. If the number of passed fields is less than the
                 number of fields in the primary key, then only the passed
                 fields are compared, so ``select{1,2}`` will match a tuple
                 whose primary key is ``{1,2,3}``.
                 *  if ``options.fetch_pos`` is set to **true**, returns a base64-encoded string representing
                    the position of the last selected tuple as the second value
        :rtype:  array of tuples

        A ``select`` request can also be done with a specific index and index
        options, which are the subject of :doc:`/reference/reference_lua/box_index/select`.

        **Possible errors:**

        *   No such space.
        *   Wrong type.
        *   :errcode:`ER_TRANSACTION_CONFLICT` if a transaction conflict is detected in the
            :ref:`MVCC transaction mode <txn_mode_transaction-manager>`.


        **Complexity factors:** Index size, Index type.

        **Examples:**

        Below are few examples of using ``select`` with different parameters.
        To try out these examples, you need to bootstrap a Tarantool instance
        as described in :ref:`Using data operations <box_space-operations-detailed-examples>`.

        .. code-block:: tarantoolsession

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

            -- Select a specified tuple --
            tarantool> bands:select(4)
            ---
            - - [4, 'The Beatles', 1960]
            ...

            -- Select maximum 3 tuples with the primary key value greater than 3
            tarantool> bands:select({3}, {iterator='GT', limit = 3})
            ---
            - - [4, 'The Beatles', 1960]
              - [5, 'Pink Floyd', 1965]
              - [6, 'The Rolling Stones', 1962]
            ...

            -- Select maximum 3 tuples after the specified tuple
            tarantool> bands:select({}, {after = {4, 'The Beatles', 1960}, limit = 3})
            ---
            - - [5, 'Pink Floyd', 1965]
              - [6, 'The Rolling Stones', 1962]
              - [7, 'The Doors', 1965]
            ...

            -- Step 1: select 3 first tuples and fetch a last tuple's position.
            tarantool> result, position = bands:select({}, {limit = 3, fetch_pos = true})
            ---
            ...
            -- Step 2: pass the last tuple's position as the 'after' parameter.
            tarantool> bands:select({}, {limit = 3, after = position})
            ---
            - - [4, 'The Beatles', 1960]
              - [5, 'Pink Floyd', 1965]
              - [6, 'The Rolling Stones', 1962]
            ...


        To learn how to search by the specified index, see :ref:`index.select <box_index-select>`.

        .. note::

            You can get a field from a tuple both by the field number and field name.
            See example: :ref:`using field names instead of field numbers <box_space-get_field_names>`.
