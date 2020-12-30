.. _box_space-len:

===============================================================================
space_object:len()
===============================================================================

.. module:: box.space

.. class:: space_object

    .. method:: len()

        Return the number of tuples in the space.
        If compared with :ref:`count() <box_space-count>`, this method works
        faster because ``len()`` does not scan the entire space to count the
        tuples.

        :param space_object space_object: an :ref:`object reference
                                          <app_server-object_reference>`

        :return: Number of tuples in the space.

        **Example:**

        .. code-block:: tarantoolsession

            tarantool> box.space.tester:len()
            ---
            - 2
            ...

        **Note re storage engine:** vinyl supports ``len()`` but the result may be approximate.
        If an exact result is necessary then use :ref:`count() <box_space-count>`
        or :ref:`pairs():length() <box_space-pairs>`.
