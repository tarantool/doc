.. _box_info_memory:

================================================================================
box.info.memory()
================================================================================

.. module:: box.info

.. function:: memory()

    Get information about memory usage for the current instance.

    .. NOTE::

        To get a picture of the vinyl subsystem, use
        :ref:`box.stat.vinyl() <box_introspection-box_stat_vinyl>` instead.

    * ``cache`` -- the number of bytes used for caching user data. The
      memtx storage engine does not require a cache, so in fact this is
      the number of bytes in the cache for the tuples stored for the vinyl
      storage engine.
    * ``data`` -- the number of bytes used for storing user data
      (the tuples) with the memtx engine and with level 0 of the vinyl engine,
      without taking memory fragmentation into account.
    * ``index`` -- the number of bytes used for indexing user data,
      including memtx and vinyl memory tree extents, the vinyl page index,
      and the vinyl bloom filters.
    * ``lua`` -- the number of bytes used for Lua runtime.
    * ``net`` -- the number of bytes used for network input/output buffers.
    * ``tx`` -- the number of bytes in use by active transactions.
      For the vinyl storage engine, this is the total size of all allocated
      objects (struct ``txv``, struct ``vy_tx``, struct ``vy_read_interval``)
      and tuples pinned for those objects.

    **Example**

    ..  code-block:: tarantoolsession

        sharded_cluster_crud:storage-a-002> box.info.memory()
        ---
        - cache: 0
          data: 43848
          index: 1130496
          lua: 10516849
          net: 1572864
          tx: 0
        ...
