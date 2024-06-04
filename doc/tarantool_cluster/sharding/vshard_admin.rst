..  _vshard-admin:

Sharding with vshard
====================

Sharding in Tarantool is implemented in the ``vshard`` module.
For a quick start with ``vshard``, refer to :ref:`vshard-quick-start`.

.. NOTE::

    Starting with the 3.0 version, the recommended way of configuring Tarantool is using a :ref:`configuration file <configuration_file>`.
    The :ref:`sharding <configuration_reference_sharding>` section defines configuration parameters related to sharding.
    To learn how to configure ``vshard`` in code, see :ref:`vshard-config-reference`.


..  _vshard-install:

Installation
------------

The ``vshard`` module is distributed separately from the main Tarantool package.
To install the module, execute the following command:

..  code-block:: console

    $ tt rocks install vshard

If you are developing a sharded cluster application, add the ``vshard`` module dependency to a ``*.rockspec`` file:

..  literalinclude:: /code_snippets/snippets/sharding/instances.enabled/sharded_cluster/sharded_cluster-scm-1.rockspec
    :language: none
    :start-at: dependencies
    :end-before: build
    :dedent:

..  note::

    The minimum required version of ``vshard`` is 0.1.25.


..  _vshard-config-cluster:

Configuration overview
----------------------

Configuring settings related to sharding might include the following steps:

1.  Configure :ref:`connection settings <vshard_config_connectivity>` to allow instances within a sharded cluster to communicate with each other.

2.  Specify which :ref:`role <vshard_config_sharding_roles>` each replica set plays in a sharded cluster.

3.  Configure how data is :ref:`partitioned <vshard_config_data_partitioning>` across shards.

4.  Specify settings related to :ref:`data rebalancing <vshard_config_rebalancing>`.


.. _vshard_config_connectivity:

Connectivity
------------

This section describes connection options that enable communication between instances within a sharded cluster.
For general information about connections, see the :ref:`configuration_connections` topic.

.. _vshard_config_advertise_uri:

Advertise URI
~~~~~~~~~~~~~

In a sharded cluster configuration, you need to specify how a router and rebalancer connect to storages using the :ref:`iproto.advertise.sharding <configuration_reference_iproto_advertise_sharding>` option.
In the example below, the ``storage`` user is used for this purpose:

..  literalinclude:: /code_snippets/snippets/sharding/instances.enabled/sharded_cluster/config.yaml
    :language: yaml
    :start-at: iproto
    :end-at: login: storage
    :dedent:

The ``storage`` user should have the ``sharding`` role described in the next section.


.. _vshard_config_credentials:

Credentials
~~~~~~~~~~~

To allow a router and rebalancer to connect to storages, a user with the ``sharding`` :ref:`role <access_control_concepts_roles>` should be used.
The example below shows how to grant the ``sharding`` role to the ``storage`` user:

..  literalinclude:: /code_snippets/snippets/sharding/instances.enabled/sharded_cluster/config.yaml
    :language: yaml
    :start-at: credentials:
    :end-at: roles: [sharding]
    :dedent:

The ``sharding`` role has different privileges depending on a replica set's :ref:`sharding role <vshard_config_sharding_roles>`.
For replica sets with the ``storage`` sharding role, the ``sharding`` credential role has the following privileges:

-   All privileges provided by the ``replication`` role.
-   Executing :ref:`vshard.storage.* <vshard-vshard_storage>` functions.

If a replica set does not have the ``storage`` sharding role, the ``sharding`` credential role does not have any privileges.


.. _vshard_config_sharding_roles:

Sharding roles
--------------

Each replica set in a sharded cluster can have one of three roles:

*   ``router``: a replica set acts as a :ref:`router <vshard-architecture-router>`.
*   ``storage``: a replica set acts as a :ref:`storage <vshard-architecture-storage>`.
*   ``rebalancer``: a replica set acts as a :ref:`rebalancer <vshard-rebalancer>`.

You can use the :ref:`sharding.roles <configuration_reference_sharding_roles>` option to assign a specific role to a replica set or group of replica sets.
In the example below, all replica sets in the ``storages`` group have the ``storage`` role while replica sets in the ``routers`` group have the ``router`` role.

..  code-block:: yaml

    groups:
      storages:
        sharding:
          roles: [storage]
        # ...
      routers:
        sharding:
          roles: [router]
        # ...

