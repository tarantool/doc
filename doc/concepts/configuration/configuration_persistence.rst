..  _configuration_persistence:

Persistence
===========

To ensure data persistence, Tarantool provides the abilities to:

*   record each data change request into a :ref:`write-ahead log <internals-wal>` (WAL) file (``.xlog`` files)
*   take :ref:`snapshots <internals-snapshot>` that contain on-disk copy of the entire data set for a given moment (``.snap`` files)

During the recovery process, Tarantool can load the latest snapshot file and then read the requests from the WAL files,
produced after this snapshot was made.

To learn more about the persistence mechanism in Tarantool, see the :ref:`Persistence <concepts-data_model-persistence>` section.
The formats of WAL and snapshot files are described in detail in the :ref:`File formats <internals-data_persistence>` section.

..  _configuration_persistence_snapshot:

Configure the snapshots
-----------------------

**Example on GitHub**: `snapshot <https://github.com/tarantool/doc/tree/latest/doc/code_snippets/snippets/config/instances.enabled/persistence_snapshot>`_

This section describes how to define snapshot settings in the :ref:`snapshot <configuration_reference_snapshot>` section of a YAML configuration.

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

..  _configuration_persistence_checkpoint_daemon:

Configure the automatic snapshot creation
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

In Tarantool, it is possible to set automatic :ref:`snapshot creation </reference/reference_lua/box_snapshot>`.
To enable it, the :ref:`snapshot.by.interval <configuration_reference_snapshot_by_interval>` option is used.
The option sets up the :ref:`checkpoint daemon <configuration_reference_checkpoint_daemon>` (snapshot daemon), which is
a constantly running :ref:`fiber <app-fibers>`.
The checkpoint daemon takes new snapshots every ``snapshot.by.interval`` seconds.
When the number of snapshots reaches the limit of :ref:`snapshot.count <configuration_reference_snapshot_count>` size,
the daemon activates Tarantool garbage collector after the new snapshot is taken.
Tarantool garbage collector deletes the oldest snapshot file and any associated WAL files.

The :ref:`snapshot.by.wal_size <configuration_reference_snapshot_by_wal_size>` option defines the maximum size in bytes
for of all WAL files created since the last snapshot taken.
Once this size is exceeded, the checkpoint daemon takes a snapshot and deletes the old WAL files.

The configuration of the checkpoint daemon might look as follows:

..  literalinclude:: /code_snippets/snippets/config/instances.enabled/persistence_snapshot/config.yaml
    :language: yaml
    :start-at: count:
    :end-at: 60
    :dedent:

If the ``snapshot.by.interval`` option is set to zero, the checkpoint daemon is disabled.
If the ``snapshot.count`` option is set to zero, the checkpoint daemon does not delete old snapshots.

..  _configuration_persistence_wal:

Configure the write-ahead log
-----------------------------

**Example on GitHub**: `wal <https://github.com/tarantool/doc/tree/latest/doc/code_snippets/snippets/config/instances.enabled/persistence_wal>`_

This section describes how to define WAL settings in the :ref:`wal <configuration_reference_wal>` section of a YAML configuration.

..  _configuration_persistence_wal_mode:

Set the WAL mode
~~~~~~~~~~~~~~~~

To be able to recover data in case of a possible instance restart, enable recording to the write-ahead log.
To do it, set the :ref:`wal.mode <configuration_reference_wal_mode>` configuration option to ``write`` or ``fsync``.
The example below shows how to specify the ``write`` WAL mode for ``instance001``:

..  literalinclude:: /code_snippets/snippets/config/instances.enabled/persistence_wal/config.yaml
    :language: yaml
    :start-at: instance001
    :end-at: 'write'
    :dedent:

The ``write`` mode enables WAL and writes the data without waiting the data to be flushed to the storage device.
The ``fsync`` mode enables WAL and ensures that the record is written to the storage device.

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

In Tarantool, the :ref:`checkpoint daemon <configuration_reference_checkpoint_daemon>` (snapshot daemon)
takes new snapshots at the given interval (see :ref:`snapshot.by.interval <configuration_reference_snapshot_by_interval>`).
After an instance restart, the daemon activates the Tarantool garbage collector that deletes the old WAL files.

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

In Tarantool Enterprise, you can store an old and new tuple for each crud operation performed.
The detailed description and examples of the WAL extensions are provided in the :ref:`WAL extensions <wal_extensions>` section.

See also: :ref:`wal.ext.* <configuration_reference_wal_ext>` configuration options.
