.. _box_index-random:

===============================================================================
index_object:random()
===============================================================================

.. class:: index_object

    .. method:: random(seed)

        Find a random value in the specified index. This method is useful when
        it's important to get insight into data distribution in an index without
        having to iterate over the entire data set.


        :param index_object index_object: an :ref:`object reference
                                          <app_server-object_reference>`.
        :param number seed: an arbitrary non-negative integer

        :return: the tuple for the random key in the index.
        :rtype:  tuple

        **Complexity factors:** Index size, Index type.

        **Note regarding storage engine:** vinyl does not support ``random()``.

        **Example:**

        .. code-block:: tarantoolsession

            tarantool> box.space.tester.index.secondary:random(1)
            ---
            - ['Beta!', 66, 'This is the second tuple!']
            ...
