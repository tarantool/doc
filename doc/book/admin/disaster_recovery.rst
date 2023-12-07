.. _admin-disaster_recovery:

Disaster recovery
=================

The minimal fault-tolerant Tarantool configuration would be a :ref:`replica set <replication-architecture>`
that includes a master and a replica, or two masters.
The basic recommendation is to configure all Tarantool instances in a replica set to create :ref:`snapshot files <index-box_persistence>` on a regular basis.

Here are action plans for typical crash scenarios.


.. _admin-disaster_recovery-master_replica:

Master-replica
--------------

.. _admin-disaster_recovery-master_replica_manual_failover:

Master crash: manual failover
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

**Configuration:** master-replica (:ref:`manual failover <replication-master_replica_bootstrap>`).

**Problem:** The master has crashed.

**Actions:**

1.  Ensure the master is stopped.
    For example, log in to the master machine and use ``tt stop``.

2.  Configure a new replica set leader using the :ref:`<replicaset_name>.leader <configuration_reference_replicasets_name_leader>` option.

3.  Reload configuration on all instances using :ref:`config:reload() <config-module>`.

4.  Make sure that a new replica set leader is a master using :ref:`box.info.ro <box_introspection-box_info>`.

5.  Remove a crashed master from a replica set as described in :ref:`Removing instances <replication-remove_instances>`.

6.  Set up a replacement for the crashed master on a spare host as described in :ref:`Adding instances <replication-add_instances>`.

See also: :ref:`Performing manual failover <replication-controlled_failover>`.


.. _admin-disaster_recovery-master_replica_auto_failover:

Master crash: automated failover
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

**Configuration:** master-replica (:ref:`automated failover <replication-bootstrap-auto>`).

**Problem:** The master has crashed.

**Actions:**

1.  Use ``box.info.election`` to make sure a new master is elected automatically.

2.  Remove a crashed master from a replica set.

3.  Set up a replacement for the crashed master on a spare host.
    Learn more from :ref:`Adding and removing instances <replication-automated-failover-add-remove-instances>`.

See also: :ref:`Testing automated failover <replication-automated-failover-testing>`.


.. _admin-disaster_recovery-master_replica_data_loss:

Data loss
~~~~~~~~~

**Configuration:** master-replica.

**Problem:** Some transactions are missing on a replica after the master has crashed.

**Actions:**

You lose a few transactions in the master
:ref:`write-ahead log file <index-box_persistence>`, which may have not
transferred to the replica before the crash. If you were able to salvage the master
``.xlog`` file, you may be able to recover these.

1.  Find out instance UUID from the crashed master :ref:`xlog <internals-wal>`:

    .. code-block:: console

        $ head -5 var/lib/instance001/*.xlog | grep Instance
        Instance: 9bb111c2-3ff5-36a7-00f4-2b9a573ea660

2.  On the new master, use the UUID to find the position:

    .. code-block:: tarantoolsession

        app:instance002> box.info.vclock[box.space._cluster.index.uuid:select{'9bb111c2-3ff5-36a7-00f4-2b9a573ea660'}[1][1]]
        ---
        - 999
        ...

3.  :ref:`Play the records <tt-play>` from the crashed ``.xlog`` to the new master, starting from the
    new master position:

    .. code-block:: console

        $ tt play 127.0.0.1:3302 var/lib/instance001/00000000000000000000.xlog \
                  --from 1000 \
                  --replica 1 \
                  --username admin --password secret


.. _admin-disaster_recovery-master_master:

Master-master
-------------

**Configuration:** :ref:`master-master <replication-bootstrap-master-master>`.

**Problem:** one master has crashed.

**Actions:**

1.  Let the load be handled by another master alone.

2.  Remove a crashed master from a replica set.

3.  Set up a replacement for the crashed master on a spare host.
    Learn more from :ref:`Adding and removing instances <replication-master-master-add-remove-instances>`.


.. _admin-disaster_recovery-data_loss:

Data loss
---------

**Configuration:** master-replica or master-master.

**Problem:** Data was deleted at one master and this data loss was propagated to the other node (master or replica).

**Actions:**

1.  Put all nodes in read-only mode.
    Depending on the :ref:`replication.failover <configuration_reference_replication_failover>` mode, this can be done as follows:

    -   ``manual``: change a replica set leader to ``null``.
    -   ``election``: switch from the ``election`` failover mode to ``manual`` and change a replica set leader to ``null``.
    -   ``off``: set ``database.mode`` to ``ro``.

    Reload configurations on all instances using the ``reload()`` function provided by the :ref:`config <config-module>` module.

2.  Turn off deletion of expired checkpoints with :doc:`/reference/reference_lua/box_backup/start`.
    This prevents the Tarantool garbage collector from removing files
    made with older checkpoints until :doc:`/reference/reference_lua/box_backup/stop` is called.

3.  Get the latest valid :ref:`.snap file <internals-snapshot>` and
    use ``tt cat`` command to calculate at which LSN the data loss occurred.

4.  Start a new instance and use :ref:`tt play <tt-play>` command to
    play to it the contents of ``.snap`` and ``.xlog`` files up to the calculated LSN.

5.  Bootstrap a new replica from the recovered master.

..  NOTE::

    The steps above are applicable only to data in the memtx storage engine.
