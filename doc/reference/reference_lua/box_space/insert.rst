.. _box_space-insert:

===============================================================================
space_object:insert()
===============================================================================

.. class:: space_object

    .. method:: insert(tuple)

        Insert a tuple into a space.

        :param space_object space_object: an :ref:`object reference
                                          <app_server-object_reference>`
        :param tuple/table         tuple: tuple to be inserted.

        :return: the inserted tuple
        :rtype:  tuple

        **Possible errors:**

        *   :errcode:`ER_TUPLE_FOUND` if a tuple with the same unique-key value already
            exists.
        *   :errcode:`ER_TRANSACTION_CONFLICT` if a transaction conflict in detected in the
            :ref:`MVCC transaction mode <txn_mode_transaction-manager>`.

        **Example:**

        .. code-block:: tarantoolsession

            tarantool> box.space.tester:insert{5000,'tuple number five thousand'}
            ---
            - [5000, 'tuple number five thousand']
            ...

        For more usage scenarios and typical errors see
        :ref:`Example: using data operations <box_space-operations-detailed-examples>`
        further in this section.
