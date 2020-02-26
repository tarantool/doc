.. _vshard-admin:

===============================================================================
Administration
===============================================================================

.. _vshard-install:

-------------------------------------------------------------------------------
Installation
-------------------------------------------------------------------------------

The ``vshard`` module is distributed separately from the main Tarantool package.
To install it, say this:

.. code-block:: console

    $ tarantoolctl rocks install vshard

.. NOTE::

    The ``vshard`` module requires Tarantool version 1.9+,
    `Tarantool development package <https://www.tarantool.io/en/doc/1.10/tutorials/c_tutorial/#c-stored-procedures>`_,
    ``git``, ``cmake`` and ``gcc`` packages installed.

.. _vshard-config-cluster:

-------------------------------------------------------------------------------
Configuration
-------------------------------------------------------------------------------

Any viable sharded cluster consists of:

* one or more replica sets, each containing two or more
  :ref:`storage <vshard-storage>` instances,
* one or more :ref:`router <vshard-router>` instances.

The number of ``storage`` instances in a replica set defines the redundancy factor
of the data. The recommended value is 3 or more. The number of ``router`` instances
is not limited, because routers are completely stateless. We recommend increasing
the number of routers when an existing ``router`` instance becomes CPU or I/O bound.

``vshard`` supports multiple ``router`` instances on a single Tarantool
instance. Each ``router`` can be connected to any ``vshard`` cluster. Multiple
``router`` instances can be connected to the same cluster.

As the ``router`` and ``storage`` applications perform completely different sets of functions,
they should be deployed to different Tarantool instances. Although it is technically
possible to place the router application on every ``storage`` node, this approach is
highly discouraged and should be avoided on production deployments.

All ``storage`` instances can be deployed using identical instance (configuration)
files.

Self-identification is currently performed using ``tarantoolctl``:

.. code-block:: console

    $ tarantoolctl instance_name

All ``router`` instances can also be deployed using identical instance (configuration)
files.

All cluster nodes must share a common topology. An administrator must
ensure that the configurations are identical. We suggest using a configuration
management tool like Ansible or Puppet to deploy the cluster.

Sharding is not integrated into any system for centralized configuration management.
It is expected that the application itself is responsible for interacting with such
a system and passing the sharding parameters.

The configuration example of a simple sharded cluster is available
:ref:`here <vshard-config-cluster-example>`.

.. _vshard-replica-weights:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Replica weights
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The ``router`` sends all read-write requests to the master instance only. Setting replica
weights allows sending read-only requests not only to the master instance, but to any
available replica that is the 'nearest' to the ``router``. Weights are used to define
distances between replicas within a replica set.

Weights can be used, for example, to define the physical distance between the
``router`` and each replica in each replica set. In this case read requests
are sent to the nearest replica (with the lowest weight).

Setting weights can also help to define the most powerful replicas: the ones that
can process the largest number of requests per second.

The idea is to specify the zone for every ``router`` and every replica, therefore
filling a matrix of relative zone weights. This approach allows setting different
weights in different zones for the same replica set.

To set weights, use the zone attribute for each replica during configuration:

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

Then, specify relative weights for each zone pair in the ``weights`` parameter of
``vshard.router.cfg``. For example:

