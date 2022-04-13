Router API
==========

..  _vshard-vshard_router:

..  container:: table

    ..  rst-class:: left-align-column-1
    ..  rst-class:: left-align-column-2

    +---------------------------------------------+-----------------------------------------------------------------------------------------------------------+
    | Subsection                                  | Methods                                                                                                   |
    +=============================================+===========================================================================================================+
    | :ref:`Router public API                     | * :ref:`vshard.router.bootstrap() <router_api-bootstrap>`                                                 |
    | <vshard_api_reference-router_public_api>`   | * :ref:`vshard.router.cfg(cfg) <router_api-cfg>`                                                          |
    |                                             | * :ref:`vshard.router.new(name, cfg) <router_api-new>`                                                    |
    |                                             | * :ref:`vshard.router.call(bucket_id, mode, function_name, {argument_list}, {options}) <router_api-call>` |
    |                                             | * :ref:`vshard.router.callro(bucket_id, function_name, {argument_list}, {options}) <router_api-callro>`   |
    |                                             | * :ref:`vshard.router.callrw(bucket_id, function_name, {argument_list}, {options}) <router_api-callrw>`   |
    |                                             | * :ref:`vshard.router.callre(bucket_id, function_name, {argument_list}, {options}) <router_api-callre>`   |
    |                                             | * :ref:`vshard.router.callbro(bucket_id, function_name, {argument_list}, {options}) <router_api-callbro>` |
    |                                             | * :ref:`vshard.router.callbre(bucket_id, function_name, {argument_list}, {options}) <router_api-callbre>` |
    |                                             | * :ref:`vshard.router.map_callrw(function_name, {argument_list}, {options}) <router_api-map_callrw>`      |
    |                                             | * :ref:`vshard.router.route(bucket_id) <router_api-route>`                                                |
    |                                             | * :ref:`vshard.router.routeall() <router_api-routeall>`                                                   |
    |                                             | * :ref:`vshard.router.bucket_id_strcrc32(key) <router_api-bucket_id_strcrc32>`                            |
    |                                             | * :ref:`vshard.router.bucket_id_mpcrc32(key) <router_api-bucket_id_mpcrc32>`                              |
    |                                             | * :ref:`vshard.router.bucket_count() <router_api-bucket_count>`                                           |
    |                                             | * :ref:`vshard.router.sync(timeout) <router_api-sync>`                                                    |
    |                                             | * :ref:`vshard.router.discovery_wakeup() <router_api-discovery_wakeup>`                                   |
    |                                             | * :ref:`vshard.router.discovery_set() <router_api-discovery_set>`                                         |
    |                                             | * :ref:`vshard.router.info() <router_api-info>`                                                           |
    |                                             | * :ref:`vshard.router.buckets_info() <router_api-buckets_info>`                                           |
    |                                             | * :ref:`replicaset_object:call() <router_api-replicaset_call>`                                            |
    |                                             | * :ref:`replicaset_object:callro() <router_api-replicaset_callro>`                                        |
    |                                             | * :ref:`replicaset_object:callrw() <router_api-replicaset_callrw>`                                        |
    |                                             | * :ref:`replicaset_object:callre() <router_api-replicaset_callre>`                                        |
    +---------------------------------------------+-----------------------------------------------------------------------------------------------------------+
    | :ref:`Router internal API                   | * :ref:`vshard.router.bucket_discovery(bucket_id) <router_api-bucket_discovery>`                          |
    | <vshard_api_reference-router_internal_api>` |                                                                                                           |
    +---------------------------------------------+-----------------------------------------------------------------------------------------------------------+

..  _vshard_api_reference-router_public_api:

Router public API
-----------------

..  _router_api-bootstrap:

..  function:: vshard.router.bootstrap()

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

    ..  code-block:: lua

        vshard.router.bootstrap({timeout = 4, if_not_bootstrapped = true})

    ..  NOTE::

        To detect whether a cluster is bootstrapped, ``vshard`` looks for at least
        one bucket in the whole cluster. If the cluster was bootstrapped only
        partially (for example, due to an error during the first bootstrap), then
        it will be considered a bootstrapped cluster on a next bootstrap call
        with ``if_not_bootstrapped``. So this is still a bad practice. Avoid
        calling ``bootstrap()`` multiple times.

..  _router_api-cfg:

..  function:: vshard.router.cfg(cfg)

    Configure the database and start sharding for the specified ``router``
    instance. See the :ref:`sample configuration <vshard-config-cluster-example>`.

    :param cfg: a configuration table

