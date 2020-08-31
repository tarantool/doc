.. _replication-bootstrap:

================================================================================
Bootstrapping a replica set
================================================================================

.. _replication-master_replica_bootstrap:

--------------------------------------------------------------------------------
Master-replica bootstrap
--------------------------------------------------------------------------------

Let us first bootstrap a simple **master-replica** set containing two instances,
each located on its own machine. For easier administration, we make the
:ref:`instance files <admin-instance_file>` almost identical.

.. image:: mr-1m-1r-twoway.png
    :align: center

Here is an example of the master's instance file:

.. code-block:: lua

   -- instance file for the master
   box.cfg{
     listen = 3301,
     replication = {'replicator:password@192.168.0.101:3301',  -- master URI
                    'replicator:password@192.168.0.102:3301'}, -- replica URI
     read_only = false
   }
   box.once("schema", function()
      box.schema.user.create('replicator', {password = 'password'})
      box.schema.user.grant('replicator', 'replication') -- grant replication role
      box.schema.space.create("test")
      box.space.test:create_index("primary")
      print('box.once executed on master')
   end)

where:

* the ``box.cfg()`` :ref:`listen <cfg_basic-listen>` parameter defines a URI
  (port 3301 in our example), on which the master can accept connections from
  replicas.
* the ``box.cfg()`` :ref:`replication <cfg_replication-replication>` parameter
  defines the URIs at which all instances in the replica set can accept connections.
  It includes the replica's URI as well, although the replica is not a replication
  source right now. This parameter is mandatory only for master-master or full-mesh
  cluster setups.

  .. NOTE::

     For security reasons, we recommend that administrators prevent unauthorized
     replication sources by associating a password with every user that has a
     replication :ref:`role <authentication-roles>`. That way, the :ref:`URI
     <index-uri>` for ``replication`` parameter must have the long form
     ``username:password@host:port``.

* the :ref:`read_only = false <cfg_basic-read_only>` parameter setting enables
  data-change operations on the instance and makes the instance act as a master,
  not as a replica. *That is the only parameter setting in our instance files
  that will differ.*
* the :ref:`box.once() <box-once>` function contains database initialization logic
  that should be executed only once during the replica set lifetime.

In this example, we create a space with a primary index, and a user for
replication purposes. We also say ``print('box.once executed on master')``
so that it will later be visible on a console whether ``box.once()`` was executed.

.. NOTE::

   Replication requires privileges. We can grant privileges for accessing spaces
   directly to the user who will start the instance. However, it is more usual
   to grant privileges for accessing spaces to a
   :ref:`role <authentication-roles>`, and then grant the role to the user who
   will start the replica.

Here we use Tarantool's predefined role named "replication" which by default
grants "read" privileges for all database objects ("universe"), and we can
change privileges for this role as required.

In the replica's instance file, we set the ``read_only`` parameter to "true", and
say ``print('box.once executed on replica')`` so that later it will be visible
that ``box.once()`` was not executed more than once.
Otherwise the replica's instance file is identical to the master's instance file.

.. code-block:: lua

   -- instance file for the replica
   box.cfg{
     listen = 3301,
     replication = {'replicator:password@192.168.0.101:3301',  -- master URI
                    'replicator:password@192.168.0.102:3301'}, -- replica URI
     read_only = true
   }
   box.once("schema", function()
      box.schema.user.create('replicator', {password = 'password'})
      box.schema.user.grant('replicator', 'replication') -- grant replication role
      box.schema.space.create("test")
      box.space.test:create_index("primary")
      print('box.once executed on replica')
   end)

.. NOTE::

   The replica does not inherit the master’s configuration parameters, such as
   those making the :ref:`checkpoint daemon <book_cfg_checkpoint_daemon>` run on
   the master. To get the same behavior, set the relevant parameters
   explicitly so that they are the same on both master and replica.

Now we can launch the two instances. The master...