.. code-block:: kconfig

    weights = {
        [1] = {
            [2] = 1, -- Routers of the 1st zone see the weight of the 2nd zone as 1.
            [3] = 2, -- Routers of the 1st zone see the weight of the 3rd zone as 2.
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
            [2] = 200, -- Routers of the 3rd zone see the weight of the 2nd zone as 200.
                       -- Mind that it is not equal to the weight of the 2nd zone visible
                       -- from the 1st zone (= 1).
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

There is an **etalon number** of buckets for a replica set.
(Etalon in this context means "ideal".)
If there is no deviation
from this number in the whole replica set, then the buckets are distributed evenly.

The etalon number is calculated automatically considering the number of buckets
in the cluster and weights of the replica sets.

Rebalancing starts if the **disbalance threshold of a replica set**
exceeds the disbalance threshold
:ref:`specified in the configuration <cfg_basic-rebalancer_disbalance_threshold>`.

The disbalance threshold of a replica set is calculated as follows:

.. code-block:: none

    |etalon_bucket_number - real_bucket_number| / etalon_bucket_number * 100

For example: The user specified the number of buckets is 3000, and weights
of 3 replica sets are 1, 0.5, and 1.5. The resulting etalon numbers of buckets
for the replica sets are: 1st replica set – 1000, 2nd replica set – 500, 3rd
replica set – 1500.

This approach allows assigning a zero weight to a replica set, which initiates
migration of its buckets to the remaining cluster nodes. It also allows adding
a new zero-load replica set, which initiates migration of the buckets from the
loaded replica sets to the zero-load replica set.

.. NOTE::

    A new zero-load replica set should be assigned a weight for rebalancing to start.

When a new shard is added, the configuration can be updated dynamically:

1. The configuration should be updated on all the ``routers`` first, and then on all
   the ``storages``.
2. The new shard becomes available for rebalancing in the ``storage`` layer.
3. As a result of rebalancing, buckets are migrated to the new shard.
4. If a migrated bucket is requested, ``router`` receives an error code containing
   information about the new location of the bucket.

At this time, the new shard is already present in the ``router``'s pool of
connections, so redirection is transparent for the application.

.. _vshard-parallel-rebalancing:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Parallel rebalancing
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Originally, ``vshard`` had quite a simple ``rebalancer`` –
one process on one node that calculated *routes* which should send buckets, how
many, and to whom. The nodes applied these routes one by
one sequentially.

Unfortunately, such a simple schema worked not fast enough,
especially for Vinyl, where costs of reading disk were comparable
with network costs. In fact, with Vinyl the ``rebalancer`` routes
applier was sleeping most of the time.

Now each node can send multiple buckets in parallel in a
round-robin manner to multiple destinations, or to just one.

To set the degree of parallelism, a new option was added --
:ref:`rebalancer_max_sending <cfg_basic-rebalancer_max_sending>`.
You can specify it in a storage configuration in the root table:

.. code-block:: lua

    cfg.rebalancer_max_sending = 5
    vshard.storage.cfg(cfg, box.info.uuid)

In routers, this option is ignored.

.. NOTE::

    Specifying ``cfg.rebalancer_max_sending = N`` probably won't give N times
    speed up. It depends on network, disk, number of other fibers in the system.

**Example #1:**

  You have 10 replica sets and a new one is added.
  Now all the 10 replica sets will try to send buckets to the new one.

  Assume that each replica set can send up to 5 buckets at once. In that case,
  the new replica set will experience a rather big load of 50 buckets
  being downloaded at once. If the node needs to do some other
  work, perhaps such a big load is undesirable. Also too many
  parallel buckets can cause timeouts in the rebalancing process
  itself.

  To fix the problem, you can set a lower value for ``rebalancer_max_sending``
  for old replica sets, or decrease ``rebalancer_max_receiving`` for the new one.
  In the latter case some workers on old nodes will be throttled,
  and you will see that in the logs.

``rebalancer_max_sending`` is important, if you have restrictions for
the maximal number of buckets that can be read-only at once in the cluster. As you
remember, when a bucket is being sent, it does not accept new
write requests.

**Example #2:**

  You have 100000 buckets and each
  bucket stores ~0.001% of your data. The cluster has 10
  replica sets. And you never can afford > 0.1% of data locked on
  write. Then you should not set ``rebalancer_max_sending`` > 10 on
  these nodes. It guarantees that the rebalancer won't send more
  than 100 buckets at once in the whole cluster.

If ``max_sending`` is too high and ``max_receiving`` is too low,
then some buckets will try to get relocated – and will fail with that.
This problem will consume network resources and time. It is important to
configure these parameters to not conflict with each other.

.. _vshard-lock-pin:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Replica set lock and bucket pin
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

A replica set lock makes a replica set invisible to the ``rebalancer``: a locked
replica set can neither receive new buckets nor migrate its own buckets.

A bucket pin blocks a specific bucket from migrating: a pinned bucket stays on
the replica set to which it is pinned, until it is unpinned.

Pinning all replica set buckets is not equivalent to locking a replica set. Even if
you pin all buckets, a non-locked replica set can still receive new buckets.

Replica set lock is helpful, for example, to separate a replica set from production
replica sets for testing, or to preserve some application metadata that must not
be sharded for a while. A bucket pin is used for similar cases but in a smaller
scope.

By both locking a replica set and pinning all buckets, one can
isolate an entire replica set.

Locked replica sets and pinned buckets affect the rebalancing algorithm as the
``rebalancer`` must ignore locked replica sets and consider pinned buckets when
attempting to reach the best possible balance.

The issue is not trivial as a user can pin too many buckets to a replica set,
so a perfect balance becomes unreachable. For example, consider the following
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

The algorithms for implementing locks and pins are completely different, although
they look similar in terms of functionality.

.. _vshard-lock-and-rebalancing:

++++++++++++++++++++++++++++++++++++++++++++++++++++++++
Replica set lock and rebalancing
++++++++++++++++++++++++++++++++++++++++++++++++++++++++

Locked replica sets simply do not participate in rebalancing. This means that
even if the actual total number of buckets is not equal to the etalon number,
the disbalance cannot be fixed due to the lock. When the rebalancer detects that
one of the replica sets is locked, it recalculates the etalon number of buckets
of the non-locked replica sets as if the locked replica set and its buckets did
not exist at all.

.. _vshard-pin-and-rebalancing:

++++++++++++++++++++++++++++++++++++++++++++++++++++++++
Bucket pin and rebalancing
++++++++++++++++++++++++++++++++++++++++++++++++++++++++

Rebalancing replica sets with pinned buckets requires a more complex algorithm.
Here ``pinned_count[o]`` is the number of pinned buckets, and ``etalon_count`` is
the etalon number of buckets for a replica set:

1. The ``rebalancer`` calculates the etalon number of buckets as if all buckets
   were not pinned. Then the rebalancer checks each replica set and compares the
   etalon number of buckets with the number of pinned buckets in a replica set.
   If ``pinned_count < etalon_count``, non-locked replica sets (at this point all
   locked replica sets already are filtered out) with pinned buckets can receive
   new buckets.
2. If ``pinned_count > etalon_count``, the disbalance cannot be fixed, as the
   ``rebalancer`` cannot move pinned buckets out of this replica set. In such a case
   the etalon number is updated and set equal to the number of pinned buckets.
   The replica sets with ``pinned_count > etalon_count`` are not processed by
   the ``rebalancer``, and the number of pinned buckets is subtracted from the
   total number of buckets. The rebalancer tries to move out as many buckets as
   possible from such replica sets.
3. This procedure is restarted from step 1 for replica sets with
   ``pinned_count >= etalon_count`` until ``pinned_count <= etalon_count`` on
   all replica sets. The procedure is also restarted when the total number of
   buckets is changed.

Here is the pseudocode for the algorithm:

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

.. _vshard-ref:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Bucket ref
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Bucket ref is an in-memory counter that is similar to the
:ref:`bucket pin <vshard-lock-pin>`, but has the following differences:

#. Bucket ref is not persistent. Refs are intended for forbidding bucket transfer
   during request execution, but on restart all requests are dropped.

#. There are two types of bucket refs: read-only (RO) and read-write (RW).

   If a bucket has RW refs, it cannot be moved. However, when the rebalancer
   needs it to be sent, it locks the bucket for new write requests, waits
   until all current requests are finished, and then sends the bucket.

   If a bucket has RO refs, it can be sent, but cannot be dropped. Such a
   bucket can even enter GARBAGE or SENT state, but its data is kept until
   the last reader is gone.

   A single bucket can have both RO and RW refs.

#. Bucket ref is countable.

The :ref:`vshard.storage.bucket_ref/unref()<storage_api-bucket_ref>` methods
are called automatically when :ref:`vshard.router.call() <router_api-call>`
or :ref:`vshard.storage.call() <storage_api-call>` is used.
For raw API like ``r = vshard.router.route() r:callro/callrw`` you should
explicitly call the ``bucket_ref()`` method inside the function. Also, make sure
that you call ``bucket_unref()`` after ``bucket_ref()``, otherwise the bucket
cannot be moved from the storage until the instance restart.

To see how many refs there are for a bucket, use
:ref:`vshard.storage.buckets_info([bucket_id]) <storage_api-buckets_info>`
(the ``bucket_id`` parameter is optional).

For example:

.. code-block:: tarantoolsession

    vshard.storage.buckets_info(1)
    ---
    - 1:
        status: active
        ref_rw: 1
        ref_ro: 1
        ro_lock: true
        rw_lock: true
        id: 1

.. _vshard-define-spaces:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Defining spaces
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Database Schema is stored on ``storages``, while ``routers`` know nothing about
spaces and tuples.

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

.. NOTE::

    Every space you plan to shard must have a field with
    :ref:`bucket id <vshard-vbuckets>` numbers, indexed by the
    :ref:`shard index <cfg_basic-shard_index>`.

.. _vshard-adding-data:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Adding data
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

All DML operations with data should be performed via ``router``. The
only operation supported by ``router`` is `CALL` via ``bucket_id``:

.. code-block:: lua

    result = vshard.router.call(bucket_id, mode, func, args)

``vshard.router.call()`` routes ``result = func(unpack(args))`` call to a shard
which serves ``bucket_id``.

``bucket_id`` is just a regular number in the range
``1..``:ref:`bucket_count<cfg_basic-bucket_count>`. This number can be assigned in
an arbitrary way by the client application. A sharded Tarantool cluster uses this
number as an opaque unique identifier to distribute data across replica sets. It
is guaranteed that all records with the same ``bucket_id`` will be stored on the
same replica set.

.. _vshard-bootstrap:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Bootstrapping and restarting a storage
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

If a replica set master fails, it is recommended to:

#. Switch one of the replicas into the master mode. This allows the new master
   to process all the incoming requests.
#. Update the configuration of all the cluster members. This forwards all the
   requests to the new master.

Monitoring the master and switching the instance modes can be handled by any
external utility.

To perform a scheduled downtime of a replica set master, it is recommended to:

#. Update the configuration of the master and wait for the replicas to get into
   sync. All the requests then are forwarded to a new master.
#. Switch another instance into the master mode.
#. Update the configuration of all the nodes.
#. Shut down the old master.

To perform a scheduled downtime of a replica set, it is recommended to:

#. Migrate all the buckets to the other cluster storages.
#. Update the configuration of all the nodes.
#. Shut down the replica set.

In case a whole replica set fails, some part of the dataset becomes inaccessible.
Meanwhile, the ``router`` tries to reconnect to the master of the failed replica
set. This way, once the replica set is up and running again, the cluster is
automatically restored.

.. _vshard-fibers:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Fibers
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Searches for buckets, buckets recovery, and buckets rebalancing are performed
automatically and do not require manual intervention.

Technically, there are multiple fibers responsible for different types of
operations:

* a **discovery** fiber on the ``router`` searches for buckets in the background
* a **failover** fiber on the ``router`` maintains replica connections
* a **garbage collector** fiber on each master ``storage`` removes the contents
  of buckets that were moved
* a **bucket recovery** fiber on each master ``storage`` recovers buckets in the
  SENDING and RECEIVING states in case of reboot
* a **rebalancer** on a single master ``storage`` among all replica sets executes
  the rebalancing process.

See the :ref:`Rebalancing process <vshard-rebalancing>` and
:ref:`Migration of buckets <vshard-migrate-buckets>` sections for details.

.. _vshard-gc:

++++++++++++++++++++++++++++++++++++++++++++++++++++++++
Garbage collector
++++++++++++++++++++++++++++++++++++++++++++++++++++++++

A **garbage collector** fiber runs in the background on the master storages
of each replica set. It starts deleting the contents of the bucket in the GARBAGE
state part by part. Once the bucket is empty, its record is deleted from the
``_bucket`` system space.

.. _vshard-bucket-recovery:

++++++++++++++++++++++++++++++++++++++++++++++++++++++++
Bucket recovery
++++++++++++++++++++++++++++++++++++++++++++++++++++++++

A **bucket recovery** fiber runs on the master storages. It helps to recover
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

A **failover** fiber runs on every ``router``. If a master of a replica set
becomes unavailable, the failover fiber redirects read requests to the replicas.
Write requests are rejected with an error until the master becomes available.
