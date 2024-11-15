..  _internals-iproto-replication:
..  _box_protocol-replication:

Replication requests and responses
==================================

This section describes internal requests and responses that happen during replication.
Each of them is distinguished by the header,
containing a unique :ref:`IPROTO_REQUEST_TYPE <internals-iproto-keys-request_type>` value.
These values and the corresponding packet body structures are considered below.

Connectors and clients do not need to send replication packets.

..  _box_protocol-general:

General
-------

..  container:: table

    ..  list-table::
        :widths: 40 20 40
        :header-rows: 1

        *   -   Name
            -   Code
            -   Description

        *   -   :ref:`IPROTO_JOIN <box_protocol-join>`
            -   0x41
            -   Request to join a replica set

        *   -   :ref:`IPROTO_SUBSCRIBE <internals-iproto-replication-subscribe>`
            -   0x42
            -   Request to subscribe to a specific node in a replica set

        *   -   :ref:`IPROTO_VOTE <internals-iproto-replication-vote>`
            -   0x44
            -   Request for replication

        *   -   :ref:`IPROTO_BALLOT <box_protocol-ballots>`
            -   0x29
            -   Response to IPROTO_VOTE. Used during replica set bootstrap

        *   -   :ref:`IPROTO_FETCH_SNAPSHOT <box_protocol-fetch-snapshot>`
            -   0x45
            -   Fetch the master's snapshot and start anonymous replication.

        *   -   :ref:`IPROTO_REGISTER <box_protocol-register>`
            -   0x46
            -   Register an anonymous replica so it is not anonymous anymore

        *   -   :ref:`IPROTO_JOIN_META <box_protocol-join-meta>`
            -   0x47
            -   A request sent in response to IPROTO_JOIN or IPROTO_FETCH_SNAPSHOT
                before the instance initialization information

        *   -   :ref:`IPROTO_JOIN_SNAPSHOT <box_protocol-join-snapshot>`
            -   0x48
            -   A request sent in response to IPROTO_JOIN  or IPROTO_FETCH_SNAPSHOT
                after the instance initialization information
            
The master also sends :ref:`heartbeat <heartbeat>` messages to the replicas.
The heartbeat message's IPROTO_REQUEST_TYPE is ``0``.

Below are details on individual replication requests.
For synchronous replication requests, see :ref:`internals-iproto-replication-synchronous`.

..  _box_protocol-heartbeat:

Heartbeats
~~~~~~~~~~

Once in :ref:`replication_timeout <cfg_replication-replication_timeout>` seconds,
a master sends a :ref:`heartbeat <heartbeat>` message to a replica,
and the replica sends a response.
Both messages' IPROTO_REQUEST_TYPE is IPROTO_OK.
IPROTO_TIMESTAMP is a float-64 MP_DOUBLE 8-byte timestamp.

Since version 2.11, both messages have an optional field in the body that contains
the :ref:`IPROTO_VCLOCK_SYNC <internals-iproto-keys-vclock>` key.
The master's heartbeat has no body if the IPROTO_VCLOCK_SYNC key is omitted.

The message from master to a replica:

..  raw:: html
    :file: images/repl_heartbeat_message.svg

The response from the replica:

..  raw:: html
    :file: images/repl_heartbeat_response.svg

The tutorial :ref:`Understanding the binary protocol <box_protocol-illustration>`
shows actual byte codes of the above heartbeat examples.

..  _box_protocol-join:

IPROTO_JOIN
~~~~~~~~~~~

Code: 0x41.

To join a replica set, an instance must send an initial IPROTO_JOIN request to
the master instance of the replica set:

..  raw:: html
    :file: images/repl_join_request.svg

.. iproto_fetch_snapshot_response_sequence_start

The instance that receives the request sends the following messages in response:

1.  Its vclock:

    ..  raw:: html
        :file: images/repl_join_response.svg