.. code-block:: console

   $ # launching the master
   $ tarantool master.lua
   2017-06-14 14:12:03.847 [18933] main/101/master.lua C> version 1.7.4-52-g980d30092
   2017-06-14 14:12:03.848 [18933] main/101/master.lua C> log level 5
   2017-06-14 14:12:03.849 [18933] main/101/master.lua I> mapping 268435456 bytes for tuple arena...
   2017-06-14 14:12:03.859 [18933] iproto/101/main I> binary: bound to [::]:3301
   2017-06-14 14:12:03.861 [18933] main/105/applier/replicator@192.168.0. I> can't connect to master
   2017-06-14 14:12:03.861 [18933] main/105/applier/replicator@192.168.0. coio.cc:105 !> SystemError connect, called on fd 14, aka 192.168.0.102:56736: Connection refused
   2017-06-14 14:12:03.861 [18933] main/105/applier/replicator@192.168.0. I> will retry every 1 second
   2017-06-14 14:12:03.861 [18933] main/104/applier/replicator@192.168.0. I> remote master is 1.7.4 at 192.168.0.101:3301
   2017-06-14 14:12:19.878 [18933] main/105/applier/replicator@192.168.0. I> remote master is 1.7.4 at 192.168.0.102:3301
   2017-06-14 14:12:19.879 [18933] main/101/master.lua I> initializing an empty data directory
   2017-06-14 14:12:19.908 [18933] snapshot/101/main I> saving snapshot `/var/lib/tarantool/master/00000000000000000000.snap.inprogress'
   2017-06-14 14:12:19.914 [18933] snapshot/101/main I> done
   2017-06-14 14:12:19.914 [18933] main/101/master.lua I> vinyl checkpoint done
   2017-06-14 14:12:19.917 [18933] main/101/master.lua I> ready to accept requests
   2017-06-14 14:12:19.918 [18933] main/105/applier/replicator@192.168.0. I> failed to authenticate
   2017-06-14 14:12:19.918 [18933] main/105/applier/replicator@192.168.0. xrow.cc:431 E> ER_LOADING: Instance bootstrap hasn't finished yet
   box.once executed on master
   2017-06-14 14:12:19.920 [18933] main C> entering the event loop

... (the display confirms that ``box.once()`` was executed on the master) -- and the replica:

.. code-block:: console

   $ # launching the replica
   $ tarantool replica.lua
   2017-06-14 14:12:19.486 [18934] main/101/replica.lua C> version 1.7.4-52-g980d30092
   2017-06-14 14:12:19.486 [18934] main/101/replica.lua C> log level 5
   2017-06-14 14:12:19.487 [18934] main/101/replica.lua I> mapping 268435456 bytes for tuple arena...
   2017-06-14 14:12:19.494 [18934] iproto/101/main I> binary: bound to [::]:3311
   2017-06-14 14:12:19.495 [18934] main/104/applier/replicator@192.168.0. I> remote master is 1.7.4 at 192.168.0.101:3301
   2017-06-14 14:12:19.495 [18934] main/105/applier/replicator@192.168.0. I> remote master is 1.7.4 at 192.168.0.102:3302
   2017-06-14 14:12:19.496 [18934] main/104/applier/replicator@192.168.0. I> failed to authenticate
   2017-06-14 14:12:19.496 [18934] main/104/applier/replicator@192.168.0. xrow.cc:431 E> ER_LOADING: Instance bootstrap hasn't finished yet

In both logs, there are messages saying that the replica was bootstrapped from the master:

.. code-block:: console

   $ # bootstrapping the replica (from the master's log)
   <...>
   2017-06-14 14:12:20.503 [18933] main/106/main I> initial data sent.
   2017-06-14 14:12:20.505 [18933] relay/[::ffff:192.168.0.101]:/101/main I> recover from `/var/lib/tarantool/master/00000000000000000000.xlog'
   2017-06-14 14:12:20.505 [18933] main/106/main I> final data sent.
   2017-06-14 14:12:20.522 [18933] relay/[::ffff:192.168.0.101]:/101/main I> recover from `/Users/e.shebunyaeva/work/tarantool-test-repl/master_dir/00000000000000000000.xlog'
   2017-06-14 14:12:20.922 [18933] main/105/applier/replicator@192.168.0. I> authenticated

.. code-block:: console

   $ # bootstrapping the replica (from the replica's log)
   <...>
   2017-06-14 14:12:20.498 [18934] main/104/applier/replicator@192.168.0. I> authenticated
   2017-06-14 14:12:20.498 [18934] main/101/replica.lua I> bootstrapping replica from 192.168.0.101:3301
   2017-06-14 14:12:20.512 [18934] main/104/applier/replicator@192.168.0. I> initial data received
   2017-06-14 14:12:20.512 [18934] main/104/applier/replicator@192.168.0. I> final data received
   2017-06-14 14:12:20.517 [18934] snapshot/101/main I> saving snapshot `/var/lib/tarantool/replica/00000000000000000005.snap.inprogress'
   2017-06-14 14:12:20.518 [18934] snapshot/101/main I> done
   2017-06-14 14:12:20.519 [18934] main/101/replica.lua I> vinyl checkpoint done
   2017-06-14 14:12:20.520 [18934] main/101/replica.lua I> ready to accept requests
   2017-06-14 14:12:20.520 [18934] main/101/replica.lua I> set 'read_only' configuration option to true
   2017-06-14 14:12:20.520 [18934] main C> entering the event loop

