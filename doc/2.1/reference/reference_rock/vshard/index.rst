.. _vshard:

===============================================================================
Module `vshard`
===============================================================================

.. _vshard-summary:

-------------------------------------------------------------------------------
Summary
-------------------------------------------------------------------------------

The ``vshard`` module introduces the sharding feature, which enables
horizontal scaling in Tarantool.

While a project is growing, scaling the databases may become the most challenging
issue. Once a single server cannot withstand the load, scaling methods should be
applied.

There are two different approaches for scaling data,
`vertical and horizontal scaling <https://en.wikipedia.org/wiki/Scalability#Horizontal_and_vertical_scaling>`_:

* *Vertical scaling* implies that the hardware capacities of a single server would
  be increased.

* *Horizontal scaling* implies that a dataset is partitioned and distributed over
  multiple servers. In case new servers are added, the dataset is re-distributed
  evenly across all servers, both the original and new ones.

Sharding is a database architecture that allows for horizontal scaling.

With ``vshard``, the tuples of a dataset are distributed across
multiple nodes, with a Tarantool database server instance on each node. Each instance
handles only a subset of the total data, so larger loads can be handled by simply
adding more servers. The initial dataset is partitioned into multiple parts, so each
part is stored on a separate server. The dataset is partitioned using shard keys.

The ``vshard`` module is based on the concept of virtual buckets, where a tuple
set is partitioned into a large number of abstract virtual nodes (virtual buckets,
or buckets) rather than into a smaller number of physical nodes.

Hashing a sharding key into a large number of virtual buckets allows seamlessly
changing the number of servers in the cluster. The rebalancing mechanism distributes
buckets evenly among all shards in case some servers were added or removed.

The buckets have states, so it is easy to monitor the server states. For example,
a server instance is active and available for all types of requests, or a failover
occurred and the instance accepts only read requests.

The ``vshard`` module provides analogs for the data-manipulation functions of the
Tarantool ``box`` library (select, insert, replace, update, delete).

.. _vshard-install:

-------------------------------------------------------------------------------
Installation
-------------------------------------------------------------------------------

The ``vshard`` module is distributed separately from the main Tarantool package.
To acquire it, do a separate installation:

.. code-block:: console

    $ tarantoolctl rocks install vshard

.. NOTE::

    The ``vshard`` module requires Tarantool version 1.9+.

.. _vshard-quick-start:

-------------------------------------------------------------------------------
Quick start
-------------------------------------------------------------------------------

The ``vshard/example/`` directory includes a pre-configured development cluster
of 1 ``router`` and 2 replica sets of 2 nodes (2 ``storages``) each, making 5
Tarantool instances in total:

* ``router_1`` – a ``router`` instance
* ``storage_1_a`` – a ``storage`` instance, the master of the first replica set
* ``storage_1_b`` – a ``storage`` instance, the replica of the first replica set
* ``storage_2_a`` – a ``storage`` instance, the master of the second replica set
* ``storage_2_b`` – a ``storage`` instance, the replica of the second replica set

All instances are managed using the ``tarantoolctl`` utility from the root directory
of the project.

Change the directory to ``example/`` and use make to run the development cluster:

.. code-block:: console

    $ cd example/
    $ make
    tarantoolctl stop storage_1_a  # stop the first storage instance
    Stopping instance storage_1_a...
    tarantoolctl stop storage_1_b
    <...>
    rm -rf data/
    tarantoolctl start storage_1_a # start the first storage instance
    Starting instance storage_1_a...
    Starting configuration of replica 8a274925-a26d-47fc-9e1b-af88ce939412
    I am master
    Taking on replicaset master role...
    Run console at unix/:./data/storage_1_a.control
    started
    mkdir ./data/storage_1_a
    <...>
    tarantoolctl start router_1 # start the router
    Starting instance router_1...
    Starting router configuration
    Calling box.cfg()...
    <...>
    Run console at unix/:./data/router_1.control
    started
    mkdir ./data/router_1
    Waiting cluster to start
    echo "vshard.router.bootstrap()" | tarantoolctl enter router_1
    connected to unix/:./data/router_1.control
    unix/:./data/router_1.control> vshard.router.bootstrap()
    ---
    - true
    ...
    unix/:./data/router_1.control>
    tarantoolctl enter router_1 # enter the admin console
    connected to unix/:./data/router_1.control
    unix/:./data/router_1.control>

Some ``tarantoolctl`` commands:

* ``tarantoolctl start router_1`` – start the router instance
* ``tarantoolctl enter router_1``  – enter the admin console

The full list of ``tarantoolctl`` commands for managing Tarantool instances is
available in :ref:`reference on tarantoolctl <tarantoolctl>`.

Essential make commands you need to know:

* ``make start`` – start all Tarantool instances
* ``make stop`` – stop all Tarantool instances
* ``make logcat`` – show logs from all instances
* ``make enter`` – enter the admin console on router_1
* ``make clean`` – clean up all persistent data
* ``make test`` – run the test suite (you can also run test-run.py in the test directory)
* ``make`` – execute ``make stop``, ``make clean``, ``make start`` and ``make enter``

For example, to start all instances, use ``make start``:

.. code-block:: console

    $ make start
    $ ps x|grep tarantool
    46564   ??  Ss     0:00.34 tarantool storage_1_a.lua <running>
    46566   ??  Ss     0:00.19 tarantool storage_1_b.lua <running>
    46568   ??  Ss     0:00.35 tarantool storage_2_a.lua <running>
    46570   ??  Ss     0:00.20 tarantool storage_2_b.lua <running>
    46572   ??  Ss     0:00.25 tarantool router_1.lua <running>

To perform commands in the admin console, use the ``router`` API:

.. code-block:: tarantoolsession

    unix/:./data/router_1.control> vshard.router.info()
    ---
    - replicasets:
        ac522f65-aa94-4134-9f64-51ee384f1a54:
          replica: &0
            network_timeout: 0.5
            status: available
            uri: storage@127.0.0.1:3303
            uuid: 1e02ae8a-afc0-4e91-ba34-843a356b8ed7
          uuid: ac522f65-aa94-4134-9f64-51ee384f1a54
          master: *0
        cbf06940-0790-498b-948d-042b62cf3d29:
          replica: &1
            network_timeout: 0.5
            status: available
            uri: storage@127.0.0.1:3301
            uuid: 8a274925-a26d-47fc-9e1b-af88ce939412
          uuid: cbf06940-0790-498b-948d-042b62cf3d29
          master: *1
      bucket:
        unreachable: 0
        available_ro: 0
        unknown: 0
        available_rw: 3000
      status: 0
      alerts: []
    ...

.. _vshard-architecture:

------------------------------------------------------------------------------
Architecture
------------------------------------------------------------------------------

A sharded cluster in Tarantool consists of storages, routers, and a rebalancer.

A **storage** is a node storing a subset of a dataset. Multiple replicated storages
are deployed as replica sets to provide redundancy (a replica set can also be
referred as shard).

A **router** is a standalone software component that routes read and write requests
from the client application to shards.

A **rebalancer** is an internal component that distributes the dataset among all
shards evenly in case some servers are added or removed. It also balances the load
considering the capacities of existing replica sets.

.. image:: schema.svg
    :align: center

.. _vshard-storage:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Storage
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

