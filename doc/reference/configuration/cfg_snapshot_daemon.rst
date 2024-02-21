* :ref:`checkpoint_count <cfg_checkpoint_daemon-checkpoint_count>`
* :ref:`checkpoint_interval <cfg_checkpoint_daemon-checkpoint_interval>`
* :ref:`checkpoint_wal_threshold <cfg_checkpoint_daemon-checkpoint_wal_threshold>`

..  _cfg_checkpoint_daemon:

**Checkpoint daemon**

The checkpoint daemon (snapshot daemon) is a constantly running :ref:`fiber <app-fibers>`.
The checkpoint daemon creates a schedule for the periodic snapshot creation based on
the configuration options and the speed of file size growth.
If enabled, the daemon makes new :ref:`snapshot <concepts-data_model-persistence>` (``.snap``) files according to this schedule.

The work of the checkpoint daemon is based on the following configuration options:

*   :ref:`checkpoint_interval <cfg_checkpoint_daemon-checkpoint_interval>` -- a new snapshot is taken once in a given period.
*   :ref:`checkpoint_wal_threshold <cfg_checkpoint_daemon-checkpoint_wal_threshold>` -- a new snapshot is taken once the size
    of all WAL files created since the last snapshot exceeds a given limit.

If necessary, the checkpoint daemon also activates the :ref:`Tarantool garbage collector <cfg_checkpoint_daemon-garbage-collector>`
that deletes old snapshots and WAL files.

..  _cfg_checkpoint_daemon-garbage-collector:

**Tarantool garbage collector**

Tarantool garbage collector can be activated by the :ref:`checkpoint daemon <cfg_checkpoint_daemon-checkpoint_count>`.
The garbage collector tracks the snapshots that are to be :ref:`relayed to a replica <memtx-replication>` or needed
by other consumers. When the files are no longer needed, Tarantool garbage collector deletes them.

..  NOTE::

    The garbage collector called by the checkpoint daemon is distinct from the `Lua garbage collector <https://www.lua.org/manual/5.1/manual.html#2.10>`_
    which is for Lua objects, and distinct from the Tarantool garbage collector that specializes in :ref:`handling shard buckets <vshard-gc>`.

This garbage collector is called as follows:

*   When the number of snapshots reaches the limit of :ref:`checkpoint_count <configuration_reference_snapshot_count>` size.
    After a new snapshot is taken, Tarantool garbage collector deletes the oldest snapshot file and any associated WAL files.

*   When the size of all WAL files created since the last snapshot reaches the limit of :ref:`checkpoint_wal_threshold <cfg_checkpoint_daemon-checkpoint_wal_threshold>`.
    Once this size is exceeded, the checkpoint daemon takes a snapshot, then the garbage collector deletes the old WAL files.

If an old snapshot file is deleted, the Tarantool garbage collector also deletes
any :ref:`write-ahead log (.xlog) <internals-wal>` files that meet the following conditions:

*   The WAL files are older than the snapshot file.
*   The WAL files contain information present in the snapshot file.

Tarantool garbage collector also deletes obsolete vinyl ``.run`` files.

Tarantool garbage collector doesn't delete a file in the following cases:

*   A backup is running, and the file has not been backed up
    (see :ref:`Hot backup <admin-backups-hot_backup_vinyl_memtx>`).

*   Replication is running, and the file has not been relayed to a replica
    (see :ref:`Replication architecture <replication-architecture>`),

*   A replica is connecting.

*   A replica has fallen behind.
    The progress of each replica is tracked; if a replica's position is far
    from being up to date, then the server stops to give it a chance to catch up.
    If an administrator concludes that a replica is permanently down, then the
    correct procedure is to restart the server, or (preferably) :ref:`remove the replica from the cluster <replication-remove_instances>`.

..  _cfg_checkpoint_daemon-checkpoint_interval:

..  confval:: checkpoint_interval

    Since version 1.7.4.

    The interval in seconds between actions by the :ref:`checkpoint daemon <cfg_checkpoint_daemon>`.
    If the option is set to a value greater than zero, and there is
    activity that causes change to a database, then the checkpoint daemon
    calls :doc:`box.snapshot() </reference/reference_lua/box_snapshot>` every ``checkpoint_interval``
    seconds, creating a new snapshot file each time. If the option
    is set to zero, the checkpoint daemon is disabled.

    ..  code-block:: lua

        box.cfg{ checkpoint_interval = 7200 }

    In the example, the checkpoint daemon creates a new database snapshot every two hours, if there is activity.

    | Type: integer
    | Default: 3600 (one hour)
    | Environment variable: TT_CHECKPOINT_INTERVAL
    | Dynamic: yes

..  _cfg_checkpoint_daemon-checkpoint_count:

..  confval:: checkpoint_count

    Since version 1.7.4.

    The maximum number of snapshots that are stored in the
    :ref:`memtx_dir <cfg_basic-memtx_dir>` directory.
    If the number of snapshots after creating a new one exceeds this value,
    the :ref:`Tarantool garbage collector <cfg_checkpoint_daemon-garbage-collector>` deletes old snapshots.
    If the option is set to zero, the garbage collector
    does not delete old snapshots.

    ..  code-block:: lua

        box.cfg{
            checkpoint_interval = 7200,
            checkpoint_count  = 3
        }

    In the example, the checkpoint daemon creates a new snapshot every two hours until
    it has created three snapshots. After creating a new snapshot (the fourth one), the oldest snapshot
    and any associated write-ahead-log files are deleted.

    ..  NOTE::

        Snapshots will not be deleted if replication is ongoing and the file has not been relayed to a replica.
        Therefore, ``checkpoint_count`` has no effect unless all replicas are alive.


    | Type: integer
    | Default: 2
    | Environment variable: TT_CHECKPOINT_COUNT
    | Dynamic: yes

..  _cfg_checkpoint_daemon-checkpoint_wal_threshold:

..  confval:: checkpoint_wal_threshold

    Since version 2.1.2.

    The threshold for the total size in bytes for all WAL files created since the last checkpoint.
    Once the configured threshold is exceeded, the WAL thread notifies the
    :ref:`checkpoint daemon <cfg_checkpoint_daemon>` that it must make a new checkpoint and delete old WAL files.

    This parameter enables administrators to handle a problem that could occur
    with calculating how much disk space to allocate for a partition containing
    WAL files.

    | Type: integer
    | Default: 10^18 (a large number so in effect there is no limit by default)
    | Environment variable: TT_CHECKPOINT_WAL_THRESHOLD
    | Dynamic: yes
