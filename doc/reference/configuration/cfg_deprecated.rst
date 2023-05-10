.. _cfg_deprecated:

These parameters are deprecated since Tarantool version 1.7.4:

* :ref:`coredump <cfg_basic-coredump_deprecated>`
* :ref:`logger <cfg_logging-logger_deprecated>`
* :ref:`logger_nonblock <cfg_logging-logger_nonblock_deprecated>`
* :ref:`panic_on_snap_error <cfg_binary_logging_snapshots-panic_on_snap_error_deprecated>`,
* :ref:`panic_on_wal_error <cfg_binary_logging_snapshots-panic_on_wal_error_deprecated>`
* :ref:`replication_source <cfg_replication-replication_source_deprecated>`
* :ref:`slab_alloc_arena <cfg_storage-slab_alloc_arena_deprecated>`
* :ref:`slab_alloc_maximal <cfg_storage-slab_alloc_maximal_deprecated>`
* :ref:`slab_alloc_minimal <cfg_storage-slab_alloc_minimal_deprecated>`
* :ref:`snap_dir <cfg_basic-snap_dir_deprecated>`
* :ref:`snapshot_count <cfg_checkpoint_daemon-snapshot_count_deprecated>`
* :ref:`snapshot_period <cfg_checkpoint_daemon-snapshot_period_deprecated>`
* :ref:`rows_per_wal <cfg_binary_logging_snapshots-rows_per_wal>`
* :ref:`election_fencing_enabled <cfg_election-election_fencing_enabled_deprecated>`

.. _cfg_basic-coredump_deprecated:

.. confval:: coredump

    **Deprecated**, do not use.

    | Type: boolean
    | Default: false
    | Dynamic: no

.. _cfg_logging-logger_deprecated:

.. confval:: logger

    **Deprecated** in favor of :ref:`log <cfg_logging-log>`.
    The parameter was only renamed,
    while the type, values and semantics remained intact.
    
.. _cfg_logging-logger_nonblock_deprecated:

.. confval:: logger_nonblock

    **Deprecated** in favor of :ref:`log_nonblock <cfg_logging-log_nonblock>`.
    The parameter was only renamed,
    while the type, values and semantics remained intact.

.. _cfg_binary_logging_snapshots-panic_on_snap_error_deprecated:

.. confval:: panic_on_snap_error

    **Deprecated** in favor of
    :ref:`force_recovery <cfg_binary_logging_snapshots-force_recovery>`.

    If there is an error while reading a snapshot file
    (at server instance start), abort.

    | Type: boolean
    | Default: true
    | Dynamic: no

.. _cfg_binary_logging_snapshots-panic_on_wal_error_deprecated:

.. confval:: panic_on_wal_error

    **Deprecated** in favor of
    :ref:`force_recovery <cfg_binary_logging_snapshots-force_recovery>`.

    | Type: boolean
    | Default: true
    | Dynamic: yes

.. _cfg_replication-replication_source_deprecated:

.. confval:: replication_source

    **Deprecated** in favor of
    :ref:`replication <cfg_replication-replication>`.
    The parameter was only renamed,
    while the type, values and semantics remained intact.

.. _cfg_storage-slab_alloc_arena_deprecated:

.. confval:: slab_alloc_arena

    **Deprecated** in favor of
    :ref:`memtx_memory <cfg_storage-memtx_memory>`.
    
    How much memory Tarantool allocates to actually store tuples, **in gigabytes**.
    When the limit is reached, INSERT or UPDATE requests begin failing with
    error :errcode:`ER_MEMORY_ISSUE`. While the server does not go beyond the
    defined limit to allocate tuples, there is additional memory used to store
    indexes and connection information. Depending on actual configuration and
    workload, Tarantool can consume up to 20% more than the limit set here.

    | Type: float
    | Default: 1.0
    | Dynamic: no

.. _cfg_storage-slab_alloc_maximal_deprecated:

.. confval:: slab_alloc_maximal

    **Deprecated** in favor of
    :ref:`memtx_max_tuple_size <cfg_storage-memtx_max_tuple_size>`.
    The parameter was only renamed,
    while the type, values and semantics remained intact.

.. _cfg_storage-slab_alloc_minimal_deprecated:

.. confval:: slab_alloc_minimal

    **Deprecated** in favor of
    :ref:`memtx_min_tuple_size <cfg_storage-memtx_min_tuple_size>`.
    The parameter was only renamed,
    while the type, values and semantics remained intact.

.. _cfg_basic-snap_dir_deprecated:

.. confval:: snap_dir

    **Deprecated** in favor of :ref:`memtx_dir <cfg_basic-memtx_dir>`.
    The parameter was only renamed,
    while the type, values and semantics remained intact.

.. _cfg_checkpoint_daemon-snapshot_period_deprecated:

.. confval:: snapshot_period

    **Deprecated** in favor of
    :ref:`checkpoint_interval <cfg_checkpoint_daemon-checkpoint_interval>`.
    The parameter was only renamed,
    while the type, values and semantics remained intact.

.. _cfg_checkpoint_daemon-snapshot_count_deprecated:

.. confval:: snapshot_count

    **Deprecated** in favor of
    :ref:`checkpoint_count <cfg_checkpoint_daemon-checkpoint_count>`.
    The parameter was only renamed,
    while the type, values and semantics remained intact.

.. _cfg_binary_logging_snapshots-rows_per_wal:

.. confval:: rows_per_wal

    **Deprecated** in favor of
    :ref:`wal_max_size <cfg_binary_logging_snapshots-wal_max_size>`.
    The parameter does not allow to properly limit size of WAL logs.

.. _cfg_election-election_fencing_enabled_deprecated:

.. confval:: election_fencing_enabled

    **Deprecated** in Tarantool v2.11 in favor of
    :ref:`election_fencing_mode <cfg_replication-election_fencing_mode>`.

    The parameter does not allow using the ``strict`` fencing mode. Setting to ``true``
    is equivalent to setting the ``soft``
    :ref:`election_fencing_mode <cfg_replication-election_fencing_mode>`.
    Setting to ``false`` is equivalent to setting the ``off``
    :ref:`election_fencing_mode <cfg_replication-election_fencing_mode>`.

    | Type: boolean
    | Default: true
    | Environment variable: TT_ELECTION_FENCING_ENABLED
    | Dynamic: yes
