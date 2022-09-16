..  _internals-iproto-replication:

Replication requests and responses
==================================

..  _box_protocol-replication:

Replication
-----------

IPROTO_JOIN = 0x41
~~~~~~~~~~~~~~~~~~

First you must send an initial IPROTO_JOIN request.

..  cssclass:: highlight
..  parsed-literal::

    # <size>
    msgpack(:samp:`{{MP_UINT unsigned integer = size(<header>) + size(<body>)}}`)
    # <header>
    msgpack({
        IPROTO_REQUEST_TYPE: IPROTO_JOIN,
        IPROTO_SYNC: :samp:`{{MP_UINT unsigned integer}}`
    })
    # <body>
    msgpack({
        IPROTO_INSTANCE_UUID: :samp:`{{uuid}}`
    })

Then the instance which you want to connect to will send its last SNAP file,
by simply creating a number of INSERTs (with additional LSN and ServerID)
(do not reply to this). Then that instance will send a vclock's MP_MAP and
close a socket.

..  cssclass:: highlight
..  parsed-literal::

    # <size>
    msgpack(:samp:`{{MP_UINT unsigned integer = size(<header>) + size(<body>)}}`)
    # <header>
    msgpack({
        Response-Code-Indicator: 0,
        IPROTO_SYNC: :samp:`{{MP_UINT unsigned integer}}`
    })
    # <body>
    msgpack({
        IPROTO_VCLOCK: :samp:`{{MP_INT SRV_ID, MP_INT SRV_LSN}}`
    })

IPROTO_SUBSCRIBE = 0x42
~~~~~~~~~~~~~~~~~~~~~~~

Then you must send an IPROTO_SUBSCRIBE request.

..  cssclass:: highlight
..  parsed-literal::

    # <size>
    msgpack(:samp:`{{MP_UINT unsigned integer = size(<header>) + size(<body>)}}`)
    # <header>
    msgpack({
        IPROTO_REQUEST_TYPE: IPROTO_SUBSCRIBE,
        IPROTO_SYNC: :samp:`{{MP_UINT unsigned integer}}`,
        IPROTO_INSTANCE_UUID: :samp:`{{uuid}}`,
        IPROTO_CLUSTER_UUID: :samp:`{{uuid}}`,
    })
    # <body>
    msgpack({
        IPROTO_VCLOCK: :samp:`{{MP_INT SRV_ID, MP_INT SRV_LSN}}`
    })

Then you must process every request that could come through other masters.
Every request between masters will have additional LSN and SERVER_ID.


..  _box_protocol-heartbeat:

HEARTBEATS
~~~~~~~~~~

Frequently a master sends a :ref:`heartbeat <heartbeat>` message to a replica.
For example, if there is a replica with id = 2,
and a timestamp with a moment in 2020, a master might send this:

..  cssclass:: highlight
..  parsed-literal::

    # <header>
    msgpack({
        IPROTO_REQUEST_TYPE: 0
        IPROTO_REPLICA_ID: 2
        IPROTO_TIMESTAMP: :samp:`{{Float 64 MP_DOUBLE 8-byte timestamp}}`
    })

and the replica might send back this:

..  code-block:: none

    # <header>
    msgpack({
        Response-Code-Indicator: IPROTO_OK
        IPROTO_REPLICA_ID: 2
        IPROTO_VCLOCK: {1, 6}
    })

Later in :ref:`Binary protocol -- illustration <box_protocol-illustration>`
we will show actual byte codes of the above heartbeat examples.

..  _box_protocol-ballots:

BALLOTS
~~~~~~~

While connecting for replication, an instance sends a request with header IPROTO_VOTE (0x44).
The normal response is ER_OK,and IPROTO_BALLOT (0x29).
The fields within IPROTO_BALLOT are map items:

..  code-block:: none

    IPROTO_BALLOT_IS_RO_CFG (0x01) + MP_BOOL
    IPROTO_BALLOT_VCLOCK (0x02) + vclock
    IPROTO_BALLOT_GC_VCLOCK (0x03) + vclock
    IPROTO_BALLOT_IS_RO (0x04) + MP_BOOL
    IPROTO_BALLOT_IS_ANON = 0x05 + MP_BOOL
    IPROTO_BALLOT_IS_BOOTED = 0x06 + MP_BOOL
    IPROTO_BALLOT_CAN_LEAD = 0x07 + MP_BOOL


IPROTO_BALLOT_IS_RO_CFG and IPRO_BALLOT_VCLOCK and IPROTO_BALLOT_GC_VCLOCK and IPROTO_BALLOT_IS_RO
were added in version :doc:`2.6.1 </release/2.6.1>`.
IPROTO_BALLOT_IS_ANON was added in version :doc:`2.7.1 </release/2.7.1>`.
IPROTO_BALLOT_IS_BOOTED was added in version 2.7.3 and 2.8.2 and 2.9.1.
There have been some name changes starting with version 2.7.3 and 2.8.2 and 2.9.1:
IPROTO_BALLOT_IS_RO_CFG was formerly called IPROTO_BALLOT_IS_RO,
and IPROTO_BALLOT_IS_RO was formerly called IPROTO_BALLOT_IS_LOADING.

