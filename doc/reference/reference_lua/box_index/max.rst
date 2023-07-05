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


        **Possible errors:**

        *   Index is not of type 'TREE'.
        *   :errcode:`ER_TRANSACTION_CONFLICT` if a transaction conflict is detected in the
            :ref:`MVCC transaction mode <txn_mode_transaction-manager>`.

        **Complexity factors:** index size, index type.

        **Example:**

        Below are few examples of using ``max``.
        To try out these examples, you need to bootstrap a Tarantool database
        as described in :ref:`Using data operations <box_space-operations-detailed-examples>`.

        ..  literalinclude:: /code_snippets/test/indexes/index_aggr_functions_test.lua
            :language: lua
            :lines: 42-53,86-100
            :dedent:
