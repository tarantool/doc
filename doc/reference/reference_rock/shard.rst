.. _shard-module:

-------------------------------------------------------------------------------
                            Module `shard`
-------------------------------------------------------------------------------

.. module:: shard

With sharding, the tuples of a tuple set are distributed to multiple nodes,
with a Tarantool database server instance on each node. With this arrangement,
each instance is handling only a subset of the total data,
so larger loads can be handled by simply adding more computers to a network.

The Tarantool `shard` module has facilities for creating shards,
as well as analogues for the data-manipulation functions of the box library
(select, insert, replace, update, delete).

First some terminology:

.. glossary::

    **Consistent hash**
        The `shard` module distributes according to a hash algorithm, that is,
        it applies a hash function to a tuple's primary-key value in order to
        decide which shard the tuple belongs to. The hash function is
        `consistent <https://en.wikipedia.org/wiki/Consistent_hashing>`_
        so that changing the number of servers will not affect results for many
        keys. The specific hash function that the `shard` module uses is
        :ref:`digest.guava <digest-guava>` in the :codeitalic:`digest` module.

    **Instance**
        A currently-running in-memory copy of the Tarantool server, sometimes
        called a "server instance". Usually each shard is associated with one
        instance, or, if both sharding and replicating are going on, each shard
        is associated with one replica set.

    **Queue**
        A temporary list of recent update requests. Sometimes called "batching".
        Since updates to a sharded database can be slow, it may speed up
        throughput to send requests to a queue rather than wait for the update
        to finish on every node. The `shard` module has functions for adding
        requests to the queue, which it will process without further intervention.
        Queuing is optional.

    **Redundancy**
        The number of replicated data copies in each shard.

    **Replica**
        An instance which is part of a replica set.

    **Replica set**
        Often a single shard is associated with a single instance;
        however, often the shard is replicated. When a shard is replicated,
        the multiple instances ("replicas"), which handle the shard's
        replicated data, are a "replica set".

    **Replicated data**
        A complete copy of the data. The `shard` module handles both sharding
        and replication. One shard can contain one or more replicated data copies.
        When a write occurs, the write is attempted on every replicated data copy in turn.
        The `shard` module does not use the built-in replication feature.

    **Shard**
        A subset of the tuples in the database partitioned according to the
        value returned by the consistent hash function. Usually each shard
        is on a separate node, or a separate set of nodes (for example if
        redundancy = 3 then the shard will be on three nodes).

    **Zone**
        A physical location where the nodes are closely connected, with
        the same security and backup and access points. The simplest example
        of a zone is a single computer with a single Tarantool-server instance.
        A shard's replicated data copies should be in different zones.

The `shard` package is distributed separately from the main `tarantool` package.
To acquire it, do a separate installation:

* with Tarantool 1.7.4+, say:

  .. code-block:: console

      $ tarantoolctl rocks install shard

* install with `yum` or `apt`, for example on Ubuntu say:

  .. code-block:: console

      $ sudo apt-get install tarantool-shard

* or download from GitHub `tarantool/shard` and use the Lua files as described
  in the `README <https://github.com/tarantool/shard>`_.

Then, before using the module, say ``shard = require('shard')``.

The most important function is:

.. cssclass:: highlight
.. parsed-literal::

    shard.init(*shard-configuration*)

This must be called for every shard.

The shard configuration is a table with these fields:

* `servers` (a list of URIs of nodes and the zones the nodes are in)
* `login` (the user name which applies for accessing via the `shard` module)
* `password` (the password for the login)
* `redundancy` (a number, minimum 1)
* `binary` (a port number that this host is listening on, on the current host,
  (distinguishable from the 'listen' port specified by `box.cfg`)

Possible errors:

* redundancy should not be greater than the number of servers;
* the servers must be alive;
* two replicated data copies of the same shard should not be in the same zone.

=====================================================================
          Example: `shard.init` syntax for one shard
=====================================================================

* The number of replicated data copies per shard (redundancy) is 3.
* The number of instances is 3.
* The `shard` module will conclude that there is only one shard.

.. code-block:: tarantoolsession

    tarantool> cfg = {
             >   servers = {
             >     { uri = 'localhost:33131', zone = '1' },
             >     { uri = 'localhost:33132', zone = '2' },
             >     { uri = 'localhost:33133', zone = '3' }
             >   },
             >   login = 'test_user',
             >   password = 'pass',
             >   redundancy = '3',
             >   binary = 33131,
             > }
    ---
    ...
    tarantool> shard.init(cfg)
    ---
    ...

=====================================================================
           Example: `shard.init` syntax for three shards
=====================================================================

This describes three shards. Each shard has two replicated data copies. Since the number of
servers is 7, and the number of replicated data copies per shard is 2, and dividing 7 / 2
leaves a remainder of 1, one of the servers will not be used. This is not
necessarily an error, because perhaps one of the servers in the list is not alive.

.. code-block:: tarantoolsession

    tarantool> cfg = {
             >   servers = {
             >     { uri = 'host1:33131', zone = '1' },
             >     { uri = 'host2:33131', zone = '2' },
             >     { uri = 'host3:33131', zone = '3' },
             >     { uri = 'host4:33131', zone = '4' },
             >     { uri = 'host5:33131', zone = '5' },
             >     { uri = 'host6:33131', zone = '6' },
             >     { uri = 'host7:33131', zone = '7' }
             >   },
             >   login = 'test_user',
             >   password = 'pass',
             >   redundancy = '2',
             >   binary = 33131,
             > }
    ---
    ...
    tarantool> shard.init(cfg)
    ---
    ...

Every data-access function in the `box` module has an analogue in the `shard`
module:

.. cssclass:: highlight
.. parsed-literal::

    shard[*space-name*].insert{...}
    shard[*space-name*].replace{...}
    shard[*space-name*].delete{...}
    shard[*space-name*].select{...}
    shard[*space-name*].update{...}
    shard[*space-name*].auto_increment{...}

For example, to insert in table T in a sharded database you simply
say ``shard.T:insert{...}`` instead of ``box.space.T:insert{...}``.

A ``shard.T:select{}`` request without a primary key will cause an error.

Every queued data-access function has an analogue in the `shard` module:

.. cssclass:: highlight
.. parsed-literal::

    shard[*space-name*].q_insert{...}
    shard[*space-name*].q_replace{...}
    shard[*space-name*].q_delete{...}
    shard[*space-name*].q_select{...}
    shard[*space-name*].q_update{...}
    shard[*space-name*].q_auto_increment{...}

The user must add an `operation_id`. For details of queued data-access functions,
and of maintenance-related functions, see the
`README <https://github.com/tarantool/shard>`_.

=====================================================================
             Example: shard, minimal configuration
=====================================================================

There is only one shard, and that shard contains only one replicated data copy.
So this isn't
illustrating the features of either replication or sharding, it's only
illustrating what the syntax is, and what the messages look like, that anyone
could duplicate in a minute or two with the magic of cut-and-paste.

.. code-block:: tarantoolsession

    $ mkdir ~/tarantool_sandbox_1
    $ cd ~/tarantool_sandbox_1
    $ rm -r *.snap
    $ rm -r *.xlog
    $ ~/tarantool-1.7/src/tarantool

    tarantool> box.cfg{listen = 3301}
    tarantool> box.schema.space.create('tester')
    tarantool> box.space.tester:create_index('primary', {})
    tarantool> box.schema.user.create('test_user', {password = 'pass'})
    tarantool> box.schema.user.grant('test_user', 'read,write,execute', 'universe')
    tarantool> cfg = {
             >   servers = {
             >       { uri = 'localhost:3301', zone = '1' },
             >   },
             >   login = 'test_user';
             >   password = 'pass';
             >   redundancy = 1;
             >   binary = 3301;
             > }
    tarantool> shard = require('shard')
    tarantool> shard.init(cfg)
    tarantool> -- Now put something in ...
    tarantool> shard.tester:insert{1,'Tuple #1'}

If you cut and paste the above, then the result,
showing only the requests and responses for `shard.init`
and `shard.tester`, should look approximately like this:

.. code-block:: tarantoolsession

    <...>
    tarantool> shard.init(cfg)
    2017-09-06 ... I> Sharding initialization started...
    2017-09-06 ... I> establishing connection to cluster servers...
    2017-09-06 ... I> connected to all servers
    2017-09-06 ... I> started
    2017-09-06 ... I> redundancy = 1
    2017-09-06 ... I> Adding localhost:3301 to shard 1
    2017-09-06 ... I> shards = 1
    2017-09-06 ... I> Done
    ---
    - true
    ...
    tarantool> -- Now put something in ...
    ---
    ...
    tarantool> shard.tester:insert{1,'Tuple #1'}
    ---
    - - [1, 'Tuple #1']
    ...

=====================================================================
                 Example: shard, scaling out
=====================================================================

There are two shards, and each shard contains one replicated data copy.
This requires two nodes. In real life the two nodes would be two computers,
but for this illustration the requirement is merely: start two shells,
which we'll call Terminal#1 and Terminal #2.

On Terminal #1, say:

.. code-block:: tarantoolsession

    $ mkdir ~/tarantool_sandbox_1
    $ cd ~/tarantool_sandbox_1
    $ rm -r *.snap
    $ rm -r *.xlog
    $ ~/tarantool-1.7/src/tarantool

    tarantool> box.cfg{listen = 3301}
    tarantool> box.schema.space.create('tester')
    tarantool> box.space.tester:create_index('primary', {})
    tarantool> box.schema.user.create('test_user', {password = 'pass'})
    tarantool> box.schema.user.grant('test_user', 'read,write,execute', 'universe')
    tarantool> console = require('console')
    tarantool> cfg = {
             >   servers = {
             >     { uri = 'localhost:3301', zone = '1' },
             >     { uri = 'localhost:3302', zone = '2' },
             >   },
             >   login = 'test_user',
             >   password = 'pass',
             >   redundancy = 1,
             >   binary = 3301,
             > }
    tarantool> shard = require('shard')
    tarantool> shard.init(cfg)
    tarantool> -- Now put something in ...
    tarantool> shard.tester:insert{1,'Tuple #1'}

On Terminal #2, say:

.. code-block:: tarantoolsession

    $ mkdir ~/tarantool_sandbox_2
    $ cd ~/tarantool_sandbox_2
    $ rm -r *.snap
    $ rm -r *.xlog
    $ ~/tarantool-1.7/src/tarantool

    tarantool> box.cfg{listen = 3302}
    tarantool> box.schema.space.create('tester')
    tarantool> box.space.tester:create_index('primary', {})
    tarantool> box.schema.user.create('test_user', {password = 'pass'})
    tarantool> box.schema.user.grant('test_user', 'read,write,execute', 'universe')
    tarantool> console = require('console')
    tarantool> cfg = {
             >   servers = {
             >     { uri = 'localhost:3301', zone = '1' };
             >     { uri = 'localhost:3302', zone = '2' };
             >   };
             >   login = 'test_user';
             >   password = 'pass';
             >   redundancy = 1;
             >   binary = 3302;
             > }
    tarantool> shard = require('shard')
    tarantool> shard.init(cfg)
    tarantool> -- Now get something out ...
    tarantool> shard.tester:select{1}

What will appear on Terminal #1 is: a loop of error messages saying "Connection
refused" and "server check failure". This is normal. It will go on until
Terminal #2 process starts.

What will appear on Terminal #2, at the end, should look like this:

.. code-block:: tarantoolsession

    tarantool> shard.tester:select{1}
    ---
    - - - [1, 'Tuple #1']
    ...

This shows that what was inserted by Terminal #1 can be selected by Terminal #2,
via the `shard` module.

For details, see the `README <https://github.com/tarantool/shard>`_.
