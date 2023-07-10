.. _vshard-config-reference:

===============================================================================
Configuration reference
===============================================================================

.. _vshard-config-basic-params:

-------------------------------------------------------------------------------
Basic parameters
-------------------------------------------------------------------------------

* :ref:`sharding <cfg_basic-sharding>`
* :ref:`weights <cfg_basic-weights>`
* :ref:`shard_index <cfg_basic-shard_index>`
* :ref:`bucket_count <cfg_basic-bucket_count>`
* :ref:`collect_bucket_garbage_interval <cfg_basic-collect_bucket_garbage_interval>`
* :ref:`collect_lua_garbage <cfg_basic-collect_lua_garbage>`
* :ref:`sync_timeout <cfg_basic-sync_timeout>`
* :ref:`rebalancer_disbalance_threshold <cfg_basic-rebalancer_disbalance_threshold>`
* :ref:`rebalancer_max_receiving <cfg_basic-rebalancer_max_receiving>`
* :ref:`rebalancer_max_sending <cfg_basic-rebalancer_max_sending>`
* :ref:`discovery_mode <cfg_basic-discovery_mode>`

.. _cfg_basic-sharding:

.. confval:: sharding

    A field defining the logical topology of the sharded Tarantool cluster.

    | Type: table
    | Default: false
    | Dynamic: yes

.. _cfg_basic-weights:

.. confval:: weights

    A field defining the configuration of relative weights for each zone pair in a
    replica set. See the :ref:`Replica weights <vshard-replica-weights>` section.

    | Type: table
    | Default: false
    | Dynamic: yes

.. _cfg_basic-shard_index:

.. confval:: shard_index

    Name or id of a TREE index over the :ref:`bucket id <vshard-vbuckets>`.
    Spaces without this index do not participate in a sharded Tarantool
    cluster and can be used as regular spaces if needed. It is necessary to
    specify the first part of the index, other parts are optional.

    | Type: non-empty string or non-negative integer
    | Default: "bucket_id"
    | Dynamic: no

.. _cfg_basic-bucket_count:

.. confval:: bucket_count

    The total number of buckets in a cluster.

    This number should be several orders of magnitude larger than the potential number
    of cluster nodes, considering potential scaling out in the foreseeable future.

    **Example:**

    If the estimated number of nodes is M, then the data set should be divided into
    100M or even 1000M buckets, depending on the planned scaling out. This number is
    certainly greater than the potential number of cluster nodes in the system being
    designed.

    Keep in mind that too many buckets can cause a need to allocate more memory to store
    routing information. On the other hand, an insufficient number of buckets can lead to
    decreased granularity when rebalancing.

    | Type: number
    | Default: 3000
    | Dynamic: no

.. _cfg_basic-collect_bucket_garbage_interval:

.. confval:: collect_bucket_garbage_interval

    The interval between garbage collector actions, in seconds.

    | Type: number
    | Default: 0.5
    | Dynamic: yes

.. _cfg_basic-collect_lua_garbage:

.. confval:: collect_lua_garbage

    If set to true, the Lua ``collectgarbage()`` function is called periodically.

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

    A maximum bucket disbalance threshold, in percent.
    The disbalance is calculated for each replica set using the following formula:

    .. code-block:: none

        |etalon_bucket_count - real_bucket_count| / etalon_bucket_count * 100

    | Type: number
    | Default: 1
    | Dynamic: yes

.. _cfg_basic-rebalancer_max_receiving:

.. confval:: rebalancer_max_receiving

    The maximum number of buckets that can be received in parallel by a single
    replica set. This number must be limited, because when a new replica set is added to
    a cluster, the rebalancer sends a very large amount of buckets from the existing
    replica sets to the new replica set. This produces a heavy load on the new replica set.

    **Example:**

    Suppose ``rebalancer_max_receiving`` is equal to 100, ``bucket_count`` is equal to 1000.
    There are 3 replica sets with 333, 333 and 334 buckets on each respectively.
    When a new replica set is added, each replica set’s ``etalon_bucket_count`` becomes
    equal to 250. Rather than receiving all 250 buckets at once, the new replica set
    receives 100, 100 and 50 buckets sequentially.

    | Type: number
    | Default: 100
    | Dynamic: yes

.. _cfg_basic-rebalancer_max_sending:

.. confval:: rebalancer_max_sending

    The degree of parallelism for
    :ref:`parallel rebalancing <vshard-parallel-rebalancing>`.

    Works for storages only, ignored for routers.

    The maximum value is ``15``.

    | Type: number
    | Default: 1
    | Dynamic: yes

.. _cfg_basic-discovery_mode:

.. confval:: discovery_mode

    A mode of a bucket discovery fiber: ``on``/``off``/``once``. See details
    :ref:`below <router_api-discovery_set>`.

    | Type: string
    | Default: 'on'
    | Dynamic: yes

.. _vshard-config-replica-set-funcs:

-------------------------------------------------------------------------------
Replica set parameters
-------------------------------------------------------------------------------

* :ref:`uuid <cfg_replica_set-uuid>`
* :ref:`weight <cfg_replica_set-weight>`
* :ref:`master <cfg_replica_set-master>`

.. _cfg_replica_set-uuid:

.. confval:: uuid

    A unique identifier of a replica set.

    | Type:
    | Default:
    | Dynamic:

.. _cfg_replica_set-weight:

.. confval:: weight

    A weight of a replica set. See the :ref:`Replica set weights <vshard-replica-set-weights>`
    section for details.

    | Type:
    | Default: 1
    | Dynamic:

..  _cfg_replica_set-master:

..  confval:: master

    Turns on automated master discovery in a replica set if set to ``auto``.
    Applicable only to the configuration of a router; the storage configuration ignores this parameter.

    The parameter should be specified per replica set.
    The configuration is not compatible with a manual master selection.

    **Examples**

    Correct configuration:

    ..  code-block:: kconfig
        :emphasize-lines: 4

        config = {
            sharding = {
                <replicaset uuid> = {
                    master = 'auto',
                    replicas = {...},
                },
                ...
            },
            ...
        }

    Incorrect configuration:

    ..  code-block:: kconfig
        :emphasize-lines: 4, 7, 11

        config = {
            sharding = {
                <replicaset uuid> = {
                    master = 'auto',
                    replicas = {
                        <replica uuid1> = {
                            master = true,
                            ...
                        },
                        <replica uuid2> = {
                            master = false,
                            ...
                        },
                    },
                },
                ...
            },
            ...
        }

    If the configuration is incorrect, it is not applied, and the ``vshard.router.cfg()`` call throws an error.

    If the ``master`` parameter is set to ``auto`` for some replica sets, the router goes to these replica sets,
    discovers the master in each of them, and periodically checks if the master instance still has its master status.
    When the master in the replica set stops being a master, the router goes around all the nodes of the replica set
    to find out which one is the new master.

    Without this setting, the router cannot detect master nodes in the configured replica sets on its own.
    It relies only on how they are specified in the configuration.
    This becomes a problem when the master changes, and the change is not delivered to the router's configuration:
    for instance, in case the router doesn't rely on a central configuration provider
    or the provider cannot deliver a new configuration due to some reason.

    | Type: string
    | Default: ``nil``
    | Dynamic: yes
