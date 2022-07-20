..  confval:: wal_dir

    Since :tarantool-release:`1.6.2`.
    The directory where write-ahead log (``.xlog``) files are stored.
    Can be relative to :ref:`work_dir <cfg_basic-work_dir>`.
    Sometimes ``wal_dir`` and :ref:`memtx_dir <cfg_basic-memtx_dir>` are specified with different values,
    so that write-ahead log files and snapshot files can be stored on different disks.
    If not specified, defaults to ``work_dir``.

    | Type: string
    | Default: "."
    | Environment variable: TT_WAL_DIR
    | Dynamic: no
