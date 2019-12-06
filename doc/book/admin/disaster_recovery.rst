.. _admin-disaster_recovery:

================================================================================
Disaster recovery
================================================================================

The minimal fault-tolerant Tarantool configuration would be a
:ref:`replication cluster<replication-topologies>`
that includes a master and a replica, or two masters.

The basic recommendation is to configure all Tarantool instances in a cluster to
create :ref:`snapshot files <index-box_persistence>` at a regular basis.

Here follow action plans for typical crash scenarios.

.. _admin-disaster_recovery-master_replica:

--------------------------------------------------------------------------------
Master-replica
--------------------------------------------------------------------------------

Configuration: One master and one replica.

Problem: The master has crashed.

Your actions:

1. Ensure the master is stopped for good. For example, log in to the master
   machine and use ``systemctl stop tarantool@<instance_name>``.

2. Switch the replica to master mode by setting
   :ref:`box.cfg.read_only <cfg_basic-read_only>` parameter to *false* and let
   the load be handled by the replica (effective master).

3. Set up a replacement for the crashed master on a spare host, with
   :ref:`replication <cfg_replication-replication>` parameter set to replica
   (effective master), so it begins to catch up with the new master’s state.
   The new instance should have :ref:`box.cfg.read_only <cfg_basic-read_only>`
   parameter set to *true*.

You lose the few transactions in the master
:ref:`write ahead log file <index-box_persistence>`, which it may have not
transferred to the replica before crash. If you were able to salvage the master
.xlog file, you may be able to recover these. In order to do it:

1. Find out the position of the crashed master, as reflected on the new master.

   a. Find out instance UUID from the crashed master :ref:`xlog <internals-wal>`:

      .. code-block:: console

          $ head -5 *.xlog | grep Instance
          Instance: ed607cad-8b6d-48d8-ba0b-dae371b79155

   b. On the new master, use the UUID to find the position:

      .. code-block:: tarantoolsession

          tarantool> box.info.vclock[box.space._cluster.index.uuid:select{'ed607cad-8b6d-48d8-ba0b-dae371b79155'}[1][1]]
          ---
          - 23425
          <...>

2. Play the records from the crashed .xlog to the new master, starting from the
   new master position:

   a. Issue this request locally at the new master's machine to find out
      instance ID of the new master:

      .. code-block:: tarantoolsession

          tarantool> box.space._cluster:select{}
          ---
          - - [1, '88580b5c-4474-43ab-bd2b-2409a9af80d2']
          ...

   b. Play the records to the new master:

      .. code-block:: console

          $ tarantoolctl <new_master_uri> <xlog_file> play --from 23425 --replica 1

.. _admin-disaster_recovery-master_master:

--------------------------------------------------------------------------------
Master-master
--------------------------------------------------------------------------------

Configuration: Two masters.

Problem: Master#1 has crashed.

Your actions:

1. Let the load be handled by master#2 (effective master) alone.

2. Follow the same steps as in the
:ref:`master-replica <admin-disaster_recovery-master_replica>` recovery scenario
to create a new master and salvage lost data.

.. _admin-disaster_recovery-data_loss:

--------------------------------------------------------------------------------
Data loss
--------------------------------------------------------------------------------

Configuration: Master-master or master-replica.

Problem: Data was deleted at one master and this data loss was propagated to the
other node (master or replica).

The following steps are applicable only to data in memtx storage engine.
Your actions:

1. Put all nodes in :ref:`read-only mode <cfg_basic-read_only>` and disable
   deletion of expired checkpoints with :ref:`box.backup.start() <reference_lua-box_backup-backup_start>`.
   This will prevent the Tarantool garbage collector from removing files
   made with older checkpoints until :ref:`box.backup.stop() <reference_lua-box_backup-backup_stop>` is called.

2. Get the latest valid :ref:`.snap file <internals-snapshot>` and
   use ``tarantoolctl cat`` command to calculate at which lsn the data loss occurred.

3. Start a new instance (instance#1) and use ``tarantoolctl play`` command to
   play to it the contents of .snap/.xlog files up to the calculated lsn.

4. Bootstrap a new replica from the recovered master (instance#1).
