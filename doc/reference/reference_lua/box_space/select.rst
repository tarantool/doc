.. _box_space-select:

===============================================================================
space_object:select()
===============================================================================

.. class:: space_object

    .. method:: select([key [,, options]])

        Search for a tuple or a set of tuples in the given space. This method
        doesn't yield (for details see :ref:`Cooperative multitasking <app-cooperative_multitasking>`).

        :param space_object space_object: an :ref:`object reference
                                          <app_server-object_reference>`
        :param scalar/table          key: value to be matched against the index
                                          key, which may be multi-part.
        :param table/nil         options: none, any or all of the same options that
                                          :doc:`/reference/reference_lua/box_index/select`
                                          allows:

                                          * ``options.iterator`` (:ref:`type of iterator <box_index-iterator-types>`)
                                          * ``options.limit`` (maximum number of tuples)
                                          * ``options.offset`` (number of tuples to skip)

        :return: the tuples whose primary-key fields are equal to the fields of
                 the passed key. If the number of passed fields is less than the
                 number of fields in the primary key, then only the passed
                 fields are compared, so ``select{1,2}`` will match a tuple
                 whose primary key is ``{1,2,3}``.
        :rtype:  array of tuples

        A ``select`` request can also be done with a specific index and index
        options, which are the subject of :doc:`/reference/reference_lua/box_index/select`.

        **Possible errors:**

        *   No such space.
        *   Wrong type.
        *   :errcode:`ER_TRANSACTION_CONFLICT` if a transaction conflict in detected in the
            :ref:`MVCC transaction mode <txn_mode_transaction-manager>`.


        **Complexity factors:** Index size, Index type.

        **Example:**

        .. code-block:: tarantoolsession

            tarantool> s = box.schema.space.create('tmp', {temporary=true})
            ---
            ...
            tarantool> s:create_index('primary',{parts = { {field = 1, type = 'unsigned'}, {field = 2, type = 'string'}} })
            ---
            ...
            tarantool> s:insert{1,'A'}
            ---
            - [1, 'A']
            ...
            tarantool> s:insert{1,'B'}
            ---
            - [1, 'B']
            ...
            tarantool> s:insert{1,'C'}
            ---
            - [1, 'C']
            ...
            tarantool> s:insert{2,'D'}
            ---
            - [2, 'D']
            ...
            tarantool> -- must equal both primary-key fields
            tarantool> s:select{1,'B'}
            ---
            - - [1, 'B']
            ...
            tarantool> -- must equal only one primary-key field
            tarantool> s:select{1}
            ---
            - - [1, 'A']
              - [1, 'B']
              - [1, 'C']
            ...
            tarantool> -- must equal 0 fields, so returns all tuples
            tarantool> s:select{}
            ---
            - - [1, 'A']
              - [1, 'B']
              - [1, 'C']
              - [2, 'D']
            ...
            tarantool> -- the first field must be greater than 0, and
            tarantool> -- skip the first tuple, and return up to
            tarantool> -- 2 tuples. This example's options all
            tarantool> -- depend on index characteristics so see
            tarantool> -- more explanation in index_object:select().
            tarantool> s:select({0},{iterator='GT',offset=1,limit=2})
            ---
            - - [1, 'B']
              - [1, 'C']
            ...

        As the last request in the above example shows:
        to make complex ``select`` requests, where you can specify which
        index to search and what condition to use (for example "greater than"
        instead of "equal to") and how many tuples to return, it will be
        necessary to become familiar with :doc:`/reference/reference_lua/box_index/select`.

        Remember that you can get a field from a tuple both by field number and by
        field name which is more convenient. See example: :ref:`using field names
        instead of field numbers <box_space-get_field_names>`.

        For more usage scenarios and typical errors see
        :ref:`Example: using data operations <box_space-operations-detailed-examples>`
        further in this section.
