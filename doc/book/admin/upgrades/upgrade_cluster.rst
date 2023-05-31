
..  _admin-upgrades_replication_cluster:

Replication cluster upgrade
===========================

Below are the general instructions for upgrading a Tarantool cluster with replication.
Upgrading from some versions can involve certain specifics. To find out if it is your
your case, check the version-specific topics of the :ref:`Upgrades <admin-upgrades>`
section.

A replication cluster can be upgraded without downtime due to its redundancy.
When you disconnect a single instance for an upgrade, there is always another
instance that takes over its functionality: being a master storage for the same
data buckets or work as a router. This way, you can upgrade all the instances one by one.

The high-level steps of cluster upgrade are the following:

#.  :ref:`Ensure the application compatibility <upgrade_cluster-check-app>` with
    the target Tarantool version.
#.  :ref:`Check the cluster health <upgrade_cluster-pre-check>`.
#.  :ref:`Install the target Tarantool version <upgrade_cluster-install>` on the
    cluster nodes.
#.  :ref:`Upgrade router <upgrade_cluster-routers>` nodes one by one.
#.  :ref:`Upgrade storage replicasets <upgrade_cluster-storages>` one by one.


..  important::

    The only way to upgrade Tarantool from version 1.6, 1.7, or 1.9 to 2.x **without downtime** is
    taking an intermediate step by upgrading to 1.10 and then to 2.x.

    Before upgrading Tarantool from 1.6 to 2.x, please read about the associated
    :ref:`caveats <admin-upgrades-1.6-1.10>`.

.. note::

    Some upgrade steps are moved to the separate section :ref:`Procedures and checks <upgrade_cluster-procedures>`
    to avoid overloading the general instruction with details. Typically, these are
    checks you should repeat during the upgrade to ensure it goes well.

If you experience issues during upgrade, you can roll back to the source version.
The rollback instructions are provided in the :ref:`Rollback <upgrade_cluster-rollback>`
section.

.. _upgrade_cluster-check-app:

Checking your application
-------------------------

..  include:: ../_includes/upgrade_check_app.rst


.. _upgrade_cluster-pre-check:

Pre-upgrade checks
------------------

Perform these steps before the upgrade to ensure that your cluster is working correctly:

#.  On each ``router`` instance, perform the :ref:`vshard.router check <upgrade_router_check>`:

    ..  code-block:: tarantoolsession

        vshard.router.info()
        -- no issues in the output
        -- sum of 'bucket.available_rw' == total number of buckets

#.  On each ``storage`` instance, perform the :ref:`replication check <upgrade_replication_check>`:

    ..  code-block:: tarantoolsession

        box.info
        -- box.info.status == 'running'
        -- box.info.ro == 'false' on one instance in each replicaset.
        -- box.info.replication[*].upstream.status == 'follow'
        -- box.info.replication[*].downstream.status == 'follow'
        -- box.info.replication[*].upstream.lag <= box.cfg.replication_timeout
        -- can also be moderately larger under a write load


#.  On each ``storage`` instance, perform the :ref:`vshard.storage check <upgrade_storage_check>`:

    ..  code-block:: tarantoolsession

        vshard.storage.info()
        -- no issues in the output
        -- replication.status == 'follow'

#.  Check all instances' logs for application errors.

.. note::

    If you're running Cartridge, you can check the health of the cluster instances
    on the **Cluster** tab of its web interface.

If you find issues during these checks, make sure to fix them before starting
the upgrade procedure.

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

After completing the router instances upgrade, perform the :ref:`vshard.router check <upgrade_router_check>`
on each of them.

.. _upgrade_cluster-storages:

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

*   Make sure that the Cartridge ``upgrade_schema`` :doc:`option </book/cartridge/cartridge_api/modules/cartridge/#cfg-opts-box-opts>`
    is disabled.

Then perform the following steps on each storage replicaset:

.. note::

    To detect possible upgrade issues early, we recommend that you perform
    a :ref:`replication check <upgrade_replication_check>` on all instances of
    the replicaset **after each step**.

#.  Pick a replica (a **read-only** instance) from the replicaset and restart it
    on the target Tarantool version. Wait until it reaches the ``running`` status
    (``box.info.status == running``).
#.  Restart all other **read-only** instances of the replicaset on the target
    version one by one.
#.  Make one of the updated replicas the new master using the applicable instruction
    from :ref:`Switching the master <upgrade_switch_master>`.

    .. warning::

        This is the point of no return when upgrading from version 1.6: once you
        complete it, the schema is no longer compatible with the source Tarantool version.

#.  Restart the last instance of the replicaset (the former master, now
    a replica) on the target version.

.. _upgrade_no-return:

