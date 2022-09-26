.. _box_space-len:

===============================================================================
space_object:len()
===============================================================================

.. class:: space_object

    .. method:: len()

        Return the number of tuples in the space.
        If compared with :doc:`count() </reference/reference_lua/box_space/count>`,
        this method works faster because ``len()`` does not scan the entire space
        to count the tuples.

        :param space_object space_object: an :ref:`object reference
                                          <app_server-object_reference>`

        :return: Number of tuples in the space.

        **Possible errors:**

        *   :errcode:`ER_TRANSACTION_CONFLICT` if a transaction conflict is detected in the
            :ref:`MVCC transaction mode <txn_mode_transaction-manager>`.

        **Example:**

        .. code-block:: tarantoolsession

            tarantool> box.space.tester:len()
            ---
            - 2
            ...

        **Note re storage engine:** vinyl supports ``len()`` but the result may be approximate.
        If an exact result is necessary then use :doc:`count() </reference/reference_lua/box_space/count>`
        or :doc:`pairs():length() </reference/reference_lua/box_space/pairs>`.
