..  _configuration_persistence:

Persistence
===========

To ensure data persistence, Tarantool provides the abilities to:

*   Record each data change request into a :ref:`write-ahead log <internals-wal>` (WAL) file (``.xlog`` files).
*   Take :ref:`snapshots <internals-snapshot>` that contain on-disk copy of the entire data set for a given moment
    (``.snap`` files). It is possible to set automatic snapshot creation using the :ref:`checkpoint daemon <configuration_persistence_checkpoint_daemon>`.

During the recovery process, Tarantool can load the latest snapshot file and then read the requests from the WAL files,
produced after this snapshot was made.

To learn more about the persistence mechanism in Tarantool, see the :ref:`Persistence <concepts-data_model-persistence>` section.
The formats of WAL and snapshot files are described in detail in the :ref:`File formats <internals-data_persistence>` section.

..  _configuration_persistence_snapshot:

Configure the snapshots
-----------------------

**Example on GitHub**: `snapshot <https://github.com/tarantool/doc/tree/latest/doc/code_snippets/snippets/config/instances.enabled/persistence_snapshot>`_

This section describes how to define snapshot settings in the :ref:`snapshot <configuration_reference_snapshot>` section of a YAML configuration.

..  _configuration_persistence_snapshot_creation:

Set up automatic snapshot creation
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

In Tarantool, it is possible to automate the :ref:`snapshot creation </reference/reference_lua/box_snapshot>`.
Automatic creation is enabled by default and can be configured in two ways:

*   A new snapshot is taken once in a given period (see :ref:`snapshot.by.interval <configuration_reference_snapshot_by_interval>`).
*   A new snapshot is taken once the size of all WAL files created since the last snapshot exceeds a given limit
    (see :ref:`snapshot.by.wal_size <configuration_reference_snapshot_by_wal_size>`).

The ``snapshot.by.interval`` option sets up the :ref:`checkpoint daemon <configuration_persistence_checkpoint_daemon>`
that takes a new snapshot every ``snapshot.by.interval`` seconds.
If the ``snapshot.by.interval`` option is set to zero, the checkpoint daemon is disabled.

The ``snapshot.by.wal_size`` option defines the maximum size in bytes for of all WAL files created since the last snapshot taken.
Once this size is exceeded, the checkpoint daemon takes a snapshot. Then, :ref:`Tarantool garbage collector <configuration_persistence_garbage_collector>`
deletes the old WAL files.

The example shows how to specify the ``snapshot.by.interval`` and the ``snapshot.by.wal_size`` options:

..  literalinclude:: /code_snippets/snippets/config/instances.enabled/persistence_snapshot/config.yaml
    :language: yaml
    :start-at: by:
    :end-at: 1000000000000000000
    :dedent:

..  _configuration_persistence_snapshot_dir:

Specify a directory for snapshot files
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

To configure a directory where the snapshot files are stored, use the :ref:`snapshot.dir <configuration_reference_snapshot_dir>`
configuration option.
The example below shows how to specify a snapshot directory for ``instance001`` explicitly:

..  literalinclude:: /code_snippets/snippets/config/instances.enabled/persistence_snapshot/config.yaml
    :language: yaml
    :start-at: instance001:
    :end-at: 'var/lib/{{ instance_name }}/snapshots'
    :dedent:

By default, WAL files and snapshot files are stored in the same directory ``var/lib/{{ instance_name }}``.
However, you can specify different directories for them.
For example, you can place snapshots and write-ahead logs on different hard drives for better reliability:

..  code-block:: yaml

    instance001:
      snapshot:
        dir: '/media/drive1/snapshots'
      wal:
        dir: '/media/drive2/wals'

..  _configuration_persistence_snapshot_count:

Configure a maximum number of stored snapshots
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

You can set a limit on the number of snapshots stored in the :ref:`snapshot.dir <configuration_reference_snapshot_dir>`
directory using the :ref:`snapshot.count <configuration_reference_snapshot_count>` option.
Once the number of snapshots reaches the given limit, :ref:`Tarantool garbage collector <configuration_persistence_garbage_collector>`
deletes the oldest snapshot file and any associated WAL files after the new snapshot is taken.

