.. _box_space-upsert:

===============================================================================
space_object:upsert()
===============================================================================

.. class:: space_object

    .. method:: upsert({tuple}, {{operator, field_identifier, value}, ...}, )

        Update or insert a tuple.

        If there is an existing tuple which matches the key fields of ``tuple``,
        then the request has the same effect as
        :doc:`/reference/reference_lua/box_space/update` and the
        ``{{operator, field_identifier, value}, ...}`` parameter is used.
        If there is no existing tuple which matches the key fields of ``tuple``,
        then the request has the same effect as
        :doc:`/reference/reference_lua/box_space/insert` and the
        ``{tuple}`` parameter is used. However, unlike ``insert`` or
        ``update``, ``upsert`` will not read a tuple and perform
        error checks before returning -- this is a design feature which
        enhances throughput but requires more caution on the part of the user.

        :param space_object space_object: an :ref:`object reference
                                          <app_server-object_reference>`
        :param table/tuple tuple: default tuple to be inserted, if analogue
                                  isn't found
        :param string   operator: operation type represented in string
        :param number   field_identifier: what field the operation will apply to
        :param lua_value   value: what value will be applied

        :return: null

        **Possible errors:**

        *    It is illegal to modify a primary-key field.
        *    It is illegal to use upsert with a space that has a unique secondary
             index.
        *   :errcode:`ER_TRANSACTION_CONFLICT` if a transaction conflict is detected in the
            :ref:`MVCC transaction mode <txn_mode_transaction-manager>`.

        **Complexity factors:** Index size, Index type, number of indexes
        accessed, WAL settings.

        **Example:**

        .. code-block:: lua

            box.space.tester:upsert({12,'c'}, {{'=', 3, 'a'}, {'=', 4, 'b'}})

        For more usage scenarios and typical errors see
        :ref:`Example: using data operations <box_space-operations-detailed-examples>`
        further in this section.