Note that the ``rebalancer`` role is optional.
If it is not specified, a rebalancer is selected automatically from the master instances of replica sets.
To specify the rebalancer manually or turn it off, use the :ref:`sharding.rebalancer_mode <configuration_reference_sharding_rebalancer_mode>` option.


.. _vshard_config_data_partitioning:

Data partitioning
-----------------

This section describes configuration settings related to data partitioning.
Learn how to define spaces to be sharded in :ref:`vshard-define-spaces`.


.. _vshard_config_bucket_count:

Bucket count
~~~~~~~~~~~~

To define the total number of buckets in a cluster, configure the :ref:`sharding.bucket_count <configuration_reference_sharding_bucket_count>` option at the :ref:`global level <configuration_scopes>`.
In the example below, ``sharding.bucket_count`` is set to 1000:

..  literalinclude:: /code_snippets/snippets/sharding/instances.enabled/sharded_cluster/config.yaml
    :language: yaml
    :start-after: login: storage
    :end-at: bucket_count
    :dedent:

``sharding.bucket_count`` should be several orders of magnitude larger than the potential number of cluster nodes considering potential scaling out in the future.

If the estimated number of nodes in a cluster is N, then the data set should be divided into 100N or even 1000N buckets depending on the planned scaling out.
This number is greater than the potential number of cluster nodes in the system being designed.

Keep in mind that too many buckets can cause a need to allocate more memory to store routing information.
On the other hand, an insufficient number of buckets can lead to decreased granularity when :ref:`rebalancing <vshard-rebalancing>`.



..  _vshard-replica-set-weights:

Replica set weights
~~~~~~~~~~~~~~~~~~~

A replica set weight defines the storage capacity of the replica set: the larger the weight, the more buckets the replica set can store.
You can configure a replica set weight using the :ref:`sharding.weight <configuration_reference_sharding_weight>` option.
This option can be used to store the prevailing amount of data on a replica set with more memory space.
You can also assign a zero weight to a replica set to initiate :ref:`migration of its buckets <vshard_config_rebalancing>` to the remaining cluster nodes.

In the example below, the ``storage-a`` replica set can store twice as much data as ``storage-b``:

..  code-block:: yaml

    # ...
    replicasets:
      storage-a:
        sharding:
          weight: 2
        # ...
      storage-b:
        sharding:
          weight: 1
        # ...


.. _vshard_config_rebalancing:

Data rebalancing
----------------


..  _vshard-rebalancing:

Rebalancing process
~~~~~~~~~~~~~~~~~~~

There is an **etalon number** of buckets for a replica set.
(Etalon in this context means "ideal".)
If there is no deviation
from this number in the whole replica set, then the buckets are distributed evenly.

The etalon number is calculated automatically considering the number of buckets
in the cluster and the weights of the replica sets.

Rebalancing starts if the **disbalance threshold of a replica set**
exceeds the disbalance threshold specified in the configuration
(the :ref:`sharding.rebalancer_disbalance_threshold <configuration_reference_sharding_rebalancer_disbalance_threshold>` option).

The disbalance threshold of a replica set is calculated as follows:

.. code-block:: none

    |etalon_bucket_number - real_bucket_number| / etalon_bucket_number * 100

For example, a cluster is configured as follows:

*   The number of buckets (:ref:`sharding.bucket_count <configuration_reference_sharding_bucket_count>`) is set to 3000.
*   :ref:`Weights <vshard-replica-set-weights>` of 3 replica sets are 1, 0.5, and 1.5.

In this case, the etalon numbers of buckets for the replica sets are:

*   1st replica set -- 1000.
*   2nd replica set -- 500.
*   3rd replica set -- 1500.

You can set a :ref:`replica set weight <vshard-replica-set-weights>` to zero to initiate migration of its buckets to the remaining cluster nodes.
You can also add a new replica set with a non-zero weight to initiate migration of the buckets from the existing replica sets.

When a new shard is added, a configuration should be reloaded on each instance to migrate buckets to a new shard:

*   If a :ref:`centralized configuration storage <configuration_etcd>` is used, Tarantool reloads a changed configuration automatically.
*   If a local configuration file is used, you need to reload a configuration on all the routers first and then on all the storages.


..  _vshard-parallel-rebalancing:

Parallel rebalancing
~~~~~~~~~~~~~~~~~~~~

Originally, ``vshard`` had quite a simple ``rebalancer`` –
one process on one node that calculated *routes* that should send buckets, how
many, and to whom. The nodes applied these routes one by
one sequentially.