..  _router_api-new:

..  function:: vshard.router.new(name, cfg)

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
    :param cfg: a configuration table. See the
                :ref:`sample configuration <vshard-config-cluster-example>`.

    :Return: a router instance, if created successfully; otherwise, nil and an
             error object

..  _router_api-call:

..  function:: vshard.router.call(bucket_id, mode, function_name, {argument_list}, {options})

    Call the function identified by function-name on the shard storing the bucket
    identified by bucket_id.
    See the :ref:`Processing requests <vshard-process-requests>` section
    for details on function operation.

    :param bucket_id: a bucket identifier
    :param mode: either a string = 'read'|'write', or a map with mode='read'|'write' and/or prefer_replica=true|false and/or balance=true|false.
    :param function_name: a function to execute
    :param argument_list: an array of the function's arguments
    :param options:

        * ``timeout``—a request timeout, in seconds. If the ``router`` cannot identify a
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

    If ``balance=true`` then there is load balancing—reads are distributed over all the nodes
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

    ..  code-block:: lua

        vshard.router.call(100,
                           'write',
                           'customer_add',
                           {{customer_id = 2, bucket_id = 100, name = 'name2', accounts = {}}},
                           {timeout = 5})
        -- or, the same thing but with a map for the second argument
        vshard.router.call(100,
                           {mode='write'},
                           'customer_add',
                           {{customer_id = 2, bucket_id = 100, name = 'name2', accounts = {}}},
                           {timeout = 5})

..  _router_api-callro:

..  function:: vshard.router.callro(bucket_id, function_name, {argument_list}, {options})

    Call the function identified by function-name on the shard storing the bucket identified by bucket_id,
    in read-only mode (similar to calling vshard.router.call
    with mode='read'). See the
    :ref:`Processing requests <vshard-process-requests>` section for details on
    function operation.

    :param bucket_id: a bucket identifier
    :param function_name: a function to execute
    :param argument_list: an array of the function's arguments
    :param options:

        * ``timeout``—a request timeout, in seconds. In case the ``router`` cannot identify a
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

..  _router_api-callrw:

..  function:: vshard.router.callrw(bucket_id, function_name, {argument_list}, {options})

    Call the function identified by function-name on the shard storing the bucket identified by bucket_id,
    in read-write mode (similar to calling vshard.router.call
    with mode='write'). See the :ref:`Processing requests <vshard-process-requests>` section
    for details on function operation.

    :param bucket_id: a bucket identifier
    :param function_name: a function to execute
    :param argument_list: an array of the function's arguments
    :param options:

        * ``timeout``—a request timeout, in seconds. In case the ``router`` cannot identify a
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

..  _router_api-callre:

..  function:: vshard.router.callre(bucket_id, function_name, {argument_list}, {options})

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

        * ``timeout``—a request timeout, in seconds. In case the ``router`` cannot identify a
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

..  _router_api-callbro:

..  function:: vshard.router.callbro(bucket_id, function_name, {argument_list}, {options})

    This has the same effect as
    :ref:`vshard.router.call() <router_api-call>`
    with mode parameter = ``{mode='read', balance=true}``.

..  _router_api-callbre:

..  function:: vshard.router.callbre(bucket_id, function_name, {argument_list}, {options})

    This has the same effect as
    :ref:`vshard.router.call() <router_api-call>`
    with mode parameter = ``{mode='read', balance=true, prefer_replica=true}``.

..  _router_api-map_callrw:

..  function:: vshard.router.map_callrw(function_name, {argument_list}, {options})

    The function implements consistent map-reduce over the entire cluster.
    Consistency means:

    *   All the data was accessible.
    *   The data was not migrated between physical storages during the map requests execution.

    The function can be helpful if you need to access:

    *   all the data in the cluster

    *   a vast number of buckets scattered over the instances
        in case their individual :ref:`vshard.router.call() <router_api-call>` takes up too much time.

    The function is called on the master node of each replica set with the given arguments.

    :param function_name: a function to call on the storages (masters of all replica sets)
    :param argument_list: an array of the function's arguments
    :param options:

        *   ``timeout``---a request timeout, in seconds. The timeout is for the entire ``map_callrw()``, including all its stages.
        *   ``return_raw``---[TBD] :ref:` <net_box-options>` The option is supported for the Tarantool versions started/starting from 2.10.0.

            [TDB rewrite & perhaps move to the Return sections below]

            On error, the result is the same as always:
            ``nil, err, err_uuid``.

            On success, the result is a map of the following format:
            {[replicaset_uuid] = msgpack.object}. The msgpack.object here
            stores a MessagePack array with the results returned from the
            storage's map-function.

            The use case is the same as for the case when the bare net.box is used - to avoid
            decoding of the results into the Lua land. Helpful when the router is
            used as a proxy and the results received from the storage are big.

            Example:

            ..  code-block:: lua

                local res = vshard.router.map_callrw('my_func', args, {..., return_raw = true})

                for replicaset_uuid, msgpack_value in pairs(res) do
                    log.info('Replicaset %s returned %s', replicaset_uuid,
                             msgpack_value:decode())
                end

    ..  important::

        Do not use a big timeout (longer than 1 minute, for instance). The router tries to block the bucket moves
        to another storage for the given timeout on all storages. On failure, the block remains for the entire timeout.

    :Return:

    *   On success: a map with replica set UUIDs (keys) and results of the ``function_name`` (values).

        ..  code-block:: lua

            {uuid1 = {res1}, uuid2 = {res2}, ...}

        If the function returns ``nil`` or ``box.NULL`` from one of the storages,
        it will not be present in the resulting map.

    *   On failure: ``nil``, error object, and optional replica set UUID where the error occurred.
        UUID will not be returned if the error is not related to a particular replica set.
        For instance, the method fails if not all buckets were found, even if all replica sets were scanned successfully.
        Handling the result looks like this:

        ..  code-block:: lua

            res, err, uuid = vshard.router.map_callrw(...)
            if not res then
                -- Error.
                -- 'err' - error object. 'uuid' - optional UUID of replica set
                -- where the error happened.
                ...
            else
                -- Success.
                for uuid, value in pairs(res) do
                    ...
                end
            end

    Map-Reduce in vshard can be divided into three stages: Ref, Map, and Reduce.

    **Ref and Map**. ``map_callrw()`` combines both the Ref and the Map stages.
    The Ref stage ensures data consistency while executing the user's function (``function_name``) on all nodes.
    Keep in mind that consistency is incompatible with rebalancing (it breaks data consistency).
    Map-reduce and rebalancing are mutually exclusive, they compete for the cluster time.
    Any bucket move makes the sender and receiver nodes inconsistent,
    so it is impossible to call a function on them to access all the data
    without :ref:`vshard.storage.bucket_ref() <storage_api-bucket_ref>`.
    It makes the Ref stage intricate, as it should work together with the rebalancer to ensure
    they do not block each other.

    For this, the storage has a special scheduler for bucket moves and storage refs.
    Storage ref is a volatile counter defined on each instance.
    It is incremented when a map-reduce request comes and decremented when it ends.
    Storage ref pins the entire instance with all its buckets, not just a single bucket (like bucket ref).

    The scheduler shares storage time between bucket moves and storage refs fairly.
    The distribution depends on how long and frequent the moves and refs are.
    It can be configured using the storage options ``sched_move_quota`` and ``sched_ref_quota``.
    Keep in mind that the scheduler configuration may affect map-reduce requests if used during rebalancing.

    During the Map stage, ``map_callrw()`` sends map requests one by one to many servers.
    On success, the function returns a map. The map is a set of "key—value" pairs.
    The keys are replica set UUIDs, and the values are the results of the user's function—``function_name``.

    **Reduce**. The Reduce stage is not performed by vshard.
    It is what the user's code does with the results of ``map_callrw()``.

    ..  note::

        ``map_callrw()`` works only on masters.
        Therefore, you can't use it if at least one replica set has its master node down.

..  _router_api-route:

..  function:: vshard.router.route(bucket_id)

    Return the replica set object for the bucket with the specified bucket id value.

    :param bucket_id: a bucket identifier

    :Return: a replica set object

    **Example:**

    .. code-block:: lua

        replicaset = vshard.router.route(123)

..  _router_api-routeall:

..  function:: vshard.router.routeall()

    Return all available replica set objects.

    :Return: a map of the following type: ``{UUID = replicaset}``
    :Rtype: a map of replica set objects

    **Example:**

    .. code-block:: lua

        function selectall()
            local resultset = {}
            shards, err = vshard.router.routeall()
            if err ~= nil then
                error(err)
            end
            for uid, replica in pairs(shards) do
                local set = replica:callro('box.space.*space-name*:select', {{}, {limit=10}}, {timeout=5})
                for _, item in ipairs(set) do
                    table.insert(resultset, item)
                end
            end
            table.sort(resultset, function(a, b) return a[1] < b[1] end)
            return resultset
        end

