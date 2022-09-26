.. _box_space-count:

===============================================================================
space_object:count()
===============================================================================

.. class:: space_object

    .. method:: count([key], [iterator])

        Return the number of tuples.
        If compared with :doc:`len() </reference/reference_lua/box_space/len>`,
        this method works slower because ``count()`` scans the entire space to
        count the tuples.

        :param space_object space_object: an :ref:`object reference
                                          <app_server-object_reference>`
        :param scalar/table key: primary-key field values, must be passed as a
                                 Lua table if key is multi-part
        :param iterator: comparison method

        :return: Number of tuples.

        **Possible errors:**

        *   :errcode:`ER_TRANSACTION_CONFLICT` if a transaction conflict is detected in the
            :ref:`MVCC transaction mode <txn_mode_transaction-manager>`.

        **Example:**

        .. code-block:: tarantoolsession

            tarantool> box.space.tester:count(2, {iterator='GE'})
            ---
            - 1
            ...
