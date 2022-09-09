..  _replication-add_instances:

Adding instances
================

..  _replication-add_replica:

This tutorial is intended as a follow-up to the
:ref:`replication bootstrapping <replication-bootstrap>` guide.
It continues building on the examples from that page.
It is recommended that you complete the bootstrapping guide before you proceed.


Adding a replica
----------------

..  image:: mr-1m-2r-mesh-add.png
    :align: center

To add a second **replica** instance to the **master-replica** set from our
:ref:`bootstrapping example <replication-master_replica_bootstrap>`, we need an
analog of the instance file that we created for the first replica in that set:

..  code-block:: lua

    -- instance file for replica #2
    box.cfg{
      listen = 3301,
      replication = {'replicator:password@192.168.0.101:3301',  -- master URI
                     'replicator:password@192.168.0.102:3301',  -- replica #1 URI
                     'replicator:password@192.168.0.103:3301'}, -- replica #2 URI
      read_only = true
    }
    box.once("schema", function()
       box.schema.user.create('replicator', {password = 'password'})
       box.schema.user.grant('replicator', 'replication') -- grant replication role
       box.schema.space.create("test")
       box.space.test:create_index("primary")
       print('box.once executed on replica #2')
    end)

Here we add the URI of replica #2 to the :ref:`replication <cfg_replication-replication>`
parameter, so now it contains three URIs.

After we launch the new replica instance, it gets connected to the master
instance and retrieves the master's write-ahead-log and snapshot files:

..  code-block:: console

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

Since we are adding a read-only instance, there is no need to dynamically
update the ``replication`` parameter on the other running instances. This update
would be required if we :ref:`added a master instance <replication-add_master>`.

However, we recommend specifying the URI of replica #3 in all instance files of the
replica set. This will keep all the files consistent with each other and with
the current replication topology, and so will help to avoid configuration errors
in case of further configuration updates and replica set restart.

..  _replication-add_master:

Adding a master
---------------

..  image:: mm-3m-mesh-add.png
    :align: center

To add a third master instance to the **master-master** set from our
:ref:`bootstrapping example <replication-master_master_bootstrap>`, we need an
analog of the instance files that we created to bootstrap the other master
instances in that set:

..  code-block:: lua

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
       box.schema.user.grant('replicator', 'replication') -- grant replication role
       box.schema.space.create("test")
       box.space.test:create_index("primary")
    end)

Here we make the following changes:

*   Add the URI of master #3 to the :ref:`replication <cfg_replication-replication>`
    parameter.
*   Temporarily specify :ref:`read_only=true <cfg_basic-read_only>` to disable
    data-change operations on the instance. After launch, master #3 will act as a
    replica until it retrieves all data from the other masters in the replica set.

After we launch master #3, it gets connected to the other master
instances and retrieves their write-ahead-log and snapshot files:

..  code-block:: console

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

Next, we add the URI of master #3 to the ``replication`` parameter on the existing two
masters. Replication-related parameters are dynamic, so we only need to make a
``box.cfg{}`` request on each of the running instances:

..  code-block:: tarantoolsession

    # adding master #3 URI to replication sources
    tarantool> box.cfg{replication =
             > {'replicator:password@192.168.0.101:3301',
             > 'replicator:password@192.168.0.102:3301',
             > 'replicator:password@192.168.0.103:3301'}}
    ---
    ...

When master #3 catches up with the other masters' state, we can disable
read-only mode for this instance:

..  code-block:: tarantoolsession

    # making master #3 a real master
    tarantool> box.cfg{read_only=false}
    ---
    ...

We also recommend to specify master #3 URI in all instance files in order to
keep all the files consistent with each other and with the current replication
topology.
