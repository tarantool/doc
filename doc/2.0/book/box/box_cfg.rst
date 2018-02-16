.. _box_introspection-box_cfg:

--------------------------------------------------------------------------------
Submodule `box.cfg`
--------------------------------------------------------------------------------

.. module:: box.cfg

The ``box.cfg`` submodule is for administrators to specify all the
:ref:`server configuration parameters <box_cfg_params>`.

Say ``box.cfg`` without braces to view the current configuration, for example:

.. code-block:: tarantoolsession

    tarantool> box.cfg
    ---
    - checkpoint_count: 2
      too_long_threshold: 0.5
      slab_alloc_factor: 1.1
      memtx_max_tuple_size: 1048576
      background: false
      <...>
    ...

To set the parameters, say ``box.cfg{...}``, for example:

.. code-block:: tarantoolsession

    tarantool> box.cfg{listen = 3301}

If you say ``box.cfg{}`` with no parameters, Tarantool applies default settings:

.. code-block:: tarantoolsession

    tarantool> box.cfg{}
    tarantool> box.cfg
    ---
    - listen               = nil
      memtx_memory         = 256 * 1024 *1024
      memtx_min_tuple_size = 16
      memtx_max_tuple_size = 1024 * 1024
      slab_alloc_factor    = 1.05
      work_dir             = nil
      memtx_dir            = "."
      wal_dir              = "."

      vinyl_dir            = '.'
      vinyl_memory         = 128 * 1024 * 1024
      vinyl_cache          = 128 * 1024 * 1024
      vinyl_max_tuple_size = 1024 * 1024
      vinyl_read_threads   = 1
      vinyl_write_threads  = 2
      vinyl_timeout        = 60
      vinyl_run_count_per_level = 2
      vinyl_run_size_ratio      = 3.5
      vinyl_range_size          = 1024 * 1024 * 1024
      vinyl_page_size           = 8 * 1024
      vinyl_bloom_fpr           = 0.05
      log                  = nil
      log_nonblock         = true
      log_level            = 5
      log_format           = "plain"
      io_collect_interval  = nil
      readahead            = 16320
      snap_io_rate_limit   = nil
      too_long_threshold   = 0.5
      wal_mode             = "write"
      rows_per_wal         = 500000
      wal_max_size         = 256 * 1024 * 1024
      wal_dir_rescan_delay = 2
      force_recovery       = false
      replication          = nil
      custom_proc_title    = nil
      pid_file             = nil
      background           = false
      username             = nil
      coredump             = false
      read_only            = false
      hot_standby          = false
      checkpoint_interval  = 3600
      checkpoint_count     = 2
      worker_pool_threads  = 4
      replication_timeout  = 1
    ...

The first call to ``box.cfg{...}`` (with or without parameters) initiates
Tarantool's database module :ref:`box <box-module>`.
Before Tarantool 2.0, you needed to call ``box.cfg{...}`` prior to performing
any database operations.
Now you can start working with the database outright, without calling
``box.cfg{...}``. In this case, Tarantool initiates the database module and
applies default settings, as if you said ``box.cfg{}`` (without parameters).

``box.cfg{...}`` is also the command that reloads
:ref:`persistent data files <index-box_persistence>` into RAM upon restart
once we have data.