..  _router_api-bucket_id:

..  function:: vshard.router.bucket_id(key)

    **Deprecated**. Logs a warning when used because it is not consistent
    for cdata numbers.

    In particular, it returns 3 different values for normal Lua numbers
    like 123, for unsigned long long cdata (like ``123ULL``, or
    ``ffi.cast('unsigned long long',123)``), and for signed long long cdata
    (like ``123LL``, or ``ffi.cast('long long', 123)``). And it is important.

    ..  code-block:: lua

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

..  _router_api-bucket_id_strcrc32:

..  function:: vshard.router.bucket_id_strcrc32(key)

    Calculate the bucket id using a simple built-in hash function.

    :param key: a hash key. This can be any Lua object (number, table, string).

    :Return: a bucket identifier
    :Rtype: number

    **Example:**

    ..  code-block:: tarantoolsession

        tarantool> vshard.router.bucket_count()
        ---
        - 3000
        ...

        tarantool> vshard.router.bucket_id_strcrc32("18374927634039")
        ---
        - 2032
        ...

        tarantool> vshard.router.bucket_id_strcrc32(18374927634039)
        ---
        - 2032
        ...

        tarantool> vshard.router.bucket_id_strcrc32("test")
        ---
        - 1216
        ...

        tarantool> vshard.router.bucket_id_strcrc32("other")
        ---
        - 2284
        ...

    ..  Note::

        Remember that it is not safe. See details in :ref:`bucket_id() <router_api-bucket_id>`

..  _router_api-bucket_id_mpcrc32:

..  function:: vshard.router.bucket_id_mpcrc32(key)

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

    ..  code-block:: tarantoolsession

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

..  _router_api-bucket_count:

..  function:: vshard.router.bucket_count()

    Return the total number of buckets specified in ``vshard.router.cfg()``.

    :Return: the total number of buckets
    :Rtype: number

    .. code-block:: tarantoolsession

        tarantool> vshard.router.bucket_count()
        ---
        - 10000
        ...


..  _router_api-sync:

..  function:: vshard.router.sync(timeout)

    Wait until the dataset is synchronized on replicas.

    :param timeout: a timeout, in seconds

    :return: ``true`` if the dataset was synchronized successfully; or ``nil`` and
             ``err`` explaining why the dataset cannot be synchronized.

..  _router_api-discovery_wakeup:

..  function:: vshard.router.discovery_wakeup()

    Force wakeup of the bucket discovery fiber.

..  _router_api-discovery_set:

..  function:: vshard.router.discovery_set(mode)

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
    to never enable it even for a short time—then specify the
    ``discovery_mode`` option in the :ref:`configuration <cfg_basic-discovery_mode>`.
    It takes the same values as :samp:`vshard.router.discovery_set({mode})`.

    You may decide to turn off discovery or make it ``once`` if you have
    many routers, or tons of buckets (hundreds of thousands and more),
    and you see that the discovery process consumes notable CPU % on
    routers and storages. In that case it may be wise to turn off the
    discovery when there is no rebalancing in the cluster. And turn it
    on for new routers, as well as for all routers when rebalancing is
    started.

..  _router_api-info:

..  function:: vshard.router.info()

    Return information about each instance.

    :Return:

    Replica set parameters:

    * replica set uuid
    * master instance parameters
    * replica instance parameters

    Instance parameters:

    * ``uri``—URI of the instance
    * ``uuid``—UUID of the instance
    * ``status``—status of the instance (``available``, ``unreachable``, ``missing``)
    * ``network_timeout``—a timeout for the request. The value is updated automatically
      on each 10th successful request and each 2nd failed request.

    Bucket parameters:

    * ``available_ro``—the number of buckets known to the ``router`` and available for read requests
    * ``available_rw``—the number of buckets known to the ``router`` and available for read and write requests
    * ``unavailable``—the number of buckets known to the ``router`` but unavailable for any requests
    * ``unreachable``—the number of buckets whose replica sets are not known to the ``router``

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

..  _router_api-buckets_info:

..  function:: vshard.router.buckets_info()

    Return information about each bucket. Since a bucket map can be huge,
    only the required range of buckets can be specified.

    :param offset: the offset in a bucket map of the first bucket to show
    :param limit: the maximum number of buckets to show

    :Return: a map of the following type: ``{bucket_id = 'unknown'/replicaset_uuid}``

    .. code-block:: tarantoolsession

        tarantool> vshard.router.buckets_info()
        ---
        - - uuid: aaaaaaaa-0000-4000-a000-000000000000
            status: available_rw
          - uuid: aaaaaaaa-0000-4000-a000-000000000000
            status: available_rw
          - uuid: aaaaaaaa-0000-4000-a000-000000000000
            status: available_rw
          - uuid: bbbbbbbb-0000-4000-a000-000000000000
            status: available_rw
          - uuid: bbbbbbbb-0000-4000-a000-000000000000
            status: available_rw
          - uuid: bbbbbbbb-0000-4000-a000-000000000000
            status: available_rw
          - uuid: bbbbbbbb-0000-4000-a000-000000000000
            status: available_rw
        ...


..  class:: replicaset_object

    ..  _router_api-replicaset_call:

    ..  method:: call(function_name, {argument_list}, {options})

        Call a function on a nearest available master (distances are defined using
        ``replica.zone`` and ``cfg.weights`` matrix) with specified
        arguments.

        .. NOTE::

            The ``replicaset_object:call`` method is similar to ``replicaset_object:callrw``.

        :param function_name: function to execute
        :param argument_list: array of the function's arguments
        :param options:

            * ``timeout``—a request timeout, in seconds. In case the ``router`` cannot identify a
              shard with the bucket id, the operation will be repeated until the
              timeout is reached.

            * other :ref:`net.box options <net_box-options>`, such as ``is_async``,
              ``buffer``, ``on_push`` are also supported.

        :return:

            * result of ``function_name`` on success
            * nil, err otherwise

    ..  _router_api-replicaset_callrw:

    ..  method:: callrw(function_name, {argument_list}, {options})

        Call a function on a nearest available master (distances are defined using
        ``replica.zone`` and ``cfg.weights`` matrix) with a specified
        arguments.

        ..  NOTE::

            The ``replicaset_object:callrw`` method is similar to ``replicaset_object:call``.

        :param function_name: function to execute
        :param argument_list: array of the function's arguments
        :param options:

            * ``timeout``—a request timeout, in seconds. In case the ``router`` cannot identify a
              shard with the bucket id, the operation will be repeated until the
              timeout is reached.

            * other :ref:`net.box options <net_box-options>`, such as ``is_async``,
              ``buffer``, ``on_push`` are also supported.

        :return:

            * result of ``function_name`` on success
            * nil, err otherwise

        ..  code-block:: lua

            tarantool> local bucket = 1; return vshard.router.callrw(
                     >     bucket,
                     >     'box.space.actors:insert',
                     >     {{
                     >         1, bucket, 'Renata Litvinova',
                     >         {theatre="Moscow Art Theatre"}
                     >     }},
                     >     {timeout=5}
                     > )


    ..  _router_api-replicaset_callro:

    ..  method:: callro(function_name, {argument_list}, {options})

        Call a function on the nearest available replica (distances are defined
        using ``replica.zone`` and ``cfg.weights`` matrix) with specified
        arguments. It is recommended to use
        ``replicaset_object:callro()`` for calling only read-only functions, as the called functions can be executed not only
        on a master, but also on replicas.

        :param function_name: function to execute
        :param argument_list: array of the function's arguments
        :param options:

            * ``timeout``—a request timeout, in seconds. In case the ``router`` cannot identify a
              shard with the bucket id, the operation will be repeated until the
              timeout is reached.

            * other :ref:`net.box options <net_box-options>`, such as ``is_async``,
              ``buffer``, ``on_push`` are also supported.

        :return:

            * result of ``function_name`` on success
            * nil, err otherwise

    ..  _router_api-replicaset_callre:

    ..  method:: replicaset:callre(function_name, {argument_list}, {options})

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

            * ``timeout``—a request timeout, in seconds. In case the ``router`` cannot identify a
              shard with the bucket id, the operation will be repeated until the
              timeout is reached.

            * other :ref:`net.box options <net_box-options>`, such as ``is_async``,
              ``buffer``, ``on_push`` are also supported.

        :return:

            * result of ``function_name`` on success
            * nil, err otherwise

..  _vshard_api_reference-router_internal_api:

Router internal API
-------------------

..  _router_api-bucket_discovery:

..  function:: vshard.router.bucket_discovery(bucket_id)

    Search for the bucket in the whole cluster. If the bucket is not
    found, it is likely that it does not exist. The bucket might also be
    moved during rebalancing and currently is in the RECEIVING state.

    :param bucket_id: a bucket identifier
