Storage API
===========

..  _vshard-vshard_storage:

..  container:: table

    ..  rst-class:: left-align-column-1
    ..  rst-class:: left-align-column-2

    +---------------------------------------------+--------------------------------------------------------------------------------------------------------------------+
    | :ref:`Storage public API                    | * :ref:`vshard.storage.cfg(cfg, instance_uuid) <storage_api-cfg>`                                                  |
    | <vshard-storage_public_api>`                | * :ref:`vshard.storage.info({options}) <storage_api-info>`                                                         |
    |                                             | * :ref:`vshard.storage.call(bucket_id, mode, function_name, {argument_list}) <storage_api-call>`                   |
    |                                             | * :ref:`vshard.storage.sync(timeout) <storage_api-sync>`                                                           |
    |                                             | * :ref:`vshard.storage.bucket_pin(bucket_id) <storage_api-bucket_pin>`                                             |
    |                                             | * :ref:`vshard.storage.bucket_unpin(bucket_id) <storage_api-bucket_unpin>`                                         |
    |                                             | * :ref:`vshard.storage.bucket_ref(bucket_id, mode) <storage_api-bucket_ref>`                                       |
    |                                             | * :ref:`vshard.storage.bucket_refro(bucket_id) <storage_api-bucket_refro>`                                         |
    |                                             | * :ref:`vshard.storage.bucket_refrw(bucket_id) <storage_api-bucket_refrw>`                                         |
    |                                             | * :ref:`vshard.storage.bucket_unref(bucket_id, mode) <storage_api-bucket_unref>`                                   |
    |                                             | * :ref:`vshard.storage.bucket_unrefro(bucket_id) <storage_api-bucket_unrefro>`                                     |
    |                                             | * :ref:`vshard.storage.bucket_unrefrw(bucket_id) <storage_api-bucket_unrefrw>`                                     |
    |                                             | * :ref:`vshard.storage.find_garbage_bucket(bucket_index, control) <storage_api-find_garbage_bucket>`               |
    |                                             | * :ref:`vshard.storage.rebalancer_disable() <storage_api-rebalancer_disable>`                                      |
    |                                             | * :ref:`vshard.storage.rebalancer_enable() <storage_api-rebalancer_enable>`                                        |
    |                                             | * :ref:`vshard.storage.is_locked() <storage_api-is_locked>`                                                        |
    |                                             | * :ref:`vshard.storage.rebalancing_is_in_progress() <storage_api-rebalancing_is_in_progress>`                      |
    |                                             | * :ref:`vshard.storage.buckets_info() <storage_api-buckets_info>`                                                  |
    |                                             | * :ref:`vshard.storage.buckets_count() <storage_api-buckets_count>`                                                |
    |                                             | * :ref:`vshard.storage.sharded_spaces() <storage_api-sharded_spaces>`                                              |
    |                                             | * :ref:`vshard.storage.on_bucket_event() <storage_api-on_bucket_event>`                                            |
    +---------------------------------------------+--------------------------------------------------------------------------------------------------------------------+
    | :ref:`Storage internal API                  | * :ref:`vshard.storage.bucket_stat(bucket_id) <storage_api-bucket_stat>`                                           |
    | <vshard-storage_internal_api>`              | * :ref:`vshard.storage.bucket_recv(bucket_id, from, data) <storage_api-bucket_recv>`                               |
    |                                             | * :ref:`vshard.storage.bucket_delete_garbage(bucket_id) <storage_api-bucket_delete_garbage>`                       |
    |                                             | * :ref:`vshard.storage.bucket_collect(bucket_id) <storage_api-bucket_collect>`                                     |
    |                                             | * :ref:`vshard.storage.bucket_force_create(first_bucket_id, count) <storage_api-bucket_force_create>`              |
    |                                             | * :ref:`vshard.storage.bucket_force_drop(bucket_id, to) <storage_api-bucket_force_drop>`                           |
    |                                             | * :ref:`vshard.storage.bucket_send(bucket_id, to) <storage_api-bucket_send>`                                       |
    |                                             | * :ref:`vshard.storage.buckets_discovery() <storage_api-buckets_discovery>`                                        |
    |                                             | * :ref:`vshard.storage.rebalancer_request_state() <storage_api-rebalancer_request_state>`                          |
    +---------------------------------------------+--------------------------------------------------------------------------------------------------------------------+

