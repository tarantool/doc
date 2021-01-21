.. _box_index-drop:

===============================================================================
index_object:drop()
===============================================================================

.. module:: box.index

.. class:: index_object

    .. method:: drop()

        Drop an index. Dropping a primary-key index has
        a side effect: all tuples are deleted.

        :param index_object index_object: an :ref:`object reference
                                          <app_server-object_reference>`.

        :return: nil.

        **Possible errors:**

        * index does not exist,
        * a primary-key index cannot be dropped while a secondary-key index
          exists.

        **Example:**

        .. code-block:: tarantoolsession

            tarantool> box.space.space55.index.primary:drop()
            ---
            ...