#.  Run :ref:`box.schema.upgrade() <box_schema-upgrade>` on the new master.
    This will update the Tarantool system spaces to match the currently installed
    version of Tarantool. The changes will be propagated to other nodes via the
    replication mechanism later.

    .. warning::

        This is the point of no return: once you complete it, the schema is no
        longer compatible with the source Tarantool version.

    .. NOTE::

        To undo schema upgrade in a case of failed upgrade, you can use :ref:`box.schema.downgrade() <box_schema-downgrade>`.

#.  Run ``box.snapshot()`` on every node in the replicaset to make sure that the
    replicas immediately see the upgraded database state in case of restart.

Once you complete the steps, enable failover or rebalancer back:

*   Enable :doc:`Cartridge failover </book/cartridge/cartridge_cli/commands/failover/>`: run

    ..  code-block:: bash

        cartridge failover set [mode]

    or use the Cartridge web interface (**Cluster** tab, **Failover: Disabled** button).

*   Enable :ref:`rebalancer <storage_api-rebalancer_enable>`: run

    ..  code-block:: tarantoolsession

        vshard.storage.rebalancer_enable()

Post-upgrade checks
-------------------

#.  On each ``router`` instance, perform the :ref:`vshard.router check <upgrade_router_check>`.
#.  Check all instance logs for errors.

.. _upgrade_cluster-rollback:

Rollback
--------

Rollback before the point of no return
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

If you decide to roll back before reaching the :ref:`point of no return <upgrade_no-return>`,
your data is fully compatible with the version you had before the upgrade.
In this case, you can roll back the same way: restart the nodes you've already
upgraded on the source version.

Rollback after the point of no return
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

If you've passed the :ref:`point of no return <upgrade_no-return>` (that is,
executed ``box.schema.upgrade()``) during the upgrade, then a rollback requires
downgrading the schema to the source version.

To check if an automatic downgrade is available for your source version, use
``box.schema.downgrade_versions()``. If the version you need is on the list,
execute the following steps on **each upgraded replicaset** to roll back:

#.  Run ``box.schema.downgrade(<version>)`` on master specifying the source version.
#.  Run ``box.snapshot()`` on every instance in the replicaset to make sure that the
    replicas immediately see the downgraded database state after restart.
#.  Restart all **read-only** instances of the replicaset on the source
    version one by one.
#.  Make one of the updated replicas the new master using the applicable instruction
    from :ref:`Switching the master <upgrade_switch_master>`.
#.  Restart the last instance of the replicaset (the former master, now
    a replica) on the source version.

Then enable failover or rebalancer back as described in the :ref:`Upgrading storages <upgrade_cluster-storages>`.

Recovering an upgrade failure after the point of no return
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. warning::

    This section applies to cases when the upgrade procedure has failed and the
    cluster is not functioning properly anymore.

In case of an upgrade failure after passing the :ref:`point of no return <upgrade_no-return>`


#.  Stop all cluster instances.
#.  Save snapshot and xlog files from all instances on which (there were changes)?
#.

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

*   ``box.info.status`` is ``running``
*   ``box.info.replication[*].upstream.status`` and ``box.info.replication[*].downstream.status``
    are ``follow``
*   ``box.info.replication[*].upstream.lag`` is less or equal than ``box.cfg.replication_timeout``,
    but it can also be moderately larger under a write load.
*   ``box.info.ro`` is ``false`` at least on one instance in **each** replicaset.
    If all instances have ``box.info.ro = true``, this means there are no writable nodes.
    On Tarantool :doc:`v. 2.10.0 </release/2.10.0>` or later, you can find out
    why this happened by running ``box.info.ro_reason``.
    If ``box.info.ro_reason`` or ``box.info.status`` has the value ``orphan``,
    the instance doesn't see the rest of the replicaset.

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
*   ``replication.status`` is ``follow``

.. _upgrade_router_check:

vshard.router check
~~~~~~~~~~~~~~~~~~~

Run ``vshard.router.info()``:

..  code-block:: tarantoolsession

    vshard.router.info()

Check that the following conditions are satisfied:

*   there are no issues or alerts
*   all buckets are available (the sum of ``bucket.available_rw`` on all replica
    sets equals the total number of buckets)

..  _upgrade_switch_master:

Switching the master
~~~~~~~~~~~~~~~~~~~~

*   **Cartridge**. If your cluster runs on Cartridge, you can switch master in the web interface.
    To do this, go to the **Cluster** tab, click **Edit replica set** and drag an
    instance to the top of **Failover priority** list to make it the master.

*   **Raft**. If you cluster uses :ref:`automated leader election <repl_leader_elect>`,
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
        the replicaset state by calling ``box.cfg{ read_only == false }`` on the master.
        Then pick another candidate and restart the procedure.

After switching the master, perform the :ref:`replication check <upgrade_replication_check>`
on each instance of the replicaset.

Restoring xlog
~~~~~~~~~~~~~~