2.  (Optional) A sequence of requests with information required for instance initialization:

    -   an :ref:`IPROTO_JOIN_META <box_protocol-join-meta>` request
    -   an :ref:`IPROTO_RAFT <box_protocol-raft>` request with IPROTO_RAFT_TERM and IPROTO_RAFT_VOTE fields
    -   an :ref:`IPROTO_RAFT_PROMOTE <internals-iproto-replication-raft_promote>` request
    -   an :ref:`IPROTO_JOIN_SNAPSHOT <box_protocol-join-snapshot>` request

    This step applies if the IPROTO_SERVER_VERSION specified in the request is `2.10` or later.

3.  A number of :ref:`INSERT <box_protocol-insert>` requests (with additional LSN and ServerID).
    This way, the data is updated on the instance that sent the IPROTO_JOIN request.
    The instance should not reply to these INSERT requests.

4.  The new vclock's MP_MAP in a response similar to the one above.

.. iproto_fetch_snapshot_response_sequence_end

5.  A number of :ref:`INSERT <box_protocol-insert>`, :ref:`REPLACE <box_protocol-replace>`,
    :ref:`UPDATE <box_protocol-update>`, :ref:`UPSERT <box_protocol-upsert>`,
    and :ref:`DELETE <box_protocol-delete>` requests. This way, the instance
    that is joining the replica set receives data updates that happened during
    the join stage.

6.  The new vclock's MP_MAP in a response similar to the one above.

..  _internals-iproto-replication-subscribe:

IPROTO_SUBSCRIBE
~~~~~~~~~~~~~~~~

Code: 0x42.

If :ref:`IPROTO_JOIN <box_protocol-join>` was successful,
the initiator instance must send an IPROTO_SUBSCRIBE request
to all the nodes listed in its :ref:`box.cfg.replication <cfg_replication-replication>`:

..  raw:: html
    :file: images/repl_subscribe_request.svg

After a successful IPROTO_SUBSCRIBE request,
the instance must process every request that could come from other masters.
Each master's request includes a vclock pair corresponding to that master --
its instance ID and its LSN, independent from other masters.

IPROTO_ID_FILTER (0x51)
is an optional key used in the SUBSCRIBE request followed by an array
of ids of instances whose rows won't be relayed to the replica.
The field is encoded only when the ID list is not empty.

..  _box_protocol-fetch-snapshot:

IPROTO_FETCH_SNAPSHOT
~~~~~~~~~~~~~~~~~~~~~

Code: 0x45.

To join a replica set as an anonymous replica, an instance must send an initial
IPROTO_FETCH_SNAPSHOT request to the master instance of the replica set:

..  raw:: html
    :file: images/repl_fetch_snapshot_request.svg

To learn about anonymous replicas, see :ref:`replication.anon <configuration_reference_replication_anon>`.

..  include:: replication.rst
    :start-after: iproto_fetch_snapshot_response_sequence_start
    :end-before: iproto_fetch_snapshot_response_sequence_end

..  _box_protocol-register:

IPROTO_REGISTER
~~~~~~~~~~~~~~~

Code: 0x46.

To register an anonymous replica in a replica set so that it's not anonymous anymore,
it must send an IPROTO_REGISTER request to a master node of the replica set:

..  raw:: html
    :file: images/repl_register.svg

The instance that receives the request sends the following messages in response:

#.  A number of :ref:`INSERT <box_protocol-insert>`, :ref:`REPLACE <box_protocol-replace>`,
    :ref:`UPDATE <box_protocol-update>`, :ref:`UPSERT <box_protocol-upsert>`,
    and :ref:`DELETE <box_protocol-delete>` requests. This way, the instance
    that is registering in the replica set receives data updates that happened
    since the time it fetched the snapshot.

#.  The new vclock's MP_MAP.

Technically, subsequent IPROTO_FETCH_SNAPSHOT and IPROTO_REGISTER requests are equivalent
to IPROTO_JOIN.

..  _box_protocol-join-meta:

IPROTO_JOIN_META
~~~~~~~~~~~~~~~~

