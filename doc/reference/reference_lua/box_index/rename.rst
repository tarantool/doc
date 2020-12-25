.. _box_index-rename:

===============================================================================
index_object:rename()
===============================================================================

.. module:: box.index

.. class:: index_object

    .. method:: rename(index-name)

        Rename an index.

        :param index_object index_object: an :ref:`object reference
                                          <app_server-object_reference>`.
        :param string index-name: new name for index

        :return: nil

        **Possible errors:** index_object does not exist.

        **Example:**

        .. code-block:: tarantoolsession

            tarantool> box.space.space55.index.primary:rename('secondary')
            ---
            ...

        **Complexity factors:** Index size, Index type, Number of tuples accessed.