**Storage** is a node storing a subset of a dataset. Multiple replicated storages
comprise a replica set. Each storage in a replica set has a role, **master** or
**replica**. Master processes read and write requests. Replicas process read
requests, but cannot process write requests.

.. image:: master_replica.svg
    :align: center

.. _vshard-vbuckets:

++++++++++++++++++++++++++++++++++++++++++++++++++++++++
Virtual buckets
++++++++++++++++++++++++++++++++++++++++++++++++++++++++

The sharded dataset is partitioned into a large number of abstract nodes called
**virtual buckets** (further referred as **buckets**).

The dataset is partitioned using the shard key (or **bucket id**, in terms of
Tarantool). Bucket id is a number from 1 to N, where N is the total number of
buckets.

.. image:: buckets.svg
    :align: center

Each replica set stores a unique subset of buckets. One bucket cannot belong to
multiple replica sets at a time.

.. image:: vbuckets.svg
    :align: center

The total number of buckets is determined by the administrator who sets up the
initial cluster configuration.

Every Tarantool space you plan to shard must have a bucket id field indexed by the
bucket id ``index``. Spaces without the bucket id indexes don’t participate in sharding
but can be used as regular spaces. By default, the name of the index coincides with
the bucket id.

.. _vshard-migrate-buckets:

++++++++++++++++++++++++++++++++++++++++++++++++++++++++
Migration of buckets
++++++++++++++++++++++++++++++++++++++++++++++++++++++++

A **rebalancer** is a background rebalancing process that ensures an even
distribution of buckets across the shards. During rebalancing, buckets are being
migrated among replica sets.

A replica set from which the bucket is being migrated is called **source**; a
target replica set to which the bucket is being migrated is called **destination**.

A **replica set lock** makes a replica set invisible to the rebalancer. A locked
replica set can neither receive new buckets nor migrate its own ones.

While being migrated, the bucket can have different states:

* ACTIVE – the bucket is available for read and write requests.
* PINNED – the bucket is locked for migrating to another replica set. Otherwise
  pinned buckets are similar to the buckets in the ACTIVE state.
* SENDING – the bucket is currently being copied to the destination replica set
  read requests to the source replica set are still processed.
* RECEIVING – the bucket is currently being filled; all requests to it are rejected.
* SENT – the bucket was migrated to the destination replica set.
* GARBAGE – the bucket was already migrated to the destination replica set during
  rebalancing; or the bucket was initially in the RECEIVING state, but some error
  occurred during the migration.

Buckets in the GARBAGE state are deleted by the garbage collector.

.. image:: states.svg
    :align: center

Altogether, migration is performed as follows:

1. At the destination replica set, a new bucket is created and assigned the RECEIVING
   state, the data copying starts, and the bucket rejects all requests.
2. The source bucket at the source replica set is assigned the SENDING state, and
   the bucket continues to process read requests.
3. Once the data is copied, the bucket on the source replica set is marked SENT and it starts rejecting all requests.
4. The bucket on the destination replica set goes into the ACTIVE state and starts
   accepting all requests.

.. _vshard-bucket-space:

++++++++++++++++++++++++++++++++++++++++++++++++++++++++
The `_bucket` system space
++++++++++++++++++++++++++++++++++++++++++++++++++++++++

The ``_bucket`` system space of each replica set stores the ids of buckets present
in the replica set. The space contains the following tuples:

* ``bucket`` – bucket id
* ``status`` – state of the bucket
* ``destination`` – uuid of the destination replica set

An example of ``_bucket.select{}``:

.. code-block:: tarantoolsession

    ---
    - - [1, ACTIVE, abfe2ef6-9d11-4756-b668-7f5bc5108e2a]
      - [2, SENT, 19f83dcb-9a01-45bc-a0cf-b0c5060ff82c]
    ...

Once the bucket is migrated, the destination replica set uuid is filled in the
table. While the bucket is still located on the source replica set, the value of
the destination replica set uuid is equal to ``NULL``.

.. _vshard-router:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Router
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

All requests from the application come to the sharded cluster through a ``router``.
The ``router`` keeps the topology of a sharded cluster transparent for the application,
thus keeping the application unaware of:

* the number and location of shards,
* data rebalancing process,
* the fact and the process of a failover that occurred after a replica's failure.

The ``router`` does not have a persistent state, nor does it store the cluster topology
or balance the data. The ``router`` is a standalone software component that can run
in the storage layer or application layer depending on the application features.

.. _vshard-routing-table:

++++++++++++++++++++++++++++++++++++++++++++++++++++++++
The routing table
++++++++++++++++++++++++++++++++++++++++++++++++++++++++

А routing table on the ``router`` stores the map of all bucket ids to replica sets.
It ensures the consistency of sharding in case of failover.

The ``router`` keeps a persistent pool of connections to all the storages that
are created at startup. This helps prevent configuration errors. Once the connection
pool is created, the ``router`` caches the current state of the routing table in order
to speed up routing. If a bucket migrated to another ``storage`` after rebalancing,
or a failover occurred and caused one of the shards switching to another replica,
the ``discovery fiber`` on the ``router`` updates the routing table automatically.

As the bucket id is explicitly indicated both in the data and in the mapping table
on the ``router``, the data is consistent regardless of the application logic. It also
makes rebalancing transparent for the application.

.. _vshard-process-requests:

++++++++++++++++++++++++++++++++++++++++++++++++++++++++
Processing requests
++++++++++++++++++++++++++++++++++++++++++++++++++++++++

Requests to the database can be performed by the application or using stored
procedures. Either way, the bucket id should be explicitly specified in the request.

All requests are forwarded to the ``router`` first. The only operation supported
by the ``router`` is ``call``. The operation is performed via ``vshard.router.call()``
function:

.. code-block:: lua

    result = vshard.router.call(<bucket_id>, <mode(read:write)>, <function_name>, {<argument_list>}, {<opts>})

Requests are processed as follows:

1. The ``router`` uses the bucket id to search for a replica set with the
   corresponding bucket in the routing table.

   If the map of the bucket id to the replica set is not known to the ``router``
   (the discovery fiber hasn’t filled the table yet), the ``router`` makes requests
   to all ``storages`` to find out where the bucket is located.
2. Once the bucket is located, the shard checks:

   * whether the bucket is stored in the ``_bucket`` system space of the replica set;
   * whether the bucket is ACTIVE or PINNED (for a read request, it can also be SENDING).
3. If all the checks succeed, the request is executed. Otherwise, it is terminated
   with the error: ``“wrong bucket”``.

.. _vshard-admin:

-------------------------------------------------------------------------------
Administration
-------------------------------------------------------------------------------

.. _vshard-config-cluster:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Configuring a sharded cluster
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

A minimal viable sharded cluster should consist of:

* one or more replica sets with two or more ``storage`` instances in each
* one or more ``router`` instances

The number of ``storage`` instances in a replica set defines the redundancy factor
of the data. The recommended value is 3 or more. The number of the ``router`` instances
is not limited, because routers are completely stateless. We recommend increasing
the number of routers when the existing ``router`` instance becomes CPU or I/O bound.

As the ``router`` and ``storage`` applications perform completely different sets of functions,
they should be deployed to different Tarantool instances. Although it is technically
possible to place the router application to every ``storage`` node, this approach is
highly discouraged and should be avoided on production deployments.

All ``storage`` instances can be deployed using identical instance (configuration)
files.

Self-identification is currently performed using ``tarantoolctl``:

