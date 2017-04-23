.. _whats_new:

********************************************************************************
What's new?
********************************************************************************

Here is a summary of significant changes introduced in specific versions of
Tarantool.

For smaller feature changes and bug fixes, see closed
`milestones <https://github.com/tarantool/tarantool/milestones?state=closed>`_
at GitHub.

.. _whats_new_16:

================================================================================
What's new in Tarantool 1.6?
================================================================================

Tarantool 1.6 is no longer getting major new features,
although it will be maintained.
The developers are concentrating on Tarantool version 1.7.


.. _whats_new_17:

================================================================================
What's new in Tarantool 1.7?
================================================================================

This section is about a later version of Tarantool -- what will be in Tarantool 1.7.
Readers should be aware of what is coming, but not expect
to see further discussion in this manual, which is for Tarantool 1.6.
There is a separate manual for Tarantool 1.7.

The disk-based storage engine, which is called `sophia` in 1.6,
will be superseded by the `vinyl` storage engine.

There will be new types for indexed fields.

The LuaJIT version will be updated.

Automatic replica set bootstrap (for easier configuration of a new replica set)
is supported.

The ``space_object:inc()`` function will be removed.

The ``space_object:dec()`` function will be removed.

The ``space_object:bsize()`` function will be added.

The ``box.coredump()`` function will be removed, for an alternative see
:ref:`Core dumps <admin-core_dumps>`.

The ``hot_standby`` configuration option will be added.

Configuration parameters revised:

* Parameters renamed:

  * ``slab_alloc_arena`` (in gigabytes) will be renamed in 1.7 to ``memtx_memory`` (in bytes),
  * ``slab_alloc_minimal`` will be renamed in 1.7 to ``memtx_min_tuple_size``,
  * ``slab_alloc_maximal`` will be renamed in 1.7 to ``memtx_max_tuple_size``,
  * ``replication_source`` will be renamed in 1.7 to ``replication``,
  * ``snap_dir`` will be renamed in 1.7 to ``memtx_dir``,
  * ``logger`` will be renamed in 1.7 to ``log``,
  * ``logger_nonblock`` will be rename in 1.7 to ``log_nonblock``,
  * ``snapshot_count`` will be renamed in 1.7 to ``checkpoint_count``,
  * ``snapshot_period`` will be renamed in 1.7 to ``checkpoint_interval``,
  * ``panic_on_wal_error`` and ``panic_on_snap_error`` will be united in 1.7 under
    ``force_recovery``.

* Until Tarantool 1.8, you can use :ref:`deprecated parameters <cfg_deprecated>`
  for both initial and runtime configuration, but Tarantool will display a warning.
  Also, you can specify both deprecated and up-to-date parameters, provided
  that their values are harmonized. If not, Tarantool will display an error.
