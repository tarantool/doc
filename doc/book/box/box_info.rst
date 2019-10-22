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
* **gc()** returns the state of the
  :ref:`Tarantool garbage collector <cfg_checkpoint_daemon-garbage-collector>`
  including the checkpoints and their consumers (users); see details
  :ref:`below <box_info_gc>`.
* **id** corresponds to **replication.id**
  (see :ref:`below <box_info_replication>`).
* **lsn** corresponds to **replication.lsn**
  (see :ref:`below <box_info_replication>`).
* **memory()** returns the statistics about memory
  (see :ref:`below <box_info_memory>`).
* **pid** is the process ID. This value is also shown by
  :ref:`tarantool <tarantool-build>` module
  and by the Linux command ``ps -A``.
* **ro** is ``true`` if the instance is in "read-only" mode
  (same as :ref:`read_only <cfg_basic-read_only>` in ``box.cfg{}``),
  or if status is 'orphan'.
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
* **vinyl()** returns runtime statistics for the vinyl storage engine.
  This function is deprecated, use
  :ref:`box.stat.vinyl() <box_introspection-box_stat_vinyl>` instead.

.. _box_info_memory:

.. function:: box.info.memory()

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

.. _box_info_gc:

.. function:: box.info.gc()

    The **gc** function of ``box.info`` gives the ``admin`` user a
    picture of the factors that affect the
    :ref:`Tarantool garbage collector <cfg_checkpoint_daemon-garbage-collector>`.
    The garbage collector compares vclock (:ref:`vector clock <replication-vector>`)
    values of users and checkpoints, so a look at ``box.info.gc()`` may show why the
    garbage collector has not removed old WAL files, or show what it may soon remove.

    * **gc().consumers** -- a list of users whose requests might affect the garbage collector.
    * **gc().checkpoints** -- a list of preserved checkpoints.
    * **gc().checkpoints[n].references** -- a list of references to a checkpoint.
    * **gc().checkpoints[n].vclock** -- a checkpoint's vclock value.
    * **gc().checkpoints[n].signature** -- a sum of a checkpoint's vclock's components.
    * **gc().checkpoint_is_in_progress** -- true if a checkpoint is in progress, otherwise false
    * **gc().vclock** -- the garbage collector's vclock.
    * **gc().signature** -- the sum of the garbage collector's checkpoint's components.

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
      * ``follow`` means that replication is in progress.
      * ``running`` means the instance's role is "master" (non read-only) and
        replication is in progress.
      * ``stopped`` means that replication was stopped due to a replication
        error (e.g. :ref:`duplicate key <error_codes>`).
      * ``orphan`` means that the instance has not (yet) succeeded in joining
        the required number of masters (see :ref:`orphan status <replication-orphan_status>`).
      * ``synch`` means that the master and replica are synchronizing to
        have the same data.

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
      :ref:`vector clock <replication-vector>`, which is a table of
      '**id**, **lsn**' pairs, for example
      :code:`vclock: {1: 3054773, 4: 8938827, 3: 285902018}`.
      Even if an instance is :ref:`removed <replication-remove_instances>`,
      its values will still appear here.

    * **replication.downstream.idle** is the time (in seconds) since the last
      time this instance sent events through the downstream replication.

    * **replication.downstream.status** is the replication status for downstream
      replications:

      * ``stopped`` means that downstream replication has stopped.
      * ``follow`` means that downstream replication is in progress.



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
        - vinyl: []
          version: 2.2.0-482-g8c84932ad
          id: 2
          ro: true
          status: running
          vclock: {1: 9}
          uptime: 356
          lsn: 0
          memory: []
          cluster:
            uuid: e261a5bc-6303-4de3-9873-556f311255e0
          pid: 160
          gc: []
          signature: 9
          replication:
            1:
              id: 1
              uuid: fce71bb3-0e99-40ec-ab7e-5159487e18d1
              lsn: 9
              upstream:
                status: follow
                idle: 0.035709699994186
                peer: replicator@127.0.0.1:3401
                lag: 0.00016164779663086
              downstream:
                status: follow
                idle: 0.59840899999836
                vclock: {1: 9}
            2:
              id: 2
              uuid: bc4629ce-ea31-4f75-b805-a4807bcacc93
              lsn: 0
          uuid: bc4629ce-ea31-4f75-b805-a4807bcacc93
        ...
