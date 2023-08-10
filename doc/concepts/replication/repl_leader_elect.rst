.. _repl_leader_elect:

Automated leader election
=========================

Starting from version :doc:`2.6.1 </release/2.6.1>`,
Tarantool has the built-in functionality
managing automated *leader election* in a replica set.
This functionality increases the fault tolerance of the systems built
on the base of Tarantool and decreases
dependency on external tools for replica set management.

To learn how to configure and monitor automated leader elections,
check the :ref:`how-to guide <how-to-repl_leader_elect>`.

The following topics are described below:

.. contents::
   :local:
   :depth: 1

.. _repl_leader_elect_and_sync_repl:

Leader election and synchronous replication
-------------------------------------------

Leader election and synchronous replication are implemented in Tarantool as
a modification of the `Raft <https://en.wikipedia.org/wiki/Raft_(computer_science)>`__
algorithm.
Raft is an algorithm of synchronous replication and automatic leader election.
Its complete description can be found in the `corresponding document <https://raft.github.io/raft.pdf>`_.

In Tarantool, :ref:`synchronous replication <repl_sync>` and leader election
are supported as two separate subsystems.
So it is possible to get synchronous replication
but use an alternative algorithm for leader election.
And vice versa -- elect a leader
in the cluster but don't use synchronous spaces at all.
Synchronous replication has a separate :ref:`documentation section <repl_sync>`.
Leader election is described below.

..  note::

    The system behavior can be specified exactly according to the Raft algorithm. To do this:

    *   Ensure that the user has only synchronous spaces.
    *   Set the :ref:`replication_synchro_quorum <repl_leader_elect_config>` option to ``N / 2 + 1``.
    *   Set the :ref:`replication_synchro_timeout <cfg_replication-replication_synchro_timeout>` option to infinity.
    *   In the :ref:`election_fencing_mode <repl_leader_elect_config>` option, select either the ``soft`` mode (the default)
        or the ``strict`` mode, which is more restrictive.

.. _repl_leader_elect_process:

Leader election process
-----------------------

Automated leader election in Tarantool helps guarantee that
there is at most one leader at any given moment of time in a replica set.
A *leader* is a writable node, and all other nodes are non-writable --
they accept read-only requests exclusively.

When :ref:`the election is enabled <repl_leader_elect_config>`, the life cycle of
a replica set is divided into so-called
*terms*. Each term is described by a monotonically growing number.
After the first boot, each node has its term equal to 1. When a node sees that
it is not a leader and there is no leader available for some time in the replica
set, it increases the term and starts a new leader election round.

Leader election happens via votes. The node that started the election votes
for itself and sends vote requests to other nodes.
Upon receiving vote requests, a node votes for the first of them, and then cannot
do anything in the same term but wait for a leader to be elected.

The node that collected a quorum of votes defined by the :ref:`replication_synchro_quorum <repl_leader_elect_config>` parameter
becomes the leader
and notifies other nodes about that. Also, a split vote can happen
when no nodes received a quorum of votes. In this case,
after a :ref:`random timeout <repl_leader_elect_config>`,
each node increases its term and starts a new election round if no new vote
request with a greater term arrives during this time.
Eventually, a leader is elected.

If any unfinalized synchronous transactions are left from the previous leader,
the new leader finalizes them automatically.

All the non-leader nodes are called *followers*. The nodes that start a new
election round are called *candidates*. The elected leader sends heartbeats to
the non-leader nodes to let them know it is alive.

In case there are no heartbeats for the period of :ref:`replication_timeout <cfg_replication-replication_timeout>` * 4,
a non-leader node starts a new election if the following conditions are met:

*   The node has a quorum of connections to other cluster members.
*   None of these cluster members can see the leader node.

..  note::

    A cluster member considers the leader node to be alive if the member received heartbeats from the leader at least
    once during the ``replication_timeout * 4``,
    and there are no replication errors (the connection is not broken due to timeout or due to an error).

Terms and votes are persisted by each instance to preserve certain Raft guarantees.

During the election, the nodes prefer to vote for those ones that have the
newest data. So as if an old leader managed to send something before its death
to a quorum of replicas, that data wouldn't be lost.

When :ref:`election is enabled <repl_leader_elect_config>`, there must be connections
between each node pair so as it would be the full mesh topology. This is needed
because election messages for voting and other internal things need a direct
connection between the nodes.

.. _repl_leader_elect_fencing:

In the classic Raft algorithm, a leader doesn't track its connectivity to the rest of the cluster.
Once the leader is elected, it considers itself in the leader position until receiving a new term from another cluster node.
This can lead to a split situation if the other nodes elect a new leader upon losing the connectivity to the previous one.

The issue is resolved in Tarantool version :doc:`2.10.0 </release/2.10.0>` by introducing the leader *fencing* mode.
The mode can be switched by the :ref:`election_fencing_mode <repl_leader_elect_config>` configuration parameter.
When the fencing is set to ``soft`` or ``strict``, the leader resigns its leadership if it has less than
:ref:`replication_synchro_quorum <repl_leader_elect_config>` of alive connections to the cluster nodes.
The resigning leader receives the status of a follower in the current election term and becomes read-only.
Leader *fencing* can be turned off by setting the :ref:`election_fencing_mode <repl_leader_elect_config>` configuration parameter to ``off``.

In ``soft`` mode, a connection is considered dead if there are no responses for
:ref:`4*replication_timeout <cfg_replication-replication_timeout>` seconds both on the current leader and the followers.

In ``strict`` mode, a connection is considered dead if there are no responses
for :ref:`2*replication_timeout <cfg_replication-replication_timeout>` seconds on the current leader and for
:ref:`4*replication_timeout <cfg_replication-replication_timeout>` seconds on the followers.
This improves chances that there is only one leader at any time.

Fencing applies to the instances that have the :ref:`election_mode <repl_leader_elect_config>` set to "candidate" or "manual".

.. _repl_leader_elect_splitbrain:

There can still be a situation when a replica set has two leaders working independently (so-called *split-brain*).
It can happen, for example, if a user mistakenly lowered the :ref:`replication_synchro_quorum <repl_leader_elect_config>` below ``N / 2 + 1``.
In this situation, to preserve the data integrity, if an instance detects the split-brain anomaly in the incoming replication data,
it breaks the connection with the instance sending the data and writes the ``ER_SPLIT_BRAIN`` error in the log.

Eventually, there will be two sets of nodes with the diverged data,
and any node from one set is disconnected from any node from the other set with the ``ER_SPLIT_BRAIN`` error.

Once noticing the error, a user can choose any representative from each of the sets and inspect the data on them.
To correlate the data, the user should remove it from the nodes of one set,
and reconnect them to the nodes from the other set that have the correct data.

Also, if election is enabled on the node, it doesn't replicate from any nodes except
the newest leader. This is done to avoid the issue when a new leader is elected,
but the old leader has somehow survived and tries to send more changes
to the other nodes.

Term numbers also work as a kind of filter.
For example, if election is enabled on two nodes and ``node1`` has the term number less than ``node2``,
then ``node2`` doesn't accept any transactions from ``node1``.
