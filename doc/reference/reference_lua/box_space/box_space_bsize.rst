.. _box_space-bsize:

===============================================================================
space_object:bsize()
===============================================================================

.. module:: box.space

.. class:: space_object

    .. method:: bsize()

        :param space_object space_object: an :ref:`object reference
                                          <app_server-object_reference>`

        :return: Number of bytes in the space. This number, which is stored
                 in Tarantool's internal memory, represents the total number
                 of bytes in all tuples, not including index keys.
                 For a measure of index size,
                 see :ref:`index_object:bsize() <box_index-bsize>`.

        **Example:**

        .. code-block:: tarantoolsession

            tarantool> box.space.tester:bsize()
            ---
            - 22
            ...
