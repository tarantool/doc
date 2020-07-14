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
* **id** corresponds to :samp:`replication[{n}].id`
  (see :ref:`below <box_info_replication>`).
* **lsn** corresponds to :samp:`replication[{n}].lsn`
  (see :ref:`below <box_info_replication>`).
* **listen** returns a real address to which an instance was bound
  (see :ref:`below <box_info_listen>`).
* **memory()** returns the statistics about memory
  (see :ref:`below <box_info_memory>`).
* **pid** is the process ID. This value is also shown by
  :ref:`tarantool <tarantool-build>` module
  and by the Linux command ``ps -A``.
* **ro** is ``true`` if the instance is in "read-only" mode
  (same as :ref:`read_only <cfg_basic-read_only>` in ``box.cfg{}``),
  or if status is 'orphan'.
* **signature** is the sum of all ``lsn`` values from each :ref:`vector clock <replication-vector>`
  (**vclock**) for all instances in the replica set.
* **sql().cache.size** is the number of bytes in the SQL prepared statement cache.
* **sql().cache.stmt_count** is the number of statements in the SQL prepared statement cache.
* **status** corresponds to :samp:`replication[{n}].upstream.status`
  (see :ref:`below <box_info_replication>`).
* **uptime** is the number of seconds since the instance started.
  This value can also be retrieved with
  :ref:`tarantool.uptime() <tarantool-build>`.
* **uuid** corresponds to :samp:`replication[{n}].uuid`
  (see :ref:`below <box_info_replication>`).
* **vclock** is a table with the vclock values of all instances in a replica set which have made data changes.
* **version** is the Tarantool version. This value is also shown by
  :ref:`tarantool -V <index-tarantool_version>`.
* **vinyl()** returns runtime statistics for the vinyl storage engine.
  This function is deprecated, use
  :ref:`box.stat.vinyl() <box_introspection-box_stat_vinyl>` instead.

.. _box_info:

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
        - version: 2.4.0-251-gc44ed3c08
          id: 1
          ro: false
          uuid: 1738767b-afa3-4987-b485-c333cf83415b
          package: Tarantool
          cluster:
            uuid: 40ee7f0f-7070-4650-8883-801e7014407c
          listen: '[::1]:57122'
          replication:
            1:
              id: 1
              uuid: 1738767b-afa3-4987-b485-c333cf83415b
              lsn: 16
          signature: 16
          status: running
          vinyl: []
          uptime: 21
          lsn: 16
          sql: []
          gc: []
          pid: 20293
          memory: []
          vclock: {1: 16}
        ...

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

.. _box_info_listen:

.. data:: box.info.listen

    Return a real address to which an instance was bound. For example, if
    ``box.cfg{listen}`` was set with a zero port, ``box.info.listen`` will show
    a real port. The address is stored as a string:

    * unix/:<path> for UNIX domain sockets
    * <ip>:<port> for IPv4
    * [ip]:<port> for IPv6
    
    If an instance does not listen to anything, ``box.info.listen`` is nil.

    **Example:**

    .. code-block:: tarantoolsession

      tarantool> box.cfg{listen=0}
      ---
      ...
      tarantool> box.cfg.listen
      ---
      - '0'
      ...
      tarantool> box.info.listen
      ---
      - 0.0.0.0:44149
      ...

.. _box_info_replication:

.. data:: box.info.replication

    The **replication** section of ``box.info()`` is a table array with statistics for all
    instances in the replica set that the current instance belongs to (see also
    :ref:`"Monitoring a replica set" <replication-monitoring>`):
    In the following, *n* is the index number of one table item, for example
    :samp:`replication[1]`, which has data about server instance number 1,
    which may or may not be the same as the current instance
    (the "current instance" is what is responding to ``box.info``).

    * :samp:`replication[{n}].id` is a short numeric identifier of instance *n* within
      the replica set.
      This value is also stored in the :ref:`box.space._cluster <box_space-cluster>`
      system space.
    * :samp:`replication[{n}].uuid` is a globally unique identifier of instance *n*.
      This value is also stored in the :ref:`box.space._cluster <box_space-cluster>`
      system space.
    * :samp:`replication[{n}].lsn` is the
      :ref:`log sequence number <replication-mechanism>`
      (LSN) for the latest entry in instance *n*'s
      :ref:`write ahead log <index-box_persistence>` (WAL).
    * :samp:`replication[{n}].upstream` appears (is not nil)
      if the current instance is following or intending to follow instance *n*,
      which ordinarily means
      :samp:`replication[{n}].upstream.status` = ``follow``,
      :samp:`replication[{n}].upstream.peer` = url of instance *n* which is being followed,
      :samp:`replication[{n}].lag and idle` = the instance's speed, described later.
      Another way to say this is: :samp:`replication[{n}].upstream` will appear when
      :samp:`replication[{n}].upstream.peer` is not of the current instance,
      and is not read-only, and was specified in ``box.cfg{replication={...}}``,
      so it is shown in :ref:`box.cfg.replication <cfg_replication-replication>`.
    * :samp:`replication[{n}].upstream.status` is the replication status of the connection with instance *n*:

      * ``auth`` means that :ref:`authentication <authentication>` is happening.
      * ``connecting`` means that connection is happening.
      * ``disconnected`` means that it is not connected to the replica set (due to network problems, not replication errors).
      * ``follow`` means that the current instance's role is "replica" (read-only, or not read-only but acting as a replica for this remote peer in a master-master configuration), and is receiving or able to receive data from instance *n* (upstream) master.
      * ``running`` means that replication is in progress.
      * ``stopped`` means that replication was stopped due to a replication error (for example :ref:`duplicate key <error_codes>`).
      * ``orphan`` means that it has not (yet) succeeded in joining the required number of masters (see :ref:`orphan status <replication-orphan_status>`).
      * ``sync`` means that the master and replica are synchronizing to have the same data.

    .. _box_info_replication_upstream_idle:

    * :samp:`replication[{n}].upstream.idle` is the time (in seconds) since
      the last event was received.
      This is the primary indicator of replication health.
      See more in :ref:`Monitoring a replica set <replication-monitoring>`.

    .. _box_info_replication_upstream_peer:

    * :samp:`replication[{n}].upstream.peer` contains instance *n*'s
      :ref:`URI <index-uri>` for example 127.0.0.1:3302.
      See more in :ref:`Monitoring a replica set <replication-monitoring>`.

    .. _box_info_replication_upstream_lag:

    * :samp:`replication[{n}].upstream.lag` is the time difference between the local time
      of instance *n*, recorded when the event was received, and the local time
      at another master recorded when the event was written to the
      :ref:`write ahead log <internals-wal>` on that master.
      See more in :ref:`Monitoring a replica set <replication-monitoring>`.

    * :samp:`replication[{n}].upstream.message` contains an error message in case of a
      :ref:`degraded state <replication-recover>`, otherwise it is nil.

    * :samp:`replication[{n}].downstream` appears (is not nil)
      with data about an instance that is following instance *n*
      or is intending to follow it, which ordinarily means
      :samp:`replication[{n}].downstream.status` = ``follow``,

    * :samp:`replication[{n}].downstream.vclock` contains the
      :ref:`vector clock <replication-vector>`, which is a table of
      '**id**, **lsn**' pairs, for example
      :code:`vclock: {1: 3054773, 4: 8938827, 3: 285902018}`.
      (Notice that the table may have multiple pairs although ``vclock`` is a singular name.)
      Even if instance *n* is :ref:`removed <replication-remove_instances>`,
      its values will still appear here; however,
      its values will be overridden if an instance joins later with the same UUID.
      Vendor clock pairs will only appear if ``lsn > 0``.
      :samp:`replication[{n}].downstream.vclock` may be the same as the current instance's vclock (``box.info.vclock``)
      because this is for all known vclock values of the cluster.
      A master will know what is in a replica's copy of vclock
      because, when the master makes a data change, it sends
      the change information to the replica (including the master's
      vector clock), and the replica replies with what is in its entire
      vector clock table.
      Also the replica sends its entire vector clock table in response
      to a master's heartbeat message, see the heartbeat-message examples
      in section :ref:`Binary protocol -- replication <box_protocol-heartbeat>`.

    * :samp:`replication[{n}].downstream.idle` is the time (in seconds) since the last
      time that instance *n* sent events through the downstream replication.

    * :samp:`replication[{n}].downstream.status` is the replication status for downstream
      replications:

      * ``stopped`` means that downstream replication has stopped.
      * ``follow`` means that downstream replication is in progress
        (instance *n* is ready to accept data from the master or is currently doing so)

    * :samp:`replication[{n}].downstream.message` and 
      :samp:`replication[{n}].downstream.system_message`
      will be nil unless a problem occurs with the connection.
      For example, if instance *n* goes down, then one may see
      status = 'stopped', message = 'unexpected EOF when reading from socket', and
      system_message = 'Broken pipe'.
      See also :ref:`degraded state <replication-recover>`.

.. _box_info_replication-anon:

.. function:: box.info.replication_anon()

    List all the :ref:`anonymous replicas <cfg_replication-replication_anon>`
    following the instance.

    The output is similar to the one produced by ``box.info.replication`` with
    an exception that anonymous replicas are indexed by their uuid strings
    rather than server ids, since server ids have no meaning for anonymous
    replicas.

    Notice that when you issue a plain ``box.info.replication_anon``, the only
    info returned is the number of anonymous replicas following the current
    instance. In order to see the full stats, you have to call
    ``box.info.replication_anon()``. This is done to not overload the ``box.info``
    output with excess info, since there may be lots of anonymous replicas.

    **Example:**

    .. code-block:: tarantoolsession

      tarantool> box.info.replication_anon
      ---
      - count: 2
      ...

      tarantool> box.info.replication_anon()
      ---
      - 3a6a2cfb-7e47-42f6-8309-7a25c37feea1:
          id: 0
          uuid: 3a6a2cfb-7e47-42f6-8309-7a25c37feea1
          lsn: 0
          downstream:
            status: follow
            idle: 0.76203499999974
            vclock: {1: 1}
        f58e4cb0-e0a8-42a1-b439-591dd36c8e5e:
          id: 0
          uuid: f58e4cb0-e0a8-42a1-b439-591dd36c8e5e
          lsn: 0
          downstream:
            status: follow
            idle: 0.0041349999992235
            vclock: {1: 1}
      ...

    Notice that anonymous replicas hide their ``lsn`` from the others, so an
    anonymous replica ``lsn`` will always be reported as zero, even if an anonymous
    replica performs some local space operations.
    To find out the ``lsn`` of a specific anonymous replica, you have to issue ``box.info.lsn`` on
    it.
