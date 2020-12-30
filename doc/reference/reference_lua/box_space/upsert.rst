.. _box_space-upsert:

===============================================================================
space_object:upsert()
===============================================================================

.. module:: box.space

.. class:: space_object

    .. method:: upsert(tuple, {{operator, field_no, value}, ...}, )

        Update or insert a tuple.

        If there is an existing tuple which matches the key fields of ``tuple``, then the
        request has the same effect as :ref:`space_object:update() <box_space-update>` and the
        ``{{operator, field_no, value}, ...}`` parameter is used.
        If there is no existing tuple which matches the key fields of ``tuple``, then the
        request has the same effect as :ref:`space_object:insert() <box_space-insert>` and the
        ``{tuple}`` parameter is used. However, unlike ``insert`` or
        ``update``, ``upsert`` will not read a tuple and perform
        error checks before returning -- this is a design feature which
        enhances throughput but requires more caution on the part of the user.

        :param space_object space_object: an :ref:`object reference
                                          <app_server-object_reference>`
        :param table/tuple tuple: default tuple to be inserted, if analogue
                                  isn't found
        :param string   operator: operation type represented in string
        :param number   field_no: what field the operation will apply to. The
                                  field number can be negative, meaning the
                                  position from the end of tuple.
                                  (#tuple + negative field number + 1)
        :param lua_value   value: what value will be applied

        :return: null

        **Possible errors:**

        * It is illegal to modify a primary-key field.
        * It is illegal to use upsert with a space that has a unique secondary
          index.

        **Complexity factors:** Index size, Index type, number of indexes
        accessed, WAL settings.

        **Example:**

        .. code-block:: lua

            box.space.tester:upsert({12,'c'}, {{'=', 3, 'a'}, {'=', 4, 'b'}})

        For more usage scenarios and typical errors see
        :ref:`Example: using data operations <box_space-operations-detailed-examples>`
        further in this section.
