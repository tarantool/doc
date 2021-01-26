.. _box_space-delete:

===============================================================================
space_object:delete()
===============================================================================

.. class:: space_object

    .. method:: delete(key)

        Delete a tuple identified by a primary key.

        :param space_object space_object: an :ref:`object reference
                                          <app_server-object_reference>`
        :param scalar/table key: primary-key field values, must be passed as a
                                 Lua table if key is multi-part

        :return: the deleted tuple
        :rtype:  tuple

        **Complexity factors:** Index size, Index type

        **Note re storage engine:**
        vinyl will return ``nil``, rather than the deleted tuple.

        **Example:**

        .. code-block:: tarantoolsession

            tarantool> box.space.tester:delete(1)
            ---
            - [1, 'My first tuple']
            ...
            tarantool> box.space.tester:delete(1)
            ---
            ...
            tarantool> box.space.tester:delete('a')
            ---
            - error: 'Supplied key type of part 0 does not match index part type:
              expected unsigned'
            ...

        For more usage scenarios and typical errors see
        :ref:`Example: using data operations <box_space-operations-detailed-examples>`
        further in this section.
