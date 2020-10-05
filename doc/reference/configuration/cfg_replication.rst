* :ref:`replication <cfg_replication-replication>`
* :ref:`replication_connect_timeout <cfg_replication-replication_connect_timeout>`
* :ref:`replication_connect_quorum <cfg_replication-replication_connect_quorum>`
* :ref:`replication_skip_conflict <cfg_replication-replication_skip_conflict>`
* :ref:`replication_sync_lag <cfg_replication-replication_sync_lag>`
* :ref:`replication_sync_timeout <cfg_replication-replication_sync_timeout>`
* :ref:`replication_timeout <cfg_replication-replication_timeout>`
* :ref:`replicaset_uuid <cfg_replication-replicaset_uuid>`
* :ref:`instance_uuid <cfg_replication-instance_uuid>`

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

    If one of the URIs is "self" -- that is, if one of the URIs is for the
    instance where ``box.cfg{}`` is being executed on -- then it is ignored.
    Thus it is possible to use the same ``replication`` specification on
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
    | Dynamic: **yes**

.. _cfg_replication-replication_connect_timeout:

.. confval:: replication_connect_timeout

    Since version 1.9.0.
    The number of seconds that a replica will wait when trying to
    connect to a master in a cluster.
    See :ref:`orphan status <replication-orphan_status>` for details.

    This parameter is different from
    :ref:`replication_timeout <cfg_replication-replication_timeout>`,
    which is only used to automatically reconnect replication when it
    gets no heartbeats.

    | Type: float
    | Default: 30
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
    | Dynamic: **yes**

.. _cfg_replication-replication_skip_conflict:

.. confval:: replication_skip_conflict

    Since version 1.10.1.
    By default, if a replica adds a unique key that another replica has
    added, replication :ref:`stops <replication-replication_stops>`
    with error = ER_TUPLE_FOUND.

    However, by specifying ``replication_skip_conflict = true``,
    users can state that such errors may be ignored.

    Example:

    .. code-block:: lua

        box.cfg{replication_skip_conflict=true}

    | Type: boolean
    | Default: false
    | Dynamic: **yes**


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
    | Dynamic: **yes**

.. _cfg_replication-replication_timeout:

.. confval:: replication_timeout

    Since version 1.8.2.
    If the master has no updates to send to the replicas, it sends heartbeat messages
    every ``replication_timeout`` seconds, and each replica sends an ACK packet back.

    Both master and replicas are programmed to drop the connection if they get no
    response in four ``replication_timeout`` periods.
    If the connection is dropped, a replica tries to reconnect to the master.

    See more in :ref:`Monitoring a replica set <replication-monitoring>`.

    | Type: integer
    | Default: 1
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
    | Dynamic: no
