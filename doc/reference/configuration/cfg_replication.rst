* :ref:`replication <cfg_replication-replication>`
* :ref:`replication_anon <cfg_replication-replication_anon>`
* :ref:`bootstrap_leader <cfg_replication-bootstrap_leader>`
* :ref:`bootstrap_strategy <cfg_replication-bootstrap_strategy>`
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
* :ref:`replication_threads <cfg_replication-replication_replication_threads>`
* :ref:`election_mode <cfg_replication-election_mode>`
* :ref:`election_timeout <cfg_replication-election_timeout>`
* :ref:`election_fencing_mode <cfg_replication-election_fencing_mode>`
* :ref:`instance_name <cfg_replication-instance_name>`
* :ref:`replicaset_name <cfg_replication-replicaset_name>`
* :ref:`cluster_name <cfg_replication-cluster_name>`


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

    |
    | Type: string
    | Default: null
    | Environment variable: TT_REPLICATION
    | Dynamic: yes

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

    |
    | Type: boolean
    | Default: false
    | Environment variable: TT_REPLICATION_ANON
    | Dynamic: yes


.. _cfg_replication-bootstrap_leader:

.. confval:: bootstrap_leader

    Since :doc:`3.0.0 </release/3.0.0>`.

    A bootstrap leader for a replica set.
    You can pass a bootstrap leader's URI, UUID, or name.

    To specify a bootstrap leader manually, you need to set :ref:`bootstrap_strategy <cfg_replication-bootstrap_strategy>` to ``config``, for example:

    ..  code-block:: lua

        box.cfg{
            bootstrap_strategy = 'config',
            bootstrap_leader = '127.0.0.1:3301',
            replication = {'127.0.0.1:3301'},
        }

    |
    | Type: string
    | Default: null
    | Environment variable: TT_BOOTSTRAP_LEADER
    | Dynamic: yes


.. _cfg_replication-bootstrap_strategy:

.. confval:: bootstrap_strategy

    Since :doc:`2.11.0 </release/2.11.0>`.

    Specify a strategy used to bootstrap a :ref:`replica set <replication-bootstrap>`.
    The following strategies are available:

    *   ``auto``: a node doesn't boot if a half or more of other nodes in a replica set are not connected.
        For example, if the :ref:`replication <cfg_replication-replication>` parameter contains 2 or 3 nodes,
        a node requires 2 connected instances.
        In the case of 4 or 5 nodes, at least 3 connected instances are required.
        Moreover, a bootstrap leader fails to boot unless every connected node has chosen it as a bootstrap leader.

    *   ``config``: use the specified node to bootstrap a replica set.
        To specify the bootstrap leader, use the :ref:`bootstrap_leader <cfg_replication-bootstrap_leader>` option.

    *   ``supervised``: a bootstrap leader isn't chosen automatically but should be appointed using :ref:`box.ctl.make_bootstrap_leader() <box_ctl-make_bootstrap_leader>` on the desired node.

    *   ``legacy`` (deprecated since :doc:`2.11.0 </release/2.11.0>`): a node requires the :ref:`replication_connect_quorum <cfg_replication-replication_connect_quorum>` number of other nodes to be connected.
        This option is added to keep the compatibility with the current versions of Cartridge and might be removed in the future.

    |
    | Type: string
    | Default: auto
    | Environment variable: TT_BOOTSTRAP_STRATEGY
    | Dynamic: yes


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

    |
    | Type: float
    | Default: 30
    | Environment variable: TT_REPLICATION_CONNECT_TIMEOUT
    | Dynamic: yes

.. _cfg_replication-replication_connect_quorum:

.. confval:: replication_connect_quorum

    Deprecated since :doc:`2.11.0 </release/2.11.0>`.

    This option is in effect if :ref:`bootstrap_strategy <cfg_replication-bootstrap_strategy>` is set to ``legacy``.

    Specify the number of nodes to be up and running to start a replica set.
    This parameter has effect during :ref:`bootstrap <replication-leader>` or
    :ref:`configuration update <replication-configuration_update>`.
    Setting ``replication_connect_quorum`` to ``0`` makes Tarantool
    require no immediate reconnect only in case of recovery.
    See :ref:`Orphan status <replication-orphan_status>` for details.

    Example:

    .. code-block:: lua

        box.cfg { replication_connect_quorum = 2 }

    |
    | Type: integer
    | Default: null
    | Environment variable: TT_REPLICATION_CONNECT_QUORUM
    | Dynamic: yes

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

    |
    | Type: boolean
    | Default: false
    | Environment variable: TT_REPLICATION_SKIP_CONFLICT
    | Dynamic: yes


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

    |
    | Type: float
    | Default: 10
    | Environment variable: TT_REPLICATION_SYNC_LAG
    | Dynamic: yes

.. _cfg_replication-replication_sync_timeout:

.. confval:: replication_sync_timeout

    Since version 1.10.2.

    The number of seconds that a node waits when trying to sync with
    other nodes in a replica set (see :ref:`bootstrap_strategy <cfg_replication-bootstrap_strategy>`),
    after connecting or during :ref:`configuration update <replication-configuration_update>`.
    This could fail indefinitely if ``replication_sync_lag`` is smaller
    than network latency, or if the replica cannot keep pace with master
    updates. If ``replication_sync_timeout`` expires, the replica
    enters :ref:`orphan status <replication-orphan_status>`.

    |
    | Type: float
    | Default: 300
    | Environment variable: TT_REPLICATION_SYNC_TIMEOUT
    | Dynamic: yes

    .. NOTE::

        The default ``replication_sync_timeout`` value is going to be changed in future versions from ``300`` to ``0``.
        You can learn the reasoning behind this decision from the :ref:`Default value for replication_sync_timeout <compat-option-replication-timeout>` topic, which also describes how to try the new behavior in the current version.

.. _cfg_replication-replication_timeout:

.. confval:: replication_timeout

    Since version 1.7.5.

    If the master has no updates to send to the replicas, it sends heartbeat messages
    every ``replication_timeout`` seconds, and each replica sends an ACK packet back.

    Both master and replicas are programmed to drop the connection if they get no
    response in four ``replication_timeout`` periods.
    If the connection is dropped, a replica tries to reconnect to the master.

    See more in :ref:`Monitoring a replica set <replication-monitoring>`.

    |
    | Type: integer
    | Default: 1
    | Environment variable: TT_REPLICATION_TIMEOUT
    | Dynamic: yes

.. _cfg_replication-replicaset_uuid:

.. confval:: replicaset_uuid

    Since version 1.9.0.

    As described in section
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

    |
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

    |
    | Type: string
    | Default: null
    | Environment variable: TT_INSTANCE_UUID
    | Dynamic: no

.. _cfg_replication-replication_synchro_quorum:

.. confval:: replication_synchro_quorum

    Since version :doc:`2.5.1 </release/2.5.1>`.

    For :ref:`synchronous replication <repl_sync>` only.
    This option tells how many replicas should confirm the receipt of a
    synchronous transaction before it can finish its commit.

    Since version :doc:`2.5.3 </release/2.5.3>`,
    the option supports dynamic evaluation of the quorum number.
    That is, the number of quorum can be specified not as a constant number, but as a function instead.
    In this case, the option returns the formula evaluated.
    The result is treated as an integer number.
    Once any replicas are added or removed, the expression is re-evaluated automatically.

    For example,

    ..  code-block:: lua

        box.cfg{replication_synchro_quorum = "N / 2 + 1"}

    Where `N` is a current number of registered replicas in a cluster.

    Keep in mind that the example above represents a canonical quorum definition.
    The formula ``at least 50% of the cluster size + 1`` guarantees data reliability.
    Using a value less than the canonical one might lead to unexpected results,
    including a :ref:`split-brain <repl_leader_elect_splitbrain>`.

    Since version :doc:`2.10.0 </release/2.10.0>`, this option
    does not account for anonymous replicas.

    The default value for this parameter is ``N / 2 + 1``.

    It is not used on replicas, so if the master dies, the pending synchronous
    transactions will be kept waiting on the replicas until a new master is elected.

    If the value for this option is set to ``1``, the synchronous transactions work like asynchronous when not configured.
    `1` means that successful WAL write to the master is enough to commit.

    |
    | Type: number
    | Default: N / 2 + 1 (before version :doc:`2.10.0 </release/2.10.0>`, the default value was 1)
    | Environment variable: TT_REPLICATION_SYNCHRO_QUORUM
    | Dynamic: yes

.. _cfg_replication-replication_synchro_timeout:

.. confval:: replication_synchro_timeout

    Since version :doc:`2.5.1 </release/2.5.1>`.

    For :ref:`synchronous replication <repl_sync>` only.
    Tells how many seconds to wait for a synchronous transaction quorum
    replication until it is declared failed and is rolled back.

    It is not used on replicas, so if the master dies, the pending synchronous
    transactions will be kept waiting on the replicas until a new master is
    elected.

    |
    | Type: number
    | Default: 5
    | Environment variable: TT_REPLICATION_SYNCHRO_TIMEOUT
    | Dynamic: yes

.. _cfg_replication-replication_replication_threads:

.. confval:: replication_threads

    Since version :doc:`2.10.0 </release/2.10.0>`.

    The number of threads spawned to decode the incoming replication data.

    The default value is `1`.
    It means that a single separate thread handles all the incoming replication streams.
    In most cases, one thread is enough for all incoming data.
    Therefore, it is likely that the user will not need to set this configuration option.

    Possible values range from 1 to 1000.
    If there are multiple replication threads, connections to serve are distributed evenly between the threads.

    |
    | Type: number
    | Default: 1
    | Possible values: from 1 to 1000
    | Environment variable: TT_REPLICATION_THREADS
    | Dynamic: **no**