Notice that ``box.once()`` was executed only at the master, although we added
``box.once()`` to both instance files.

We could as well launch the replica first:

.. code-block:: console

   $ # launching the replica
   $ tarantool replica.lua
   2017-06-14 14:35:36.763 [18952] main/101/replica.lua C> version 1.7.4-52-g980d30092
   2017-06-14 14:35:36.765 [18952] main/101/replica.lua C> log level 5
   2017-06-14 14:35:36.765 [18952] main/101/replica.lua I> mapping 268435456 bytes for tuple arena...
   2017-06-14 14:35:36.772 [18952] iproto/101/main I> binary: bound to [::]:3301
   2017-06-14 14:35:36.772 [18952] main/104/applier/replicator@192.168.0. I> can't connect to master
   2017-06-14 14:35:36.772 [18952] main/104/applier/replicator@192.168.0. coio.cc:105 !> SystemError connect, called on fd 13, aka 192.168.0.101:56820: Connection refused
   2017-06-14 14:35:36.772 [18952] main/104/applier/replicator@192.168.0. I> will retry every 1 second
   2017-06-14 14:35:36.772 [18952] main/105/applier/replicator@192.168.0. I> remote master is 1.7.4 at 192.168.0.102:3301

... and the master later:

.. code-block:: console

   $ # launching the master
   $ tarantool master.lua
   2017-06-14 14:35:43.701 [18953] main/101/master.lua C> version 1.7.4-52-g980d30092
   2017-06-14 14:35:43.702 [18953] main/101/master.lua C> log level 5
   2017-06-14 14:35:43.702 [18953] main/101/master.lua I> mapping 268435456 bytes for tuple arena...
   2017-06-14 14:35:43.709 [18953] iproto/101/main I> binary: bound to [::]:3301
   2017-06-14 14:35:43.709 [18953] main/105/applier/replicator@192.168.0. I> remote master is 1.7.4 at 192.168.0.102:3301
   2017-06-14 14:35:43.709 [18953] main/104/applier/replicator@192.168.0. I> remote master is 1.7.4 at 192.168.0.101:3301
   2017-06-14 14:35:43.709 [18953] main/101/master.lua I> initializing an empty data directory
   2017-06-14 14:35:43.721 [18953] snapshot/101/main I> saving snapshot `/var/lib/tarantool/master/00000000000000000000.snap.inprogress'
   2017-06-14 14:35:43.722 [18953] snapshot/101/main I> done
   2017-06-14 14:35:43.723 [18953] main/101/master.lua I> vinyl checkpoint done
   2017-06-14 14:35:43.723 [18953] main/101/master.lua I> ready to accept requests
   2017-06-14 14:35:43.724 [18953] main/105/applier/replicator@192.168.0. I> failed to authenticate
   2017-06-14 14:35:43.724 [18953] main/105/applier/replicator@192.168.0. xrow.cc:431 E> ER_LOADING: Instance bootstrap hasn't finished yet
   box.once executed on master
   2017-06-14 14:35:43.726 [18953] main C> entering the event loop
   2017-06-14 14:35:43.779 [18953] main/103/main I> initial data sent.
   2017-06-14 14:35:43.780 [18953] relay/[::ffff:192.168.0.101]:/101/main I> recover from `/var/lib/tarantool/master/00000000000000000000.xlog'
   2017-06-14 14:35:43.780 [18953] main/103/main I> final data sent.
   2017-06-14 14:35:43.796 [18953] relay/[::ffff:192.168.0.102]:/101/main I> recover from `/var/lib/tarantool/master/00000000000000000000.xlog'
   2017-06-14 14:35:44.726 [18953] main/105/applier/replicator@192.168.0. I> authenticated

In this case, the replica would wait for the master to become available, so the
launch order doesn't matter. Our ``box.once()`` logic would also be executed
only once, at the master.

.. code-block:: console

   $ # the replica has eventually connected to the master
   $ # and got bootstrapped (from the replica's log)
   2017-06-14 14:35:43.777 [18952] main/104/applier/replicator@192.168.0. I> remote master is 1.7.4 at 192.168.0.101:3301
   2017-06-14 14:35:43.777 [18952] main/104/applier/replicator@192.168.0. I> authenticated
   2017-06-14 14:35:43.777 [18952] main/101/replica.lua I> bootstrapping replica from 192.168.0.199:3310
   2017-06-14 14:35:43.788 [18952] main/104/applier/replicator@192.168.0. I> initial data received
   2017-06-14 14:35:43.789 [18952] main/104/applier/replicator@192.168.0. I> final data received
   2017-06-14 14:35:43.793 [18952] snapshot/101/main I> saving snapshot `/var/lib/tarantool/replica/00000000000000000005.snap.inprogress'
   2017-06-14 14:35:43.793 [18952] snapshot/101/main I> done
   2017-06-14 14:35:43.795 [18952] main/101/replica.lua I> vinyl checkpoint done
   2017-06-14 14:35:43.795 [18952] main/101/replica.lua I> ready to accept requests
   2017-06-14 14:35:43.795 [18952] main/101/replica.lua I> set 'read_only' configuration option to true
   2017-06-14 14:35:43.795 [18952] main C> entering the event loop

.. _replication-controlled_failover:

--------------------------------------------------------------------------------
Controlled failover
--------------------------------------------------------------------------------

To perform a **controlled failover**, that is, swap the roles of the master and
replica, all we need to do is to set ``read_only=true`` at the master, and
``read_only=false`` at the replica. The order of actions is important here.
If a system is running in production, we do not want concurrent writes happening
both at the replica and the master. Nor do we want the new replica to accept
any writes until it has finished fetching all replication data from the old
master. To compare replica and master state, we can use
:ref:`box.info.signature <box_introspection-box_info>`.

1. Set ``read_only=true`` at the master.

   .. code-block:: tarantoolsession

      # at the master
      tarantool> box.cfg{read_only=true}

2. Record the master’s current position with ``box.info.signature``, containing
   the sum of all LSNs in the master’s vector clock.

   .. code-block:: tarantoolsession

      # at the master
      tarantool> box.info.signature

3. Wait until the replica’s signature is the same as the master’s.

   .. code-block:: tarantoolsession

      # at the replica
      tarantool> box.info.signature

4. Set ``read_only=false`` at the replica to enable write operations.

   .. code-block:: tarantoolsession

      # at the replica
      tarantool> box.cfg{read_only=false}

These four steps ensure that the replica doesn’t accept new writes until it’s done
fetching writes from the master.

.. _replication-master_master_bootstrap:

--------------------------------------------------------------------------------
Master-master bootstrap
--------------------------------------------------------------------------------

Now let us bootstrap a two-instance **master-master** set. For easier
administration, we make master#1 and master#2 instance files fully identical.

.. image:: mm-2m-mesh.png
    :align: center

We re-use the master's instance file from the
:ref:`master-replica example <replication-master_replica_bootstrap>` above.

.. code-block:: lua

   -- instance file for any of the two masters
   box.cfg{
     listen      = 3301,
     replication = {'replicator:password@192.168.0.101:3301',  -- master1 URI
                    'replicator:password@192.168.0.102:3301'}, -- master2 URI
     read_only   = false
   }
   box.once("schema", function()
      box.schema.user.create('replicator', {password = 'password'})
      box.schema.user.grant('replicator', 'replication') -- grant replication role
      box.schema.space.create("test")
      box.space.test:create_index("primary")
      print('box.once executed on master #1')
   end)

In the :ref:`replication <cfg_replication-replication>` parameter, we define the
URIs of both masters in the replica set and say
``print('box.once executed on master #1')`` so it will be clear when and where the
``box.once()`` logic is executed.

Now we can launch the two masters.

.. NOTE::

    Tarantool guarantees that ``box.once()`` logic will be executed once only
    for a single instance. Starting a master-master replica set in parallel
    can cause repeated execution of ``box.once``. That, particularly, can result
    in data inconsistency.

