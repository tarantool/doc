* :ref:`replication <cfg_replication-replication>`
* :ref:`replication_anon <cfg_replication-replication_anon>`
* :ref:`replication_connect_timeout <cfg_replication-replication_connect_timeout>`
* :ref:`replication_connect_quorum <cfg_replication-replication_connect_quorum>`
* :ref:`replication_skip_conflict <cfg_replication-replication_skip_conflict>`
* :ref:`replication_sync_lag <cfg_replication-replication_sync_lag>`
* :ref:`replication_sync_timeout <cfg_replication-replication_sync_timeout>`
* :ref:`replication_timeout <cfg_replication-replication_timeout>`
* :ref:`replicaset_uuid <cfg_replication-replicaset_uuid>`
* :ref:`instance_uuid <cfg_replication-instance_uuid>`
* :ref:`replication_synchro_quorum <cfg_replication-replication_synchro_quorum>`
* :ref:`replication_synchro_timeout <cfg_replication-replication_synchro_timeout>`
* :ref:`election_mode <cfg_replication-election_mode>`
* :ref:`election_timeout <cfg_replication-election_timeout>`
* :ref:`election_fencing_mode <cfg_replication-election_fencing_mode>`

.. _cfg_replication-replication:

.. confval:: replication

    Since version 1.7.4.
    If ``replication`` is not an empty string, the instance is considered to be
    a Tarantool :ref:`replica <replication>`. The replica will
    try to connect to the master specified in ``replication`` with a
    :ref:`URI <index-uri>` (Universal Resource Identifier), for example:

    :samp:`{konstantin}:{secret_password}@{tarantool.org}:{3301}`

    If there is more than one replication source in a replica set, specify an
    array of URIs, for example (replace 'uri' and 'uri2' in this example with
    valid URIs):

    :extsamp:`box.cfg{ replication = { {*{'uri1'}*}, {*{'uri2'}*} } }`

    ..  note::

        Starting from version 2.10.0, there is a number of other ways for specifying several URIs. See :ref:`syntax examples <index-uri-several>`.

    If one of the URIs is "self" -- that is, if one of the URIs is for the
    instance where ``box.cfg{}`` is being executed -- then it is ignored.
    Thus, it is possible to use the same ``replication`` specification on
    multiple server instances, as shown in
    :ref:`these examples <replication-bootstrap>`.

    The default user name is 'guest'.

    A read-only replica does not accept data-change requests on the
    :ref:`listen <cfg_basic-listen>` port.

    The ``replication`` parameter is dynamic, that is, to enter master
    mode, simply set ``replication`` to an empty string and issue:

    :extsamp:`box.cfg{ replication = {*{new-value}*} }`

    | Type: string
    | Default: null
    | Environment variable: TT_REPLICATION
    | Dynamic: **yes**

.. _cfg_replication-replication_anon:

.. confval:: replication_anon

    Since version 2.3.1.
    A Tarantool replica can be anonymous. This type of replica
    is read-only (but you still can write to temporary and
    replica-local spaces), and it isn't present in the ``_cluster`` table.

    Since an anonymous replica isn't registered in the ``_cluster`` table,
    there is no limitation for anonymous replicas count in a replica set:
    you can have as many of them as you want.

    In order to make a replica anonymous, pass the option
    ``replication_anon=true`` to ``box.cfg`` and set ``read_only``
    to ``true``.

    Let's go through anonymous replica bootstrap.
    Suppose we have got a master configured with

    .. code-block:: lua

        box.cfg{listen=3301}

    and created a local space called "loc":

    .. code-block:: lua

        box.schema.space.create('loc', {is_local=true})
        box.space.loc:create_index("pk")

    Now, to configure an anonymous replica, we need to issue ``box.cfg``,
    as usual.

    .. code-block:: lua

        box.cfg{replication_anon=true, read_only=true, replication=3301}

    As mentioned above, ``replication_anon`` may be set to ``true`` only together
    with ``read_only``.
    The instance will fetch the master's snapshot and start following its
    changes. It will receive no id, so its id value will remain zero.

    .. code-block:: tarantoolsession

        tarantool> box.info.id
        ---
        - 0
        ...
        tarantool> box.info.replication
        ---
        - 1:
            id: 1
            uuid: 3c84f8d9-e34d-4651-969c-3d0ed214c60f
            lsn: 4
            upstream:
            status: follow
            idle: 0.6912029999985
            peer:
            lag: 0.00014615058898926
        ...

    Now we can use the replica.
    For example, we can do inserts into the local space:

    .. code-block:: tarantoolsession

        tarantool> for i = 1,10 do
            > box.space.loc:insert{i}
            > end
        ---
        ...

    Note that while the instance is anonymous, it will increase the 0-th
    component of its ``vclock``:

    .. code-block:: tarantoolsession

        tarantool> box.info.vclock
        ---
        - {0: 10, 1: 4}
        ...

    Let's now promote the anonymous replica to a regular one:

    .. code-block:: tarantoolsession

        tarantool> box.cfg{replication_anon=false}
        2019-12-13 20:34:37.423 [71329] main I> assigned id 2 to replica 6a9c2ed2-b9e1-4c57-a0e8-51a46def7661
        2019-12-13 20:34:37.424 [71329] main/102/interactive I> set 'replication_anon' configuration option to false
        ---
        ...

        tarantool> 2019-12-13 20:34:37.424 [71329] main/117/applier/ I> subscribed
        2019-12-13 20:34:37.424 [71329] main/117/applier/ I> remote vclock {1: 5} local vclock {0: 10, 1: 5}
        2019-12-13 20:34:37.425 [71329] main/118/applierw/ C> leaving orphan mode

    The replica has just received an id equal to 2. We can make it read-write now.

    .. code-block:: tarantoolsession

        tarantool> box.cfg{read_only=false}
        2019-12-13 20:35:46.392 [71329] main/102/interactive I> set 'read_only' configuration option to false
        ---
        ...

        tarantool> box.schema.space.create('test')
        ---
        - engine: memtx
        before_replace: 'function: 0x01109f9dc8'
        on_replace: 'function: 0x01109f9d90'
        ck_constraint: []
        field_count: 0
        temporary: false
        index: []
        is_local: false
        enabled: false
        name: test
        id: 513
        - created
        ...

        tarantool> box.info.vclock
        ---
        - {0: 10, 1: 5, 2: 2}
        ...

    Now the replica tracks its changes in the 2nd ``vclock`` component,
    as expected.
    It can also become a replication master from now on.

    Notes:

    * You cannot replicate from an anonymous instance.
    * To promote an anonymous instance to a regular one,
      first start it as anonymous, and only
      then issue ``box.cfg{replication_anon=false}``
    * In order for the deanonymization to succeed, the
      instance must replicate from some read-write instance,
      otherwise it cannot be added to the ``_cluster`` table.

    | Type: boolean
    | Default: false
    | Environment variable: TT_REPLICATION_ANON
    | Dynamic: **yes**

.. _cfg_replication-replication_connect_timeout:

.. confval:: replication_connect_timeout

    Since version 1.9.0.
    The number of seconds that a replica will wait when trying to
    connect to a master in a cluster.
    See :ref:`orphan status <replication-orphan_status>` for details.

    This parameter is different from
    :ref:`replication_timeout <cfg_replication-replication_timeout>`,
    which a master uses to disconnect a replica when the master
    receives no acknowledgments of heartbeat messages.

    | Type: float
    | Default: 30
    | Environment variable: TT_REPLICATION_CONNECT_TIMEOUT
    | Dynamic: **yes**

.. _cfg_replication-replication_connect_quorum:

.. confval:: replication_connect_quorum

    Since version 1.9.0.
    By default a replica will try to connect to all the masters,
    or it will not start. (The default is recommended so that all replicas
    will receive the same replica set UUID.)

    However, by specifying ``replication_connect_quorum = N``, where
    N is a number greater than or equal to zero,
    users can state that the replica only needs to connect to N masters.

    This parameter has effect during bootstrap and during
    :ref:`configuration update <replication-configuration_update>`.
    Setting ``replication_connect_quorum = 0`` makes Tarantool
    require no immediate reconnect only in case of recovery.
    See :ref:`orphan status <replication-orphan_status>` for details.

    Example:

    .. code-block:: lua

        box.cfg{replication_connect_quorum=2}

    | Type: integer
    | Default: null
    | Environment variable: TT_REPLICATION_CONNECT_QUORUM
    | Dynamic: **yes**

