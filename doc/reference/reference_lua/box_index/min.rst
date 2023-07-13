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
        *   :errcode:`ER_TRANSACTION_CONFLICT` if a transaction conflict is detected in the
            :ref:`MVCC transaction mode <txn_mode_transaction-manager>`.

        **Complexity factors:** Index size, Index type.

        **Example:**

        Below are few examples of using ``min``.
        To try out these examples, you need to bootstrap a Tarantool database
        as described in :ref:`Using data operations <box_space-operations-detailed-examples>`.

        ..  literalinclude:: /code_snippets/test/indexes/index_aggr_functions_test.lua
            :language: lua
            :lines: 42-53,70-84
            :dedent:
