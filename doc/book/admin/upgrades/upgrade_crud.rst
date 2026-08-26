.. _admin-upgrades-crud:

Upgrading the crud module
=========================

The `crud <https://github.com/tarantool/crud>`_ module is used together with
``vshard`` in sharded clusters. Upgrading ``crud`` has a compatibility limitation
introduced in version 1.7.0.

.. note::
   For the minimum set of privileges required for CRUD operations, see the
   :ref:`Reading and writing data with CRUD <access_control_minimal_priv-crud_read_write>`
   section.

.. _admin-upgrades-crud-safe-mode:

Compatibility limitation during upgrade
---------------------------------------

Starting from ``crud`` 1.7.0, the module automatically switches the cluster to
**safe mode** when vshard
`rebalancing <../../../platform/sharding/vshard_admin#vshard_config_rebalancing>`_
starts. Safe mode prevents writing data to an incorrect replica set during
rebalancing.

The following safe mode specifics should be taken into account:

* safe mode is enabled independently on each storage instance participating in
  rebalancing;
* safe mode is not disabled automatically after rebalancing completes and must
  be disabled explicitly.

To check whether safe mode is enabled on a storage instance:

.. code-block:: bash

   tarantool> _crud.rebalance_safe_mode_status()

or via the ``tnt_crud_storage_safe_mode_enabled`` metric.

.. note::
   The safe mode metric is available only when the ``metrics`` module is
   installed.

To return to normal mode after rebalancing:

1. Wait until bucket migration (vshard rebalancing) is complete.
2. On each router, clear the CRUD routing cache:

   .. code-block:: lua

      crud.rebalance.router_cache_clear()

3. On each storage instance, disable safe mode via the ``_crud`` Storage API.
   The command must be executed on all storage instances, including replicas:

   .. code-block:: lua

      _crud.rebalance_safe_mode_disable()

Requests to spaces that use the ``vinyl`` engine are always executed in safe mode
regardless of the current safe mode status.

When upgrading from crud versions below 1.7.0 to 1.7.0 and later, the following
compatibility limitation applies:

In CRUD 1.7.0–1.7.4, storages require ``bucket_id``. Therefore, ``get``,
``update``, and ``delete`` operations sent by a router running CRUD below 1.7.0
fail with an error. Other operations (``insert``, ``replace``, ``upsert``,
``select``, ``count``) work normally.

Starting from CRUD 1.7.5, storages support compatibility mode with routers below
1.7.0. If ``bucket_id`` is missing, the storage executes the operation without
``bucket ref``, writes a warning to the log, and, if the ``metrics`` module is
installed, also increments
``tnt_crud_storage_nil_bucket_id_compat_total``.

On storages running CRUD 1.7.5+, while not all routers have been upgraded to CRUD
1.7.0 or later, ``get``, ``update``, and ``delete`` operations are executed in
compatibility mode with reduced rebalancing safety. Storages write a warning to
the log and, if the ``metrics`` module is installed, also increment
``tnt_crud_storage_nil_bucket_id_compat_total``.

.. _admin-upgrades-crud-order:

Upgrade order
-------------

When upgrading crud, follow this order:

When upgrading crud to versions below 1.7.0 or to versions starting from 1.7.5,
use the standard upgrade order — first storages, then routers:

1. Upgrade storage replica nodes
2. Upgrade storage master nodes
3. Upgrade routers

.. warning::
   CRUD 1.7.0–1.7.4 releases were withdrawn due to Storage API incompatibility
   with older router versions. Upgrading to these versions is not recommended.
   When upgrading from a version below 1.7.0, upgrade directly to 1.7.5+, without
   using 1.7.0–1.7.4 as intermediate versions.

When upgrading through crud 1.7.0–1.7.4, upgrade routers first and then storages.
Do not run rebalancing until the upgrade is complete:

1. Upgrade routers
2. Upgrade storage replica nodes
3. Upgrade storage master nodes

For details on the standard cluster upgrade order, see
:ref:`the corresponding section <admin-upgrades-replication-cluster>`.
