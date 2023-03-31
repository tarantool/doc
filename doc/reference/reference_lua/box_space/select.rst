.. _box_space-select:

===============================================================================
space_object:select()
===============================================================================

.. class:: space_object

    .. method:: select([key [,, options]])

        Search for a tuple or a set of tuples in the given space by the primary key.
        To search by the specific index, use the :doc:`/reference/reference_lua/box_index/select` method.

        .. note::

            Note that this method doesn't yield. For details, see :ref:`Cooperative multitasking <app-cooperative_multitasking>`.

        :param space_object space_object: an :ref:`object reference
                                          <app_server-object_reference>`.
        :param scalar/table          key: a value to be matched against the index
                                          key, which may be multi-part.
        :param table/nil         options: none, any, or all of the same options that
                                          :doc:`/reference/reference_lua/box_index/select`
                                          allows:

                                          * ``options.iterator`` -- the :ref:`iterator type .<box_index-iterator-types>`. The default iterator type is 'EQ'.
                                          * ``options.limit`` -- the maximum number of tuples.
                                          * ``options.offset`` -- the number of tuples to skip.
                                          * ``options.after`` -- a tuple or the position of a tuple (:ref:`tuple_pos <box_index-tuple_pos>`) after which ``select`` starts the search. You can pass an empty string or :ref:`box.NULL <box-null>` to this option.
                                          * ``options.fetch_pos`` -- if **true**, the ``select`` method returns the position of the last selected tuple as the second value.

        :return:

            This function might return one or two values:

            *   The tuples whose primary-key fields are equal to the fields of the passed key.
                If the number of passed fields is less than the
                number of fields in the primary key, then only the passed
                fields are compared, so ``select{1,2}`` matches a tuple
                whose primary key is ``{1,2,3}``.
            *   (Optionally) If ``options.fetch_pos`` is set to **true**, returns a base64-encoded string representing the position of the last selected tuple as the second value.
                If now tuples are fetched, returns ``nil``.

        :rtype:

            *   array of tuples
            *   (Optionally) string


        **Possible errors:**

        *   No such space.
        *   Wrong type.
        *   :errcode:`ER_TRANSACTION_CONFLICT` if a transaction conflict is detected in the
            :ref:`MVCC transaction mode <txn_mode_transaction-manager>`.
        *   Iterator position is invalid.


        **Complexity factors:** Index size, Index type.

        **Examples:**

        Below are few examples of using ``select`` with different parameters.
        To try out these examples, you need to bootstrap a Tarantool instance
        as described in :ref:`Using data operations <box_space-operations-detailed-examples>`.

        .. code-block:: tarantoolsession

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

            -- Select a tuple by the specified primary key --
            tarantool> bands:select(4)
            ---
            - - [4, 'The Beatles', 1960]
            ...

            -- Select maximum 3 tuples with the primary key value greater than 3 --
            tarantool> bands:select({3}, {iterator='GT', limit = 3})
            ---
            - - [4, 'The Beatles', 1960]
              - [5, 'Pink Floyd', 1965]
              - [6, 'The Rolling Stones', 1962]
            ...

            -- Select maximum 3 tuples after the specified tuple --
            tarantool> bands:select({}, {after = {4, 'The Beatles', 1960}, limit = 3})
            ---
            - - [5, 'Pink Floyd', 1965]
              - [6, 'The Rolling Stones', 1962]
              - [7, 'The Doors', 1965]
            ...

            -- Select first 3 tuples and fetch a last tuple's position --
            tarantool> result, position = bands:select({}, {limit = 3, fetch_pos = true})
            ---
            ...
            -- Then, pass this position as the 'after' parameter --
            tarantool> bands:select({}, {limit = 3, after = position})
            ---
            - - [4, 'The Beatles', 1960]
              - [5, 'Pink Floyd', 1965]
              - [6, 'The Rolling Stones', 1962]
            ...

        .. note::

            You can get a field from a tuple both by the field number and field name.
            See example: :ref:`using field names instead of field numbers <box_space-get_field_names>`.