Code: 0x47.

When an instance receives an IPOTO_JOIN or IPROTO_FETCH_SNAPSHOT request, its responses
include the information required for the instance initialization: current Raft term,
current state of synchronous transaction queue. Before sending this information,
the instance sends an IPROTO_JOIN_META request with an empty body:

..  raw:: html
    :file: images/repl_join_meta.svg

Learn more in :ref:`IPROTO_JOIN <box_protocol-join>`

..  _box_protocol-join-snapshot:

IPROTO_JOIN_SNAPSHOT
~~~~~~~~~~~~~~~~~~~~

Code: 0x48.

An instance that has received an IPROTO_JOIN or IPROTO_FETCH_SNAPSHOT request
sends an IPROTO_JOIN_SNAPSHOT request with an empty body after it completes sending
the instance initialization information.

..  raw:: html
    :file: images/repl_join_snapshot.svg

Learn more in :ref:`IPROTO_JOIN <box_protocol-join>`

..  _internals-iproto-replication-vote:

IPROTO_VOTE
~~~~~~~~~~~

Code: 0x44.

When connecting for replication, an instance sends an IPROTO_VOTE request. It has no body:

..  raw:: html
    :file: images/repl_vote.svg

IPROTO_VOTE is critical during replica set bootstrap.
The response to this request is :ref:`IPROTO_BALLOT <box_protocol-ballots>`.

..  _box_protocol-ballots:

IPROTO_BALLOT
~~~~~~~~~~~~~

Code: 0x29.

This value of IPROTO_REQUEST_TYPE indicates a message sent in response
to :ref:`IPROTO_VOTE <internals-iproto-replication-vote>` (not to be confused with the key IPROTO_RAFT_VOTE).

IPROTO_BALLOT and IPROTO_VOTE are critical during replica set bootstrap.
IPROTO_BALLOT corresponds to a map containing the following fields:

..  raw:: html
    :file: images/repl_ballot.svg

IPROTO_BALLOT_REGISTERED_REPLICA_UUIDS has the MP_ARRAY type.
The array contains MP_STR elements.

..  _internals-iproto-replication-synchronous:

Synchronous
-----------

..  container:: table

    ..  list-table::
        :widths: 40 20 40
        :header-rows: 1

        *   -   Name
            -   Code
            -   Description

        *   -   :ref:`IPROTO_RAFT <box_protocol-raft>`
            -   0x1e
            -   Inform that the node changed its :ref:`RAFT status <repl_leader_elect>`

        *   -   :ref:`IPROTO_RAFT_PROMOTE <internals-iproto-replication-raft_promote>`
            -   0x1f
            -   Wait, then choose new replication leader

        *   -   :ref:`IPROTO_RAFT_DEMOTE <internals-iproto-replication-raft_demote>`
            -   0x20
            -   Revoke the leader role from the instance

        *   -   :ref:`IPROTO_RAFT_CONFIRM <box_protocol-raft_confirm>`
            -   0x28
            -   Confirm that the RAFT transactions have achieved quorum and can be committed

        *   -   :ref:`IPROTO_RAFT_ROLLBACK <box_protocol-raft_rollback>`
            -   0x29
            -   Roll back the RAFT transactions because they haven't achieved quorum 



..  _box_protocol-raft:

IPROTO_RAFT
~~~~~~~~~~~

Code: 0x1e.

A node broadcasts the IPROTO_RAFT request to all the replicas connected to it
when the RAFT state of the node changes.
It can be any actions changing the state, like starting a new election, bumping the term,
voting for another node, becoming the leader, and so on.

If there should be a response, for example, in case of a vote request to other nodes,
the response will also be an IPROTO_RAFT message.
In this case, the node should be connected as a replica to another node from which the response is expected
because the response is sent via the replication channel.
In other words, there should be a full-mesh connection between the nodes.

..  raw:: html
    :file: images/repl_raft.svg

IPROTO_REPLICA_ID is the ID of the replica from which the request came.

