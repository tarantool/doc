
..  _admin-upgrades-replication-cluster:

Replication cluster upgrade
===========================

Below are the general instructions for upgrading a Tarantool cluster with replication.
Upgrading from some versions can involve certain specifics. To find out if it is your case, check the version-specific topics of the :ref:`Upgrades <admin-upgrades>`
section.

A replication cluster can be upgraded without downtime due to its redundancy.
When you disconnect a single instance for an upgrade, there is always another
instance that takes over its functionality: being a master storage for the same
data buckets or working as a router. This way, you can upgrade all the instances one by one.

The high-level steps of cluster upgrade are the following:

#.  :ref:`Ensure the application compatibility <admin-upgrades-cluster-check-app>` with
    the target Tarantool version.
#.  :ref:`Check the cluster health <admin-upgrades-cluster-pre-check>`.
#.  :ref:`Install the target Tarantool version <admin-upgrades-cluster-install>` on the
    cluster nodes.
#.  :ref:`Upgrade router <admin-upgrades-cluster-routers>` nodes one by one.
#.  :ref:`Upgrade storage replica sets <admin-upgrades-cluster-storages>` one by one.


..  important::

    The only way to upgrade Tarantool from version 1.6, 1.7, or 1.9 to 2.x **without downtime** is
    taking an intermediate step by upgrading to 1.10 and then to 2.x.

    Before upgrading Tarantool from 1.6 to 2.x, please read about the associated
    :ref:`caveats <admin-upgrades-1.6-1.10>`.

.. note::

    Some upgrade steps are moved to the separate section :ref:`Procedures and checks <upgrade_cluster-procedures>`
    to avoid overloading the general instruction with details. Typically, these are
    checks you should repeat during the upgrade to ensure it goes well.

If you experience issues during upgrade, you can roll back to the original version.
The rollback instructions are provided in the :ref:`Rollback <admin-upgrades-cluster-rollback>`
section.

.. _admin-upgrades-cluster-check-app:

Checking your application
-------------------------

..  include:: ../_includes/upgrade_check_app.rst


.. _admin-upgrades-cluster-pre-check:

Pre-upgrade checks
------------------

Perform these steps before the upgrade to ensure that your cluster is working correctly:

..  include:: ../_includes/upgrade_checks_pre.rst

In case of any issues, make sure to fix them before starting the upgrade procedure.

.. _admin-upgrades-cluster-install:

Installing the target version
-----------------------------

Install the target Tarantool version on all hosts of the cluster. You can do this
using a package manager or the :ref:`tt utility <tt-cli>`.
See the installation instructions at the Tarantool `download page <http://tarantool.org/download.html>`_
and in the :ref:`tt install reference <tt-install>`.

Check that the target Tarantool version is installed by running ``tarantool -v``
on all hosts.

Upgrading a Tarantool cluster with no downtime
----------------------------------------------

.. _admin-upgrades-cluster-routers:

Upgrading routers
~~~~~~~~~~~~~~~~~

Upgrade **router** instances one by one:

#.  Stop one ``router`` instance.
#.  Start this instance on the target Tarantool version.
#.  Repeat the previous steps for each ``router`` instance.

After completing the router instances upgrade, perform the :ref:`vshard.router check <admin-upgrades-router-check>`
on each of them.

.. _admin-upgrades-cluster-storages:

Upgrading storages
~~~~~~~~~~~~~~~~~~

Before upgrading **storage** instances:

*   Disable :doc:`Cartridge failover </book/cartridge/cartridge_cli/commands/failover/>`: run

    ..  code-block:: bash

        cartridge failover disable

    or use the Cartridge web interface (**Cluster** tab, **Failover: <Mode>** button).

*   Disable :ref:`rebalancer <storage_api-rebalancer_disable>`: run

    ..  code-block:: tarantoolsession

        vshard.storage.rebalancer_disable()

*   Make sure that the Cartridge ``upgrade_schema`` :doc:`option </book/cartridge/cartridge_api/modules/cartridge>`
    is ``false``.

..  include:: ../_includes/upgrade_storages.rst

Once you complete the steps, enable failover or rebalancer back:

*   Enable :doc:`Cartridge failover </book/cartridge/cartridge_cli/commands/failover/>`: run

    ..  code-block:: bash

        cartridge failover set [mode]

    or use the Cartridge web interface (**Cluster** tab, **Failover: Disabled** button).

*   Enable the :ref:`rebalancer <storage_api-rebalancer_enable>`: run

    ..  code-block:: tarantoolsession

        vshard.storage.rebalancer_enable()

Post-upgrade checks
-------------------

Perform these steps after the upgrade to ensure that your cluster is working correctly:

..  include:: ../_includes/upgrade_checks_pre.rst


.. _admin-upgrades-cluster-rollback:

Rollback
--------

Rollback before the point of no return
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

If you decide to roll back before reaching the :ref:`point of no return <admin-upgrades-no-return>`,
your data is fully compatible with the version you had before the upgrade.
In this case, you can roll back the same way: restart the nodes you've already
upgraded on the original version.

Rollback after the point of no return
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

If you've passed the :ref:`point of no return <admin-upgrades-no-return>` (that is,
executed ``box.schema.upgrade()``) during the upgrade, then a rollback requires
downgrading the schema to the original version.

To check if an automatic downgrade is available for your original version, use
``box.schema.downgrade_versions()``. If the version you need is on the list,
execute the following steps on **each upgraded replica set** to roll back:

#.  Run ``box.schema.downgrade(<version>)`` on master specifying the original version.
#.  Run ``box.snapshot()`` on every instance in the replica set to make sure that the
    replicas immediately see the downgraded database state after restart.
#.  Restart all **read-only** instances of the replica set on the source
    version one by one.
#.  Make one of the updated replicas the new master using the applicable instruction
    from :ref:`Switching the master <admin-upgrades-switch-master>`.
#.  Restart the last instance of the replica set (the former master, now
    a replica) on the original version.

Then enable failover or rebalancer back as described in the :ref:`Upgrading storages <admin-upgrades-cluster-storages>`.

Recovering from a failed upgrade
--------------------------------

.. warning::

    This section applies to cases when the upgrade procedure has failed and the
    cluster is not functioning properly anymore. Thus, it implies a downtime and
    a full cluster restart.

In case of an upgrade failure after passing the :ref:`point of no return <admin-upgrades-no-return>`,
follow these steps to roll back to the original version:

#.  Stop all cluster instances.
#.  Save snapshot and ``xlog`` files from all instances whose data was modified
    after the last backup procedure. These files will help apply these modifications
    later.
#.  Save the latest backups from all instances.
#.  Restore the original Tarantool version on all hosts of the cluster.
#.  Launch the cluster on the original Tarantool version.

    .. note::

        At this point, the application becomes fully functional and contains data
        from the backups. However, the data modifications made after the backups
        were taken must be restored manually.

#.  Manually apply the latest data modifications from ``xlog`` files you saved on step 2
    using the :ref:`xlog <xlog>` module. On instances where such changes happened,
    do the following:

    #.  Find out the vclock value of the latest operation in the original WAL.
    #.  Play the operations from the newer xlog starting from this vclock on the
        instance.

    .. important::

        If the upgrade has failed after calling ``box.schema.upgrade()``,
        **don't apply** the modifications of system spaces done by this call.
        This can make the schema incompatible with the original Tarantool version.

Find more information about the Tarantool recovery in :ref:`Disaster recovery <admin-disaster_recovery>`.

.. _admin-upgrades-cluster-procedures:

Procedures and checks
---------------------

.. _admin-upgrades-replication-check:

Replication check
~~~~~~~~~~~~~~~~~

Run ``box.info``:

..  code-block:: tarantoolsession

    box.info

Check that the following conditions are satisfied:

*   ``box.info.status`` is ``running``
*   ``box.info.replication[*].upstream.status`` and ``box.info.replication[*].downstream.status``
    are ``follow``
*   ``box.info.replication[*].upstream.lag`` is less or equal than ``box.cfg.replication_timeout``,
    but it can also be moderately larger under a write load.
*   ``box.info.ro`` is ``false`` at least on one instance in **each** replica set.
    If all instances have ``box.info.ro = true``, this means there are no writable nodes.
    On Tarantool :doc:`v. 2.10.0 </release/2.10.0>` or later, you can find out
    why this happened by running ``box.info.ro_reason``.
    If ``box.info.ro_reason`` or ``box.info.status`` has the value ``orphan``,
    the instance doesn't see the rest of the replica set.

Then run ``box.info`` once more and check that ``box.info.replication[*].upstream.lag``
values are updated.

.. _admin-upgrades-storage-check:

vshard.storage check
~~~~~~~~~~~~~~~~~~~~

Run ``vshard.storage.info()``:

..  code-block:: tarantoolsession

    vshard.storage.info()

Check that the following conditions are satisfied:

*   there are no issues or alerts
*   ``replication.status`` is ``follow``

.. _admin-upgrades-router-check:

vshard.router check
~~~~~~~~~~~~~~~~~~~

Run ``vshard.router.info()``:

..  code-block:: tarantoolsession

    vshard.router.info()

Check that the following conditions are satisfied:

*   there are no issues or alerts
*   all buckets are available (the sum of ``bucket.available_rw`` on all replica
    sets equals the total number of buckets)

..  _admin-upgrades-switch-master:

Switching the master
~~~~~~~~~~~~~~~~~~~~

*   **Cartridge**. If your cluster runs on Cartridge, you can switch the master in the web interface.
    To do this, go to the **Cluster** tab, click **Edit replica set**, and drag an
    instance to the top of **Failover priority** list to make it the master.

*   **Raft**. If your cluster uses :ref:`automated leader election <repl_leader_elect>`,
    switch the master by following these steps:

    #.  Pick a *candidate* -- a read-only instance to become the new master.
    #.  Run ``box.ctl.promote()`` on the candidate. The operation will start and
        wait for the election to happen.
    #.  Run `box.cfg{ election_mode = "voter" }` on the current master.
    #.  Check that the candidate became the new master: its ``box.info.ro``
        must be ``false``.

*   **Legacy**. If your cluster doesn't work on Cartridge or have automated leader election,
    switch the master by following these steps:

    #.  Pick a *candidate* -- a read-only instance to become the new master.
    #.  Run `box.cfg{ read_only = true }` on the current master.
    #.  Check that the candidates vclock matches the master's vclock:
        The value of ``box.info.vclock[<master_id>]`` on the candidate must be equal
        to ``box.info.lsn`` on the master. ``<master_id>`` here is the value of
        ``box.info.id`` on the master.

        If the vclock values don't match, stop the switch procedure and restore
        the replica set state by calling ``box.cfg{ read_only == false }`` on the master.
        Then pick another candidate and restart the procedure.

After switching the master, perform the :ref:`replication check <upgrades-admin-replication-check>`
on each instance of the replica set.