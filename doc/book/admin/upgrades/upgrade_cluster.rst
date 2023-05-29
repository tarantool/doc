
..  _admin-upgrades_replication_cluster:

Replication cluster upgrade
===========================

Below are the general instructions for upgrading a Tarantool cluster with replication.
Upgrading from some versions can involve certain specifics. You can find
instructions for individual versions :ref:`in this list <admin-upgrades_version_specifics>`.

..  important::

    The only way to upgrade Tarantool from version 1.6, 1.7, or 1.9 to 2.x **without downtime** is
    taking an intermediate step by upgrading to 1.10 and then to 2.x.

    Before upgrading Tarantool from 1.6 to 2.x, please read about the associated
    :ref:`caveats <admin-upgrades-1.6-1.10>`.

Instances of a replication cluster can be upgraded without downtime one by one due
to redundancy. When you disconnect a node, there still remain nodes that serve the
same purpose: store the same data buckets or work as a router.

The high-level steps of cluster upgrade are the following:

#.  :ref:`Ensure the application compatibility <upgrade_cluster-check-app>` with
    the target Tarantool version.
#.  :ref:`Check the cluster health <upgrade_cluster-pre-check>`.
#.  :ref:`Install the target Tarantool version <upgrade_cluster-install>` on the
    cluster nodes.
#.  :ref:`Upgrade router <upgrade_cluster-routers>` nodes one by one.
#.  :ref:`Upgrade storage replicasets <upgrade_cluster-storage>`one by one.

The detailed upgrade instructions contain repeating steps, such as replication check
that should be performed several times during upgrade. These steps are described
in the :ref:`Procedures and checks <upgrade_cluster-procedure>` section.

If you experience issues during upgrade, you can roll back to the source version.
The rollback instructions are provided in the :ref:`Rollback <upgrade_cluster-rollback>`
section.

.. _upgrade_cluster-check-app:

Checking your application
-------------------------

..  include:: ./../_includes/upgrade_check_app.rst


.. _upgrade_cluster-pre-check:

Pre-upgrade checks
------------------

Perform these steps before the upgrade to ensure that your cluster is working correctly:

#.  Check the cluster health:

    *   On each ``router`` instance, perform the :ref:`vshard.router check <upgrade_router_check>`.
    *   On each ``storage`` instance, perform the :ref:`replication check <upgrade_replication_check>`.
    *   On each ``storage`` instance, perform the :ref:`vshard.storage check <upgrade_storage_check>`.

#.  Check all instances' logs for errors.

If you find issues during these checks before the upgrade, make sure to fix them
before starting the upgrade procedure.

Upgrading a Tarantool cluster with no downtime
----------------------------------------------

.. _upgrade_cluster-install:

Installing target version
~~~~~~~~~~~~~~~~~~~~~~~~~

Install the target Tarantool version on all hosts of the cluster. You can do this
using a package manager or the :ref:`tt utility <tt-cli>`.
See the installation instructions at Tarantool `download page <http://tarantool.org/download.html>`_
and in the :ref:`tt install reference <tt-install>`.

Check that the target Tarantool version is installed by running ``tarantool -v``.


.. _upgrade_cluster-routers:

Upgrading routers
~~~~~~~~~~~~~~~~~

Upgrade **router** instances one by one:

#.  Stop one ``router`` instance.
#.  Start this instance on the target Tarantool version.
#.  Repeat previous steps for each ``router`` instance.
#.  On each ``router`` instance, perform the :ref:`vshard.router check <upgrade_router_check>`.


.. _upgrade_cluster-storages:

Upgrading storages
~~~~~~~~~~~~~~~~~~

To upgrade **storage** instances, perform the following steps on each replicaset:

#.  Disable failover.
#.  Disable rebalancer.
#.  Make sure that the Cartridge ``upgrade_schema`` :doc:`option </book/cartridge/cartridge_api/modules/cartridge/#cfg-opts-box-opts>`
    is disabled.
#.  Pick a **read-only** instance from the replicaset and restart it on the target
    Tarantool version. Wait until it reaches the ``running`` status (``box.info.status == running``).
#.  Perform the :ref:`replication check <upgrade_replication_check>` on each
    instance of the replicaset.
#.  Restart all other **read-only** instances of the replicaset on the target
    version one by one.
#.  Perform the :ref:`replication check <upgrade_replication_check>` on each
    instance of the replicaset.
#.  Make one of the updated replicas the new master:

    *   :ref:`Switch master <upgrade_switch_master>`
    *   Perform the :ref:`replication check <upgrade_replication_check>` on each
        instance of the replicaset

    .. warning::

        This step is the no-return point for upgrading from version 1.6.

