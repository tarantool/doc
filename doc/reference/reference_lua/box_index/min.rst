.. _box_index-min:

index_object:min()
==================

..  class:: index_object

    ..  method:: min([key])

        Find the minimum value in the specified index.

        :param index_object index_object: an :ref:`object reference
                                          <app_server-object_reference>`.
        :param scalar/table      key: values to be matched against the index key

        :return: the tuple for the first key in the index. If the optional
                 ``key`` value is supplied, returns the first key that is greater than or equal to ``key``.
                 Starting with :doc:`Tarantool 2.0.4 </release/2.1.2>`,
                 ``index_object:min(key)`` returns nothing
                 if ``key`` doesn't match any value in the index.
        :rtype:  tuple

        **Possible errors:**

        *   Index is not of type 'TREE'.
        *   :errcode:`ER_TRANSACTION_CONFLICT` if a transaction conflict in detected in the
            :ref:`MVCC transaction mode <txn_mode_transaction-manager>`.

        **Complexity factors:** Index size, Index type.

        **Example:**

        ..  code-block:: tarantoolsession

            tarantool> box.space.tester.index.primary:min()
            ---
            - ['Alpha!', 55, 'This is the first tuple!']
            ...
