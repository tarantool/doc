.. _whats_new:

********************************************************************************
What's new?
********************************************************************************

Here is a summary of significant changes introduced in specific versions of
Tarantool.

For smaller feature changes and bug fixes, see closed
`milestones <https://github.com/tarantool/tarantool/milestones?state=closed>`_
at GitHub.

.. _whats_new_17:

================================================================================
What's new in Tarantool 1.7?
================================================================================

The disk-based storage engine, which was called `sophia` or `phia`
in earlier versions, is superseded by the `vinyl` storage engine.

There are new types for indexed fields.

The LuaJIT version is updated.

Automatic replica set bootstrap (for easier configuration of a new replica set)
is supported.

The ``space_object:inc()`` function is removed.

The ``space_object:dec()`` function is removed.

The ``box.coredump()`` function is removed, for an alternative see
:ref:`Generating a core file <administration-core>`.

The ``hot_standby`` configuration option is added.

Configuration parameters revised:

* Parameters renamed:

  * ``slab_alloc_arena`` (in gigabytes) to ``memtx_memory`` (in bytes),
  * ``slab_alloc_minimal`` to ``memtx_min_tuple_size``,
  * ``slab_alloc_maximal`` to ``memtx_max_tuple_size``,
  * ``replication_source`` to ``replication``,
  * ``snap_dir`` to ``memtx_dir``,
  * ``logger`` to ``log``,
  * ``logger_nonblock`` to ``log_nonblock``,
  * ``snapshot_count`` to ``checkpoint_count``,
  * ``snapshot_period`` to ``checkpoint_interval``,
  * ``panic_on_wal_error`` and ``panic_on_snap_error`` united under
    ``force_recovery``.

* Until Tarantool 1.8, you can use :ref:`deprecated parameters <cfg_deprecated>`
  for both initial and runtime configuration, but Tarantool will display a warning.
  Also, you can specify both deprecated and up-to-date parameters, provided
  that their values are harmonized. If not, Tarantool will display an error.
