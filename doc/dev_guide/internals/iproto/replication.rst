..  _internals-iproto-replication:
..  _box_protocol-replication:

Replication requests and responses
==================================

This section describes internal requests and responses that happen during replication.
Each of them is distinguished by the header,
containing a unique :ref:`IPROTO_REQUEST_TYPE <internals-iproto-keys-request_type>` value.
These values and the corresponding packet body structures are considered below.

Connectors and clients do not need to send replication packets.

General
-------

..  container:: table

    ..  list-table::
        :widths: 40 20 40
        :header-rows: 1

        *   -   Name
            -   Code
            -   Description

        *   -   IPROTO_JOIN
            -   0x41
            -

        *   -   IPROTO_SUBSCRIBE
            -   0x42
            -

        *   -   IPROTO_VOTE
            -   0x44
            -

        *   -   IPROTO_VOTE_DEPRECATED
            -   0x43
            -

        *   -   :ref:`IPROTO_BALLOT <box_protocol-ballots>`
            -   0x29
            -   Response to IPROTO_VOTE. Used during replica set bootstrap

        *   -   IPROTO_FETCH_SNAPSHOT
            -   0x45
            -   Fetch the master's snapshot and start anonymous replication.
                See :ref:`replication_anon <cfg_replication-replication_anon>`

        *   -   IPROTO_REGISTER
            -   0x46
            -   Register an anonymous replica so it is not anonymous anymore
            
Note that the master often sends :ref:`heartbeat <heartbeat>` messages to the replicas.
The heartbeat message's IPROTO_REQUEST_TYPE is ``0``.

Synchronous
-----------

..  container:: table

    ..  list-table::
        :widths: 40 20 40
        :header-rows: 1

        *   -   Name
            -   Code
            -   Description     

        *   -   IPROTO_RAFT
            -   0x1e
            -   
   
        *   -   IPROTO_RAFT_PROMOTE
            -   0x1f
            -   Wait, then choose new replication leader. See :ref:`box.ctl.promote() <box_ctl-promote>`

        *   -   IPROTO_RAFT_DEMOTE
            -   0x20
            -   

        *   -   IPROTO_RAFT_CONFIRM
            -   0x28
            -

        *   -   IPROTO_RAFT_ROLLBACK
            -   0x29
            -


..  code-block:: lua

    IPROTO_JOIN = 0x41 -- for replication
    IPROTO_SUBSCRIBE = 0x42 -- for replication SUBSCRIBE
    IPROTO_VOTE_DEPRECATED = 0x43 -- for old style vote, superseded by IPROTO_VOTE
    IPROTO_VOTE = 0x44 -- for master election
    IPROTO_FETCH_SNAPSHOT = 0x45 -- for starting anonymous replication
    IPROTO_REGISTER = 0x46 -- for leaving anonymous replication.


Details on individual requests
------------------------------

..  _box_protocol-heartbeat:

Heartbeats
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
        IPROTO_REQUEST_TYPE: IPROTO_OK
        IPROTO_REPLICA_ID: 2
        IPROTO_VCLOCK: {1, 6}
    })

The tutorial :ref:`Understanding the binary protocol <box_protocol-illustration>`
shows actual byte codes of the above heartbeat examples.

..  _box_protocol-join:

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
        IPROTO_REQUEST_TYPE: IPROTO_OK,
        IPROTO_SYNC: :samp:`{{MP_UINT unsigned integer}}`
    })
    # <body>
    msgpack({
        IPROTO_VCLOCK: :samp:`{{MP_INT SRV_ID, MP_INT SRV_LSN}}`
    })

..  _internals-iproto-replication-subscribe:

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

IPROTO_ID_FILTER = 0x51
 is an optional key used in SUBSCRIBE request followed by an array
of ids of instances whose rows won't be relayed to the replica.

SUBSCRIBE request is supplemented with an optional field of the
following structure:

+====================+
|      ID_FILTER     |
|   0x51 : ID LIST   |
| MP_INT : MP_ARRRAY |
|                    |
+====================+

The field is encoded only when the id list is not empty.


..  _box_protocol-ballots:

IPROTO_BALLOT
~~~~~~~~~~~~~

Code: 0x29.

This value of IPROTO_REQUEST_TYPE indicates a message sent in response to IPROTO_VOTE
(not to be confused with the key IPROTO_RAFT_VOTE).
IPROTO_BALLOT and IPROTO_VOTE are critical during replica set bootstrap.
While connecting for replication, an instance sends a request with header IPROTO_VOTE (0x44).
The fields within IPROTO_BALLOT are map items:

..  code-block:: none

    IPROTO_BALLOT_IS_RO_CFG (0x01) + MP_BOOL
    IPROTO_BALLOT_VCLOCK (0x02) + vclock (MP_ARRAY)
    IPROTO_BALLOT_GC_VCLOCK (0x03) + vclock (MP_ARRAY)
    IPROTO_BALLOT_IS_RO (0x04) + MP_BOOL
    IPROTO_BALLOT_IS_ANON = 0x05 + MP_BOOL
    IPROTO_BALLOT_IS_BOOTED = 0x06 + MP_BOOL
    IPROTO_BALLOT_CAN_LEAD = 0x07 + MP_BOOL

:ref:`Learn more about the keys <internals-iproto-keys-replication-general>`.

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


The next two IPROTO messages are used in replication connections between
Tarantool nodes in :ref:`synchronous replication <repl_sync>`.
The messages are not supposed to be used by any client applications in their
regular connections.




..  _box_protocol-raft_confirm:

IPROTO_RAFT_CONFIRM = 0x28
~~~~~~~~~~~~~~~~~~~~~~~~~~

This message confirms that the transactions originated from the instance
with id = IPROTO_REPLICA_ID have achieved quorum and can be committed,
up to and including LSN = IPROTO_LSN.
Prior to Tarantool :tarantool-release:`2.10.0`, IPROTO_RAFT_CONFIRM was called IPROTO_CONFIRM.

The body is a 2-item map:

..  cssclass:: highlight
..  parsed-literal::

    # <size>
    msgpack(:samp:`{{MP_UINT unsigned integer = size(<header>) + size(<body>)}}`)
    # <header>
    msgpack({
        IPROTO_REQUEST_TYPE: IPROTO_RAFT_CONFIRM,
        IPROTO_SYNC: :samp:`{{MP_UINT unsigned integer}}`
    })
    # <body>
    msgpack({
        IPROTO_REPLICA_ID: :samp:`{{MP_INT integer}}`,
        IPROTO_LSN: :samp:`{{MP_INT integer}}`
    })


..  _box_protocol-raft_rollback:

IPROTO_RAFT_ROLLBACK = 0x29
~~~~~~~~~~~~~~~~~~~~~~~~~~~

This message says that the transactions originated from the instance
with id = IPROTO_REPLICA_ID couldn't achieve quorum for some reason
and should be rolled back, down to LSN = IPROTO_LSN and including it.
Prior to Tarantool version 2.10, IPROTO_RAFT_ROLLBACK was called IPROTO_ROLLBACK.

The body is a 2-item map:

..  cssclass:: highlight
..  parsed-literal::

    # <size>
    msgpack(:samp:`{{MP_UINT unsigned integer = size(<header>) + size(<body>)}}`)
    # <header>
    msgpack({
        IPROTO_REQUEST_TYPE: IPROTO_RAFT_ROLLBACK,
        IPROTO_SYNC: :samp:`{{MP_UINT unsigned integer}}`
    })
    # <body>
    msgpack({
        IPROTO_REPLICA_ID: :samp:`{{MP_INT integer}}`,
        IPROTO_LSN: :samp:`{{MP_INT integer}}`
    })

