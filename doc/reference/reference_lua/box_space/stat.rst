.. _box_space-stat:

space_object:stat()
===================

.. class:: space_object

    .. method:: stat()

        Get statistics on memory usage by the space.

        Returns a table with the cumulative statistics on the memory usage by tuples in the space.
        Statistics are grouped by arena types: ``memtx`` or ``malloc``.
        For each arena type, the return table includes tuple memory usage statistics
        listed in the :ref:`box_tuple-info` reference.

        .. note::

            Memory usage statistics are shown only for the memtx storage engine.
            For other types of spaces, an empty table is returned.

        :param space_object space_object: an :ref:`object reference
                                          <app_server-object_reference>`

        :return: space memory usage statistics
        :rtype: table

        **Possible errors:** ``space_object`` does not exist.


        **Example:**

        .. code-block:: tarantoolsession

            tarantool> box.space.tester:stat()
            ---
            - tuple:
                memtx:
                  waste_size: 145
                  data_size: 235
                  header_size: 36
                  field_map_size: 24
                malloc:
                  waste_size: 0
                  data_size: 0
                  header_size: 0
                  field_map_size: 0
            ...