.. code-block:: console

    $ tarantoolctl instance_name

All ``router`` instances can also be deployed using identical instance (configuration)
files.

All cluster nodes must share a common topology. You as an administrator must
ensure that the configurations are identical. We suggest using a configuration
management tool like Ansible or Puppet to deploy the cluster.

Sharding is not integrated into any system for centralized configuration management.
It is implied that the application itself is responsible for interacting with such
a system and passing the sharding parameters.

.. _vshard-config-cluster-example:

++++++++++++++++++++++++++++++++++++++++++++++++++++++++
Sample configuration
++++++++++++++++++++++++++++++++++++++++++++++++++++++++

The configuration of a simple sharded cluster can look like this:

.. code-block:: kconfig

    local cfg = {
        memtx_memory = 100 * 1024 * 1024,
        replication_connect_quorum = 0,
        bucket_count = 10000,
        rebalancer_disbalance_threshold = 10,
        rebalancer_max_receiving = 100,
        sharding = {
            ['cbf06940-0790-498b-948d-042b62cf3d29'] = {
                replicas = {
                    ['8a274925-a26d-47fc-9e1b-af88ce939412'] = {
                        uri = 'storage:storage@127.0.0.1:3301',
                        name = 'storage_1_a',
                        master = true
                    },
                    ['3de2e3e1-9ebe-4d0d-abb1-26d301b84633'] = {
                        uri = 'storage:storage@127.0.0.1:3302',
                        name = 'storage_1_b'
                    }
                },
            },
            ['ac522f65-aa94-4134-9f64-51ee384f1a54'] = {
                replicas = {
                    ['1e02ae8a-afc0-4e91-ba34-843a356b8ed7'] = {
                        uri = 'storage:storage@127.0.0.1:3303',
                        name = 'storage_2_a',
                        master = true
                    },
                    ['001688c3-66f8-4a31-8e19-036c17d489c2'] = {
                        uri = 'storage:storage@127.0.0.1:3304',
                        name = 'storage_2_b'
                    }
                },
            },
        },
    }

This cluster includes one ``router`` instance and two ``storage`` instances.
Each ``storage`` instance includes one master and one replica.

The sharding field defines the logical topology of a sharded Tarantool cluster.
All the other fields are passed to ``box.cfg()`` as they are, without modifications.
See the :ref:`Configuration reference <vshard-config-reference>` section for details.

On routers call ``vshard.router.cfg(cfg)``:

.. code-block:: lua

    cfg.listen = 3300

    -- Start the database with sharding
    vshard = require('vshard')
    vshard.router.cfg(cfg)

On storages call ``vshard.storage.cfg(cfg, instance_uuid)``:

.. code-block:: lua

    -- Get instance name
    local MY_UUID = "de0ea826-e71d-4a82-bbf3-b04a6413e417"

    -- Call a configuration provider
    local cfg = require('localcfg')

    -- Start the database with sharding
    vshard = require('vshard')
    vshard.storage.cfg(cfg, MY_UUID)


``vshard.storage.cfg()`` automatically calls box.cfg()and configures the listen
port and replication parameters.

See ``router.lua`` and ``storage.lua`` in the ``vshard/example`` directory for
a sample configuration.

.. _vshard-replica-weights:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Replica weights
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The ``router`` sends all requests to the master instance only. Setting replica
weights allows sending read requests not only to the master instance, but to any
available replica that is the 'nearest' to the ``router``. Weights are used to define
distances between replicas within a replica set.

Weights can be used, for example, to define the physical distance between the
``router`` and each replica in each replica set. In such a case read requests
are sent to the literary nearest replica.

Setting weights can also help to define the most powerful replicas: the ones that
can process the largest number requests per second.

The idea is to specify the zone for every ``router`` and every replica, therefore
filling a matrix of relative zone weights. This approach allows setting different
weights in different zones for the same replica set.

To set weights, use the zone attribute for each replica in configuration:

.. code-block:: kconfig

    local cfg = {
       sharding = {
          ['...replicaset_uuid...'] = {
             replicas = {
                ['...replica_uuid...'] = {
                     ...,
                     zone = <number or string>
                }
             }
          }
       }
    }

Then, specify relative weights for each zone pair in the weights parameter of
``vshard.router.cfg``. For example:

.. code-block:: kconfig

    weights = {
        [1] = {
            [2] = 1, -- routers of the 1st zone see the weight of the 2nd zone as 1
            [3] = 2, -- routers of the 1st zone see the weight of the 3rd zone as 2


       [4] = 3, -- ...
        },
        [2] = {
            [1] = 10,
            [2] = 0,
            [3] = 10,
            [4] = 20,
        },
        [3] = {
            [1] = 100,
            [2] = 200, -- routers of the 3rd zone see the weight of the 2nd zone as 200. Mind that it is not equal to the weight of the 2nd zone = 2 visible from the 1st zone
            [4] = 1000,
        }
    }

    local cfg = vshard.router.cfg({weights = weights, sharding = ...})

.. _vshard-replica-set-weights:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Replica set weights
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

A replica set weight is not the same as the replica weight. The weight of a replica
set defines the capacity of the replica set: the larger the weight, the more
buckets the replica set can store. The total size of all sharded spaces in the
replica set is also its capacity metric.

You can consider replica set weights as the relative amount of data within a
replica set. For example, if ``replicaset_1 = 100``, and ``replicaset_2 = 200``,
the second replica set stores twice as many buckets as the first one. By default,
all weights of all replica sets are equal.

You can use weights, for example, to store the prevailing amount of data on a
replica set with more memory space.

.. _vshard-rebalancing:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Rebalancing process
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

There is an **etalon number** of buckets per a replica set. If there is no deviation
from this number on all the replica set, then the buckets are distributed evenly.

The etalon number is calculated automatically considering the number of buckets
in the cluster and weights of the replica sets.

For example: The user specified the number of buckets equal to 3000, and weights
of 3 replica sets equal to 1, 0.5, and 1.5. The resulting etalon numbers of buckets
for the replica sets are: 1st replica set – 1000, 2nd replica set – 500, 3rd
replica set – 1500.

This approach allows assigning a zero weight to a replica set, which initiates
migration of its buckets to the remaining cluster nodes. It also allows adding
a new zero-load replica set, which initiates migration of the buckets from the
loaded replica sets to the zero-load replica set.

.. NOTE::

    A new zero-load replica set should be assigned a weight for rebalancing to start.

The ``rebalancer`` wakes up periodically and redistributes data from the most
loaded nodes to less loaded nodes. Rebalancing starts if the disbalance threshold
of a replica set exceeds a disbalance threshold specified in the configuration.

The disbalance threshold is calculated as follows:

.. code-block:: none

    |etalon_bucket_number - real_bucket_number| / etalon_bucket_number * 100

When a new shard is added, the configuration can be updated dynamically:

1. The configuration should be updated on all the routers first, and then on all
   the ``storages``.
2. The new shard becomes available for rebalancing in the ``storage`` layer.
3. As a result of rebalancing, buckets are being migrated to the new shard.
4. If a migrated bucket is requested, ``router`` receives an error code containing
   information about the new location of the bucket.

At this time, the new shard is already present in the ``router``'s pool of
connections, so redirection is transparent for the application.

.. _vshard-lock-pin:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Replica set lock and bucket pin
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

A replica set lock makes a replica set invisible for the ``rebalancer``: a locked
replica set can neither receive new buckets, nor migrate its own ones.