Unfortunately, such a simple schema worked not fast enough,
especially for Vinyl, where costs of reading disk were comparable
with network costs. In fact, with Vinyl the ``rebalancer`` routes
applier was sleeping most of the time.

Now each node can send multiple buckets in parallel in a
round-robin manner to multiple destinations, or to just one.

To set the degree of parallelism, use the :ref:`sharding.rebalancer_max_sending <configuration_reference_sharding_rebalancer_max_sending>` option:

..  code-block:: yaml

    sharding:
      rebalancer_max_sending: 5

..  note::

    Specifying ``sharding.rebalancer_max_sending = N`` probably won't give N times
    speed up. It depends on network, disk, number of other fibers in the system.

..  _vshard-parallel-rebalancing-example1:

Example 1
*********

You have 10 replica sets and a new one is added.
Now all the 10 replica sets will try to send buckets to the new one.

Assume that each replica set can send up to 5 buckets at once. In that case,
the new replica set will experience a rather big load of 50 buckets
being downloaded at once. If the node needs to do some other
work, perhaps such a big load is undesirable. Also too, many
parallel buckets can cause timeouts in the rebalancing process
itself.

To fix the problem, you can set a lower value for ``rebalancer_max_sending``
for old replica sets, or decrease ``rebalancer_max_receiving`` for the new one.
In the latter case, some workers on old nodes will be throttled,
and you will see that in the logs.

``rebalancer_max_sending`` is important, if you have restrictions for
the maximum number of buckets that can be read only at once in the cluster. As you
remember, when a bucket is being sent, it does not accept new
write requests.

..  _vshard-parallel-rebalancing-example2:

Example 2
*********

You have 100000 buckets and each
bucket stores ~0.001% of your data. The cluster has 10
replica sets. And you never can afford > 0.1% of data locked on
write. Then you should not set ``rebalancer_max_sending`` > 10 on
these nodes. It guarantees that the rebalancer won't send more
than 100 buckets at once in the whole cluster.

If ``rebalancer_max_sending`` is too high and ``rebalancer_max_receiving`` is too low,
then some buckets will try to get relocated – and will fail with that.
This problem will consume network resources and time. It is important to
configure these parameters to not conflict with each other.

..  _vshard-lock-pin:

Replica set lock and bucket pin
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

A replica set lock (:ref:`sharding.lock <configuration_reference_sharding_lock>`) makes a replica set invisible to the ``rebalancer``: a locked
replica set can neither receive new buckets nor migrate its own buckets.

A bucket pin (:ref:`vshard.storage.bucket_pin(bucket_id) <storage_api-bucket_pin>`) blocks a specific bucket from migrating: a pinned bucket stays on
the replica set to which it is pinned until it is unpinned.

Pinning all replica set buckets is not equivalent to locking a replica set. Even if
you pin all buckets, a non-locked replica set can still receive new buckets.

A replica set lock is helpful, for example, to separate a replica set from production
replica sets for testing, or to preserve some application metadata that must not
be sharded for a while. A bucket pin is used for similar cases but in a smaller
scope.

By both locking a replica set and pinning all buckets, you can
isolate an entire replica set.

Locked replica sets and pinned buckets affect the rebalancing algorithm as the
``rebalancer`` must ignore locked replica sets and consider pinned buckets when
attempting to reach the best possible balance.

The issue is not trivial as a user can pin too many buckets to a replica set,
so a perfect balance becomes unreachable. For example, consider the following
cluster (assume all replica set weights are equal to 1).

The initial configuration:

..  code-block:: none

    rs1: bucket_count = 150
    rs2: bucket_count = 150, pinned_count = 120

Adding a new replica set:

..  code-block:: none

    rs1: bucket_count = 150
    rs2: bucket_count = 150, pinned_count = 120
    rs3: bucket_count = 0

The perfect balance would be ``100 - 100 - 100``, which is impossible since the
``rs2`` replica set has 120 pinned buckets. The best possible balance here is the
following:

..  code-block:: none

    rs1: bucket_count = 90
    rs2: bucket_count = 120, pinned_count 120
    rs3: bucket_count = 90

The ``rebalancer`` moved as many buckets as possible from ``rs2`` to decrease the
disbalance. At the same time, it respected equal weights of ``rs1`` and ``rs3``.

The algorithms for implementing locks and pins are completely different, although
they look similar in terms of functionality.

..  _vshard-lock-and-rebalancing:

Replica set lock and rebalancing
********************************