IPROTO_BALLOT_IS_RO_CFG corresponds to :ref:`box.cfg.read_only <cfg_basic-read_only>`.

IPROTO_BALLOT_GC_VCLOCK can be the vclock value of the instance's oldest
WAL entry, which corresponds to :ref:`box.info.gc().vclock <box_info_gc>`.

IPROTO_BALLOT_IS_RO is true if the instance is not writable,
which may happen for a variety of reasons, such as:
it was configured as :ref:`read_only <cfg_basic-read_only>`,
or it has :ref:`orphan status <replication-orphan_status>`,
or it is a :ref:`Raft <repl_leader_elect>` follower.

IPROTO_BALLOT_IS_ANON corresponds to :ref:`box.cfg.replication_anon <cfg_replication-replication_anon>`.

IPROTO_BALLOT_IS_BOOTED is true if the instance has finished its
bootstrap or recovery process.

IPROTO_BALLOT_CAN_LEAD is true if the :ref:`election_mode <cfg_replication-election_mode>`
configuration setting is either 'candidate' or 'manual', so that
during the :ref:`leader election process <repl_leader_elect_process>`
this instance may be preferred over instances whose configuration
setting is 'voter'.
IPROTO_BALLOT_CAN_LEAD support was added simultaneously in
version :doc:`2.7.3 </release/2.7.3>`
and version :doc:`2.8.2 </release/2.8.2>`.

..  _box_protocol-flags:

FLAGS
~~~~~

For replication of :ref:`synchronous transactions <repl_sync>`
a header may contain a key = IPROTO_FLAGS and an MP_UINT value = one or more
bits: IPROTO_FLAG_COMMIT or IPROTO_FLAG_WAIT_SYNC or IPROTO_FLAG_WAIT_ACK.

..  cssclass:: highlight
..  parsed-literal::

    # <size>
    msgpack(:samp:`{{MP_UINT unsigned integer = size(<header>) + size(<body>)}}`)
    # <header>
    msgpack({
        # ... other header items ...,
        IPROTO_FLAGS: :samp:`{{MP_UINT unsigned integer}}`
    })
    # <body>
    msgpack({
        # ... message for a transaction ...
    })

IPROTO_FLAG_COMMIT (0x01) will be set if this is the last message for a transaction,
IPROTO_FLAG_WAIT_SYNC (0x02) will be set if this is the last message for a transaction which cannot be completed immediately,
IPROTO_FLAG_WAIT_ACK (0x04) will be set if this is the last message for a synchronous transaction.

..  _box_protocol-raft:

IPROTO_RAFT = 0x1e
~~~~~~~~~~~~~~~~~~

A node broadcasts the IPROTO_RAFT request to all the replicas connected to it when the RAFT state of the node changes.
It can be any actions changing the state, like starting a new election, bumping the term, voting for another node, becoming the leader, and so on.

If there should be a response, for example, in case of a vote request to other nodes, the response will also be an IPROTO_RAFT message.
In this case, the node should be connected as a replica to another node from which the response is expected because the response is sent via the replication channel.
In other words, there should be a full-mesh connection between the nodes.

..  cssclass:: highlight
..  parsed-literal::

    # <size>
    msgpack(:samp:`{{MP_UINT unsigned integer = size(<header>) + size(<body>)}}`)
    # <header>
    msgpack({
        IPROTO_REQUEST_TYPE: IPROTO_RAFT,
        IPROTO_REPLICA_ID: :samp:`{{MP_INT integer}}`,  # ID of the replica which the request came from

    })
    # <body>
    msgpack({
        IPROTO_RAFT_TERM: :samp:`{{MP_UINT unsigned integer}}`,     # RAFT term of the instance
        IPROTO_RAFT_VOTE: :samp:`{{MP_UINT unsigned integer}}`,     # Instance vote in the current term (if any).
        IPROTO_RAFT_STATE: :samp:`{{MP_UINT unsigned integer}}`,    # Instance state. Possible values: 1 -- follower, 2 -- candidate, 3 -- leader.
        IPROTO_RAFT_VCLOCK: :samp:`{{MP_ARRAY {{MP_INT SRV_ID, MP_INT SRV_LSN}, {MP_INT SRV_ID, MP_INT SRV_LSN}, ...}}}`,   # Current vclock of the instance. Presents only on the instances in the "candidate" state (IPROTO_RAFT_STATE == 2).
        IPROTO_RAFT_LEADER_ID: :samp:`{{MP_UINT unsigned integer}}`,     # Current leader node ID as seen by the node that issues the request. Since version :doc:`2.10.0 </release/2.10.0>`.
        IPROTO_RAFT_IS_LEADER_SEEN: :samp:`{{MP_BOOL boolean}}`     # Shows whether the node has a direct connection to the leader node. Since version :doc:`2.10.0 </release/2.10.0>`.

    })
