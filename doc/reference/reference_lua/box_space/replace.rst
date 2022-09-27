.. _box_space-replace:

===============================================================================
space_object:replace() / put()
===============================================================================

.. class:: space_object

    .. method:: replace(tuple)
                put(tuple)

        Insert a tuple into a space. If a tuple with the same primary key already
        exists, ``box.space...:replace()`` replaces the existing tuple with a new
        one. The syntax variants ``box.space...:replace()`` and
        ``box.space...:put()`` have the same effect; the latter is sometimes used
        to show that the effect is the converse of ``box.space...:get()``.

        :param space_object space_object: an :ref:`object reference
                                          <app_server-object_reference>`
        :param table/tuple tuple: tuple to be inserted

        :return: the inserted tuple.
        :rtype:  tuple

        **Possible errors:**

        *   :errcode:`ER_TUPLE_FOUND` if a different tuple with the same unique-key
            value already exists. (This will only happen if there is a unique secondary index.)
        *   :errcode:`ER_TRANSACTION_CONFLICT` if a transaction conflict is detected in the
            :ref:`MVCC transaction mode <txn_mode_transaction-manager>`.

        **Complexity factors:** Index size, Index type,
        Number of indexes accessed, WAL settings.

        **Example:**

        .. code-block:: lua

            box.space.tester:replace{5000, 'tuple number five thousand'}

        For more usage scenarios and typical errors see
        :ref:`Example: using data operations <box_space-operations-detailed-examples>`
        further in this section.
