* :ref:`replication <cfg_replication-replication>`

.. _cfg_replication-replication:

.. confval:: replication

    If ``replication`` is not an empty string, the instance is considered to be
    a Tarantool :ref:`replica <index-box_replication>`. The replica will
    try to connect to the master specified in ``replication`` with a
    :ref:`URI <index-uri>` (Universal Resource Identifier), for example:
    
    :samp:`{konstantin}:{secret_password}@{tarantool.org}:{3301}`

    If there is more than one replication source in a replica set, specify an
    array of URIs, for example:
    
    :extsamp:`box.cfg{ replication = { {*{'uri1'}*}, {*{'uri2'}*} } }`

    If one of the URIs is "self" -- that is, if one of the URIs is for the
    instance where ``box.cfg{}`` is being executed on -- then it is ignored.
    Thus it is possible to use the same ``replication`` specification on
    multiple servers.

    The default user name is ‘guest’. A replica does not accept
    data-change requests on the :ref:`listen <cfg_basic-listen>` port.
    The ``replication`` parameter is dynamic, that is, to enter master
    mode, simply set ``replication`` to an empty string and issue:
    
    :extsamp:`box.cfg{ replication = {*{new-value}*} }`

    | Type: string
    | Default: null
    | Dynamic: **yes**
