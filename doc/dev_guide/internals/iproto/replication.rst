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

        *   -   :ref:`IPROTO_JOIN <box_protocol-join>`
            -   0x41
            -   Request to join a replica set

        *   -   :ref:`IPROTO_SUBSCRIBE <internals-iproto-replication-subscribe>`
            -   0x42
            -   Request to subscribe to a replica set

        *   -   :ref:`IPROTO_VOTE <internals-iproto-replication-vote>`
            -   0x44
            -   Request for replication

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
            
The master also sends :ref:`heartbeat <heartbeat>` messages to the replicas.
The heartbeat message's IPROTO_REQUEST_TYPE is ``0``.

Below are details on individual replication requests.
For synchronous replication requests, see :ref:`below <internals-iproto-replication-synchronous>`.

..  _box_protocol-heartbeat:

Heartbeats
~~~~~~~~~~

Once in :ref:`replication_timeout <cfg_replication-replication_timeout>` seconds,
a master sends a :ref:`heartbeat <heartbeat>` message to a replica.
The heartbeat message's IPROTO_REQUEST_TYPE is ``0``.

In the example below, the master sends a heartbeat message to a replica with id = 2,
and the timestamp is a moment in 2020. The replica sends a response.
Note that the master's heartbeat has no body:

..  raw:: html
    :file: images/repl_heartbeat.svg

IPROTO_TIMESTAMP is a float-64 MP_DOUBLE 8-byte timestamp.

The tutorial :ref:`Understanding the binary protocol <box_protocol-illustration>`
shows actual byte codes of the above heartbeat examples.

..  _box_protocol-join:

IPROTO_JOIN
~~~~~~~~~~~

Code: 0x41.

To join a replica set, an instance must send an initial IPROTO_JOIN request to any node in the replica set:

..  raw:: html
    :file: images/repl_join_request.svg

The node that receives the request sends its vclock in response:

..  raw:: html
    :file: images/repl_join_response.svg

After that, the node sends its last SNAP file,
by simply creating a number of INSERTs (with additional LSN and ServerID).
The instance that sent the IPROTO_JOIN request should not reply to these INSERT requests.

Then the node in the replica set sends the new vclock's MP_MAP in a response similar to the one above
and closes the socket.

..  _internals-iproto-replication-subscribe:

IPROTO_SUBSCRIBE
~~~~~~~~~~~~~~~~

Code: 0x42.

If :ref:`IPROTO_JOIN <box_protocol-join>` was successful,
the initiator instance must send an IPROTO_SUBSCRIBE request
to all the nodes listed in its :ref:`box.cfg.replication <cfg_replication-replication>`:

..  raw:: html
    :file: images/repl_subscribe_request.svg

After an IPROTO_SUBSCRIBE request,
the instance must process every request that could come through other masters.
Every request between masters will have an additional pair in the vclock map.

IPROTO_ID_FILTER (0x51)
is an optional key used in SUBSCRIBE request followed by an array
of ids of instances whose rows won't be relayed to the replica.
The field is encoded only when the id list is not empty.

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

This value of IPROTO_REQUEST_TYPE indicates a message sent in response to IPROTO_VOTE
(not to be confused with the key IPROTO_RAFT_VOTE).

IPROTO_BALLOT and IPROTO_VOTE are critical during replica set bootstrap.
IPROTO_BALLOT corresponds to a map containing the following fields:

..  raw:: html
    :file: images/repl_ballot.svg

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
            -   Inform that the node changed its RAFT status
   
        *   -   IPROTO_RAFT_PROMOTE
            -   0x1f
            -   Wait, then choose new replication leader. See :ref:`box.ctl.promote() <box_ctl-promote>`

        *   -   IPROTO_RAFT_DEMOTE
            -   0x20
            -   Revoke the leader role from the instance. See :ref:`box.ctl.demote() <box_ctl-demote>`

        *   -   :ref:`IPROTO_RAFT_CONFIRM <box_protocol-raft_confirm>`
            -   0x28
            -   Confirm that the RAFT transactions have achieved quorum and can be committed

        *   -   :ref:`IPROTO_RAFT_ROLLBACK <box_protocol-raft_confirm>`
            -   0x29
            -   Revoke the RAFT transactions because they haven't achieved quorum 



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

IPROTO_REPLICA_ID is the replica from which the request came.


..  _box_protocol-raft_confirm:

IPROTO_RAFT_CONFIRM
~~~~~~~~~~~~~~~~~~~

Code: 0x28.

This message is used in replication connections between
Tarantool nodes in :ref:`synchronous replication <repl_sync>`.
It is not supposed to be used by any client applications in their
regular connections.

This message confirms that the transactions originated from the instance
with id = IPROTO_REPLICA_ID have achieved quorum and can be committed,
up to and including LSN = IPROTO_LSN.

The body is a 2-item map:

..  raw:: html
    :file: images/repl_raft_confirm.svg

Prior to Tarantool :tarantool-release:`2.10.0`, IPROTO_RAFT_CONFIRM was called IPROTO_CONFIRM.

..  _box_protocol-raft_rollback:

IPROTO_RAFT_ROLLBACK
~~~~~~~~~~~~~~~~~~~~

Code: 0x29.

This message is used in replication connections between
Tarantool nodes in :ref:`synchronous replication <repl_sync>`.
It is not supposed to be used by any client applications in their
regular connections.

This message says that the transactions originated from the instance
with id = IPROTO_REPLICA_ID couldn't achieve quorum for some reason
and should be rolled back, down to LSN = IPROTO_LSN and including it.

The body is a 2-item map:

..  raw:: html
    :file: images/repl_raft_rollback.svg

Prior to Tarantool version 2.10, IPROTO_RAFT_ROLLBACK was called IPROTO_ROLLBACK.
