* :ref:`replication <cfg_replication-replication>`
* :ref:`replication_timeout <cfg_replication-replication_timeout>`

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
