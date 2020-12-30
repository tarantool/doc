.. _box_space-rename:

===============================================================================
space_object:rename()
===============================================================================

.. module:: box.space

.. class:: space_object

    .. method:: rename(space-name)

        Rename a space.

        :param space_object space_object: an :ref:`object reference
                                          <app_server-object_reference>`
        :param string space-name: new name for space

        :return: nil

        **Possible errors:** ``space_object`` does not exist.

        **Example:**

        .. code-block:: tarantoolsession

            tarantool> box.space.space55:rename('space56')
            ---
            ...
            tarantool> box.space.space56:rename('space55')
            ---
            ...
