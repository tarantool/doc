.. _replication-add_instances:

================================================================================
Adding instances
================================================================================

.. _replication-add_replica:

--------------------------------------------------------------------------------
Adding a replica
--------------------------------------------------------------------------------

.. image:: mr-1m-2r-mesh-add.svg
    :align: center

To add a second **replica** instance to the **master-replica** set from our
:ref:`bootstrapping example <replication-master_replica_bootstrap>`, we need an
analog of the instance file that we created for the first replica in that set:

.. code-block:: lua

   -- instance file for replica #2
   box.cfg{
     listen = 3301,
     replication = ('replicator:password@192.168.0.101:3301',  -- master URI
                    'replicator:password@192.168.0.102:3301',  -- replica #1 URI
                    'replicator:password@192.168.0.103:3301'), -- replica #2 URI
     read_only = true
   }
   box.once("schema", function()
      box.schema.user.create('replicator', {password = 'password'})
      box.schema.user.grant('replicator', 'replication’) -- grant replication role
      box.schema.space.create("test")
      box.space.test:create_index("primary")
      print('box.once executed on replica #2')
   end)

Here we add replica #2 URI to :ref:`replication <cfg_replication-replication>`
parameter, so now it contains three URIs.

After we launch the new replica instance, it gets connected to the master
instance and retrieves the master's write ahead log and snapshot files:

.. code-block:: console

   $ # launching replica #2
   $ tarantool replica2.lua
   2017-06-14 14:54:33.927 [46945] main/101/replica2.lua C> version 1.7.4-52-g980d30092
   2017-06-14 14:54:33.927 [46945] main/101/replica2.lua C> log level 5
   2017-06-14 14:54:33.928 [46945] main/101/replica2.lua I> mapping 268435456 bytes for tuple arena...
   2017-06-14 14:54:33.930 [46945] main/104/applier/replicator@192.168.0.10 I> remote master is 1.7.4 at 192.168.0.101:3301
   2017-06-14 14:54:33.930 [46945] main/104/applier/replicator@192.168.0.10 I> authenticated
   2017-06-14 14:54:33.930 [46945] main/101/replica2.lua I> bootstrapping replica from 192.168.0.101:3301
   2017-06-14 14:54:33.933 [46945] main/104/applier/replicator@192.168.0.10 I> initial data received
   2017-06-14 14:54:33.933 [46945] main/104/applier/replicator@192.168.0.10 I> final data received
   2017-06-14 14:54:33.934 [46945] snapshot/101/main I> saving snapshot `/var/lib/tarantool/replica2/00000000000000000010.snap.inprogress'
   2017-06-14 14:54:33.934 [46945] snapshot/101/main I> done
   2017-06-14 14:54:33.935 [46945] main/101/replica2.lua I> vinyl checkpoint done
   2017-06-14 14:54:33.935 [46945] main/101/replica2.lua I> ready to accept requests
   2017-06-14 14:54:33.935 [46945] main/101/replica2.lua I> set 'read_only' configuration option to true
   2017-06-14 14:54:33.936 [46945] main C> entering the event loop

Since we're adding a read-only instance, there is no need to dynamically
update ``replication`` parameter on the other running instances. This update
would be required if we :ref:`added a master instance <replication-add_master>`.

However, we recommend to specify replica #3 URI in all instance files of the
replica set. This will keep all the files consistent with each other and with
the current replication topology, and so will help to avoid configuration errors
in case of further reconfigurations and replica set restart.

.. _replication-add_master:

--------------------------------------------------------------------------------
Adding a master
--------------------------------------------------------------------------------

.. image:: mm-3m-mesh-add.svg
    :align: center

To add a third master instance to the **master-master** set from our
:ref:`bootstrapping example <replication-master_master_bootstrap>`, we need an
analog of the instance files that we created to bootstrap the other master
instances in that set:

.. code-block:: lua

   -- instance file for master #3
   box.cfg{
     listen      = 3301,
     replication = {'replicator:password@192.168.0.101:3301',  -- master#1 URI
                    'replicator:password@192.168.0.102:3301',  -- master#2 URI
                    'replicator:password@192.168.0.103:3301'}, -- master#3 URI
     read_only   = true, -- temporarily read-only
   }
   box.once("schema", function()
      box.schema.user.create('replicator', {password = 'password'})
      box.schema.user.grant('replicator', 'replication’) -- grant "replication" role
      box.schema.space.create("test")
      box.space.test:create_index("primary")
   end)

Here we make the following changes:

* Add master#3 URI to :ref:`replication <cfg_replication-replication>`
  parameter.
* Temporarily specify :ref:`read_only=true <cfg_basic-read_only>` to disable
  data-change operations on the instance. After launch, master #3 will act as a
  replica until it retrieves all data from the other masters in the replica set.

After we launch the third master instance, it gets connected to the other master
instances and retrieves their write ahead logs and snapshot files:

.. code-block:: console

   $ # launching master #3
   $ tarantool master3.lua
   2017-06-14 17:10:00.556 [47121] main/101/master3.lua C> version 1.7.4-52-g980d30092
   2017-06-14 17:10:00.557 [47121] main/101/master3.lua C> log level 5
   2017-06-14 17:10:00.557 [47121] main/101/master3.lua I> mapping 268435456 bytes for tuple arena...
   2017-06-14 17:10:00.559 [47121] iproto/101/main I> binary: bound to [::]:3301
   2017-06-14 17:10:00.559 [47121] main/104/applier/replicator@192.168.0.10 I> remote master is 1.7.4 at 192.168.0.101:3301
   2017-06-14 17:10:00.559 [47121] main/105/applier/replicator@192.168.0.10 I> remote master is 1.7.4 at 192.168.0.102:3301
   2017-06-14 17:10:00.559 [47121] main/106/applier/replicator@192.168.0.10 I> remote master is 1.7.4 at 192.168.0.103:3301
   2017-06-14 17:10:00.559 [47121] main/105/applier/replicator@192.168.0.10 I> authenticated
   2017-06-14 17:10:00.559 [47121] main/101/master3.lua I> bootstrapping replica from 192.168.0.102:3301
   2017-06-14 17:10:00.562 [47121] main/105/applier/replicator@192.168.0.10 I> initial data received
   2017-06-14 17:10:00.562 [47121] main/105/applier/replicator@192.168.0.10 I> final data received
   2017-06-14 17:10:00.562 [47121] snapshot/101/main I> saving snapshot `/Users/e.shebunyaeva/work/tarantool-test-repl/master3_dir/00000000000000000009.snap.inprogress'
   2017-06-14 17:10:00.562 [47121] snapshot/101/main I> done
   2017-06-14 17:10:00.564 [47121] main/101/master3.lua I> vinyl checkpoint done
   2017-06-14 17:10:00.564 [47121] main/101/master3.lua I> ready to accept requests
   2017-06-14 17:10:00.565 [47121] main/101/master3.lua I> set 'read_only' configuration option to true
   2017-06-14 17:10:00.565 [47121] main C> entering the event loop
   2017-06-14 17:10:00.565 [47121] main/104/applier/replicator@192.168.0.10 I> authenticated

Next, we add master#3 URI to ``replication`` parameter on the existing two
masters. Replication-related parameters are dynamic, so we only need to make a
``box.cfg{}`` request on each of the running instances:

.. code-block:: tarantoolsession

   # adding master #3 URI to replication sources
   tarantool> box.cfg{replication =
            > {'replicator:password@192.168.0.101:3301',
            > 'replicator:password@192.168.0.102:3301',
            > 'replicator:password@192.168.0.103:3301'}}
   ---
   ...

When master #3 catches up with the other masters' state, we can disable
read-only mode for this instance:

.. code-block:: tarantoolsession

   # making master #3 a real master
   tarantool> box.cfg{read_only=false}
   ---
   ...

We also recommend to specify master #3 URI in all instance files in order to
keep all the files consistent with each other and with the current replication topology.

.. _replication-orphan_status:

--------------------------------------------------------------------------------
Orphan status
--------------------------------------------------------------------------------

Starting with Tarantool version 1.9, there is a change to the
procedure when an instance joins a cluster.
During ``box.cfg()`` the instance will try to join all masters listed
in :ref:`box.cfg.replication <cfg_replication-replication>`.
If the instance does not succeed with at least
the number of masters specified in
:ref:`replication_connect_quorum <cfg_replication-replication_connect_quorum>`,
then it will switch to **orphan status**.
While an instance is in orphan status, it is read-only.

To "join" a master, a replica instance must "connect" to the
master node and then "sync".

"Connect" means contact the master over the physical network
and receive acknowledgment. If there is no acknowledgment after
:ref:`box.replication_connect_timeout <cfg_replication-replication_connect_timeout>`
seconds (usually 4 seconds), and retries fail or do not happen,
then the connect step fails.

"Sync" means receive updates
from the master in order to make a local database copy.
Syncing is complete when the replica has received all the
updates, or at least has received enough updates that the
replica's :ref:`lag <box_info_replication_upstream_lag>`
is less than or equal to the number of seconds specified by the
configuration parameter
:ref:`box.cfg.replication_sync_lag <cfg_replication-replication_sync_lag>`.

Situation 1: ``box.cfg{}`` is being called for the first time.
A replica is joining but no cluster exists yet.
In pseudocode:

.. code-block:: none

    try to connect to all box.cfg.replication nodes
      -- up to 3 retries are possible
      -- if number of successful connects < 1, abort
    if this instance is chosen as the cluster leader,
    (that is, it is the master that other nodes must join), then
    {
      /* this is called "cluster bootstrap" or "automtic bootstrap" */
      set status to "running"
      return from box.cfg{}
    }
    otherwise
    {
      this instance will be a replica joining an existing cluster,
      see Situation 2.
    }

Situation 2: ``box.cfg{}`` is being called for the first time.
A replica is joining an existing cluster.
In pseudocode:

.. code-block:: none

    try to connect to all box.cfg.replication nodes
      -- if number of successful connects < 1, abort
    if box.replication.sync_status is nil
    or box.replication.sync_status is 365 * 100 * 86400 (TIMEOUT_INFINITY), then
    {
      set status to "running"
    }
    otherwise
    {
      set status to "orphan"
      for each master in box.cfg.replication that was connected
      {
        if master version < '1.9.0', continue
        receive upates from master until syncing is complete
        -- but if it fails to sync, continue
      }
      if the number of syncs is greater than or equal to the quorum
      {
        set status to "running" or "follow"
      }
      otherwise
      {
        /* status remains = "orphan" */
      }
    }
    return from box.cfg{}

Situation 3: ``box.cfg{}`` is not being called for the first time.
It is being called again in order to perform "recovery".
In pseudocode:

.. code-block:: none

    perform "recovery" from the last snapshot and the WAL files
    Do the same steps as in Situation 2, except that:
      -- perhaps retries are not attempted if the connect step fails
      -- it is not necessary to sync for every master, it is only
         necessary to sync for box.cfg.replication_connect_quorum masters

Situation 4: ``box.cfg{}`` is not being called for the first time.
It is being called again because some replication parameter
or something in the cluster has changed.
In pseudocode:

.. code-block:: none

    try to connect to all box.cfg.replication nodes
      -- if number of connects < number of nodes, abort
      /* there is no "sync" */
    set status to "running" or "follow"

The above pseudocode descriptions are not intended as a complete
narration of all the steps.
