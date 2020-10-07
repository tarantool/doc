* :ref:`force_recovery <cfg_binary_logging_snapshots-force_recovery>`,
* :ref:`rows_per_wal <cfg_binary_logging_snapshots-rows_per_wal>`,
* :ref:`wal_max_size <cfg_binary_logging_snapshots-wal_max_size>`,
* :ref:`snap_io_rate_limit <cfg_binary_logging_snapshots-snap_io_rate_limit>`,
* :ref:`wal_mode <cfg_binary_logging_snapshots-wal_mode>`,
* :ref:`wal_dir_rescan_delay <cfg_binary_logging_snapshots-wal_dir_rescan_delay>`

.. _cfg_binary_logging_snapshots-force_recovery:

.. confval:: force_recovery

    Since version 1.7.4.
    If ``force_recovery`` equals true, Tarantool tries to continue if there is
    an error while reading a :ref:`snapshot file<index-box_persistence>`
    (at server instance start) or a :ref:`write-ahead log file<internals-wal>`
    (at server instance start or when applying an update at a replica): skips
    invalid records, reads as much data as possible and lets the process finish
    with a warning. Users can prevent the error from recurring by writing to
    the database and executing :ref:`box.snapshot() <box-snapshot>`.    

    Otherwise, Tarantool aborts recovery if there is an error while reading.

    | Type: boolean
    | Default: false
    | Dynamic: no

.. _cfg_binary_logging_snapshots-rows_per_wal:

.. confval:: rows_per_wal

    Since version 1.6.2.
    How many log records to store in a single write-ahead log file.
    When this limit is reached, Tarantool creates another WAL file
    named :samp:`{<first-lsn-in-wal>}.xlog`. This can be useful for
    simple rsync-based backups.

    | Type: integer
    | Default: 500000
    | Dynamic: no

.. _cfg_binary_logging_snapshots-wal_max_size:

.. confval:: wal_max_size

    Since version 1.7.4.
    The maximum number of bytes in a single write-ahead log file.
    When a request would cause an .xlog file to become larger than
    ``wal_max_size``, Tarantool creates another WAL file --
    the same effect that happens when the
    :ref:`rows_per_wal <cfg_binary_logging_snapshots-rows_per_wal>`
    limit is reached.

    | Type: integer
    | Default: 268435456 (256 * 1024 * 1024) bytes
    | Dynamic: no

.. _cfg_binary_logging_snapshots-snap_io_rate_limit:

.. confval:: snap_io_rate_limit

    Since version 1.4.9.
    Reduce the throttling effect of :ref:`box.snapshot <box-snapshot>` on
    INSERT/UPDATE/DELETE performance by setting a limit on how many
    megabytes per second it can write to disk. The same can be
    achieved by splitting :ref:`wal_dir <cfg_basic-wal_dir>` and
    :ref:`memtx_dir <cfg_basic-memtx_dir>`
    locations and moving snapshots to a separate disk.
    The limit also affects what
    :ref:`box.stat.vinyl().regulator <box_introspection-box_stat_vinyl_regulator>`
    may show for the write rate of dumps to .run and .index files.

    | Type: float
    | Default: null
    | Dynamic: **yes**

.. _cfg_binary_logging_snapshots-wal_mode:

.. confval:: wal_mode

    Since version 1.6.2. Specify fiber-WAL-disk synchronization mode as:

    * ``none``: write-ahead log is not maintained;
    * ``write``: :ref:`fibers <fiber-fibers>` wait for their data to be written to
      the write-ahead log (no :manpage:`fsync(2)`);
    * ``fsync``: fibers wait for their data, :manpage:`fsync(2)`
      follows each :manpage:`write(2)`;

    | Type: string
    | Default: "write"
    | Dynamic: no

.. _cfg_binary_logging_snapshots-wal_dir_rescan_delay:

.. confval:: wal_dir_rescan_delay

    Since version 1.6.2.
    Number of seconds between periodic scans of the write-ahead-log
    file directory, when checking for changes to write-ahead-log
    files for the sake of :ref:`replication <replication>` or :ref:`hot standby <index-hot_standby>`.

    | Type: float
    | Default: 2
    | Dynamic: no
