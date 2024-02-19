* :ref:`checkpoint_count <cfg_checkpoint_daemon-checkpoint_count>`
* :ref:`checkpoint_interval <cfg_checkpoint_daemon-checkpoint_interval>`
* :ref:`checkpoint_wal_threshold <cfg_checkpoint_daemon-checkpoint_wal_threshold>`

The checkpoint daemon is a fiber which is constantly running. At intervals,
it may make new :ref:`snapshot (.snap) files <index-box_persistence>` and then
may delete old snapshot files.

The :ref:`checkpoint_interval <cfg_checkpoint_daemon-checkpoint_interval>` and
:ref:`checkpoint_count <cfg_checkpoint_daemon-checkpoint_count>` configuration
settings determine how long the intervals are, and how many snapshots should
exist before deletions occur.

.. _cfg_checkpoint_daemon-garbage-collector:

**Tarantool garbage collector**

The checkpoint daemon may activate the Tarantool garbage collector
which deletes old files. This garbage collector is distinct from the
`Lua garbage collector <https://www.lua.org/manual/5.1/manual.html#2.10>`_
which is for Lua objects, and distinct from a
Tarantool garbage collector which specializes in
:ref:`handling shard buckets <vshard-gc>`.

If the checkpoint daemon deletes an old snapshot file, then the
Tarantool garbage collector will also delete
any :ref:`write-ahead log (.xlog) <internals-wal>` files which are older than
the snapshot file and which contain information that is present in the snapshot
file. It will also delete obsolete vinyl ``.run`` files.

The checkpoint daemon and the Tarantool garbage collector will not delete a file if:

* a **backup** is ongoing and the file has not been backed up
  (see :ref:`"Hot backup" <admin-backups-hot_backup_vinyl_memtx>`), or

* **replication** is ongoing and the file has not been relayed to a replica
  (see :ref:`"Replication architecture" <replication-architecture>`),

* a replica is connecting, or

* a replica has fallen behind.
  The progress of each replica is tracked; if a replica's position is far
  from being up to date, then the server stops to give it a chance to
  catch up.
  If an administrator concludes that a replica is permanently down, then the
  correct procedure is to restart the server, or (preferably)
  :ref:`remove the replica from the cluster <replication-remove_instances>`.

.. _cfg_checkpoint_daemon-checkpoint_interval:

.. confval:: checkpoint_interval

    Since version 1.7.4.

    The interval in seconds between actions by the checkpoint daemon. If
    ``checkpoint_interval`` is set to a value greater than zero, and there is
    activity which causes change to a database, then the checkpoint daemon
    calls :doc:`box.snapshot() </reference/reference_lua/box_snapshot>` every ``checkpoint_interval``
    seconds, creating a new snapshot file each time. If ``checkpoint_interval``
    is set to zero, the checkpoint daemon is disabled.

    .. code-block:: lua

        box.cfg{ checkpoint_interval = 7200 }

    In the example, the checkpoint daemon creates a new database snapshot every two hours, if there is activity.

    | Type: integer
    | Default: 3600 (one hour)
    | Environment variable: TT_CHECKPOINT_INTERVAL
    | Dynamic: yes

.. _cfg_checkpoint_daemon-checkpoint_count:

.. confval:: checkpoint_count

    Since version 1.7.4.

    The maximum number of snapshots that are stored in the
    :ref:`memtx_dir <cfg_basic-memtx_dir>` directory
    before the checkpoint daemon deletes old snapshots.
    If ``checkpoint_count`` is set to zero, the checkpoint daemon
    does not delete old snapshots.

    .. code-block:: lua

        box.cfg{
            checkpoint_interval = 7200,
            checkpoint_count  = 3
        }

    In the example, the checkpoint daemon creates a new snapshot every two hours until
    it has created three snapshots. After that, it deletes the oldest snapshot
    (and any associated write-ahead-log files) after creating a new one.

    ..  NOTE::

        Snapshots will not be deleted if replication is ongoing and the file has not been relayed to a replica.
        Therefore, ``snapshot.count`` has no effect unless all replicas are alive.


    | Type: integer
    | Default: 2
    | Environment variable: TT_CHECKPOINT_COUNT
    | Dynamic: yes

.. _cfg_checkpoint_daemon-checkpoint_wal_threshold:

.. confval:: checkpoint_wal_threshold

    Since version 2.1.2.

    The threshold for the total size in bytes of all WAL files created since the last checkpoint.
    Once the configured threshold is exceeded, the WAL thread notifies the
    checkpoint daemon that it must make a new checkpoint and delete old WAL files.

    This parameter enables administrators to handle a problem that could occur
    with calculating how much disk space to allocate for a partition containing
    WAL files.

    | Type: integer
    | Default: 10^18 (a large number so in effect there is no limit by default)
    | Environment variable: TT_CHECKPOINT_WAL_THRESHOLD
    | Dynamic: yes
