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
    The threshold is calculated for each replica set using the following formula:

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
Replica set functions
-------------------------------------------------------------------------------

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
    section for details.

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
* :ref:`vshard.router.cfg(cfg) <router_api-cfg>`
* :ref:`vshard.router.new(name, cfg) <router_api-new>`
* :ref:`vshard.router.call(bucket_id, mode, function_name, {argument_list}, {options}) <router_api-call>`
* :ref:`vshard.router.callro(bucket_id, function_name, {argument_list}, {options}) <router_api-callro>`
* :ref:`vshard.router.callrw(bucket_id, function_name, {argument_list}, {options}) <router_api-callrw>`
* :ref:`vshard.router.callre(bucket_id, function_name, {argument_list}, {options}) <router_api-callre>`
* :ref:`vshard.router.callbro(bucket_id, function_name, {argument_list}, {options}) <router_api-callbro>`
* :ref:`vshard.router.callbre(bucket_id, function_name, {argument_list}, {options}) <router_api-callbre>`
* :ref:`vshard.router.route(bucket_id) <router_api-route>`
* :ref:`vshard.router.routeall() <router_api-routeall>`
* :ref:`vshard.router.bucket_id_strcrc32(key) <router_api-bucket_id_strcrc32>`
* :ref:`vshard.router.bucket_id_mpcrc32(key) <router_api-bucket_id_mpcrc32>`
* :ref:`vshard.router.bucket_count() <router_api-bucket_count>`
* :ref:`vshard.router.sync(timeout) <router_api-sync>`
* :ref:`vshard.router.discovery_wakeup() <router_api-discovery_wakeup>`
* :ref:`vshard.router.discovery_set() <router_api-discovery_set>`
* :ref:`vshard.router.info() <router_api-info>`
* :ref:`vshard.router.buckets_info() <router_api-buckets_info>`
* :ref:`replicaset_object:call() <router_api-replicaset_call>`
* :ref:`replicaset_object:callro() <router_api-replicaset_callro>`
* :ref:`replicaset_object:callrw() <router_api-replicaset_callrw>`
* :ref:`replicaset_object:callre() <router_api-replicaset_callre>`

.. _router_api-bootstrap:

.. function:: vshard.router.bootstrap()

    Perform the initial cluster bootstrap and distribute all buckets across the
    replica sets.

    :param timeout: a number of seconds before ending a bootstrap attempt as
                    unsuccessful.
                    Recreate the cluster in case of bootstrap timeout.
    :param if_not_bootstrapped: by default is set to ``false`` that means raise
                                an error, when the cluster is already
                                bootstrapped. ``True`` means consider an already
                                bootstrapped cluster a success.

    **Example:**

    .. code-block:: lua

        vshard.router.bootstrap({timeout = 4, if_not_bootstrapped = true})

    .. NOTE::

        To detect whether a cluster is bootstrapped, ``vshard`` looks for at least
        one bucket in the whole cluster. If the cluster was bootstrapped only
        partially (for example, due to an error during the first bootstrap), then
        it will be considered a bootstrapped cluster on a next bootstrap call
        with ``if_not_bootstrapped``. So this is still a bad practice. Avoid
        calling ``bootstrap()`` multiple times.

.. _router_api-cfg:

.. function:: vshard.router.cfg(cfg)

    Configure the database and start sharding for the specified ``router``
    instance. See the :ref:`sample configuration <vshard-config-cluster-example>`
    above.

    :param cfg: a configuration table

.. _router_api-new:

.. function:: vshard.router.new(name, cfg)

    Create a new router instance. ``vshard`` supports multiple routers in a
    single Tarantool instance. Each router can be connected to any ``vshard``
    cluster, and multiple routers can be connected to the same cluster.

    A router created via ``vshard.router.new()`` works in the same way as
    a static router, but the method name is preceded by a colon
    (``vshard.router:method_name(...)``), while for a static router
    the method name is preceded by a period (``vshard.router.method_name(...)``).

    A static router can be obtained via the ``vshard.router.static()`` method
    and then used like a router created via the ``vshard.router.new()``
    method.

    .. NOTE::

        ``box.cfg`` is shared among all the routers of a single instance.

    :param name: a router instance name. This name is used as a prefix in logs of
                 the router and must be unique within the instance
    :param cfg: a configuration table. The
                :ref:`sample configuration <vshard-config-cluster-example>` is
                described above.

    :Return: a router instance, if created successfully; otherwise, nil and an
             error object