..  _vshard-storage_public_api:

Storage public API
------------------

..  _storage_api-cfg:

..  function:: vshard.storage.cfg(cfg, instance_uuid)

    Configure the database and start sharding for the specified ``storage``
    instance.

    :param cfg: a ``storage`` configuration
    :param instance_uuid: UUID of the instance

..  _storage_api-info:

..  function:: vshard.storage.info({options})

    Return information about the storage instance. Since vshard v.0.1.22, the
    function also accepts options, which can be used to get additional
    information.

    :param options:

       *    ``with_services`` — a bool value. If set to ``true``, the
            function returns information about the background services
            (such as garbage collector, rebalancer, recovery, or applier
            of the routes) that are working on the current instance. See
            :ref:`vshard.router.info <router_api-info>` for detailed
            reference.

    **Example:**

    ..  code-block:: tarantoolsession

        tarantool> vshard.storage.info()
        ---
        - replicasets:
            c862545d-d966-45ff-93ad-763dce4a9723:
              uuid: c862545d-d966-45ff-93ad-763dce4a9723
              master:
                uri: admin@localhost:3302
            1990be71-f06e-4d9a-bcf9-4514c4e0c889:
              uuid: 1990be71-f06e-4d9a-bcf9-4514c4e0c889
              master:
                uri: admin@localhost:3304
          bucket:
            receiving: 0
            active: 15000
            total: 15000
            garbage: 0
            pinned: 0
            sending: 0
          status: 0
          replication:
            status: master
          alerts: []
        ...

..  _storage_api-call:

..  function:: vshard.storage.call(bucket_id, mode, function_name, {argument_list})

    Call the specified function on the current ``storage`` instance.

    :param bucket_id: a bucket identifier
    :param mode: a type of the function: 'read' or 'write'
    :param function_name: function to execute
    :param argument_list: array of the function's arguments

    :Return:

    The original return value of the executed function, or ``nil`` and
    error object.

..  _storage_api-sync:

..  function:: vshard.storage.sync(timeout)

    Wait until the dataset is synchronized on replicas.

    :param timeout: a timeout, in seconds

    :return: ``true`` if the dataset was synchronized successfully; or ``nil`` and
             ``err`` explaining why the dataset cannot be synchronized.

..  _storage_api-bucket_pin:

..  function:: vshard.storage.bucket_pin(bucket_id)

    Pin a bucket to a replica set. A pinned bucket cannot be moved
    even if it breaks the cluster balance.

    :param bucket_id: a bucket identifier

    :return: ``true`` if the bucket is pinned successfully; or ``nil`` and
             ``err`` explaining why the bucket cannot be pinned

..  _storage_api-bucket_unpin:

..  function:: vshard.storage.bucket_unpin(bucket_id)

    Return a pinned bucket back into the active state.

    :param bucket_id: a bucket identifier

    :return: ``true`` if the bucket is unpinned successfully; or ``nil`` and
             ``err`` explaining why the bucket cannot be unpinned

..  _storage_api-bucket_ref:

..  function:: vshard.storage.bucket_ref(bucket_id, mode)

    Create an RO or RW :ref:`ref <vshard-ref>`.

    :param bucket_id: a bucket identifier
    :param mode: 'read' or 'write'

    :return: ``true`` if the bucket ref is created successfully; or ``nil`` and
             ``err`` explaining why the ref cannot be created

..  _storage_api-bucket_refro:

..  function:: vshard.storage.bucket_refro(bucket_id)

    An alias for :ref:`vshard.storage.bucket_ref <storage_api-bucket_ref>` in
    the RO mode.

    :param bucket_id: a bucket identifier

    :return: ``true`` if the bucket ref is created successfully; or ``nil`` and
             ``err`` explaining why the ref cannot be created

..  _storage_api-bucket_refrw:

..  function:: vshard.storage.bucket_refrw(bucket_id)

    An alias for :ref:`vshard.storage.bucket_ref <storage_api-bucket_ref>` in
    the RW mode.

    :param bucket_id: a bucket identifier

    :return: ``true`` if the bucket ref is created successfully; or ``nil`` and
             ``err`` explaining why the ref cannot be created

