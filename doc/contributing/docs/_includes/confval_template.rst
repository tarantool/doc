..  confval:: wal_dir

    Since version 1.6.2.
    A directory where write-ahead log (``.xlog``) files are stored.
    Can be relative to ``work_dir``.
    Sometimes wal_dir and memtx_dir are specified with different values,
    so that write-ahead log files and snapshot files can be stored on different disks.
    If not specified, defaults to ``work_dir``.

    | Type: string
    | Default: "."
    | Environment variable: TT_WAL_DIR
    | Dynamic: no