..  _internals-iproto-replication-raft_promote:

IPROTO_RAFT_PROMOTE
~~~~~~~~~~~~~~~~~~~

Code: 0x1f.

See :ref:`box.ctl.promote() <box_ctl-promote>`.

..  raw:: html
    :file: images/repl_raft_promote.svg

In the header:

*   IPROTO_REPLICA_ID is the replica ID of the node that sent the request.
*   IPROTO_LSN is the actual LSN of the promote operation as recorded in the WAL.

In the body:

*   IPROTO_REPLICA_ID is the replica ID of the previous :ref:`synchronous queue owner <box_info_synchro>`.
*   IPROTO_LSN is the LSN of the last operation on the previous synchronous queue owner.
*   IPROTO_TERM is the term in which the node that sent the request becomes the synchronous queue owner.
    This term corresponds to the value of :ref:`box.info.synchro.queue.term <box_info_synchro>` on the instance.

..  _internals-iproto-replication-raft_demote:

IPROTO_RAFT_DEMOTE
~~~~~~~~~~~~~~~~~~

Code: 0x20.

See :ref:`box.ctl.demote() <box_ctl-demote>`.

..  raw:: html
    :file: images/repl_raft_demote.svg

In the header:

*   IPROTO_REPLICA_ID is the replica ID of the node that sent the request.
*   IPROTO_LSN is the actual LSN of the demote operation as recorded in the WAL.

In the body:

*   IPROTO_REPLICA_ID is the replica ID of the node that sent the request
    (same as the value in the header).
*   IPROTO_LSN is the LSN of the last synchronous transaction recorded in the node's WAL.
*   IPROTO_TERM is the term in which the queue becomes empty.

..  _box_protocol-raft_confirm:

IPROTO_RAFT_CONFIRM
~~~~~~~~~~~~~~~~~~~

Code: 0x28.

This message is used in replication connections between
Tarantool nodes in :ref:`synchronous replication <repl_sync>`.
It is not supposed to be used by any client applications in their
regular connections.

This message confirms that the transactions that originated from the instance
with id = IPROTO_REPLICA_ID (body) have achieved quorum and can be committed,
up to and including LSN = IPROTO_LSN (body).

The body is a 2-item map:

..  raw:: html
    :file: images/repl_raft_confirm.svg

In the header:

*   IPROTO_REPLICA_ID is the ID of the replica that sends the confirm message.
*   IPROTO_LSN is the LSN of the confirmation action.

In the body:

*   IPROTO_REPLICA_ID is the ID of the instance from which the transactions originated.
*   IPROTO_LSN is the LSN up to which the transactions should be confirmed.

Prior to Tarantool :tarantool-release:`2.10.0`, IPROTO_RAFT_CONFIRM was called IPROTO_CONFIRM.

..  _box_protocol-raft_rollback:

IPROTO_RAFT_ROLLBACK
~~~~~~~~~~~~~~~~~~~~

Code: 0x29.

This message is used in replication connections between
Tarantool nodes in :ref:`synchronous replication <repl_sync>`.
It is not supposed to be used by any client applications in their
regular connections.

This message says that the transactions that originated from the instance
with id = IPROTO_REPLICA_ID (body) couldn't achieve quorum for some reason
and should be rolled back, down to LSN = IPROTO_LSN (body) and including it.

The body is a 2-item map:

..  raw:: html
    :file: images/repl_raft_rollback.svg

In the header:

*   IPROTO_REPLICA_ID is the ID of the replica that sends the rollback message.
*   IPROTO_LSN is the LSN of the rollback action.

In the body:

*   IPROTO_REPLICA_ID is the ID of the instance from which the transactions originated.
*   IPROTO_LSN is the LSN starting with which all pending synchronous transactions should be rolled back.

Prior to Tarantool :tarantool-release:`2.10.0`, IPROTO_RAFT_ROLLBACK was called IPROTO_ROLLBACK.
