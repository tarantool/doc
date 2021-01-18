.. _box_info_memory:

================================================================================
box.info.memory()
================================================================================

.. module:: box.info

.. function:: memory()

    The **memory** function of ``box.info`` gives the ``admin`` user a
    picture of the whole Tarantool instance.

    .. NOTE::

        To get a picture of the vinyl subsystem, use
        :ref:`box.stat.vinyl() <box_introspection-box_stat_vinyl>` instead.

    * **memory().cache** -- number of bytes used for caching user data. The
      memtx storage engine does not require a cache, so in fact this is
      the number of bytes in the cache for the tuples stored for the vinyl
      storage engine.
    * **memory().data** -- number of bytes used for storing user data
      (the tuples) with the memtx engine and with level 0 of the vinyl engine,
      without taking memory fragmentation into account.
    * **memory().index** -- number of bytes used for indexing user data,
      including memtx and vinyl memory tree extents, the vinyl page index,
      and the vinyl bloom filters.
    * **memory().lua** -- number of bytes used for Lua runtime.
    * **memory().net** -- number of bytes used for network input/output buffers.
    * **memory().tx** -- number of bytes in use by active transactions.
      For the vinyl storage engine, this is the total size of all allocated
      objects (struct ``txv``, struct ``vy_tx``, struct ``vy_read_interval``)
      and tuples pinned for those objects.

    An example with a minimum allocation while only the memtx storage engine is
    in use:

    .. code-block:: tarantoolsession

        tarantool> box.info.memory()
        ---
        - cache: 0
          data: 6552
          tx: 0
          lua: 1315567
          net: 98304
          index: 1196032
        ...