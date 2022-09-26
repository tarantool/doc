..  _box_index-max:

index_object:max()
==================

..  class:: index_object

    ..  method:: max([key])

        Find the maximum value in the specified index.

        :param index_object index_object: an :ref:`object reference
                                          <app_server-object_reference>`
        :param scalar/table      key: values to be matched against the index key

        :return: the tuple for the last key in the index. If the optional ``key`` value
                 is supplied, returns the last key that is less than or equal to ``key``.
                 Starting with :doc:`Tarantool 2.0.4 </release/2.1.2>`, ``index_object:max(key)``
                 returns nothing if ``key`` doesn't match any value in the index.
        :rtype:  tuple

        **Possible errors:** index is not of type 'TREE'.

        **Possible errors:**

        *   :errcode:`ER_TRANSACTION_CONFLICT` if a transaction conflict is detected in the
            :ref:`MVCC transaction mode <txn_mode_transaction-manager>`.

        **Complexity factors:** index size, index type.

        **Example:**

        ..  code-block:: tarantoolsession

            tarantool> box.space.tester.index.primary:max()
            ---
            - ['Gamma!', 55, 'This is the third tuple!']
            ...