.. _router_api-call:

.. function:: vshard.router.call(bucket_id, mode, function_name, {argument_list}, {options})

    Call the function identified by function-name on the shard storing the bucket
    identified by bucket_id.
    See the :ref:`Processing requests <vshard-process-requests>` section
    for details on function operation.

    :param bucket_id: a bucket identifier
    :param mode: either a string = 'read'|'write', or a map with mode='read'|'write' and/or prefer_replica=true|false and/or balance=true|false.
    :param function_name: a function to execute
    :param argument_list: an array of the function's arguments
    :param options:

        * ``timeout`` – a request timeout, in seconds. If the ``router`` cannot identify a
          shard with the specified ``bucket_id``, the operation will be repeated until the
          timeout is reached.

        * other :ref:`net.box options <net_box-options>`, such as ``is_async``,
          ``buffer``, ``on_push`` are also supported.

    The mode parameter has two possible forms: a string or a map. Examples of the string form are:
    ``'read'``, ``'write'``. Examples of the map form are: ``{mode='read'}``, ``{mode='write'}``,
    ``{mode='read', prefer_replica=true}``, ``{mode='read', balance=true}``,
    ``{mode='read', prefer_replica=true, balance=true}``.

    If ``'write'`` is specified then the target is the master.

    If ``prefer_replica=true`` is specified then the preferred target is one of the replicas, but
    the target is the master if there is no conveniently available replica.

    It may be good to specify prefer_replica=true for functions which are expensive in terms
    of resource use, to avoid slowing down the master.

    If ``balance=true`` then there is load balancing -- reads are distributed over all the nodes
    in the replica set in round-robin fashion, with a preference for replicas if
    prefer_replica=true is also set.

    :Return: The original return value of the executed function, or ``nil`` and
             error object. The error object has a type attribute equal to
             ``ShardingError`` or one of the regular Tarantool errors
             (``ClientError``, ``OutOfMemory``, ``SocketError``, etc.).

             ``ShardingError`` is returned on errors specific for sharding:
             the master is missing, wrong bucket id, etc. It has an attribute code
             containing one of the values from the ``vshard.error.code.*`` LUA table, an
             optional attribute containing a message with the human-readable error description,
             and other attributes specific for the error code.

    **Examples:**

    To call ``customer_add`` function from ``vshard/example``, say:

    .. code-block:: lua

        vshard.router.call(100, 'write', 'customer_add', {{customer_id = 2, bucket_id = 100, name = 'name2', accounts = {}}}, {timeout = 100})
        -- or, the same thing but with a map for the second argument
        vshard.router.call(100, {mode='write'}, 'customer_add', {{customer_id = 2, bucket_id = 100, name = 'name2', accounts = {}}}, {timeout = 100})

.. _router_api-callro:

.. function:: vshard.router.callro(bucket_id, function_name, {argument_list}, {options})

    Call the function identified by function-name on the shard storing the bucket identified by bucket_id,
    in read-only mode (similar to calling vshard.router.call
    with mode='read'). See the
    :ref:`Processing requests <vshard-process-requests>` section for details on
    function operation.

    :param bucket_id: a bucket identifier
    :param function_name: a function to execute
    :param argument_list: an array of the function's arguments
    :param options:

        * ``timeout`` – a request timeout, in seconds. In case the ``router`` cannot identify a
          shard with the bucket id, the operation will be repeated until the
          timeout is reached.

        * other :ref:`net.box options <net_box-options>`, such as ``is_async``,
          ``buffer``, ``on_push`` are also supported.

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

    Call the function identified by function-name on the shard storing the bucket identified by bucket_id,
    in read-write mode (similar to calling vshard.router.call
    with mode='write'). See the :ref:`Processing requests <vshard-process-requests>` section
    for details on function operation.

    :param bucket_id: a bucket identifier
    :param function_name: a function to execute
    :param argument_list: an array of the function's arguments
    :param options:

        * ``timeout`` – a request timeout, in seconds. In case the ``router`` cannot identify a
          shard with the bucket id, the operation will be repeated until the
          timeout is reached.

        * other :ref:`net.box options <net_box-options>`, such as ``is_async``,
          ``buffer``, ``on_push`` are also supported.

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

