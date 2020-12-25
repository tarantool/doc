.. _box_index-min:

===============================================================================
index_object:min()
===============================================================================

.. module:: box.index

.. class:: index_object

    .. method:: min([key])

        Find the minimum value in the specified index.

        :param index_object index_object: an :ref:`object reference
                                          <app_server-object_reference>`.
        :param scalar/table      key: values to be matched against the index key

        :return: the tuple for the first key in the index. If optional
                 ``key`` value is supplied, returns the first key which
                 is greater than or equal to ``key`` value.
                 In a future version of Tarantool, index:min(``key`` value) will return nothing
                 if ``key`` value is not equal to a value in the index.
        :rtype:  tuple

        **Possible errors:** index is not of type 'TREE'.

        **Complexity factors:** Index size, Index type.

        **Example:**

        .. code-block:: tarantoolsession

            tarantool> box.space.tester.index.primary:min()
            ---
            - ['Alpha!', 55, 'This is the first tuple!']
            ...