#.  Restart the last instance of the replicaset (the former master, now
    a read-only instance) on the target version.
#.  Perform the :ref:`replication check <upgrade_replication_check>` on each
    instance of the replicaset.
#.  Run :ref:`box.schema.upgrade() <box_schema-upgrade>` on the new master.
    This will update the Tarantool system spaces to match the currently installed
    version of Tarantool. There is no need  to run ``box.schema.upgrade()`` on every
    node: changes are propagated to other nodes via the regular replication mechanism.

    .. warning::

        This step is the no-return point.

    .. NOTE::

        To undo schema upgrade in a case of failed upgrade, you can use :ref:`box.schema.downgrade() <box_schema-downgrade>`.

#.  Run ``box.snapshot()`` on every node in the replica set to make sure that the
    replicas immediately see the upgraded database state in case of restart.

Post-upgrade checks
-------------------

#.  On each ``router`` instance, perform the :ref:`vshard.router check <upgrade_router_check>`.
#.  Check all instance logs for errors.
#.  Enable rebalancer.
#.  Enable failover.


.. _upgrade_cluster-rollback:

Rollback
--------


.. _upgrade_cluster-procedures:

Procedures and checks
---------------------

.. _upgrade_replication_check:

Replication check
~~~~~~~~~~~~~~~~~

Run ``box.info``:

    ..  code-block:: tarantoolsession

        box.info

Check that the following conditions are satisfied:

*   ``box.info.status == running``
*   ``box.info.replication[*].status == running``
*   ``box.info.replication`` doesn't contain ``stopped`` or ``error`` statuses
*   ``box.info.replication[*].upstream.lag`` values don't exceed one second

Then run ``box.info`` once more and check that ``box.info.replication[*].upstream.lag``
values are updated.


.. _upgrade_storage_check:

vshard.storage check
~~~~~~~~~~~~~~~~~~~~

Run ``vshard.storage.info()``:

    ..  code-block:: tarantoolsession

        vshard.storage.info()

Check that the following conditions are satisfied:

*   there are no issues or alerts
*   replication status is ``healthy``

.. _upgrade_router_check:

vshard.router check
~~~~~~~~~~~~~~~~~~~

Run ``vshard.router.info()``:

    ..  code-block:: tarantoolsession

        vshard.router.info()

Check that the following conditions are satisfied:

*   there are no issues or alerts
*   all buckets are available (the sum of ``available_rw`` on all replicas equals
    the total number of buckets)

Disabling failover
~~~~~~~~~~~~~~~~~~

Enabling failover
~~~~~~~~~~~~~~~~~~

Disabling rebalancer
~~~~~~~~~~~~~~~~~~~~

Enabling rebalancer
~~~~~~~~~~~~~~~~~~~~

..  _upgrade_switch_master:

Switching the master
~~~~~~~~~~~~~~~~~~~~

Restoring xlog
~~~~~~~~~~~~~~


Pre-upgrade old
---------------

.. // old check

#.  Check the replica set health by running the following code on every instance:

    ..  code-block:: tarantoolsession

        box.info.ro -- "false" at least on one instance
        box.info.status -- should be "running"

    If all instances have ``box.info.ro = true``, this means there are no writable nodes.
    If you're running Tarantool :doc:`v. 2.10.0 </release/2.10.0>` or later,
    you can find out the reason by running ``box.info.ro_reason``.
    If it has the value ``orphan``, the instance doesn't see the rest of the replica set.
    Similarly, if ``box.info.status`` has the value ``orphan``, the instance doesn't see the rest of the replica set.
    First resolve the replication issues and only then continue.

    If you're running Cartridge, you can also check node health in the UI.

#.  Make sure each replica is connected to the rest of the replica set.
    To do this, run ``box.info.replication`` in the instance's console
    and check the output table for values like ``upstream``, ``downstream``, and ``lag``.

    For each instance ``id``, there are ``upstream`` and ``downstream`` values.
    Both of them should have the value ``follow``, except on the instance where you run this code.
    This means that the replicas are connected and there are no errors in the data flow.

    The value of the ``lag`` field can be less or equal than ``box.cfg.replication_timeout``,
    but it can also be moderately larger.
    For example, if ``box.cfg.replication_timeout`` is 1 second and the write load on the master is high,
    it's generally OK to have a lag of about 10 seconds on the master.
    It is up to the user to decide what lag values are fine.

If the replica set is healthy, proceed to the upgrade.

.. // end of old check