.. _router_api-callre:

.. function:: vshard.router.callre(bucket_id, function_name, {argument_list}, {options})

    Call the function identified by function-name on the shard storing the bucket identified by bucket_id,
    in read-only mode (similar to calling ``vshard.router.call``
    with ``mode='read'``), with preference for a replica rather than a master
    (similar to calling ``vshard.router.call`` with ``prefer_replica = true``). See the
    :ref:`Processing requests <vshard-process-requests>` section for details on
    function operation.

    :param bucket_id: a bucket identifier
    :param function_name: a function to execute
    :param argument_list: an array of the function's arguments
    :param options:

        * ``timeout`` – a request timeout, in seconds. In case the ``router`` cannot identify a
          shard with the bucket id, the operation will be repeated until the
          timeout is reached.

        * other :ref:`net.box options <net_box-options>`, such as ``is_async``,
          ``buffer``, ``on_push`` are also supported.

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

.. _router_api-callbro:

.. function:: vshard.router.callbro(bucket_id, function_name, {argument_list}, {options})

    This has the same effect as
    :ref:`vshard.router.call() <router_api-call>`
    with mode parameter = ``{mode='read', balance=true}``.

.. _router_api-callbre:

.. function:: vshard.router.callbre(bucket_id, function_name, {argument_list}, {options})

    This has the same effect as
    :ref:`vshard.router.call() <router_api-call>`
    with mode parameter = ``{mode='read', balance=true, prefer_replica=true}``.

.. _router_api-route:

.. function:: vshard.router.route(bucket_id)

    Return the replica set object for the bucket with the specified bucket id value.

    :param bucket_id: a bucket identifier

    :Return: a replica set object

    **Example:**

    .. code-block:: lua

        replicaset = vshard.router.route(123)

.. _router_api-routeall:

.. function:: vshard.router.routeall()

    Return all available replica set objects.

    :Return: a map of the following type: ``{UUID = replicaset}``
    :Rtype: a map of replica set objects

    **Example:**

    .. code-block:: lua

        replicasets = vshard.router.routeall()

.. _router_api-bucket_id:

.. function:: vshard.router.bucket_id(key)

    **Deprecated**. Logs a warning when used because it is not consistent
    for cdata numbers.

    In particular, it returns 3 different values for normal Lua numbers
    like 123, for unsigned long long cdata (like ``123ULL``, or
    ``ffi.cast('unsigned long long',123)``), and for signed long long cdata
    (like ``123LL``, or ``ffi.cast('long long', 123)``). And it is important.

    .. code-block:: lua

        vshard.router.bucket_id(123)
        vshard.router.bucket_id(123LL)
        vshard.router.bucket_id(123ULL)

    For float and double cdata 
    (``ffi.cast('float', number)``, ``ffi.cast('double', number)``) these functions
    return different values even for the same numbers of the same floating point
    type. This is because ``tostring()`` on a floating point cdata number returns not
    the number, but a pointer at it. Different on each call.

    ``vshard.router.bucket_id_strcrc32()`` behaves exactly the same, but
    does not log a warning. In case you need that behavior.

.. _router_api-bucket_id_strcrc32:

.. function:: vshard.router.bucket_id_strcrc32(key)

    Calculate the bucket id using a simple built-in hash function.

    :param key: a hash key. This can be any Lua object (number, table, string).

    :Return: a bucket identifier
    :Rtype: number

    **Example:**

    .. code-block:: lua

        bucket_id = vshard.router.bucket_id_strcrc32(18374927634039)

    .. Note::

        Remember that it is not safe. See details in :ref:`bucket_id() <router_api-bucket_id>`

.. _router_api-bucket_id_mpcrc32:

.. function:: vshard.router.bucket_id_mpcrc32(key)

    This function is safer than ``bucket_id_strcrc32``. It takes a CRC32 from
    a MessagePack encoded value. That is, bucket id of integers does not
    depend on their Lua type. In case of a string key, it does not encode it into
    MessagePack, but takes a hash right from the string. 

    :param key: a hash key. This can be any Lua object (number, table, string).

    :Return: a bucket identifier
    :Rtype: number

    However it still may return different values for not equal floating point
    types. That is, ``ffi.cast('float', number)`` may be reflected into a bucket id
    not equal to ``ffi.cast('double', number)``. This can't be fixed, because a
    float value, even being casted to double, may have a garbage tail in its fraction.

    Floating point keys should not be used to calculate a bucket id,
    usually.

    Be very careful in case you store floating point types in a space. When data
    is returned from a space, it is cast to Lua number. And if that value had
    an empty fraction part, it will be treated as an integer by ``bucket_id_mpcrc32()``.
    So you need to do explicit casts in such cases. Here is an example of the problem:

    .. code-block:: tarantoolsession

        tarantool> s = box.schema.create_space('test', {format = {{'id', 'double'}}}); _ = s:create_index('pk')
        ---
        ...

        tarantool> inserted = ffi.cast('double', 1)
        ---
        ...

        -- Value is stored as double
        tarantool> s:replace({inserted})
        ---
        - [1]
        ...

        -- But when returned to Lua, stored as Lua number, not cdata.
        tarantool> returned = s:get({inserted}).id
        ---
        ...

        tarantool> type(returned), returned
        ---
        - number
        - 1
        ...

        tarantool> vshard.router.bucket_id_mpcrc32(inserted)
        ---
        - 1411
        ...
        tarantool> vshard.router.bucket_id_mpcrc32(returned)
        ---
        - 1614
        ...

.. _router_api-bucket_count:

.. function:: vshard.router.bucket_count()

    Return the total number of buckets specified in ``vshard.router.cfg()``.

    :Return: the total number of buckets
    :Rtype: number

.. _router_api-sync:

.. function:: vshard.router.sync(timeout)

    Wait until the dataset is synchronized on replicas.

    :param timeout: a timeout, in seconds

    :return: ``true`` if the dataset was synchronized successfully; or ``nil`` and
             ``err`` explaining why the dataset cannot be synchronized.

.. _router_api-discovery_wakeup:

.. function:: vshard.router.discovery_wakeup()

    Force wakeup of the bucket discovery fiber.

.. _router_api-discovery_set:

.. function:: vshard.router.discovery_set(mode)

    Turn on/off the background discovery fiber used by the router to
    find buckets.

    :param mode: working mode of a discovery fiber. There are three modes: ``on``,
                 ``off`` and ``once``

    When the mode is ``on`` (default), the discovery fiber works during all the lifetime
    of the router. Even after all buckets are discovered, it will
    still come to storages and download their buckets with some big
    period (`DISCOVERY_IDLE_INTERVAL <https://github.com/tarantool/vshard/blob/master/vshard/consts.lua>`_).
    This is useful if the bucket topology changes often and the number of
    buckets is not big. The router will keep its route table up to
    date even when no requests are processed.

    When the mode is ``off``, discovery is disabled completely.

    When the mode is ``once``, discovery starts and finds the locations of
    all buckets, and then the discovery fiber is terminated. This
    is good for a large bucket count and for clusters, where rebalancing is rare.

    The method is good to enable/disable discovery after the router is
    already started, but discovery is enabled by default. You may want
    to never enable it even for a short time -- then specify the
    ``discovery_mode`` option in the :ref:`configuration <cfg_basic-discovery_mode>`.
    It takes the same values as :samp:`vshard.router.discovery_set({mode})`.

    You may decide to turn off discovery or make it ``once`` if you have
    many routers, or tons of buckets (hundreds of thousands and more),
    and you see that the discovery process consumes notable CPU % on
    routers and storages. In that case it may be wise to turn off the
    discovery when there is no rebalancing in the cluster. And turn it
    on for new routers, as well as for all routers when rebalancing is
    started.

.. _router_api-info:

.. function:: vshard.router.info()

    Return information about each instance.

    :Return:

    Replica set parameters:

    * replica set uuid
    * master instance parameters
    * replica instance parameters

    Instance parameters:

    * ``uri`` — URI of the instance
    * ``uuid`` — UUID of the instance
    * ``status`` – status of the instance (``available``, ``unreachable``, ``missing``)
    * ``network_timeout`` – a timeout for the request. The value is updated automatically
      on each 10th successful request and each 2nd failed request.

    Bucket parameters:

    * ``available_ro`` – the number of buckets known to the ``router`` and available for read requests
    * ``available_rw`` – the number of buckets known to the ``router`` and available for read and write requests
    * ``unavailable`` – the number of buckets known to the ``router`` but unavailable for any requests
    * ``unreachable`` – the number of buckets whose replica sets are not known to the ``router``

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

    Return information about each bucket. Since a bucket map can be huge,
    only the required range of buckets can be specified.

    :param offset: the offset in a bucket map of the first bucket to show
    :param limit: the maximum number of buckets to show

    :Return: a map of the following type: ``{bucket_id = 'unknown'/replicaset_uuid}``

.. class:: replicaset_object

    .. _router_api-replicaset_call:

    .. method:: call(function_name, {argument_list}, {options})

        Call a function on a nearest available master (distances are defined using
        ``replica.zone`` and ``cfg.weights`` matrix) with specified
        arguments.

        .. NOTE::

            The ``replicaset_object:call`` method is similar to ``replicaset_object:callrw``.

        :param function_name: function to execute
        :param argument_list: array of the function's arguments
        :param options:

            * ``timeout`` – a request timeout, in seconds. In case the ``router`` cannot identify a
              shard with the bucket id, the operation will be repeated until the
              timeout is reached.

            * other :ref:`net.box options <net_box-options>`, such as ``is_async``,
              ``buffer``, ``on_push`` are also supported.

        :return: 

            * result of ``function_name`` on success
            * nill, err otherwise

    .. _router_api-replicaset_callrw:

    .. method:: callrw(function_name, {argument_list}, {options})

        Call a function on a nearest available master (distances are defined using
        ``replica.zone`` and ``cfg.weights`` matrix) with a specified
        arguments.

        .. NOTE::

            The ``replicaset_object:callrw`` method is similar to ``replicaset_object:call``.

        :param function_name: function to execute
        :param argument_list: array of the function's arguments
        :param options:

            * ``timeout`` – a request timeout, in seconds. In case the ``router`` cannot identify a
              shard with the bucket id, the operation will be repeated until the
              timeout is reached.

            * other :ref:`net.box options <net_box-options>`, such as ``is_async``,
              ``buffer``, ``on_push`` are also supported.

        :return: 

            * result of ``function_name`` on success
            * nill, err otherwise

    .. _router_api-replicaset_callro:

    .. method:: callro(function_name, {argument_list}, {options})

        Call a function on the nearest available replica (distances are defined
        using ``replica.zone`` and ``cfg.weights`` matrix) with specified
        arguments. It is recommended to use
        ``replicaset_object:callro()`` for calling only read-only functions, as the called functions can be executed not only
        on a master, but also on replicas.

        :param function_name: function to execute
        :param argument_list: array of the function's arguments
        :param options:

            * ``timeout`` – a request timeout, in seconds. In case the ``router`` cannot identify a
              shard with the bucket id, the operation will be repeated until the
              timeout is reached.

            * other :ref:`net.box options <net_box-options>`, such as ``is_async``,
              ``buffer``, ``on_push`` are also supported.

        :return: 

            * result of ``function_name`` on success
            * nill, err otherwise

    .. _router_api-replicaset_callre:

    .. method:: replicaset:callre(function_name, {argument_list}, {options})

        Call a function on the nearest available replica (distances are defined using
        ``replica.zone`` and ``cfg.weights`` matrix) with specified
        arguments,
        with preference for a replica rather than a master
        (similar to calling ``vshard.router.call`` with ``prefer_replica = true``).
        It is recommended to use
        ``replicaset_object:callre()`` for calling only read-only functions, as the called function can be executed not
        only on a master, but also on replicas.

        :param function_name: function to execute
        :param argument_list: array of the function's arguments
        :param options:

            * ``timeout`` – a request timeout, in seconds. In case the ``router`` cannot identify a
              shard with the bucket id, the operation will be repeated until the
              timeout is reached.

            * other :ref:`net.box options <net_box-options>`, such as ``is_async``,
              ``buffer``, ``on_push`` are also supported.

        :return: 

            * result of ``function_name`` on success
            * nill, err otherwise

.. _vshard_api_reference-router_internal_api:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Router internal API
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

* :ref:`vshard.router.bucket_discovery(bucket_id) <router_api-bucket_discovery>`

