.. _box_introspection-box_cfg:

--------------------------------------------------------------------------------
Submodule `box.cfg`
--------------------------------------------------------------------------------

.. module:: box.cfg

The ``box.cfg`` submodule is used for specifying
:ref:`server configuration parameters <box_cfg_params>`.

To view the current configuration, say ``box.cfg`` without braces:

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

To set particular parameters, use the following syntax: ``box.cfg{key = value [, key = value ...]}``
(further referred to as ``box.cfg{...}`` for short). For example:

.. code-block:: tarantoolsession

    tarantool> box.cfg{listen = 3301}

Parameters that are not specified in the ``box.cfg{...}`` call explicitly will
be set to the :ref:`default values<box_cfg_default>`.

If you say ``box.cfg{}`` with no parameters, Tarantool applies the following
default settings to all the parameters:

.. _box_cfg_default:

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
      net_msg_max                  = 768
      pid_file                     = nil
      readahead                    = 16320
      read_only                    = false
      replication                  = nil
      replication_connect_quorum   = nil
      replication_connect_timeout  = 30
      replication_skip_conflict    = false
      replication_sync_lag         = 10
      replication_sync_timeout     = 300
      replication_timeout          = 1
      slab_alloc_factor            = 1.05
      snap_io_rate_limit           = nil
      too_long_threshold           = 0.5
      username                     = nil
      vinyl_bloom_fpr              = 0.05
      vinyl_cache                  = 128 * 1024 * 1024
      vinyl_dir                    = '.'
      vinyl_max_tuple_size         = 1024 * 1024* 1024 * 1024
      vinyl_memory                 = 128 * 1024 * 1024
      vinyl_page_size              = 8 * 1024
      vinyl_range_size             = nil
      vinyl_read_threads           = 1
      vinyl_run_count_per_level    = 2
      vinyl_run_size_ratio         = 3.5
      vinyl_timeout                = 60
      vinyl_write_threads          = 4
      wal_dir                      = '.'
      wal_dir_rescan_delay         = 2
      wal_max_size                 = 256 * 1024 * 1024
      wal_mode                     = 'write'
      worker_pool_threads          = 4
      work_dir                     = nil

The first call to ``box.cfg{...}`` (with or without parameters) initiates
Tarantool's database module :ref:`box <box-module>`.
To perform any database operations, you must call ``box.cfg{...}`` first.

``box.cfg{...}`` is also the command that reloads
:ref:`persistent data files <index-box_persistence>` into RAM upon restart
once we have data.