Locked replica sets do not participate in rebalancing. This means that
even if the actual total number of buckets is not equal to the etalon number,
the disbalance cannot be fixed due to the lock. When the rebalancer detects that
one of the replica sets is locked, it recalculates the etalon number of buckets
of the non-locked replica sets as if the locked replica set and its buckets did
not exist at all.

..  _vshard-pin-and-rebalancing:

Bucket pin and rebalancing
**************************

Rebalancing replica sets with pinned buckets requires a more complex algorithm.
Here ``pinned_count[o]`` is the number of pinned buckets, and ``etalon_count`` is
the etalon number of buckets for a replica set:

1.  The ``rebalancer`` calculates the etalon number of buckets as if all buckets
    were not pinned. Then the rebalancer checks each replica set and compares the
    etalon number of buckets with the number of pinned buckets in a replica set.
    If ``pinned_count < etalon_count``, non-locked replica sets (at this point all
    locked replica sets already are filtered out) with pinned buckets can receive
    new buckets.
2.  If ``pinned_count > etalon_count``, the disbalance cannot be fixed, as the
    ``rebalancer`` cannot move pinned buckets out of this replica set. In such a case
    the etalon number is updated and set equal to the number of pinned buckets.
    The replica sets with ``pinned_count > etalon_count`` are not processed by
    the ``rebalancer``, and the number of pinned buckets is subtracted from the
    total number of buckets. The rebalancer tries to move out as many buckets as
    possible from such replica sets.
3.  This procedure is restarted from step 1 for replica sets with
    ``pinned_count >= etalon_count`` until ``pinned_count <= etalon_count`` on
    all replica sets. The procedure is also restarted when the total number of
    buckets is changed.

Here is the pseudocode for the algorithm:

..  code-block:: lua

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

..  _vshard-ref:

Bucket ref
~~~~~~~~~~

Bucket ref is an in-memory counter that is similar to the
:ref:`bucket pin <vshard-lock-pin>`, but has the following differences:

#.  Bucket ref is not persistent. Refs are intended for forbidding bucket transfer
    during request execution, but on restart all requests are dropped.

#.  There are two types of bucket refs: read-only (RO) and read-write (RW).

    If a bucket has RW refs, it cannot be moved. However, when the rebalancer
    needs it to be sent, it locks the bucket for new write requests, waits
    until all current requests are finished, and then sends the bucket.

    If a bucket has RO refs, it can be sent, but cannot be dropped. Such a
    bucket can even enter GARBAGE or SENT state, but its data is kept until
    the last reader is gone.

    A single bucket can have both RO and RW refs.

#.  Bucket ref is countable.

The :ref:`vshard.storage.bucket_ref/unref()<storage_api-bucket_ref>` methods
are called automatically when :ref:`vshard.router.call() <router_api-call>`
or :ref:`vshard.storage.call() <storage_api-call>` is used.
For raw API like ``r = vshard.router.route() r:callro/callrw``, you should
explicitly call the ``bucket_ref()`` method inside the function. Also, make sure
that you call ``bucket_unref()`` after ``bucket_ref()``, otherwise the bucket
cannot be moved from the storage until the instance is restarted.

To see how many refs there are for a bucket, use
:ref:`vshard.storage.buckets_info([bucket_id]) <storage_api-buckets_info>`
(the ``bucket_id`` parameter is optional).

For example:

..  code-block:: tarantoolsession

    vshard.storage.buckets_info(1)
    ---
    - 1:
        status: active
        ref_rw: 1
        ref_ro: 1
        ro_lock: true
        rw_lock: true
        id: 1



.. _vshard_defining_manipulating_data:

Defining and manipulating data
------------------------------

..  _vshard-define-spaces:

Data definition
~~~~~~~~~~~~~~~

Sharded spaces should be defined in a storage application inside :ref:`box.once() <box-once>` and should have a field with :ref:`bucket id <vshard-vbuckets>` values.
This field should meet the following requirements:

-   The field's :ref:`data type <index-box_data-types>` can be ``unsigned``, ``number``, or ``integer``.
-   The field must be non-nullable.
-   The field must be indexed by the :ref:`shard_index <configuration_reference_sharding_shard_index>`. The default name for this index is ``bucket_id``.

In the example below, the ``bands`` space has the ``bucket_id`` field, which is used to partition a dataset across different storage instances:

..  literalinclude:: /code_snippets/snippets/sharding/instances.enabled/sharded_cluster/storage.lua
    :language: lua
    :start-at: box.once
    :end-before: function insert_band
    :dedent:

Example on GitHub: `sharded_cluster <https://github.com/tarantool/doc/tree/latest/doc/code_snippets/snippets/sharding/instances.enabled/sharded_cluster>`_




..  _vshard-adding-data:

Data manipulation
~~~~~~~~~~~~~~~~~

All DML operations with data should be performed via a router using the ``vshard.router.call`` functions, such as :ref:`vshard.router.callrw() <router_api-callrw>` or :ref:`vshard.router.callro() <router_api-callro>`.
For example, a storage application has the ``insert_band`` function used to insert new tuples:

..  literalinclude:: /code_snippets/snippets/sharding/instances.enabled/sharded_cluster/storage.lua
    :language: lua
    :start-at: function insert_band
    :end-before: function get_band
    :dedent:

In a router application, you can define the ``put`` function that specifies how a router selects the storage to write data:

..  literalinclude:: /code_snippets/snippets/sharding/instances.enabled/sharded_cluster/router.lua
    :language: lua
    :start-at: function put
    :end-before: function get
    :dedent:

Learn more at :ref:`vshard-process-requests`.

.. _vshard-maintenance:

Sharded cluster maintenance
---------------------------

.. _vshard-maintenance-master_crash:

Master crash
~~~~~~~~~~~~

If a replica set master fails, it is recommended to:

#.  Switch one of the replicas into the master mode. This allows the new master
    to process all the incoming requests.
#.  Update the configuration of all the cluster members. This forwards all the
    requests to the new master.

.. _vshard-maintenance-replicaset_crash:

Replica set crash
~~~~~~~~~~~~~~~~~

In case a whole replica set fails, some part of the dataset becomes inaccessible.
Meanwhile, the router tries to reconnect to the master of the failed replica set.
This way, once the replica set is up and running again, the cluster is automatically restored.


.. _vshard-maintenance-master_scheduled_downtime:

Master scheduled downtime
~~~~~~~~~~~~~~~~~~~~~~~~~

To perform a scheduled downtime of a replica set master, it is recommended to:

#.  Update the configuration to use another instance as a master.
#.  Reload the configuration on all the instances.
    All the requests then are forwarded to a new master.
#   Shut down the old master.

.. _vshard-maintenance-replicaset_scheduled_downtime:

Replica set scheduled downtime
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

To perform a scheduled downtime of a replica set, it is recommended to:

#.  Migrate all the buckets to the other cluster storages.
    You can do this by assigning a zero :ref:`weight <vshard-replica-set-weights>` to a replica set to initiate migration of its buckets to the remaining cluster nodes.
#.  Update the configuration of all the nodes.
#.  Shut down the replica set.


..  _vshard-fibers:

Fibers
------

Searches for buckets, buckets recovery, and buckets rebalancing are performed
automatically and do not require manual intervention.

Technically, there are multiple fibers responsible for different types of
operations:

*   a **discovery** fiber on the router searches for buckets in the background
*   a **failover** fiber on the router maintains replica connections
*   a **garbage collector** fiber on each master storage removes the contents
    of buckets that were moved
*   a **bucket recovery** fiber on each master storage recovers buckets in the
    SENDING and RECEIVING states in case of reboot
*   a **rebalancer** on a single master storage among all replica sets executes the rebalancing process.

See the :ref:`Rebalancing process <vshard-rebalancing>` and
:ref:`Migration of buckets <vshard-migrate-buckets>` sections for details.

..  _vshard-gc:

Garbage collector
~~~~~~~~~~~~~~~~~


A **garbage collector** fiber runs in the background on the master storages
of each replica set. It starts deleting the contents of the bucket in the GARBAGE
state part by part. Once the bucket is empty, its record is deleted from the
``_bucket`` system space.

..  _vshard-bucket-recovery:

Bucket recovery
~~~~~~~~~~~~~~~

A **bucket recovery** fiber runs on the master storages. It helps to recover
buckets in the SENDING and RECEIVING states in case of reboot.

Buckets in the SENDING state are recovered as follows:

1.  The system first searches for buckets in the SENDING state.
2.  If such a bucket is found, the system sends a request to the destination
    replica set.
3.  If the bucket on the destination replica set is ACTIVE, the original bucket
    is deleted from the source node.

Buckets in the RECEIVING state are deleted without extra checks.

..  _vshard-failover:

Failover
~~~~~~~~

A **failover** fiber runs on every router. If a master of a replica set
becomes unavailable, the failover fiber redirects read requests to the replicas.
Write requests are rejected with an error until the master becomes available.