A bucket pin blocks a specific bucket from migrating: a pinned bucket stays on
the replica set to which it is pinned, until unpinned.

Pinning all replica set buckets is not equal to locking a replica set. Even if
you pin all buckets, a non-locked replica set can still receive new buckets.

Replica set lock is helpful, for example, to separate a replica set from production
replica sets for testing, or to preserve some application metadata that must not
be sharded for a while. A bucket pin is used for similar cases but in a smaller
scope.

Introducing both locking a replica set and pinning all buckets is done for the
ability to isolate an entire replica set.

Locked replica sets and pinned buckets affect the rebalancing algorithm as the
``rebalancer`` must ignore locked replica sets and consider pinned buckets when
attempting to reach the best possible balance.

The issue is not trivial as a user can pin too many buckets to a replica set,
so a perfect balance becomes unreachable. For example, look at the following
cluster (assume all replica set weights are equal to 1).

The initial configuration:

.. code-block:: none

    rs1: bucket_count = 150
    rs2: bucket_count = 150, pinned_count = 120

Adding a new replica set:

.. code-block:: none

    rs1: bucket_count = 150
    rs2: bucket_count = 150, pinned_count = 120
    rs3: bucket_count = 0

The perfect balance would be ``100 - 100 - 100``, which is impossible since the
``rs2`` replica set has 120 pinned buckets. The best possible balance here is the
following:

.. code-block:: none

    rs1: bucket_count = 90
    rs2: bucket_count = 120, pinned_count 120
    rs3: bucket_count = 90

The ``rebalancer`` moved as many buckets as possible from ``rs2`` to decrease the
disbalance. At the same time it respected equal weights of ``rs1`` and ``rs3``.

The algorithms of considering locks and pins are completely different, although
they look similar in terms of functionality.

.. _vshard-lock-and-rebalancing:

++++++++++++++++++++++++++++++++++++++++++++++++++++++++
Replica set lock and rebalancing
++++++++++++++++++++++++++++++++++++++++++++++++++++++++

Locked replica sets simply don’t participate in rebalancing. This means that
even if the actual total number of buckets is not equal to the etalon number,
the disbalance cannot be fixed due to lock. When the rebalancer detects that
one of the replica sets is locked, it recalculates the etalon number of buckets
of the non-locked replica sets as if the locked replica set and its buckets didn’t
exist at all.

.. _vshard-pin-and-rebalancing:

++++++++++++++++++++++++++++++++++++++++++++++++++++++++
Bucket pin and rebalancing
++++++++++++++++++++++++++++++++++++++++++++++++++++++++

Rebalancing replica sets with pinned buckets requires a more complex algorithm.
Here pinned_count[o] is the number of pinned buckets, and ``etalon_count`` is
the etalon number of buckets per a replica set:

1. The ``rebalancer`` calculates the etalon number of buckets as if all buckets
   were not pinned. Then the rebalancer checks each replica set and compares the
   etalon number of buckets with the number of pinned buckets on a replica set.
   If ``pinned_count < etalon_count``, non-locked replica sets (on this step all
   locked replica sets already are filtered out) with pinned buckets can receive
   new buckets.
2. If ``pinned_count > etalon_count``, the disbalance cannot be fixed, as the
   ``rebalancer`` cannot move pinned buckets out of this replica set. In such a case
   the etalon number is updated and set equal to the number of pinned buckets.
   The replica sets with ``pinned_count > etalon_count`` are not processed by
   the ``rebalancer``, and the number of pinned buckets is subtracted from the
   total number of buckets. The rebalancer tries to move out as many buckets as
   possible from such replica sets.
3. The described procedure is restarted from the step 1 for replica sets with
   ``pinned_count >= etalon_count`` until ``pinned_count <= etalon_count`` on
   all replica sets. The procedure is also restarted when the total number of
   buckets is changed.

The pseudocode for the algorithm is the following:

.. code-block:: lua

    function cluster_calculate_perfect_balance(replicasets, bucket_count)
            -- rebalance the buckets using weights of the still viable replica sets --
    end;

    cluster = <all of the non-locked replica sets>;
    bucket_count = <the total number of buckets in the cluster>;
    can_reach_balance = false
    while not can_reach_balance do
            can_reach_balance = true
            cluster_calculate_perfect_balance(cluster, bucket_count);
            foreach replicaset in cluster do
                    if replicaset.perfect_bucket_count <
                       replicaset.pinned_bucket_count then
                            can_reach_balance = false
                            bucket_count -= replicaset.pinned_bucket_count;
                            replicaset.perfect_bucket_count =
                                    replicaset.pinned_bucket_count;
                    end;
            end;
    end;
    cluster_calculate_perfect_balance(cluster, bucket_count);

The complexity of the algorithm is ``O(N^2)``, where N is the number of replica sets.
On each step, the algorithm either finishes the calculation, or ignores at least
one new replica set overloaded with the pinned buckets, and updates the etalon
number of buckets on other replica sets.

.. _vshard-define-spaces:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Defining spaces
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Spaces should be defined within a storage application using ``box.once()``.
For example:

.. code-block:: lua

    box.once("testapp:schema:1", function()
        local customer = box.schema.space.create('customer')
        customer:format({
            {'customer_id', 'unsigned'},
            {'bucket_id', 'unsigned'},
            {'name', 'string'},
        })
        customer:create_index('customer_id', {parts = {'customer_id'}})
        customer:create_index('bucket_id', {parts = {'bucket_id'}, unique = false})

        local account = box.schema.space.create('account')
        account:format({
            {'account_id', 'unsigned'},
            {'customer_id', 'unsigned'},
            {'bucket_id', 'unsigned'},
            {'balance', 'unsigned'},
            {'name', 'string'},
        })
        account:create_index('account_id', {parts = {'account_id'}})
        account:create_index('customer_id', {parts = {'customer_id'}, unique = false})
        account:create_index('bucket_id', {parts = {'bucket_id'}, unique = false})
        box.snapshot()

        box.schema.func.create('customer_lookup')
        box.schema.role.grant('public', 'execute', 'function', 'customer_lookup')
        box.schema.func.create('customer_add')
    end)

.. _vshard-bootstrap:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Bootstrapping and restarting a storage
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

If a replica set master fails, it is recommended to:

1. Switch one of the replicas into the master mode. It allows the new master
   to process all the incoming requests.
2. Update the configuration of all the cluster members. It forwards all the
   requests to the new master.

Monitoring the master and switching the instance modes can be handled by any
external utility.

To perform a scheduled downtime of a replica set master, it is recommended to:

1. Update the configuration of the master and wait for the replicas to get into
   sync. All the requests then are forwarded to a new master.
2. Switch another instance into the master mode.
3. Update the configuration of all the nodes.
4. Shut down the old master.

To perform a scheduled downtime of a replica set, it is recommended to:

1. Migrate all the buckets to the other cluster storages.
2. Update the configuration of all the nodes.
3. Shut down the replica set.

In case a whole replica set fails, some part of the dataset becomes inaccessible.
Meanwhile, the ``router`` tries to reconnect to the master of the failed replica
set. This way, once the replica set is up and running again, the cluster is
automatically restored.

.. _vshard-fibers:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Fibers
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Search for buckets, buckets recovery, and buckets rebalancing are performed
automatically and do not require human intervention.