.. _router_api-bucket_discovery:

.. function:: vshard.router.bucket_discovery(bucket_id)

    Search for the bucket in the whole cluster. If the bucket is not
    found, it is likely that it does not exist. The bucket might also be
    moved during rebalancing and currently is in the RECEIVING state.

    :param bucket_id: a bucket identifier

.. _vshard-storage_public_api:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Storage public API
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

* :ref:`vshard.storage.cfg(cfg, name) <storage_api-cfg>`
* :ref:`vshard.storage.info() <storage_api-info>`
* :ref:`vshard.storage.call(bucket_id, mode, function_name, {argument_list}) <storage_api-call>`
* :ref:`vshard.storage.sync(timeout) <storage_api-sync>`
* :ref:`vshard.storage.bucket_pin(bucket_id) <storage_api-bucket_pin>`
* :ref:`vshard.storage.bucket_unpin(bucket_id) <storage_api-bucket_unpin>`
* :ref:`vshard.storage.bucket_ref(bucket_id, mode) <storage_api-bucket_ref>`
* :ref:`vshard.storage.bucket_refro() <storage_api-bucket_refro>`
* :ref:`vshard.storage.bucket_refrw() <storage_api-bucket_refrw>`
* :ref:`vshard.storage.bucket_unref(bucket_id, mode) <storage_api-bucket_unref>`
* :ref:`vshard.storage.bucket_unrefro() <storage_api-bucket_unrefro>`
* :ref:`vshard.storage.bucket_unrefrw() <storage_api-bucket_unrefrw>`
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
    :param instance_uuid: UUID of the instance

.. _storage_api-info:

.. function:: vshard.storage.info()

    Return information about the storage instance in the following format:

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

.. _storage_api-call:

.. function:: vshard.storage.call(bucket_id, mode, function_name, {argument_list})

    Call the specified function on the current ``storage`` instance.

    :param bucket_id: a bucket identifier
    :param mode: a type of the function: 'read' or 'write'
    :param function_name: function to execute
    :param argument_list: array of the function's arguments

    :Return:

    The original return value of the executed function, or ``nil`` and
    error object.

.. _storage_api-sync:

.. function:: vshard.storage.sync(timeout)

    Wait until the dataset is synchronized on replicas.

    :param timeout: a timeout, in seconds

    :return: ``true`` if the dataset was synchronized successfully; or ``nil`` and
             ``err`` explaining why the dataset cannot be synchronized.

.. _storage_api-bucket_pin:

.. function:: vshard.storage.bucket_pin(bucket_id)

    Pin a bucket to a replica set. A pinned bucket cannot be moved
    even if it breaks the cluster balance.

    :param bucket_id: a bucket identifier

    :return: ``true`` if the bucket is pinned successfully; or ``nil`` and
             ``err`` explaining why the bucket cannot be pinned

.. _storage_api-bucket_unpin:

.. function:: vshard.storage.bucket_unpin(bucket_id)

    Return a pinned bucket back into the active state.

    :param bucket_id: a bucket identifier

    :return: ``true`` if the bucket is unpinned successfully; or ``nil`` and
             ``err`` explaining why the bucket cannot be unpinned

.. _storage_api-bucket_ref:

.. function:: vshard.storage.bucket_ref(bucket_id, mode)

    Create an RO or RW :ref:`ref <vshard-ref>`.

    :param bucket_id: a bucket identifier
    :param mode: 'read' or 'write'

    :return: ``true`` if the bucket ref is created successfully; or ``nil`` and
             ``err`` explaining why the ref cannot be created

.. _storage_api-bucket_refro:

.. function:: vshard.storage.bucket_refro()

    An alias for :ref:`vshard.storage.bucket_ref <storage_api-bucket_ref>` in
    the RO mode.

.. _storage_api-bucket_refrw:

.. function:: vshard.storage.bucket_refrw()

    An alias for :ref:`vshard.storage.bucket_ref <storage_api-bucket_ref>` in
    the RW mode.

.. _storage_api-bucket_unref:

.. function:: vshard.storage.bucket_unref(bucket_id, mode)

    Remove a RO/RW :ref:`ref <vshard-ref>`.

    :param bucket_id: a bucket identifier
    :param mode: 'read' or 'write'

    :return: ``true`` if the bucket ref is removed successfully; or ``nil`` and
             ``err`` explaining why the ref cannot be removed

