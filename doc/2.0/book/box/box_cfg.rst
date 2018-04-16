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
    tarantool> box.cfg -- sorted in the alphabetic order
    ---
    - background                   = false
      checkpoint_count             = 2
      checkpoint_interval          = 3600
      coredump                     = false
      custom_proc_title            = nil
      feedback_enabled             = true
      feedback_host                = 'https://feedback.tarantool.io'
      feedback_interval            = 3600
      force_recovery               = false
      hot_standby                  = false
      io_collect_interval          = nil
      listen                       = nil
      log                          = nil
      log_format                   = plain
      log_level                    = 5
      log_nonblock                 = true
      memtx_dir                    = '.'
      memtx_max_tuple_size         = 1024 * 1024
      memtx_memory                 = 256 * 1024 *1024
      memtx_min_tuple_size         = 16
      pid_file                     = nil
      readahead                    = 16320
      read_only                    = false
      replication                  = nil
      replication_connect_timeout  = 4
      replication_sync_lag         = 10
      replication_timeout          = 1
      rows_per_wal                 = 500000
      slab_alloc_factor            = 1.05
      snap_io_rate_limit           = nil
      too_long_threshold           = 0.5
      username                     = nil
      vinyl_bloom_fpr              = 0.05
      vinyl_cache                  = 128
      vinyl_dir                    = '.'
      vinyl_max_tuple_size         = 1024 * 1024* 1024 * 1024
      vinyl_memory                 = 128 * 1024 * 1024
      vinyl_page_size              = 8 * 1024
      vinyl_range_size             = 1024 * 1024 * 1024
      vinyl_read_threads           = 1
      vinyl_run_count_per_level    = 2
      vinyl_run_size_ratio         = 3.5
      vinyl_timeout                = 60
      vinyl_write_threads          = 2
      wal_dir                      = '.'
      wal_dir_rescan_delay         = 2
      wal_max_size                 = 256 * 1024 * 1024
      wal_mode                     = 'write'
      worker_pool_threads          = 4
      work_dir                     = nil

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