Technically, there are multiple fibers responsible for different types of
operations:

* a **discovery** fiber on the ``router`` searches for buckets in the background
* a **failover** fiber on the ``router`` maintains replica connections
* a **garbage** collector fiber on each master ``storage`` removes the contents
  of buckets that were moved
* a **bucket** recovery fiber on each master ``storage`` recovers buckets in the
  SENDING and RECEIVING states in case of reboot
* a **rebalancer** on a single master ``storage`` among all replica sets executes
  the rebalancing process.

  See the :ref:`Rebalancing process<vshard-rebalancing>` section for details.

.. _vshard-gc:

++++++++++++++++++++++++++++++++++++++++++++++++++++++++
Garbage collector
++++++++++++++++++++++++++++++++++++++++++++++++++++++++

A **garbage collection** fiber is running in the background on the master storages
of each replica set. It starts deleting the contents of the bucket in the GARBAGE
state part by part. Once the bucket is empty, its record is deleted from the
``_bucket`` system space.

.. _vshard-bucket-recovery:

++++++++++++++++++++++++++++++++++++++++++++++++++++++++
Bucket recovery
++++++++++++++++++++++++++++++++++++++++++++++++++++++++

A **bucket recovery** fiber is running on the master storages. It helps to recover
buckets in the SENDING and RECEIVING states in case of reboot.

Buckets in the SENDING state are recovered as follows:

1. The system first searches for buckets in the SENDING state.
2. If such a bucket is found, the system sends a request to the destination
   replica set.
3. If the bucket on the destination replica set is ACTIVE, the original bucket
   is deleted from the source node.

Buckets in the RECEIVING state are deleted without extra checks.

.. _vshard-failover:

++++++++++++++++++++++++++++++++++++++++++++++++++++++++
Failover
++++++++++++++++++++++++++++++++++++++++++++++++++++++++

A failover fiber is running on every ``router``. If a master of a replica set
becomes unavailable, the failover redirects read requests to the replicas.
Write requests are rejected with an error until the master becomes available.

.. _vshard-config-reference:

-------------------------------------------------------------------------------
Configuration reference
-------------------------------------------------------------------------------

.. _vshard-config-basic-params:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Basic parameters
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

* :ref:`sharding <cfg_basic-sharding>`
* :ref:`weights <cfg_basic-weights>`
* :ref:`shard_index <cfg_basic-shard_index>`
* :ref:`bucket_count <cfg_basic-bucket_count>`
* :ref:`collect_bucket_garbage_interval <cfg_basic-collect_bucket_garbage_interval>`
* :ref:`collect_lua_garbage <cfg_basic-collect_lua_garbage>`
* :ref:`sync_timeout <cfg_basic-sync_timeout>`
* :ref:`rebalancer_disbalance_threshold <cfg_basic-rebalancer_disbalance_threshold>`
* :ref:`rebalancer_max_receiving <cfg_basic-rebalancer_max_receiving>`

.. _cfg_basic-sharding:

.. confval:: sharding

    A field defining the logical topology of the sharded Tarantool cluster.

    | Type: table
    | Default: false
    | Dynamic: yes

.. _cfg_basic-weights:

.. confval:: weights

    A field defining the configuration of relative weights for each zone pair in a
    replica set. See :ref:`Replica weights <vshard-replica-weights>` section.

    | Type: table
    | Default: false
    | Dynamic: yes

.. _cfg_basic-shard_index:

.. confval:: shard_index

    An index over the bucket id.

    | Type: non-empty string or non-negative integer
    | Default: coincides with the bucket id number
    | Dynamic: no

.. _cfg_basic-bucket_count:

.. confval:: bucket_count

    A total number of buckets in a cluster.

    This number should be several orders of magnitude larger than the potential number
    of cluster nodes, considering the potential scaling out in the foreseeable future.

    **Example:**

    If the estimated number of nodes is M, then the data set should be divided into
    100M or even 1000M buckets, depending on the planned scale out. This number is
    certainly greater than the potential number of cluster nodes in the system being
    designed.

    Mind that too many buckets can cause the need to allocate more memory to store
    routing information. In its turn, an insufficient number of buckets can lead to
    decreased granularity when rebalancing.

    | Type: number
    | Default: 3000
    | Dynamic: no

.. _cfg_basic-collect_bucket_garbage_interval:

.. confval:: collect_bucket_garbage_interval

    The interval between the garbage collector actions, in seconds.

    | Type: number
    | Default: 0.5
    | Dynamic: yes

.. _cfg_basic-collect_lua_garbage:

.. confval:: collect_lua_garbage

    If set to true, the Lua’s collectgarbage() function is called periodically.

    | Type: boolean
    | Default: no
    | Dynamic: yes

.. _cfg_basic-sync_timeout:

.. confval:: sync_timeout

    Timeout to wait for synchronization of the old master with replicas before
    demotion. Used when switching a master or when manually calling the
    ``sync()`` function.

    | Type: number
    | Default: 1
    | Dynamic: yes

.. _cfg_basic-rebalancer_disbalance_threshold:

.. confval:: rebalancer_disbalance_threshold

    A maximal bucket disbalance threshold, in percent.
    The threshold is calculated for each replica set using the following formula:

    .. code-block:: none

        |etalon_bucket_count - real_bucket_count| / etalon_bucket_count * 100

    | Type: number
    | Default: 1
    | Dynamic: yes

.. _cfg_basic-rebalancer_max_receiving:

.. confval:: rebalancer_max_receiving

    The maximal number of buckets that can be received in parallel by a single
    replica set. This number must be limited, as when a new replica set is added to
    a cluster, the rebalancer sends a very large amount of buckets from the existing
    replica sets to the new replica set. This produces a heavy load on a new replica set.

    **Example:**

    Suppose ``rebalancer_max_receiving`` is equal to 100, ``bucket_count`` is equal to 1000.
    There are 3 replica sets with 333, 333 and 334 buckets on each correspondingly.
    When a new replica set is added, each replica set’s ``etalon_bucket_count`` becomes
    equal to 250. Rather than receiving all 250 buckets at once, the new replica set
    receives 100, 100 and 50 buckets sequentially.

    | Type: number
    | Default: 100
    | Dynamic: yes

.. _vshard-config-replica-set-funcs:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Replica set functions
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

* :ref:`uuid <cfg_replica_set-uuid>`
* :ref:`weight <cfg_replica_set-weight>`

.. _cfg_replica_set-uuid:

.. confval:: uuid

    A unique identifier of a replica set.

    | Type:
    | Default:
    | Dynamic:

.. _cfg_replica_set-weight:

.. confval:: weight

    A weight of a replica set. See the :ref:`Replica set weights <vshard-replica-set-weights>`
    section for the details.

    | Type:
    | Default: 1
    | Dynamic:

.. _vshard-api-reference:

-------------------------------------------------------------------------------
API reference
-------------------------------------------------------------------------------

.. _vshard_api_reference-router_public_api:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Router public API
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

