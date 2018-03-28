* :ref:`replication <cfg_replication-replication>`
* :ref:`replication_timeout <cfg_replication-replication_timeout>`
* :ref:`replication_connect_timeout <cfg_replication-replication_connect_timeout>`
* :ref:`replication_connect_quorum <cfg_replication-replication_connect_quorum>`
* :ref:`replication_sync_lag <cfg_replication-replication_sync_lag>`
* :ref:`replicaset_uuid <cfg_replication-replicaset_uuid>`
* :ref:`instance_uuid <cfg_replication-instance_uuid>`

.. _cfg_replication-replication:

.. confval:: replication

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

.. _cfg_replication-replication_timeout:

.. confval:: replication_timeout

    A replica sends heartbeat messages to the master every second, and the
    master is programmed to reconnect automatically if it doesn’t see heartbeat
    messages more often than ``replication_timeout`` seconds.

    See more in :ref:`Monitoring a replica set <replication-monitoring>`.

    | Type: integer
    | Default: 1
    | Dynamic: **yes**

.. _cfg_replication-replication_connect_timeout:

.. confval:: replication_connect_timeout

    The number of seconds that a replica will wait when trying to
    connect to a master in a cluster.
    See more in :ref:`orphan status <replication-orphan_status>`.

    This parameter is different from
    :ref:`replication_timeout <cfg_replication-replication_timeout>`,
    which is only used to automatically reconnect replication when it
    gets no heartbeats.

    | Type: float
    | Default: 4
    | Dynamic: no

.. _cfg_replication-replication_connect_quorum:

.. confval:: replication_connect_quorum

    By default a replica will try to connect to all the masters,
    or it will not start. (The default is recommended so that all replicas
    will receive the same replica set UUID.)

    However, by specifying ``replication_connect_quorum = N``, where
    N is a number greater than or equal to zero,
    users can state that the replica only needs to connect to N masters.

    Example:

    .. code-block:: lua

        box.cfg{replication_connect_quorum=2}

    | Type: integer
    | Default: null
    | Dynamic: **yes**

.. _cfg_replication-replication_sync_lag:

.. confval:: replication_sync_lag

    The maximum :ref:`lag <box_info_replication_upstream_lag>` allowed for a replica.
    When a replica syncs (gets updates from a master), it may not catch up completely.
    The number of seconds that the replica is behind the master is called the "lag".
    Syncing is considered to be complete when the replica's lag is less than
    or equal to ``replication_sync_lag``.

    If a user sets ``replication_sync_lag`` to nil or to 365 * 100 * 86400 (TIMEOUT_INFINITY),
    then lag does not matter -- the replica is always considered to be "synced".

    | Type: float
    | Default: 10
    | Dynamic: no

.. _cfg_replication-replicaset_uuid:

.. confval:: replicaset_uuid

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

    | Type: string
    | Default: null
    | Dynamic: no

.. _cfg_replication-instance_uuid:

.. confval:: instance_uuid

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
