..  _admin-upgrades:

Upgrades
========

This topic outlines the general upgrade process for Tarantool.
If required, you can also downgrade to one of the previous versions using a similar procedure.

For information about backwards compatibility,
see the :ref:`compatibility guarantees <compatibility_guarantees>` description.

..  _admin-upgrades_check_app:










.. // old shit

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

.. // end of old shit

Upgrade procedure
~~~~~~~~~~~~~~~~~

#.  Install the target Tarantool version on all hosts of the cluster. You can
    do this using a package manager or the :ref:`tt utility <tt-cli>`.
    See the installation instructions at Tarantool `download page <http://tarantool.org/download.html>`_
    and in the :ref:`tt install reference <tt-install>`.

#.  Upgrade ``router`` instances one by one:

    #.  Stop one ``router`` instance.
    #.  Start this instance on the target Tarantool version.
    #.  Repeat previous steps for each ``router`` instance.
    #.  On each ``router`` instance, perform the vshard.router check.

#.  Upgrade a replicaset:

    #.  Disable failover.
    #.  Disable rebalancer.
    #.  Make sure that the Cartridge ``upgrade_shema`` flad is disabled:
    #.  Pick a read-only instance from the replicaset and restart it on
        the target Tarantool version. Wait until it reaches the ``running``
        status (``box.info.status == running``).
    #.  Perform the replication check on each instance on the replicaset.
    #.  Restart all other read-only instances of the repicaset on the target
        version.
    #.  Perform the replication check on each instance on the replicaset once again.
    #.  Make one of the updated replicas the new master:
        *   Switch master (link)
        *   Replication check
        *   No return for 1.6
    #.  Update the last instance of the replicaset (the former master instance).
    #.  Perform the replication check on each instance on the replicaset once again.
    #.  Run :ref:`box.schema.upgrade() <box_schema-upgrade>` on the new master.
        This will update the Tarantool system spaces to match the currently installed version of Tarantool.
        There is no need  to run ``box.schema.upgrade()`` on every node:
        changes are propagated to other nodes via the regular replication mechanism.

        .. NOTE::

            To undo schema upgrade in a case of failed upgrade, you can use :ref:`box.schema.downgrade() <box_schema-downgrade>`.

    #.  Run ``box.snapshot()`` on every node in the replica set
        to make sure that the replicas immediately see the upgraded database state in case of restart.

    #.  Perform the vshard storage check.
    #.  Check all instance logs for errors.
    #.  Enable rebalancer
    #.  Enable failover


Downgrade/Troubleshooting
-------------------------


..  _admin-upgrades_version_specifics:

Version specifics
-----------------

..  toctree::
    :maxdepth: 1

    upgrades/1.6-1.10
    upgrades/1.6-2.0-downtime
    upgrades/2.10.1
    upgrades/2.10.4