* :ref:`vshard.router.bootstrap() <router_api-bootstrap>`
* :ref:`vshard.router.cfg(cfg, instance_uuid) <router_api-cfg>`
* :ref:`vshard.router.call(bucket_id, mode(read:write), function_name, {argument_list}, {options}) <router_api-call>`
* :ref:`vshard.router.callro(bucket_id, function_name, {argument_list}, {options}) <router_api-callro>`
* :ref:`vshard.router.callrw(bucket_id, function_name, {argument_list}, {options}) <router_api-callrw>`
* :ref:`vshard.router.route(bucket_id) <router_api-route>`
* :ref:`vshard.router.routeall() <router_api-routeall>`
* :ref:`vshard.router.bucket_id(key) <router_api-bucket_id>`
* :ref:`vshard.router.bucket_count() <router_api-bucket_count>`
* :ref:`vshard.router.sync(timeout) <router_api-sync>`
* :ref:`vshard.router.discovery_wakeup() <router_api-discovery_wakeup>`
* :ref:`vshard.router.info() <router_api-info>`
* :ref:`vshard.router.buckets_info() <router_api-buckets_info>`
* :ref:`replicaset.call() <router_api-replicaset_call>`
* :ref:`replicaset.callro() <router_api-replicaset_callro>`
* :ref:`replicaset.callrw() <router_api-replicaset_callrw>`

.. _router_api-bootstrap:

.. function:: vshard.router.bootstrap()

    Perform the initial cluster bootstrap and distribute all buckets across the
    replica sets.

.. _router_api-cfg:

.. function:: vshard.router.cfg(cfg)

    Configure the database and start sharding for the specified ``router`` instance.

    :param cfg: a ``router`` configuration

.. _router_api-call:

.. function:: vshard.router.call(bucket_id, mode(read:write), function_name, {argument_list}, {options})

    Call the user function on the shard storing the bucket with the specified
    bucket id. See the :ref:`Processing requests <vshard-process-requests>` section
    for details on function operation.

    :param bucket_id: a bucket identifier
    :param mode: a type of the function: read or write
    :param function_name: a function to execute
    :param argument_list: an array of the function's arguments
    :param options:

        * ``timeout`` – a request timeout, in seconds. In case the router cannot identify a
          shard with the bucket id, the operation will be repeated until the
          timeout is reached.

    :Return:

    The original return value of the executed function, or ``nil`` and
    error object. The error object has a type attribute equal to ``ShardingError``
    or one of the regular Tarantool errors (``ClientError``, ``OutOfMemory``,
    ``SocketError``, etc.).

    ``ShardingError`` is returned on errors specific for sharding: the replica
    set is not available, the master is missing, wrong bucket id, etc. It has an
    attribute code containing one of the values from the ``vshard.error.code.*`` LUA table, an
    optional attribute containing a message with the human-readable error description,
    and other attributes specific for this error code.

    **Example:**

    To call ``customer_add`` function from ``vshard/example``, say:

    .. code-block:: lua

        result = vshard.router.call(100, 'write', 'customer_add', {{customer_id = 2, bucket_id = 100, name = 'name2', accounts = {}}}, {timeout = 100})

.. _router_api-callro:

.. function:: vshard.router.callro(bucket_id, function_name, {argument_list}, {options})

    Call the user function on the shard storing the bucket with the specified
    bucket id in the read only mode. See the
    :ref:`Processing requests <vshard-process-requests>` section for details on
    function operation.

    :param bucket_id: a bucket identifier
    :param function_name: a function to execute
    :param argument_list: an array of the function's arguments
    :param options:

        * ``timeout`` – a request timeout, in seconds. In case the ``router`` cannot identify a
          shard with the bucket id, the operation will be repeated until the
          timeout is reached.

    :Return:

    The original return value of the executed function, or ``nil`` and
    error object. The error object has a type attribute equal to ``ShardingError``
    or one of the regular Tarantool errors (``ClientError``, ``OutOfMemory``,
    ``SocketError``, etc.).

    ``ShardingError`` is returned on errors specific for sharding: the replica
    set is not available, the master is missing, wrong bucket id, etc. It has an
    attribute code containing one of the values from the ``vshard.error.code.*`` LUA table, an
    optional attribute containing a message with the human-readable error description,
    and other attributes specific for this error code.

.. _router_api-callrw:

.. function:: vshard.router.callrw(bucket_id, function_name, {argument_list}, {options})

    Call the user function on the shard storing the bucket with the specified
    bucket id in the write mode. See the :ref:`Processing requests <vshard-process-requests>` section
    for details on function operation.

    :param bucket_id: a bucket identifier
    :param function_name: a function to execute
    :param argument_list: an array of the function's arguments
    :param options:

        * ``timeout`` – a request timeout, in seconds. In case the ``router`` cannot identify a
          shard with the bucket id, the operation will be repeated until the
          timeout is reached.

    :Return:

    The original return value of the executed function, or ``nil`` and
    error object. The error object has a type attribute equal to ``ShardingError``
    or one of the regular Tarantool errors (``ClientError``, ``OutOfMemory``,
    ``SocketError``, etc.).

    ``ShardingError`` is returned on errors specific for sharding: the replica
    set is not available, the master is missing, wrong bucket id, etc. It has an
    attribute code containing one of the values from the ``vshard.error.code.*`` LUA table, an
    optional attribute containing a message with the human-readable error description,
    and other attributes specific for this error code.

.. _router_api-route:

.. function:: vshard.router.route(bucket_id)

    Return the replica set object for the bucket with the specified bucket id.

    :param bucket_id: a bucket identifier

    :Return: a replica set object

    **Example:**

    .. code-block:: lua

        replicaset = vshard.router.route(123)

.. _router_api-routeall:

.. function:: vshard.router.routeall()

    Return all available replica set objects.

    :Return: a map of the following type: ``{UUID = replicaset}``
    :Rtype: a replica set object

    **Example:**

    .. code-block:: lua

        replicaset = vshard.router.routeall()

.. _router_api-bucket_id:

.. function:: vshard.router.bucket_id(key)

    Calculate the bucket id using a simple built-in hash function.

    :param key: a hash key. This can be any Lua object (number, table, string).

    :Return: a bucket identifier
    :Rtype: number

    **Example:**

    .. code-block:: lua

        bucket_id = vshard.router.bucket_id(18374927634039)

.. _router_api-bucket_count:

.. function:: vshard.router.bucket_count()

    Return the total number of buckets specified in ``vshard.router.cfg()``.

    :Return: the total number of buckets
    :Rtype: number

.. _router_api-sync:

.. function:: vshard.router.sync(timeout)

    Wait until the dataset is synchronized on replicas.

    :param timeout: a timeout, in seconds

.. _router_api-discovery_wakeup:

.. function:: vshard.router.discovery_wakeup()

    Force wakeup of the bucket discovery fiber.

.. _router_api-info:

.. function:: vshard.router.info()

    Return the information on each instance.

    :Return:

    Replica set parameters:

    * replica set uuid
    * master instance parameters
    * replica instance parameters

    Instance parameters:

    * ``uri`` — an URI of the instance
    * ``uuid`` — an UUID of the instance
    * ``status`` – a status of the instance (``available``, ``unreachable``, ``missing``)
    * ``network_timeout`` – a timeout for the request. The value is updated automatically
      on each 10th successful request and each 2nd failed request.

    Bucket parameters:

    * ``available_ro`` – the number of buckets known to the ``router`` and available for read requests
    * ``available_rw`` – the number of buckets known to the router and available for read and write requests
    * ``unavailable`` – the number of buckets known to the ``router`` but unavailable for any requests
    * ``unreachable`` – the number of buckets which replica sets are not known to the ``router``

    **Example:**

    .. code-block:: tarantoolsession

        tarantool> vshard.router.info()
        ---
        - replicasets:
            ac522f65-aa94-4134-9f64-51ee384f1a54:
              replica: &0
                network_timeout: 0.5
                status: available
                uri: storage@127.0.0.1:3303
                uuid: 1e02ae8a-afc0-4e91-ba34-843a356b8ed7
              uuid: ac522f65-aa94-4134-9f64-51ee384f1a54
              master: *0
            cbf06940-0790-498b-948d-042b62cf3d29:
              replica: &1
                network_timeout: 0.5
                status: available
                uri: storage@127.0.0.1:3301
                uuid: 8a274925-a26d-47fc-9e1b-af88ce939412
              uuid: cbf06940-0790-498b-948d-042b62cf3d29
              master: *1
          bucket:
            unreachable: 0
            available_ro: 0
            unknown: 0
            available_rw: 3000
          status: 0
          alerts: []
        ...