..  _storage_api-bucket_unref:

..  function:: vshard.storage.bucket_unref(bucket_id, mode)

    Remove a RO/RW :ref:`ref <vshard-ref>`.

    :param bucket_id: a bucket identifier
    :param mode: 'read' or 'write'

    :return: ``true`` if the bucket ref is removed successfully; or ``nil`` and
             ``err`` explaining why the ref cannot be removed

..  _storage_api-bucket_unrefro:

..  function:: vshard.storage.bucket_unrefro(bucket_id)

    An alias for :ref:`vshard.storage.bucket_unref <storage_api-bucket_unref>` in
    the RO mode.

    :param bucket_id: a bucket identifier

    :return: ``true`` if the bucket ref is removed successfully; or ``nil`` and
             ``err`` explaining why the ref cannot be removed


..  _storage_api-bucket_unrefrw:

..  function:: vshard.storage.bucket_unrefrw(bucket_id)

    An alias for :ref:`vshard.storage.bucket_unref <storage_api-bucket_unref>` in
    the RW mode.

    :param bucket_id: a bucket identifier

    :return: ``true`` if the bucket ref is removed successfully; or ``nil`` and
             ``err`` explaining why the ref cannot be removed


..  _storage_api-find_garbage_bucket:

..  function:: vshard.storage.find_garbage_bucket(bucket_index, control)

    Find a bucket which has data in a space but is not stored
    in a ``_bucket`` space; or is in a GARBAGE state.

    :param bucket_index: index of a space with the part of a bucket id
    :param control: a garbage collector controller. If there is an increased
                    buckets generation, then the search should be interrupted.

    :return: an identifier of the bucket in the garbage state, if found; otherwise,
             nil

..  _storage_api-buckets_info:

..  function:: vshard.storage.buckets_info()

    Return information about each bucket located in storage. For example:

    ..  code-block:: tarantoolsession

        tarantool> vshard.storage.buckets_info(1)
        ---
        - 1:
            status: active
            ref_rw: 1
            ref_ro: 1
            ro_lock: true
            rw_lock: true
            id: 1

..  _storage_api-buckets_count:

..  function:: vshard.storage.buckets_count()

    Return the number of buckets located in storage.

..  _storage_api-recovery_wakeup:

..  function:: vshard.storage.recovery_wakeup()

    Immediately wake up a recovery fiber, if it exists.

..  _storage_api-rebalancing_is_in_progress:

..  function:: vshard.storage.rebalancing_is_in_progress()

    Return a flag indicating whether rebalancing is in progress. The result is true
    if the node is currently applying routes received from a rebalancer node in
    the special fiber.

..  _storage_api-is_locked:

..  function:: vshard.storage.is_locked()

    Return a flag indicating whether storage is invisible to the rebalancer.

..  _storage_api-rebalancer_disable:

..  function:: vshard.storage.rebalancer_disable()

    Disable rebalancing. A disabled rebalancer sleeps until it
    is enabled again with vshard.storage.rebalancer_enable().

..  _storage_api-rebalancer_enable:

..  function:: vshard.storage.rebalancer_enable()

    Enable rebalancing.

..  _storage_api-sharded_spaces:

..  function:: vshard.storage.sharded_spaces()

    Show the spaces that are visible to rebalancer and garbage collector fibers.

    ..  code-block:: tarantoolsession

        tarantool> vshard.storage.sharded_spaces()
        ---
        - 513:
            engine: memtx
            before_replace: 'function: 0x010e50e738'
            field_count: 0
            id: 513
            on_replace: 'function: 0x010e50e700'
            temporary: false
            index:
              0: &0
                unique: true
                parts:
                - type: number
                  fieldno: 1
                  is_nullable: false
                id: 0
                type: TREE
                name: primary
                space_id: 513
              1: &1
                unique: false
                parts:
                - type: number
                  fieldno: 2
                  is_nullable: false
                id: 1
                type: TREE
                name: bucket_id
                space_id: 513
              primary: *0
              bucket_id: *1
            is_local: false
            enabled: true
            name: actors
            ck_constraint: []
        ...

..  _storage_api-on_bucket_event:

..  function:: vshard.storage.on_bucket_event([trigger-function[, old-trigger-function]])

    Since vshard v.0.1.22. Define a trigger for execution when the data from
    the user spaces is changed (deleted or inserted) due to the rebalancing
    process. The trigger is invoked each time the data batch changes.

    :param function trigger-function: function which will become the trigger function.
    :param function old-trigger-function: existing trigger function which will
                                          be replaced by trigger-function.

    :return: nil or function pointer

    The ``trigger-function`` can have up to three parameters:

      * ``event_type`` (string) -- in order to distinguish event, you can compare
        this argument with the supported event types, ``bucket_data_recv_txn``
        and ``bucket_data_gc_txn``.
      * ``bucket_id`` (unsigned) -- bucket id.
      * ``data`` (table) -- additional information about data change transaction.
        Currently it only includes an array of all spaces (``data.spaces``),
        affected by a transaction in which trigger-function is executed.

    **Example:**

    ..  code-block:: lua

        vshard.storage.on_bucket_event(function(event, bucket_id, data)
            if event == 'bucket_data_recv_txn' then
                -- Handle it.
                for idx, space in ipairs(data.spaces) do
                    ...
                end
            elseif event == 'bucket_data_gc_txn' then
                -- Handle it.
                ...
            end
        end)

    .. NOTE::

        As everything executed inside triggers is already in a transaction,
        you shouldn't use transactions, yield-operations (:ref:`explicit <app-yields>`
        or not), changes to different space engines (see :ref:`rule #2 <box-txn_management>`).

        If the parameters are ``(nil, old-trigger-function)``, then the old trigger
        is deleted. If both parameters are omitted, then the response is a list of
        existing trigger functions.

        Details about trigger characteristics are in the
        :ref:`triggers <triggers-box_triggers>` section.

..  _vshard-storage_internal_api:

Storage internal API
--------------------

..  _storage_api-bucket_recv:

..  function:: vshard.storage.bucket_recv(bucket_id, from, data)

    Receive a bucket identified by bucket id from a remote replica set.

    :param bucket_id: a bucket identifier
    :param from: UUID of source replica set
    :param data: data logically stored in a bucket identified by bucket_id, in the same format as
                 the return value from ``bucket_collect() <storage_api-bucket_collect>``

..  _storage_api-bucket_stat:

..  function:: vshard.storage.bucket_stat(bucket_id)

    Return information about the bucket id:

    ..  code-block:: tarantoolsession

        tarantool> vshard.storage.bucket_stat(1)
        ---
        - 0
        - status: active
          id: 1
        ...

    :param bucket_id: a bucket identifier

..  _storage_api-bucket_delete_garbage:

..  function:: vshard.storage.bucket_delete_garbage(bucket_id)

    Force garbage collection for the bucket identified by bucket_id in case the bucket was
    transferred to a different replica set.

    :param bucket_id: a bucket identifier

..  _storage_api-bucket_collect:

..  function:: vshard.storage.bucket_collect(bucket_id)

    Collect all the data that is logically stored in the bucket identified by bucket_id:

    ..  code-block:: tarantoolsession

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

..  _storage_api-bucket_force_create:

..  function:: vshard.storage.bucket_force_create(first_bucket_id, count)

    Force creation of the buckets (single or multiple) on the current replica
    set. Use only for manual emergency recovery or for initial bootstrap.

    :param first_bucket_id: an identifier of the first bucket in a range
    :param count: the number of buckets to insert (default = 1)

..  _storage_api-bucket_force_drop:

..  function:: vshard.storage.bucket_force_drop(bucket_id)

    Drop a bucket manually for tests or emergency cases.

    :param bucket_id: a bucket identifier

..  _storage_api-bucket_send:

..  function:: vshard.storage.bucket_send(bucket_id, to)

    Send a specified bucket from the current replica set to a remote replica set.

    :param bucket_id: bucket identifier
    :param to: UUID of a remote replica set

..  _storage_api-rebalancer_request_state:

..  function:: vshard.storage.rebalancer_request_state()

    Check all buckets of the host storage that have the SENT or ACTIVE
    state, return the number of active buckets.

    :return: the number of buckets in the active state, if found; otherwise, nil

..  _storage_api-buckets_discovery:

..  function:: vshard.storage.buckets_discovery()

    Collect an array of active bucket identifiers for discovery.