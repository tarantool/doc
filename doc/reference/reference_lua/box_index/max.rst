.. _box_index-max:

===============================================================================
index_object:max()
===============================================================================

.. module:: box.index

.. class:: index_object

    .. method:: max([key])

        Find the maximum value in the specified index.

        :param index_object index_object: an :ref:`object reference
                                          <app_server-object_reference>`.
        :param scalar/table      key: values to be matched against the index key

        :return: the tuple for the last key in the index. If optional ``key`` value
                 is supplied, returns the last key which is less than or equal to
                 ``key`` value.
                 In a future version of Tarantool, index:max(``key`` value) will return nothing
                 if ``key`` value is not equal to a value in the index.
        :rtype:  tuple

        **Possible errors:** index is not of type 'TREE'.

        **Complexity factors:** Index size, Index type.

        **Example:**

        .. code-block:: tarantoolsession

            tarantool> box.space.tester.index.primary:max()
            ---
            - ['Gamma!', 55, 'This is the third tuple!']
            ...
