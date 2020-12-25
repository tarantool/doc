.. _box_space-drop:

===============================================================================
space_object:drop()
===============================================================================

.. module:: box.space

.. class:: space_object

    .. method:: drop()

        Drop a space. The method is performed in background and doesn't block
        consequent requests.

        :param space_object space_object: an :ref:`object reference
                                          <app_server-object_reference>`

        :return: nil

        **Possible errors:** ``space_object`` does not exist.

        **Complexity factors:** Index size, Index type,
        Number of indexes accessed, WAL settings.

        **Example:**

        .. code-block:: lua

            box.space.space_that_does_not_exist:drop()
