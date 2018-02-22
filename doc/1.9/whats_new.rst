.. _whats_new:

********************************************************************************
What's new?
********************************************************************************

Here is a summary of significant changes introduced in specific versions of
Tarantool.

For smaller feature changes and bug fixes, see closed
`milestones <https://github.com/tarantool/tarantool/milestones?state=closed>`_
at GitHub.

.. _whats_new_176:

--------------------------------------------------------------------------------
What's new in Tarantool 1.7.6?
--------------------------------------------------------------------------------

Tarantool 1.7.6 was
`released <https://github.com/tarantool/tarantool/releases/tag/1.7.6>`_
on November 7, 2017.

In addition to :ref:`rollback <box-rollback>` of a transaction, there is now
rollback to a defined point within a transaction --
:ref:`savepoint <box-savepoint>` support.

There is a new object type: :ref:`sequences <index-box_sequence>`.
The older option, :ref:`auto-increment <box_space-auto_increment>`,
will be deprecated.

String indexes can have :ref:`collations <index-collation>`.

New options are available for:

* :ref:`net_box <net_box-module>` (timeouts),
* :ref:`string <string-module>` functions,
* space :ref:`formats <box_space-format>` (user-defined field names and types),
* :ref:`base64 <digest-base64_encode>` (``urlsafe`` option), and
* index :ref:`creation <box_space-create_index>` (collation,
  :ref:`is-nullable <box_space-is_nullable>`,
  field names).

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

The ``space_object:bsize()`` function is added.

The ``box.coredump()`` function is removed, for an alternative see
:ref:`Core dumps <admin-core_dumps>`.

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

.. _whats_new_169:

--------------------------------------------------------------------------------
What's new in Tarantool 1.6.9?
--------------------------------------------------------------------------------

Since February 15, 2017, due to Tarantool issue#2040
`Remove sophia engine from 1.6 <https://github.com/tarantool/tarantool/issues/2040>`_
there no longer is a storage engine named `sophia`.
It will be superseded in version 1.7 by the `vinyl` storage engine.

.. _whats_new_16:

================================================================================
What's new in Tarantool 1.6?
================================================================================

Tarantool 1.6 is no longer getting major new features,
although it will be maintained.
The developers are concentrating on Tarantool version 1.9.

