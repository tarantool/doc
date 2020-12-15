.. _box_space-count:

===============================================================================
space_object:count()
===============================================================================

.. module:: box.space

.. class:: space_object

    .. method:: count([key], [iterator])

        Return the number of tuples.
        If compared with :ref:`len() <box_space-len>`, this method works
        slower because ``count()`` scans the entire space to count the
        tuples.

        :param space_object space_object: an :ref:`object reference
                                          <app_server-object_reference>`
        :param scalar/table key: primary-key field values, must be passed as a
                                 Lua table if key is multi-part
        :param iterator: comparison method

        :return: Number of tuples.

        **Example:**

        .. code-block:: tarantoolsession

            tarantool> box.space.tester:count(2, {iterator='GE'})
            ---
            - 1
            ...
