* :ref:`replication <cfg_replication-replication>`
* :ref:`replication_timeout <cfg_replication-replication_timeout>`
* :ref:`instance_uuid <cfg_replication-instance_uuid>`
* :ref:`replicaset_uuid <cfg_replication-replicaset_uuid>`

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

.. _cfg_replication-instance_uuid:

.. confval:: instance_uuid

    For replication administration purposes, it is possible to set the
    unique values of the instance and the replica set, instead of having
    the system generate the values.
    See the description of the
    :ref:`replicaset_uuid parameter setting <cfg_replication-replicaset_uuid>`.
    Example: ``box.cfg{instance_uuid='037fec43-18a9-4e12-a684-a42b716fcd02'}``

    | Type: string
    | Default: null
    | Dynamic: no
    
.. _cfg_replication-replicaset_uuid:

.. confval:: replicaset_uuid

    As described in section :ref:`"Replication architecture" <replication-architecture>`, each replica set is
    identified by a globally unique identifier called replica set UUID.
    Ordinarily it is sufficient to let the system generate and format a 36-byte string
    which will be permanently stored. However, some administrators may prefer
    to store Tarantool configuration information in a central repository,
    for example ZooKeeper. In that case, such administrators can assign
    their own values for either or both instance_uuid and
    replicaset_uuid, when starting up for the first time.
    The values must be true unique identifiers, not shared by other instances.
    The values must be used consistently, not changed after initial setup
    (the initial values are stored in snapshot files and are checked whenever
    the system is restarted).
    Example: ``box.cfg{replicaset_uuid='7b853d13-508b-4b8e-82e6-806f088ea6e9'}``    
    
    | Type: string
    | Default: null
    | Dynamic: no
    