.. _storage_api-bucket_unrefro:

.. function:: vshard.storage.bucket_unrefro()

    An alias for :ref:`vshard.storage.bucket_unref <storage_api-bucket_unref>` in
    the RO mode.

.. _storage_api-bucket_unrefrw:

.. function:: vshard.storage.bucket_unrefrw()

    An alias for :ref:`vshard.storage.bucket_unref <storage_api-bucket_unref>` in
    the RW mode.

.. _storage_api-find_garbage_bucket:

.. function:: vshard.storage.find_garbage_bucket(bucket_index, control)

    Find a bucket which has data in a space but is not stored
    in a ``_bucket`` space; or is in a GARBAGE state.

    :param bucket_index: index of a space with the part of a bucket id
    :param control: a garbage collector controller. If there is an increased
                    buckets generation, then the search should be interrupted.

    :return: an identifier of the bucket in the garbage state, if found; otherwise,
             nil

.. _storage_api-buckets_info:

.. function:: vshard.storage.buckets_info()

    Return information about each bucket located in storage. For example:

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

.. _storage_api-buckets_count:

.. function:: vshard.storage.buckets_count()

    Return the number of buckets located in storage.

.. _storage_api-recovery_wakeup:

.. function:: vshard.storage.recovery_wakeup()

    Immediately wake up a recovery fiber, if it exists.

.. _storage_api-rebalancing_is_in_progress:

.. function:: vshard.storage.rebalancing_is_in_progress()

    Return a flag indicating whether rebalancing is in progress. The result is true
    if the node is currently applying routes received from a rebalancer node in
    the special fiber.

.. _storage_api-is_locked:

.. function:: vshard.storage.is_locked()

    Return a flag indicating whether storage is invisible to the rebalancer.

.. _storage_api-rebalancer_disable:

.. function:: vshard.storage.rebalancer_disable()

    Disable rebalancing. A disabled rebalancer sleeps until it
    is enabled again with vshard.storage.rebalancer_enable().

.. _storage_api-rebalancer_enable:

.. function:: vshard.storage.rebalancer_enable()

    Enable rebalancing.

.. _storage_api-sharded_spaces:

.. function:: vshard.storage.sharded_spaces()

    Show the spaces that are visible to rebalancer and garbage collector fibers.

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

    Receive a bucket identified by bucket id from a remote replica set.

    :param bucket_id: a bucket identifier
    :param from: UUID of source replica set
    :param data: data logically stored in a bucket identified by bucket_id, in the same format as
                 the return value from ``bucket_collect() <storage_api-bucket_collect>``

.. _storage_api-bucket_stat:

.. function:: vshard.storage.bucket_stat(bucket_id)

    Return information about the bucket id:

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

    Force garbage collection for the bucket identified by bucket_id in case the bucket was
    transferred to a different replica set.

    :param bucket_id: a bucket identifier

.. _storage_api-bucket_collect:

.. function:: vshard.storage.bucket_collect(bucket_id)

    Collect all the data that is logically stored in the bucket identified by bucket_id:

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
    set. Use only for manual emergency recovery or for initial bootstrap.

    :param first_bucket_id: an identifier of the first bucket in a range
    :param count: the number of buckets to insert (default = 1)

.. _storage_api-bucket_force_drop:

.. function:: vshard.storage.bucket_force_drop(bucket_id)

    Drop a bucket manually for tests or emergency cases.

    :param bucket_id: a bucket identifier

.. _storage_api-bucket_send:

.. function:: vshard.storage.bucket_send(bucket_id, to)

    Send a specified bucket from the current replica set to a remote replica set.

    :param bucket_id: bucket identifier
    :param to: UUID of a remote replica set

.. _storage_api-rebalancer_request_state:

.. function:: vshard.storage.rebalancer_request_state()

    Check all buckets of the host storage that have the SENT or ACTIVE
    state, return the number of active buckets.

    :return: the number of buckets in the active state, if found; otherwise, nil

.. _storage_api-buckets_discovery:

.. function:: vshard.storage.buckets_discovery()

    Collect an array of active bucket identifiers for discovery.
