1. Pick any replica in the replica set.

2. Upgrade this replica to the new Tarantool version. See details in
   :ref:`Upgrading a Tarantool instance <admin-upgrades_instance>`.

3. Make sure the replica connected to the rest of the replica set just fine:

   ..  code-block:: tarantoolsession

       box.info.replication[id].upstream
       box.info.replication[id].downstream
      
   The ``status`` field in both outputs should have the value ``follow``.

4. :ref:`Upgrade <admin-upgrades_instance>` all the replicas by repeating steps 1--3
   until only the master keeps running the old Tarantool version.

5. Make one of the updated replicas the new master.
   Check that it continues following and being followed by all other replicas.

6. :ref:`Upgrade <admin-upgrades_instance>` the former master.

7. :ref:`Upgrade the database <admin-upgrades_db>` on the new master by running ``box.schema.upgrade()``.
   Changes are propagated to other
   nodes via the regular replication mechanism.

8. Run ``box.snapshot()`` on every node in the replica set to take a snapshot of all the data.
