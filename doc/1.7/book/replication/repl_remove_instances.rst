.. _replication-remove_instances:

================================================================================
Removing instances
================================================================================

To politely remove an instance from a replica set, follow these steps:

1. On the instance, run ``box.cfg{}`` with a blank replication source:

   .. code-block:: tarantoolsession

      tarantool> box.cfg{replication=''}
      ---
      ...

   The other instances in the replica set will carry on. If later the removed
   instance rejoins, it will receive all the updates that the other instances
   made while it was away.

2. If the instance is decommissioned forever, delete the instance's record from
   the following locations:

   a. :ref:`replication <cfg_replication-replication>` parameter at all running
      instances in the replica set:

      .. code-block:: tarantoolsession

         tarantool> box.cfg{replication=...}

   b. :ref:`box.space._cluster <box_space-cluster>` on any master instance in
      the replica set. For example, a record with instance id = 3:

      .. code-block:: tarantoolsession

         tarantool> box.space._cluster:select{}
         ---
         - - [1, '913f99c8-aee3-47f2-b414-53ed0ec5bf27']
           - [2, 'eac1aee7-cfeb-46cc-8503-3f8eb4c7de1e']
           - [3, '97f2d65f-2e03-4dc8-8df3-2469bd9ce61e']
         ...
         tarantool> box.space._cluster:delete(3)
         ---
         - [3, '97f2d65f-2e03-4dc8-8df3-2469bd9ce61e']
         ...