.. _cfg_replication-replication_skip_conflict:

.. confval:: replication_skip_conflict

    Since version 1.10.1.
    By default, if a replica adds a unique key that another replica has
    added, replication :ref:`stops <replication-replication_stops>`
    with error = ER_TUPLE_FOUND.

    However, by specifying ``replication_skip_conflict = true``,
    users can state that such errors may be ignored. So instead of saving
    the broken transaction to the xlog, it will be written there as ``NOP`` (No operation).

    Example:

    .. code-block:: lua

        box.cfg{replication_skip_conflict=true}

    | Type: boolean
    | Default: false
    | Environment variable: TT_REPLICATION_SKIP_CONFLICT
    | Dynamic: **yes**


    .. NOTE::

        ``replication_skip_conflict = true`` is recommended to be used only for
        manual replication recovery.

.. _cfg_replication-replication_sync_lag:

.. confval:: replication_sync_lag

    Since version 1.9.0.
    The maximum :ref:`lag <box_info_replication_upstream_lag>` allowed for a replica.
    When a replica :ref:`syncs <replication-orphan_status>`
    (gets updates from a master), it may not catch up completely.
    The number of seconds that the replica is behind the master is called the "lag".
    Syncing is considered to be complete when the replica's lag is less than
    or equal to ``replication_sync_lag``.

    If a user sets ``replication_sync_lag`` to nil or to 365 * 100 * 86400 (TIMEOUT_INFINITY),
    then lag does not matter -- the replica is always considered to be "synced".
    Also, the lag is ignored (assumed to be infinite) in case the master is running
    Tarantool older than 1.7.7, which does not send :ref:`heartbeat messages <heartbeat>`.

    This parameter is ignored during bootstrap.
    See :ref:`orphan status <replication-orphan_status>` for details.

    | Type: float
    | Default: 10
    | Environment variable: TT_REPLICATION_SYNC_LAG
    | Dynamic: **yes**

.. _cfg_replication-replication_sync_timeout:

.. confval:: replication_sync_timeout

    Since version 1.10.2.
    The number of seconds that a replica will wait when trying to
    sync with a master in a cluster,
    or a :ref:`quorum <cfg_replication-replication_connect_quorum>` of masters,
    after connecting or during :ref:`configuration update <replication-configuration_update>`.
    This could fail indefinitely if ``replication_sync_lag`` is smaller
    than network latency, or if the replica cannot keep pace with master
    updates. If ``replication_sync_timeout`` expires, the replica
    enters :ref:`orphan status <replication-orphan_status>`.

    | Type: float
    | Default: 300
    | Environment variable: TT_REPLICATION_SYNC_TIMEOUT
    | Dynamic: **yes**

.. _cfg_replication-replication_timeout:

.. confval:: replication_timeout

    Since version 1.7.5.
    If the master has no updates to send to the replicas, it sends heartbeat messages
    every ``replication_timeout`` seconds, and each replica sends an ACK packet back.

    Both master and replicas are programmed to drop the connection if they get no
    response in four ``replication_timeout`` periods.
    If the connection is dropped, a replica tries to reconnect to the master.

    See more in :ref:`Monitoring a replica set <replication-monitoring>`.

    | Type: integer
    | Default: 1
    | Environment variable: TT_REPLICATION_TIMEOUT
    | Dynamic: **yes**

.. _cfg_replication-replicaset_uuid:

.. confval:: replicaset_uuid

    Since version 1.9.0. As described in section
    :ref:`"Replication architecture" <replication-architecture>`,
    each replica set is identified by a
    `universally unique identifier <https://en.wikipedia.org/wiki/Universally_unique_identifier>`_
    called **replica set UUID**, and each instance is identified by an
    **instance UUID**.

    Ordinarily it is sufficient to let the system generate and format the UUID
    strings which will be permanently stored.

    However, some administrators may prefer to store Tarantool configuration
    information in a central repository, for example
    `Apache ZooKeeper <https://zookeeper.apache.org>`_.
    Such administrators can assign their own UUID values for either -- or both --
    instances (:ref:`instance_uuid <cfg_replication-instance_uuid>`) and
    replica set (``replicaset_uuid``), when starting up for the first time.

    General rules:

    * The values must be true unique identifiers, not shared by other instances
      or replica sets within the common infrastructure.

    * The values must be used consistently, not changed after initial setup
      (the initial values are stored in :ref:`snapshot files <index-box_persistence>`
      and are checked whenever the system is restarted).

    * The values must comply with `RFC 4122 <https://tools.ietf.org/html/rfc4122>`_.
      The `nil UUID <https://tools.ietf.org/html/rfc4122#section-4.1.7>`_ is not
      allowed.

    The UUID format includes sixteen octets represented as 32 hexadecimal
    (base 16) digits, displayed in five groups separated by hyphens, in the form
    ``8-4-4-4-12`` for a total of 36 characters (32 alphanumeric characters and
    four hyphens).

    Example:

    .. code-block:: lua

        box.cfg{replicaset_uuid='7b853d13-508b-4b8e-82e6-806f088ea6e9'}

    | Type: string
    | Default: null
    | Environment variable: TT_REPLICASET_UUID
    | Dynamic: no

.. _cfg_replication-instance_uuid:

.. confval:: instance_uuid

    Since version 1.9.0.
    For replication administration purposes, it is possible to set the
    `universally unique identifiers <https://en.wikipedia.org/wiki/Universally_unique_identifier>`_
    of the instance (``instance_uuid``) and the replica set
    (``replicaset_uuid``), instead of having the system generate the values.

    See the description of
    :ref:`replicaset_uuid <cfg_replication-replicaset_uuid>` parameter for details.

    Example:

    .. code-block:: lua

        box.cfg{instance_uuid='037fec43-18a9-4e12-a684-a42b716fcd02'}

    | Type: string
    | Default: null
    | Environment variable: TT_INSTANCE_UUID
    | Dynamic: no

.. _cfg_replication-replication_synchro_quorum:

.. confval:: replication_synchro_quorum

    Since version :doc:`2.5.1 </release/2.5.1>`.
    For :ref:`synchronous replication <repl_sync>` only.
    This option tells how many replicas should confirm the receipt of a
    synchronous transaction before it can finish its commit. So far this
    option accounts all replicas, including anonymous.

    It is 1 by default, so synchronous transactions work like asynchronous when
    not configured. 1 means successful WAL write on master is enough for
    commit.

    It is not used on replicas, so if the master dies, the pending synchronous
    transactions will be kept waiting on the replicas until a new master is elected.

    | Type: number
    | Default: 1
    | Environment variable: TT_REPLICATION_SYNCHRO_QUORUM
    | Dynamic: **yes**

.. _cfg_replication-replication_synchro_timeout:

.. confval:: replication_synchro_timeout

    Since version :doc:`2.5.1 </release/2.5.1>`.
    For :ref:`synchronous replication <repl_sync>` only.
    Tells how many seconds to wait for a synchronous transaction quorum
    replication until it is declared failed and is rolled back.

    It is not used on replicas, so if the master dies, the pending synchronous
    transactions will be kept waiting on the replicas until a new master is
    elected.

    | Type: number
    | Default: 5
    | Environment variable: TT_REPLICATION_SYNCHRO_TIMEOUT
    | Dynamic: **yes**

..  _cfg_replication-election_mode:

..  confval:: election_mode

    Since version :doc:`2.6.1 </release/2.6.1>`.
    Specifies the role of a replica set node in the
    :ref:`leader election process <repl_leader_elect>`.

    Possible values:

    * off
    * voter
    * candidate
    * manual.

    Participation of a replica set node in the automated leader election can be
    turned on and off by this option.

    The default value is ``off``. All nodes that have values other than ``off``
    run the Raft state machine internally talking to other nodes according
    to the Raft leader election protocol. When the option is ``off``, the node
    accepts Raft messages
    from other nodes, but it doesn't participate in the election activities,
    and this doesn't affect the node's state. So, for example, if a node is not
    a leader but it has ``election_mode = 'off'``, it is writable anyway.

    You can control which nodes can become a leader. If you want a node
    to participate in the election process but don't want that it becomes
    a leaders, set the ``election_mode`` option to ``voter``. In this case,
    the election works as usual, this particular node will vote for other nodes,
    but won't become a leader.

    If the node should be able to become a leader, use ``election_mode = 'candidate'``.

    Since version :doc:`2.8.2 </release/2.8.2>`, the manual election mode is introduced.
    It may be used when a user wants to control which instance is the leader explicitly instead of relying on
    the Raft election algorithm.

    When an instance is configured with the ``election_mode='manual'``, it behaves as follows:

    *   By default, the instance acts like a voter -- it is read-only and may vote for other instances that are candidates.
    *   Once :ref:`box.ctl.promote() <box_ctl-promote>` is called, the instance becomes a candidate and starts a new election round.
        If the instance wins the elections, it becomes a leader, but won't participate in any new elections.

    | Type: string
    | Default: 'off'
    | Environment variable: TT_ELECTION_MODE
    | Dynamic: **yes**

..  _cfg_replication-election_timeout:

..  confval:: election_timeout

    Since version :doc:`2.6.1 </release/2.6.1>`.
    Specifies the timeout between election rounds in the
    :ref:`leader election process <repl_leader_elect>` if the previous round
    ended up with a split-vote.

    In the :ref:`leader election process <repl_leader_elect_process>`, there
    can be an election timeout for the case of a split-vote.
    The timeout can be configured using this option; the default value is
    5 seconds.

    It is quite big, and for most of the cases it can be freely lowered to
    300-400 ms. It can be a floating point value (300 ms would be
    ``box.cfg{election_timeout = 0.3}``).

    To avoid the split vote repeat, the timeout is randomized on each node
    during every new election, from 100% to 110% of the original timeout value.
    For example, if the timeout is 300 ms and there are 3 nodes started
    the election simultaneously in the same term,
    they can set their election timeouts to 300, 310, and 320 respectively,
    or to 305, 302, and 324, and so on. In that way, the votes will never be split
    because the election on different nodes won't be restarted simultaneously.

    | Type: number
    | Default: 5
    | Environment variable: TT_ELECTION_TIMEOUT
    | Dynamic: **yes**

..  _cfg_replication-election_fencing_mode:

..  confval:: election_fencing_mode

    Since version :doc:`2.11.0 </release/2.11.0>`.

    Switches the :ref:`leader fencing mode <repl_leader_elect_fencing>` that
    affects the leader election process. When the parameter is set to ``soft``
    or ``strict``, the leader resigns its leadership if it has less than the
    :ref:`replication_synchro_quorum <cfg_replication-replication_synchro_quorum>`
    of alive connections to the cluster nodes.
    The resigning leader receives the status of a
    :ref:`follower <repl_leader_elect>` in the current election term and becomes
    read-only. :ref:`Leader fencing <repl_leader_elect_fencing>` can be turned
    off by setting the parameter to ``off``.

    In ``soft`` mode connection is considered dead if the where no responses for
    :ref:`4*replication_timeout <cfg_replication-replication_timeout>` both on
    current leader and followers.

    In ``strict`` mode connection is considered dead if the where no responses
    for :ref:`2*replication_timeout <cfg_replication-replication_timeout>` on
    current leader and
    :ref:`4*replication_timeout <cfg_replication-replication_timeout>` on
    followers. This improves chances that there will be only one leader at any
    time.

    Fencing applies to the instances that have
    :ref:`election_mode <cfg_replication-election_mode>` set to "candidate" or
    "manual".

    | Type: boolean
    | Default: true
    | Environment variable: TT_ELECTION_FENCING_MODE
    | Dynamic: **yes**