.. _router_api-buckets_info:

.. function:: vshard.router.buckets_info()

    Return the information on each bucket. Since a bucket map can be huge,
    only the required range of buckets can be specified.

    :param offset: the offset in a bucket map to select from
    :param limit: the maximum number of the shown buckets

    :Return: the map of the following type: ``{bucket_id = 'unknown'/replicaset_uuid}``

.. _router_api-replicaset_call:

.. function:: replicaset.call(replicaset, function_name, {argument_list}, {options})

    Call a function on a nearest available master (distances are defined using
    ``replica.zone`` and ``cfg.weights`` matrix) with a specified
    arguments.

    .. NOTE::

        The ``replicaset.call`` method is similar to ``replicaset.callrw``.

    :param replicaset: an UUID of a replica set
    :param function_name: a function to execute
    :param argument_list: an array of the function's arguments
    :param options:

        * ``timeout`` – a request timeout, in seconds. In case the ``router`` cannot identify a
          shard with the bucket id, the operation will be repeated until the
          timeout is reached.

.. _router_api-replicaset_callrw:

.. function:: replicaset.callrw(replicaset, function_name, {argument_list}, {options})

    Call a function on a nearest available master (distances are defined using
    ``replica.zone`` and ``cfg.weights`` matrix) with a specified
    arguments.

    .. NOTE::

        The ``replicaset.callrw`` method is similar to ``replicaset.call``.

    :param replicaset: an UUID of a replica set
    :param function_name: a function to execute
    :param argument_list: an array of the function's arguments
    :param options:

        * ``timeout`` – a request timeout, in seconds. In case the ``router`` cannot identify a
          shard with the bucket id, the operation will be repeated until the
          timeout is reached.

.. _router_api-replicaset_callro:

.. function:: replicaset.callro(bucket_id, function_name, {argument_list}, {options})

    Call a function on a nearest available replica (distances are defined using
    ``replica.zone`` and ``cfg.weights`` matrix) with a specified
    arguments. It is recommended to call only read-only functions using
    ``replicaset.callro()``, as the function can be executed not only on a master,
    but also on replicas.

    :param replicaset: an UUID of a replica set
    :param function_name: a function to execute
    :param argument_list: an array of the function's arguments
    :param options:

        * ``timeout`` – a request timeout, in seconds. In case the ``router`` cannot identify a
          shard with the bucket id, the operation will be repeated until the
          timeout is reached.

.. _vshard_api_reference-router_internal_api:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Router internal API
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

* :ref:`vshard.router.bucket_discovery(bucket_id) <router_api-bucket_discovery>`

.. _router_api-bucket_discovery:

.. function:: vshard.router.bucket_discovery(bucket_id)

    Search for the bucket in the whole cluster. If the bucket wasn’t
    found, it’s likely that it doesn’t exist. The bucket might also be
    moved during rebalancing and currently is in the RECEIVING state.

    :param bucket_id: a bucket identifier

.. _vshard-storage_public_api:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Storage public API
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

* :ref:`vshard.storage.cfg(cfg, name) <storage_api-cfg>`
* :ref:`vshard.storage.info() <storage_api-info>`
* :ref:`vshard.storage.sync(timeout) <storage_api-sync>`
* :ref:`vshard.storage.bucket_pin(bucket_id) <storage_api-bucket_pin>`
* :ref:`vshard.storage.bucket_unpin(bucket_id) <storage_api-bucket_unpin>`
* :ref:`vshard.storage.find_garbage_bucket(bucket_index, control) <storage_api-find_garbage_bucket>`
* :ref:`vshard.storage.rebalancer_disable() <storage_api-rebalancer_disable>`
* :ref:`vshard.storage.rebalancer_enable() <storage_api-rebalancer_enable>`
* :ref:`vshard.storage.is_locked() <storage_api-is_locked>`
* :ref:`vshard.storage.rebalancing_is_in_progress() <storage_api-rebalancing_is_in_progress>`
* :ref:`vshard.storage.buckets_info() <storage_api-buckets_info>`
* :ref:`vshard.storage.buckets_count() <storage_api-buckets_count>`
* :ref:`vshard.storage.sharded_spaces() <storage_api-sharded_spaces>`

.. _storage_api-cfg:

.. function:: vshard.storage.cfg(cfg, name)

    Configure the database and start sharding for the specified ``storage``
    instance.

    :param cfg: a ``storage`` configuration
    :param instance_uuid: an uuid of the instance

.. _storage_api-info:

.. function:: vshard.storage.info()

    Return the information on the storage instance in the following format:

    .. code-block:: tarantoolsession

        tarantool> vshard.storage.info()
        ---
        - buckets:
            2995:
              status: active
              id: 2995
            2997:
              status: active
              id: 2997
            2999:
              status: active
              id: 2999
          replicasets:
            2dd0a343-624e-4d3a-861d-f45efc571cd3:
              uuid: 2dd0a343-624e-4d3a-861d-f45efc571cd3
              master:
                state: active
                uri: storage:storage@127.0.0.1:3301
                uuid: 2ec29309-17b6-43df-ab07-b528e1243a79
            c7ad642f-2cd8-4a8c-bb4e-4999ac70bba1:
              uuid: c7ad642f-2cd8-4a8c-bb4e-4999ac70bba1
              master:
                state: active
                uri: storage:storage@127.0.0.1:3303
                uuid: 810d85ef-4ce4-4066-9896-3c352fec9e64
        ...

.. _storage_api-sync:

.. function:: vshard.storage.sync(timeout)

    Wait until the dataset is synchronized on replicas.

    :param timeout: a timeout, in seconds

.. _storage_api-bucket_pin:

.. function:: vshard.storage.bucket_pin(bucket_id)

    Pin a bucket to a replica set. Pinned bucket can not be moved
    even if it breaks the cluster balance.

    :param bucket_id: a bucket identifier

    :return: ``true`` if the bucket is unpinned successfully; or ``nil`` and
             ``err`` explaining why the bucket cannot be unpinned

.. _storage_api-bucket_unpin:

.. function:: vshard.storage.bucket_unpin(bucket_id)

    Return a pinned bucket back into the active state.

    :param bucket_id: a bucket identifier

    :return: ``true`` if the bucket is unpinned successfully; or ``nil`` and
             ``err`` explaining why the bucket cannot be unpinned

.. _storage_api-find_garbage_bucket:

.. function:: vshard.storage.find_garbage_bucket(bucket_index, control)

    Find a bucket which has data in a space, but is not stored
    in a _bucket space; or a bucket is in a garbage state.

    :param bucket_index: index of a space with the part of a bucket id
    :param control: a garbage collector controller. If there is an increased
                    buckets generation, then the search should be interrupted.

    :return: an identifier of the bucket in the garbage state, if found; otherwise,
             nil

.. _storage_api-buckets_info:

.. function:: vshard.storage.buckets_info()

    Return the information on each bucket located on storage.

.. _storage_api-buckets_count:

.. function:: vshard.storage.buckets_count()

    Return the number of buckets located on storage.

.. _storage_api-recovery_wakeup:

.. function:: vshard.storage.recovery_wakeup()

    Immediately wake up recovery fiber, if exists.

.. _storage_api-rebalancing_is_in_progress:

.. function:: vshard.storage.rebalancing_is_in_progress()

    A flag indicating whether rebalancing is in progress. The value is true,
    if the node is currently applying routes received from a rebalancer node in
    the special fiber.

.. _storage_api-is_locked:

.. function:: vshard.storage.is_locked()

    A flag indicating whether a rebalancer is locked.

.. _storage_api-rebalancer_disable:

.. function:: vshard.storage.rebalancer_disable()

    Disable rebalancing. Disabled rebalancer sleeps until it
    is enabled back.

.. _storage_api-rebalancer_enable:

.. function:: vshard.storage.rebalancer_enable()

    Enable rebalancing.

.. _storage_api-sharded_spaces:

.. function:: vshard.storage.sharded_spaces()

    Show the spaces that are visible for rebalancer and garbage collector.

.. _vshard-storage_internal_api:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Storage internal API
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

* :ref:`vshard.storage.bucket_stat(bucket_id) <storage_api-bucket_stat>`
* :ref:`vshard.storage.bucket_recv(bucket_id, from, data) <storage_api-bucket_recv>`
* :ref:`vshard.storage.bucket_delete_garbage(bucket_id) <storage_api-bucket_delete_garbage>`
* :ref:`vshard.storage.bucket_collect(bucket_id) <storage_api-bucket_collect>`
* :ref:`vshard.storage.bucket_force_create(first_bucket_id, count) <storage_api-bucket_force_create>`
* :ref:`vshard.storage.bucket_force_drop(bucket_id, to) <storage_api-bucket_force_drop>`
* :ref:`vshard.storage.bucket_send(bucket_id, to) <storage_api-bucket_send>`
* :ref:`vshard.storage.buckets_discovery() <storage_api-buckets_discovery>`
* :ref:`vshard.storage.rebalancer_request_state() <storage_api-rebalancer_request_state>`

.. _storage_api-bucket_recv:

.. function:: vshard.storage.bucket_recv(bucket_id, from, data)

    Receive a bucket id from a remote replica set.

    :param bucket_id: a bucket identifier
    :param from: a source replica set UUID
    :param data: a data logically stored in a bucket id in the same format as
                 the ``bucket_collect() <storage_api-bucket_collect>`` method
                 return value

.. _storage_api-bucket_stat:

.. function:: vshard.storage.bucket_stat(bucket_id)

    Returns information about the bucket id:

    .. code-block:: tarantoolsession

        tarantool> vshard.storage.bucket_stat(1)
        ---
        - 0
        - status: active
          id: 1
        ...

    :param bucket_id: a bucket identifier

.. _storage_api-bucket_delete_garbage:

.. function:: vshard.storage.bucket_delete_garbage(bucket_id)

    Force garbage collection for the bucket id in case the bucket was
    transferred to a different replica set.

    :param bucket_id: a bucket identifier

.. _storage_api-bucket_collect:

.. function:: vshard.storage.bucket_collect(bucket_id)

    Collect all the data that is logically stored in the bucket id:

    .. code-block:: tarantoolsession

        tarantool> vshard.storage.bucket_collect(1)
        ---
        - 0
        - - - 514
            - - [10, 1, 1, 100, 'Account 10']
              - [11, 1, 1, 100, 'Account 11']
              - [12, 1, 1, 100, 'Account 12']
              - [50, 5, 1, 100, 'Account 50']
              - [51, 5, 1, 100, 'Account 51']
              - [52, 5, 1, 100, 'Account 52']
          - - 513
            - - [1, 1, 'Customer 1']
              - [5, 1, 'Customer 5']
        ...

    :param bucket_id: a bucket identifier

.. _storage_api-bucket_force_create:

.. function:: vshard.storage.bucket_force_create(first_bucket_id, count)

    Force creation of the buckets (single or multiple) on the current replica
    set. Use only for manual emergency recovery or initial bootstrap.

    :param first_bucket_id: an identifier of the first bucket in a range
    :param count: a number of buckets to insert (1 by default)

.. _storage_api-bucket_force_drop:

.. function:: vshard.storage.bucket_force_drop(bucket_id)

    Drop a bucket manually for tests or emergency cases.

    :param bucket_id: a bucket identifier

.. _storage_api-bucket_send:

.. function:: vshard.storage.bucket_send(bucket_id, to)

    Transfer a bucket id from the current replica set to the remote replica set.

    :param bucket_id: a bucket identifier
    :param to: a remote replica set UUID

.. _storage_api-rebalancer_request_state:

.. function:: vshard.storage.rebalancer_request_state()

    Check all buckets of the host storage that have the SENT or ACTIVE
    state, return the number of active buckets.

    :return: the number of buckets in the active state, if found; otherwise, nil

.. _storage_api-buckets_discovery:

.. function:: vshard.storage.buckets_discovery()

    Collect an array of active bucket identifiers for discovery.

.. _vshard-glossary:

-------------------------------------------------------------------------------
Glossary
-------------------------------------------------------------------------------

.. glossary::

    .. vshard-vertical_scaling:

    **Vertical scaling**
        Adding more power to a single server: using a more powerful CPU, adding
        more capacity to RAM, adding more storage space, etc.

    .. vshard-horizontal_scaling:

    **Horizontal scaling**
        Adding more servers to the pool of resources, then partitioning and
        distributing a dataset across the servers.

    .. vshard-sharding:

    **Horizontal scaling**
        A database architecture that allows partitioning a dataset using a shard
        key and distributing a dataset across multiple servers. Sharding is a
        special case of horizontal scaling.

    .. vshard-node:

    **Node**
        A virtual or physical server instance.

    .. vshard-cluster:

    **Cluster**
        A set of nodes that make up a single group.

    .. vshard-storage:

    **Storage**
        A node storing a subset of a dataset.

    .. vshard-replica_set:

    **Replica set**
        A set of storage nodes storing copies of a dataset. Each storage in a
        replica set has a role, master or replica.

    .. vshard-master:

    **Master**
        A storage in a replica set processing read and write requests.

    .. vshard-replica:

    **Replica**
        A storage in a replica set processing only read requests.

    .. vshard-read_requests:

    **Read requests**
        Read-only requests, that is select requests.

    .. vshard-write_requests:

    **Write requests**
        Data-change operations, that is create, replace, update, delete requests.

    .. vshard-bucket:

    **Buckets (virtual buckets)**
        The abstract virtual nodes into which the dataset is partitioned by the
        sharding key (bucket id).

    .. vshard-bucket-id:

    **Bucket id**
        A sharding key defining which bucket belongs to which replica set.

    .. vshard-router:

    **Router**
        A proxy server responsible for routing requests from an application to
        nodes in a cluster.