..  literalinclude:: /code_snippets/snippets/config/instances.enabled/persistence_snapshot/config.yaml
    :language: yaml
    :start-at: count:
    :end-at: 7200
    :dedent:

In the example, the snapshot is created every two hours (every 7200 seconds) until there are three snapshots in the
``snapshot.dir`` directory.
After creating a new snapshot (the fourth one), the oldest snapshot and the corresponding WALs are deleted.

If the ``snapshot.count`` option is set to zero, the garbage collector does not delete old snapshots.

..  _configuration_persistence_wal:

Configure the write-ahead log
-----------------------------

**Example on GitHub**: `wal <https://github.com/tarantool/doc/tree/latest/doc/code_snippets/snippets/config/instances.enabled/persistence_wal>`_

This section describes how to define WAL settings in the :ref:`wal <configuration_reference_wal>` section of a YAML configuration.

..  _configuration_persistence_wal_mode:

Set the WAL mode
~~~~~~~~~~~~~~~~

The recording to the write-ahead log is enabled by default.
It means that if an instance restart occurs, the data will be recovered.
The recording to the WAL can be configured using the :ref:`wal.mode <configuration_reference_wal_mode>` configuration option.

There are two modes that enable writing to the WAL:

*   ``write`` (default) -- enable WAL and write the data without waiting the data to be flushed to the storage device.
*   ``fsync`` -- enable WAL and ensure that the record is written to the storage device.

The example below shows how to specify the ``write`` WAL mode for ``instance001``:

..  literalinclude:: /code_snippets/snippets/config/instances.enabled/persistence_wal/config.yaml
    :language: yaml
    :start-at: instance001
    :end-at: 'write'
    :dedent:

To turn the WAL writer off, set the ``wal.mode`` option to ``none``.

..  _configuration_persistence_wal_dir:

Specify a directory for WAL files
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

To configure a directory where the WAL files are stored, use the :ref:`wal.dir <configuration_reference_wal_dir>` configuration option.
The example below shows how to specify a directory for ``instance001`` explicitly:

..  literalinclude:: /code_snippets/snippets/config/instances.enabled/persistence_wal/config.yaml
    :language: yaml
    :start-at: wal:
    :end-at: 'var/lib/{{ instance_name }}/wals'
    :dedent:


..  _configuration_persistence_wal_rescan:

Set an interval between scans
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

If case of :ref:`replication <replication>` or :ref:`hot standby <index-hot_standby>` mode,
Tarantool scans for changes in the WAL files every :ref:`wal.dir_rescan_delay <configuration_reference_wal_dir_rescan_delay>`
seconds. The example below shows how to specify the interval between scans:

..  literalinclude:: /code_snippets/snippets/config/instances.enabled/persistence_wal/config.yaml
    :language: yaml
    :start-at: dir_rescan_delay
    :end-before: cleanup_delay
    :dedent:

..  _configuration_persistence_wal_maxsize:

Set a maximum size for the WAL file
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

A new WAL file is created when the current one reaches the :ref:`wal.max_size <configuration_reference_wal_max_size>`
size. The configuration for this option might look as follows:

..  literalinclude:: /code_snippets/snippets/config/instances.enabled/persistence_wal/config.yaml
    :language: yaml
    :start-at: max_size
    :end-at: 268435456
    :dedent:

..  _configuration_persistence_wal_rescan:

Set a delay for the garbage collector
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

In Tarantool, the :ref:`checkpoint daemon <configuration_persistence_checkpoint_daemon>`
takes new snapshots at the given interval (see :ref:`snapshot.by.interval <configuration_reference_snapshot_by_interval>`).
After an instance restart, the Tarantool garbage collector deletes the old WAL files.

To delay the immediate deletion of WAL files, use the :ref:`wal.cleanup_delay <configuration_reference_wal_cleanup_delay>`
configuration option. The delay eliminates possible erroneous situations when the master deletes WALs
needed by :ref:`replicas <replication-roles>` after restart.
As a consequence, replicas sync with the master faster after its restart and
don't need to download all the data again.

