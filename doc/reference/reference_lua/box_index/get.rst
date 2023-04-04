.. _box_index-get:

===============================================================================
index_object:get()
===============================================================================

.. class:: index_object

    .. method:: get(key)

        Search for a tuple via the given index, as described in the :ref:`select <box_index-note>` topic.

        :param index_object index_object: an :ref:`object reference
                                          <app_server-object_reference>`.
        :param scalar/table      key: values to be matched against the index key

        :return: the tuple whose index-key fields are equal to the passed key values.
        :rtype:  tuple

        **Possible errors:**

        * no such index;
        * wrong type;
        * more than one tuple matches.

        **Complexity factors:** Index size, Index type.
        See also :ref:`space_object:get() <box_space-get>`.

        **Example:**

        .. code-block:: tarantoolsession

            tarantool> box.space.tester.index.primary:get(2)
            ---
            - [2, 'Music']
            ...