.. code-block:: console

   $ # launching master #1
   $ tarantool master1.lua
   2017-06-14 15:39:03.062 [47021] main/101/master1.lua C> version 1.7.4-52-g980d30092
   2017-06-14 15:39:03.062 [47021] main/101/master1.lua C> log level 5
   2017-06-14 15:39:03.063 [47021] main/101/master1.lua I> mapping 268435456 bytes for tuple arena...
   2017-06-14 15:39:03.065 [47021] iproto/101/main I> binary: bound to [::]:3301
   2017-06-14 15:39:03.065 [47021] main/105/applier/replicator@192.168.0.10 I> can't connect to master
   2017-06-14 15:39:03.065 [47021] main/105/applier/replicator@192.168.0.10 coio.cc:107 !> SystemError connect, called on fd 14, aka 192.168.0.102:57110: Connection refused
   2017-06-14 15:39:03.065 [47021] main/105/applier/replicator@192.168.0.10 I> will retry every 1 second
   2017-06-14 15:39:03.065 [47021] main/104/applier/replicator@192.168.0.10 I> remote master is 1.7.4 at 192.168.0.101:3301
   2017-06-14 15:39:08.070 [47021] main/105/applier/replicator@192.168.0.10 I> remote master is 1.7.4 at 192.168.0.102:3301
   2017-06-14 15:39:08.071 [47021] main/105/applier/replicator@192.168.0.10 I> authenticated
   2017-06-14 15:39:08.071 [47021] main/101/master1.lua I> bootstrapping replica from 192.168.0.102:3301
   2017-06-14 15:39:08.073 [47021] main/105/applier/replicator@192.168.0.10 I> initial data received
   2017-06-14 15:39:08.074 [47021] main/105/applier/replicator@192.168.0.10 I> final data received
   2017-06-14 15:39:08.074 [47021] snapshot/101/main I> saving snapshot `/Users/e.shebunyaeva/work/tarantool-test-repl/master1_dir/00000000000000000008.snap.inprogress'
   2017-06-14 15:39:08.074 [47021] snapshot/101/main I> done
   2017-06-14 15:39:08.076 [47021] main/101/master1.lua I> vinyl checkpoint done
   2017-06-14 15:39:08.076 [47021] main/101/master1.lua I> ready to accept requests
   box.once executed on master #1
   2017-06-14 15:39:08.077 [47021] main C> entering the event loop

.. code-block:: console

   $ # launching master #2
   $ tarantool master2.lua
   2017-06-14 15:39:07.452 [47022] main/101/master2.lua C> version 1.7.4-52-g980d30092
   2017-06-14 15:39:07.453 [47022] main/101/master2.lua C> log level 5
   2017-06-14 15:39:07.453 [47022] main/101/master2.lua I> mapping 268435456 bytes for tuple arena...
   2017-06-14 15:39:07.455 [47022] iproto/101/main I> binary: bound to [::]:3301
   2017-06-14 15:39:07.455 [47022] main/104/applier/replicator@192.168.0.19 I> remote master is 1.7.4 at 192.168.0.101:3301
   2017-06-14 15:39:07.455 [47022] main/105/applier/replicator@192.168.0.10 I> remote master is 1.7.4 at 192.168.0.102:3301
   2017-06-14 15:39:07.455 [47022] main/101/master2.lua I> initializing an empty data directory
   2017-06-14 15:39:07.457 [47022] snapshot/101/main I> saving snapshot `/Users/e.shebunyaeva/work/tarantool-test-repl/master2_dir/00000000000000000000.snap.inprogress'
   2017-06-14 15:39:07.457 [47022] snapshot/101/main I> done
   2017-06-14 15:39:07.458 [47022] main/101/master2.lua I> vinyl checkpoint done
   2017-06-14 15:39:07.459 [47022] main/101/master2.lua I> ready to accept requests
   2017-06-14 15:39:07.460 [47022] main C> entering the event loop
   2017-06-14 15:39:08.072 [47022] main/103/main I> initial data sent.
   2017-06-14 15:39:08.073 [47022] relay/[::ffff:192.168.0.102]:/101/main I> recover from `/Users/e.shebunyaeva/work/tarantool-test-repl/master2_dir/00000000000000000000.xlog'
   2017-06-14 15:39:08.073 [47022] main/103/main I> final data sent.
   2017-06-14 15:39:08.077 [47022] relay/[::ffff:192.168.0.102]:/101/main I> recover from `/Users/e.shebunyaeva/work/tarantool-test-repl/master2_dir/00000000000000000000.xlog'
   2017-06-14 15:39:08.461 [47022] main/104/applier/replicator@192.168.0.10 I> authenticated