In the example, the delay is set to 5 hours (18000 seconds):

..  literalinclude:: /code_snippets/snippets/config/instances.enabled/persistence_wal/config.yaml
    :language: yaml
    :start-at: cleanup_delay
    :end-at: 18000
    :dedent:

..  _configuration_persistence_wal_ext:

Specify the WAL extensions
~~~~~~~~~~~~~~~~~~~~~~~~~~

In Tarantool Enterprise, you can store an old and new tuple for each CRUD operation performed.
The detailed description and examples of the WAL extensions are provided in the :ref:`WAL extensions <wal_extensions>` section.

See also: :ref:`wal.ext.* <configuration_reference_wal_ext>` configuration options.

..  _configuration_persistence_checkpoint_daemon:

Checkpoint daemon
-----------------

The checkpoint daemon (snapshot daemon) is a constantly running :ref:`fiber <app-fibers>`.
The checkpoint daemon creates a schedule for the periodic snapshot creation based on
the :ref:`configuration options <configuration_reference_snapshot_by>`and the speed of file size growth.
If enabled, the daemon makes new snapshots (``.snap``) files according to this schedule.

The work of checkpoint daemon is based on the following configuration options:

*   :ref:`snapshot.by.interval <configuration_reference_snapshot_by_interval>` -- a new snapshot is taken once in a given period.
*   :ref:`snapshot.by.wal_size <configuration_reference_snapshot_by_wal_size>` -- a new snapshot is taken once the size
    of all WAL files created since the last snapshot exceeds a given limit.

If necessary, the checkpoint daemon also activates the :ref:`Tarantool garbage collector <configuration_persistence_garbage_collector>` that deletes old snapshot and WAL files.

..  _configuration_persistence_garbage_collector:

Tarantool garbage collector
---------------------------

Tarantool garbage collector can be activated by the :ref:`checkpoint daemon <configuration_persistence_checkpoint_daemon>`.
The garbage collector tracks the snapshots that are to be :ref:`relayed to a replica <memtx-replication>` or needed
by other consumers. When the files are no longer needed, Tarantool garbage collector deletes them.

..  NOTE::

    The garbage collector called by the checkpoint daemon, is distinct from the `Lua garbage collector <https://www.lua.org/manual/5.1/manual.html#2.10>`_
    which is for Lua objects, and distinct from the Tarantool garbage collector that specializes in :ref:`handling shard buckets <vshard-gc>`.

This garbage collector is called as follows:

*   When the number of snapshots reaches the limit of :ref:`snapshot.count <configuration_reference_snapshot_count>` size.
    After a new snapshot is taken, Tarantool garbage collector deletes the oldest snapshot file and any associated WAL files.

*   When the size of all WAL files created since the last snapshot reaches the limit of :ref:`snapshot.by.wal_size <configuration_reference_snapshot_by_wal_size>`.
    Once this size is exceeded, the checkpoint daemon takes a snapshot, then the garbage collector deletes the old WAL files.

If an old snapshot filen is deleted, the Tarantool garbage collector also deletes
any :ref:`write-ahead log (.xlog) <internals-wal>` files that meet the following conditions:

*   The WAL files are older than the snapshot file.
*   The WAL files contain information present in the snapshot file.

Tarantool garbage collector also deletes obsolete vinyl ``.run`` files.

Tarantool garbage collector doesn't delete a file in the following cases:

*   A **backup** is running, and the file has not been backed up
    (see :ref:`"Hot backup" <admin-backups-hot_backup_vinyl_memtx>`).

*   **Replication** is running, and the file has not been relayed to a replica
    (see :ref:`"Replication architecture" <replication-architecture>`),

*   A replica is connecting.

*   A replica has fallen behind.
    The progress of each replica is tracked; if a replica's position is far
    from being up to date, then the server stops to give it a chance to catch up.
    If an administrator concludes that a replica is permanently down, then the
    correct procedure is to restart the server, or (preferably) :ref:`remove the replica from the cluster <replication-remove_instances>`.
