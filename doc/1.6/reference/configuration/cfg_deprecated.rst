.. _cfg_deprecated:

These parameters will be deprecated in Tarantool version 1.7.4:

* :ref:`coredump <cfg_basic-coredump_deprecated>`
* :ref:`logger <cfg_logging-logger_deprecated>`
* :ref:`logger_nonblock <cfg_logging-logger_nonblock_deprecated>`
* :ref:`panic_on_snap_error <cfg_binary_logging_snapshots-panic_on_snap_error_deprecated>`,
* :ref:`panic_on_wal_error <cfg_binary_logging_snapshots-panic_on_wal_error_deprecated>`
* :ref:`replication_source <cfg_replication-replication_source_deprecated>`
* :ref:`slab_alloc_arena <cfg_storage-slab_alloc_arena_deprecated>`
* :ref:`slab_alloc_factor <cfg_storage-slab_alloc_factor_deprecated>`
* :ref:`slab_alloc_maximal <cfg_storage-slab_alloc_maximal_deprecated>`
* :ref:`slab_alloc_minimal <cfg_storage-slab_alloc_minimal_deprecated>`
* :ref:`snap_dir <cfg_basic-snap_dir_deprecated>`
* :ref:`snapshot_count <cfg_snapshot_daemon-snapshot_count_deprecated>`
* :ref:`snapshot_period <cfg_snapshot_daemon-snapshot_period_deprecated>`

.. _cfg_basic-coredump_deprecated:

.. confval:: coredump_deprecated

    **Deprecated**, do not use.

    | Type: boolean
    | Default: false
    | Dynamic: no

.. _cfg_logging-logger_deprecated:

.. confval:: logger_deprecated

    **Deprecated** in 1.6 it is :ref:`logger <cfg_logging-logger>`.
    in 1.7 it will be log. 
    The parameter will only be renamed,
    while the type, values and semantics will remain intact.
    
.. _cfg_logging-logger_nonblock_deprecated:

.. confval:: logger_nonblock_deprecated

    **Deprecated** in 1.6 it is :ref:`logger_nonblock <cfg_logging-logger_nonblock>`.
    in 1.7 it will be log_nonblock.
    The parameter will only be renamed,
    while the type, values and semantics will remain intact.

.. _cfg_binary_logging_snapshots-panic_on_snap_error_deprecated:

.. confval:: panic_on_snap_error_deprecated

    **Deprecated** in 1.6 it is :ref:`panic_on_snap_error <cfg_binary_logging_snapshots-panic_on_snap_error>`,
    in 1.7 it will be force_recovery.

.. _cfg_binary_logging_snapshots-panic_on_wal_error_deprecated:

.. confval:: panic_on_wal_error_deprecated

    **Deprecated** in 1.6 it is :ref:`panic_on_wal_error <cfg_binary_logging_snapshots-panic_on_wal_error>`,
    in 1.7 it will be force_recovery.

.. _cfg_replication-replication_source_deprecated:

.. confval:: replication_source_deprecated

    **Deprecated** in 1.6 it is :ref:`replication_source <cfg_replication-replication_source>`.
    in 1.7 it will be replication.
    The parameter will only be renamed,
    while the type, values and semantics will remain intact.

.. _cfg_storage-slab_alloc_arena_deprecated:

.. confval:: slab_alloc_arena_deprecated

    **Deprecated** in 1.6 it is :ref:`slab_alloc_arena <cfg_storage-slab_alloc_arena>`,
    in 1.7 it will be memtx_memory.
    The parameter will only be renamed,
    while the type, value and semantics will remain intact.
    
.. _cfg_storage-slab_alloc_factor_deprecated:

.. confval:: slab_alloc_factor_deprecated

    **Deprecated** in 1.6 slab_alloc_factor is the multiplier for computing the sizes of memory
    chunks, in 1.7 it will not be used.

.. _cfg_storage-slab_alloc_maximal_deprecated:

.. confval:: slab_alloc_maximal_deprecated

    **Deprecated** in 1.6 it is :ref:`slab_alloc_maximal <cfg_storage-slab_alloc_maximal>`,
    in 1.7 it will be memtx_max_tuple_size.
    The parameter will only be renamed,
    while the type, values and semantics will remain intact.

.. _cfg_storage-slab_alloc_minimal_deprecated:

.. confval:: slab_alloc_minimal_deprecated

    **Deprecated** in 1.6 it is :ref:`slab_alloc_minimal <cfg_storage-slab_alloc_minimal>`,
    in 1.7 it will be memtx_min_tuple_size.
    The parameter will only be renamed,
    while the type, values and semantics will remain intact.

.. _cfg_basic-snap_dir_deprecated:

.. confval:: snap_dir_deprecated

    **Deprecated** in 1.6 it is :ref:`snap_dir <cfg_basic-snap_dir>`,
    in 1.7 it will be memtx_dir.
    The parameter will only be renamed,
    while the type, values and semantics will remain intact.

.. _cfg_snapshot_daemon-snapshot_period_deprecated:

.. confval:: snapshot_period_deprecated

    **Deprecated** in 1.6 it is :ref:`snapshot_period <cfg_snapshot_daemon-snapshot_period>`,
    in 1.7 it will be checkpoint_interval.
    The parameter will only be renamed,
    while the type, values and semantics will remain intact.

.. _cfg_snapshot_daemon-snapshot_count_deprecated:

.. confval:: snapshot_count_deprecated

    **Deprecated** in 1.6 it is :ref:`snapshot_count <cfg_snapshot_daemon-snapshot_count>`.
    in 1.7 it will be checkpoint_count.
    The parameter will only be renamed,
    while the type, values and semantics will remain intact.