..  _cfg_replication-election_mode:

..  confval:: election_mode

    Since version :doc:`2.6.1 </release/2.6.1>`.

    Specify the role of a replica set node in the
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

    |
    | Type: string
    | Default: 'off'
    | Environment variable: TT_ELECTION_MODE
    | Dynamic: yes

..  _cfg_replication-election_timeout:

..  confval:: election_timeout

    Since version :doc:`2.6.1 </release/2.6.1>`.

    Specify the timeout between election rounds in the
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

    |
    | Type: number
    | Default: 5
    | Environment variable: TT_ELECTION_TIMEOUT
    | Dynamic: yes

..  _cfg_replication-election_fencing_mode:

..  confval:: election_fencing_mode

    Since version :doc:`2.11.0 </release/2.11.0>`.

    In earlier Tarantool versions, use :ref:`election_fencing_enabled <cfg_election-election_fencing_enabled_deprecated>` instead.

    Specify the :ref:`leader fencing mode <repl_leader_elect_fencing>` that
    affects the leader election process. When the parameter is set to ``soft``
    or ``strict``, the leader resigns its leadership if it has less than
    :ref:`replication_synchro_quorum <cfg_replication-replication_synchro_quorum>`
    of alive connections to the cluster nodes.
    The resigning leader receives the status of a
    :ref:`follower <repl_leader_elect>` in the current election term and becomes
    read-only.

    *   In ``soft`` mode, a connection is considered dead if there are no responses for
        :ref:`4*replication_timeout <cfg_replication-replication_timeout>` seconds both on the current leader and the followers.

    *   In ``strict`` mode, a connection is considered dead if there are no responses
        for :ref:`2*replication_timeout <cfg_replication-replication_timeout>` seconds on the
        current leader and
        :ref:`4*replication_timeout <cfg_replication-replication_timeout>` seconds on the
        followers. This improves chances that there is only one leader at any time.

    Fencing applies to the instances that have the
    :ref:`election_mode <cfg_replication-election_mode>` set to ``candidate`` or ``manual``.
    To turn off :ref:`leader fencing <repl_leader_elect_fencing>`, set ``election_fencing_mode`` to ``off``.

    |
    | Type: string
    | Default: 'soft'
    | Environment variable: TT_ELECTION_FENCING_MODE
    | Dynamic: yes

.. _cfg_replication-instance_name:

.. confval:: instance_name

    Since version :doc:`3.0.0 </release/3.0.0>`.

    Specify the instance name.
    This value must be unique in a replica set.

    The following rules are applied to instance names:

    -   The maximum number of symbols is 63.
    -   Should start with a letter.
    -   Can contain lowercase letters (a-z). If uppercase letters are used, they are converted to lowercase.
    -   Can contain digits (0-9).
    -   Can contain the following characters: ``-``, ``_``.

    To change or remove the specified name, you should temporarily set the :ref:`box.cfg.force_recovery <cfg_binary_logging_snapshots-force_recovery>` configuration option to ``true``.
    When all the names are updated and all the instances synced, ``box.cfg.force_recovery`` can be set back to ``false``.

    ..  NOTE::

        The instance name is persisted in the :ref:`box.space._cluster <box_space-cluster>` system space.

    See also: :ref:`box_info_name`

    |
    | Type: string
    | Default: null
    | Environment variable: TT_INSTANCE_NAME
    | Dynamic: no

.. _cfg_replication-replicaset_name:

.. confval:: replicaset_name

    Since version :doc:`3.0.0 </release/3.0.0>`.

    Specify the name of a replica set to which this instance belongs.
    This value must be the same for all instances of the replica set.

    See the :ref:`instance_name <cfg_replication-instance_name>` description to learn:

    -   which rules are applied to names
    -   how to change or remove an already specified name

    ..  NOTE::

        The replica set name is persisted in the :ref:`box.space._schema <box_space-schema>` system space.

    See also: :ref:`box_info_replicaset`

    |
    | Type: string
    | Default: null
    | Environment variable: TT_REPLICASET_NAME
    | Dynamic: no

.. _cfg_replication-cluster_name:

.. confval:: cluster_name

    Since version :doc:`3.0.0 </release/3.0.0>`.

    Specify the name of a cluster to which this instance belongs.
    This value must be the same for all instances of the cluster.

    See the :ref:`instance_name <cfg_replication-instance_name>` description to learn:

    -   which rules are applied to names
    -   how to change or remove an already specified name

    ..  NOTE::

        The cluster name is persisted in the :ref:`box.space._schema <box_space-schema>` system space.

    See also: :ref:`box_info_cluster`

    |
    | Type: string
    | Default: null
    | Environment variable: TT_CLUSTER_NAME
    | Dynamic: no
