.. _box_index-count:

===============================================================================
index_object:count()
===============================================================================

.. module:: box.index

.. class:: index_object

    .. method:: count([key], [iterator])

        Iterate over an index, counting the number of
        tuples which match the key-value.

        :param index_object index_object: an :ref:`object reference
                                          <app_server-object_reference>`.
        :param scalar/table key: values to be matched against the index key
        :param         iterator: comparison method

        :return: the number of matching tuples.
        :rtype:  number

        **Example:**

        .. code-block:: tarantoolsession

            tarantool> box.space.tester.index.primary:count(999)
            ---
            - 0
            ...
            tarantool> box.space.tester.index.primary:count('Alpha!', { iterator = 'LE' })
            ---
            - 1
            ...
