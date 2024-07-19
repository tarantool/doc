
.. _box_tuple-info:

tuple_object.info()
===================

.. class:: tuple_object

    .. method:: info()

        Get information about the tuple memory usage.

        Returns a table with the following fields:

        -   ``data_size`` -- size of MessagePack data in the tuple.
            This number equals to number returned by :ref:`box_tuple-bsize`.
        -   ``header_size`` - size of the internal tuple header.
        -   ``field_map_size`` -- size of the field map.
            Field map is used to speed up access to indexed fields of the tuple.
        -   ``waste_size`` -- amount of excess memory used to store the tuple
            in mempool.
        -   ``arena`` - type of the arena where the tuple is allocated.
            Possible values are: ``memtx``, ``malloc``, ``runtime``.

        :return: tuple memory usage statistics
        :rtype: table


        **Example**

        .. code-block:: tarantoolsession

            tarantool> box.space.tester:get('222200000'):info()
            ---
            - data_size: 55
              waste_size: 95
              arena: memtx
              field_map_size: 4
              header_size: 6
            ...
