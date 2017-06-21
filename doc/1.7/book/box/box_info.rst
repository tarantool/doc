.. _box_introspection-box_info:

--------------------------------------------------------------------------------
Submodule `box.info`
--------------------------------------------------------------------------------

.. module:: box.info

The ``box.info`` submodule provides access to information about server instance
variables.

* **version** is the Tarantool version. This value is also shown by
  :ref:`tarantool --version <index-tarantool_version>`.
* **id** corresponds to **replication.id** (see below).
* **ro** is ``true`` if the instance is in "read-only" mode
  (same as :ref:`read_only <cfg_basic-read_only>` in ``box.cfg{}``).
* **vclock** corresponds to **replication.downstream.vclock** (see below).
* **uptime** is the number of seconds since the instance started.
  This value can also be retrieved with :ref:`tarantool.uptime() <tarantool-build>`.
* **lsn** corresponds to **replication.lsn** (see below).
* **vinyl** returns runtime statistics for vinyl storage engine.
* **cluster.uuid** is the UUID of the replica set.
  Every instance in a replica set will have the same ``cluster.uuid`` value.
  This value is also stored in :ref:`box.space._schema <box_space-schema>`
  system space.
* **pid** is the process ID. This value is also shown by
  :ref:`tarantool <tarantool-build>` module
  and by the Linux command ``ps -A``.
* **status** corresponds to **replication.upstream.status** (see below).
* **signature** is the sum of all **lsn** values from the vector clocks
  (**vclock**) of all instances in the replica set.
* **uuid** corresponds to **replication.uuid**  (see below).

.. _box_info_replication:

**replication** part contains statistics for all instances in the replica
set in regard to the current instance (see an example in the section
:ref:`"Monitoring a replica set" <replication-monitoring>`):

* **replication.id** is a short numeric identifier of the instance within the
  replica set.
* **replication.uuid** is a globally unique identifier of the instance.
  This value is also stored in :ref:`box.space._cluster <box_space-cluster>`
  system space.
* **replication.lsn** is the :ref:`log sequence number <replication-mechanism>`
  (LSN) for the latest entry in the instance's
  :ref:`write ahead log <index-box_persistence>` (WAL).
* **replication.upstream** contains statistics for the replication data
  uploaded by the instance.
* **replication.upstream.status** is the replication status of the instance.

  * ``auth`` means that the instance is getting authenticated to connect to a
    replication source.
  * ``connecting`` means that the instance is trying to connect to the
    replications source(s) listed
    in its :ref:`replication <cfg_replication-replication>` parameter.
  * ``disconnected`` means that the instance is not connected to the replica set
    (due to network problems, not replication errors).
  * ``follow`` means that the instance's role is "replica" (read-only) and
    replication is in progress.
  * ``running`` means the instance's role is "master" (non read-only) and
    replication is in progress.
  * ``stopped`` means that replication was stopped due to a replication error
    (e.g. duplicate key).

* **replication.upstream.idle** is the time (in seconds) since the instance
  received the last event from a master.
* **replication.upstream.lag** is the time difference between the local time at
  the instance, recorded when the event was received, and the local time at
  another master recorded when the event was written to the write ahead log on
  that master.

  Since ``lag`` calculation uses operating system clock from two different
  machines, don’t be surprised if it’s negative: a time drift may lead to the
  remote master clock being consistently behind the local instance's clock.

  For multi-master configurations, this is the maximal lag.

* **replication.downstream** contains statistics for the replication
  data requested and downloaded from the instance.
* **replication.downstream.vclock** is the instance's
  :ref:`vector clock <internals-vector>`, which contains a pair '**id**, **lsn**'.

.. function:: box.info()

    Since ``box.info`` contents are dynamic, it's not possible to iterate over
    keys with the Lua ``pairs()`` function. For this purpose, ``box.info()``
    builds and returns a Lua table with all keys and values provided in the
    submodule.

    :return: keys and values in the submodule.
    :rtype:  table

    **Example:**

    .. code-block:: tarantoolsession

        tarantool> box.info
        ---
        - version: 1.7.4-52-g980d30092
          id: 1
          ro: false
          vclock: {1: 8}
          uptime: 7280
          lsn: 8
          vinyl: []
          cluster:
            uuid: f7c0c1c6-f9d8-4df7-82ff-d4bd00610a6c
          pid: 16162
          status: running
          signature: 8
          replication:
            1:
              id: 1
              uuid: 1899631e-6369-40a1-81c9-7d170e909276
              lsn: 8
            2:
              id: 2
              uuid: bd949e5d-7ff9-413e-b4f2-c9b0149fdda6
              lsn: 0
              upstream:
                status: follow
                idle: 7256.7571430206
                lag: 0
              downstream:
                vclock: {1: 8}
            3:
              id: 3
              uuid: c5cb61d5-fa48-460d-abd7-3f13709d07a7
              lsn: 0
              upstream:
                status: follow
                idle: 7255.7510120869
                lag: 0
              downstream:
                vclock: {1: 8}
          uuid: 1899631e-6369-40a1-81c9-7d170e909276
        ...
