.. _box_introspection-box_info:

-------------------------------------------------------------------------------
Submodule `box.info`
-------------------------------------------------------------------------------

.. module:: box.info

The ``box.info`` submodule provides access to information about server instance
variables.

* **cluster.uuid** is the UUID of the replica set.
  Every instance in a replica set will have the same ``cluster.uuid`` value.
  This value is also stored in :ref:`box.space._schema <box_space-schema>`
  system space.
* **id** corresponds to **replication.id**
  (see :ref:`below <box_info_replication>`).
* **lsn** corresponds to **replication.lsn**
  (see :ref:`below <box_info_replication>`).
* **memory** has the statistics about memory
  (see :ref:`below <box_info_memory>`).
* **pid** is the process ID. This value is also shown by
  :ref:`tarantool <tarantool-build>` module
  and by the Linux command ``ps -A``.
* **ro** is ``true`` if the instance is in "read-only" mode
  (same as :ref:`read_only <cfg_basic-read_only>` in ``box.cfg{}``).
* **signature** is the sum of all **lsn** values from the vector clocks
  (**vclock**) of all instances in the replica set.
* **status** corresponds to **replication.upstream.status** (see below).
* **uptime** is the number of seconds since the instance started.
  This value can also be retrieved with
  :ref:`tarantool.uptime() <tarantool-build>`.
* **uuid** corresponds to **replication.uuid**
  (see :ref:`below <box_info_replication>`).
* **vclock** corresponds to **replication.downstream.vclock**
  (see :ref:`below <box_info_replication>`).
* **version** is the Tarantool version. This value is also shown by
  :ref:`tarantool -V <index-tarantool_version>`.
* **vinyl** returns runtime statistics for vinyl storage engine.

.. _box_info_memory:

.. function:: box.info.memory()

    The **memory** function of ``box.info`` gives the ``admin`` user a
    picture of the whole Tarantool instance. (Use ``box.info.vinyl()`` instead
    for a picture specifically of the vinyl subsystem.)

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

.. _box_info_replication:

.. data:: box.info.replication

    The **replication** section of ``box.info()`` contains statistics for all
    instances in the replica set in regard to the current instance (see also
    :ref:`"Monitoring a replica set" <replication-monitoring>`):

    * **replication.id** is a short numeric identifier of the instance within
      the replica set.
    * **replication.uuid** is a globally unique identifier of the instance.
      This value is also stored in :ref:`box.space._cluster <box_space-cluster>`
      system space.
    * **replication.lsn** is the
      :ref:`log sequence number <replication-mechanism>`
      (LSN) for the latest entry in the instance's
      :ref:`write ahead log <index-box_persistence>` (WAL).
    * **replication.upstream** contains statistics for the replication data
      uploaded by the instance.
    * **replication.upstream.status** is the replication status of the instance:

      * ``auth`` means that the instance is getting
        :ref:`authenticated <authentication>` to connect to a replication
        source.
      * ``connecting`` means that the instance is trying to connect to the
        replications source(s) listed
        in its :ref:`replication <cfg_replication-replication>` parameter.
      * ``disconnected`` means that the instance is not connected to the
        replica set (due to network problems, not replication errors).
      * ``follow`` means that the instance's :ref:`role <replication-roles>`
        is "replica" (read-only) and replication is in progress.
      * ``running`` means the instance's role is "master" (non read-only) and
        replication is in progress.
      * ``stopped`` means that replication was stopped due to a replication
        error (e.g. :ref:`duplicate key <error_codes>`).

    .. _box_info_replication_upstream_idle:

    * **replication.upstream.idle** is the time (in seconds) since the instance
      received the last event from a master.
      This is the primary indicator of replication health.
      See more in :ref:`Monitoring a replica set <replication-monitoring>`.

    .. _box_info_replication_upstream_peer:

    * **replication.upstream.peer** contains the replication user name, host IP
      adress and port number used for the instance.
      See more in :ref:`Monitoring a replica set <replication-monitoring>`.

    .. _box_info_replication_upstream_lag:

    * **replication.upstream.lag** is the time difference between the local time
      at the instance, recorded when the event was received, and the local time
      at another master recorded when the event was written to the
      :ref:`write ahead log <internals-wal>` on that master.
      See more in :ref:`Monitoring a replica set <replication-monitoring>`.

    * **replication.upstream.message** contains an error message in case of a
      :ref:`degraded state <replication-recover>`, empty otherwise.

    * **replication.downstream** contains statistics for the replication
      data requested and downloaded from the instance.

    * **replication.downstream.vclock** contains the
      :ref:`vector clock <internals-vector>`, which is a table of
      '**id**, **lsn**' pairs, for example
      :code:`vclock: {1: 3054773, 4: 8938827, 3: 285902018}`.
      Even if an instance is :ref:`removed <replication-remove_instances>`,
      its values will still appear here.

.. function:: box.info()

    Since ``box.info`` contents are dynamic, it's not possible to iterate over
    keys with the Lua ``pairs()`` function. For this purpose, ``box.info()``
    builds and returns a Lua table with all keys and values provided in the
    submodule.

    :return: keys and values in the submodule
    :rtype:  table

    **Example:**

    This example is for a master-replica set that contains one master instance
    and one replica instance. The request was issued at the replica instance.

    .. code-block:: tarantoolsession

        tarantool> box.info()
        ---
        - version: 1.7.6-68-g51fcffb77
          id: 2
          ro: true
          vclock: {1: 5}
          uptime: 917
          lsn: 0
          vinyl: []
          cluster:
            uuid: 783e2285-55b1-42d4-b93c-68dcbb7a8c18
          pid: 35341
          status: running
          signature: 5
          replication:
            1:
              id: 1
              uuid: 471cd36e-cb2e-4447-ac66-2d28e9dd3b67
              lsn: 5
              upstream:
                status: follow
                idle: 124.98795700073
                peer: replicator@192.168.0.101:3301
                lag: 0
              downstream:
                vclock: {1: 5}
            2:
              id: 2
              uuid: ac45d5d2-8a16-4520-ad5e-1abba6baba0a
              lsn: 0
          uuid: ac45d5d2-8a16-4520-ad5e-1abba6baba0a
        ...
