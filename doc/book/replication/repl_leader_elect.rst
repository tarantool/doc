.. _repl_leader_elect:

Automated leader election
=========================

Starting from version :doc:`2.6.1 </release/2.6.1>`,
Tarantool has the built-in functionality
managing automated *leader election* in a replica set.
This functionality increases the fault tolerance of the systems built
on the base of Tarantool and decreases
dependency on the external tools for replica set management.

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

Leader election happens via votes. The node, which started the election, votes
for itself and sends vote requests to other nodes.
Upon receiving vote requests, a node votes for the first of them, and then cannot
do anything in the same term but wait for a leader being elected.

The node that collected a quorum of votes defined by the :ref:`replication_synchro_quorum <repl_leader_elect_config>` parameter
becomes the leader
and notifies other nodes about that. Also, a split vote can happen
when no nodes received a quorum of votes. In this case,
after a :ref:`random timeout <repl_leader_elect_config>`,
each node increases its term and starts a new election round if no new vote
request with a greater term arrives during this time period.
Eventually, a leader is elected.

If any unfinalized synchronous transactions are left from the previous leader,
the new leader finalises them automatically.

All the non-leader nodes are called *followers*. The nodes that start a new
election round are called *candidates*. The elected leader sends heartbeats to
the non-leader nodes to let them know it is alive.

In case there are no heartbeats for the period of :ref:`replication_timeout <cfg_replication-replication_timeout>` * 4,
a non-leader node starts a new election if the following conditions are met:

*   The node has a quorum of connections to other cluster members.
*   None of these cluster members can see the leader node.

..  note::

    A cluster member considers the leader node to be alive if the member received heartbeats from the leader at least once during the period of ``replication_timeout * 4``,
    and there are no replication errors (the connection is not broken due to timeout or due to an error).

Terms and votes are persisted by each instance to preserve certain Raft guarantees.

During the election, the nodes prefer to vote for those ones that have the
newest data. So as if an old leader managed to send something before its death
to a quorum of replicas, that data wouldn't be lost.

When :ref:`election is enabled <repl_leader_elect_config>`, there must be connections
between each node pair so as it would be the full mesh topology. This is needed
because election messages for voting and other internal things need direct
connection between the nodes.

.. _repl_leader_elect_fencing:

In the classic Raft algorithm, a leader doesn't track its connectivity to the rest of the cluster.
Once the leader is elected, it considers itself in the leader position until receiving a new term from some of the cluster nodes.
This can lead to the split situation if the other nodes elect a new leader upon losing the connectivity to the previous one.

The issue is resolved in Tarantool version :doc:`2.10.0 </release/2.10.0>` by introducing the leader *fencing* mode.
The mode can be switched on and off by the :ref:`election_fencing_enabled <repl_leader_elect_config>` configuration parameter.
When the fencing is on, the leader will resign its leadership if it has less than the :ref:`replication_synchro_quorum <repl_leader_elect_config>`
of alive connections to the cluster nodes. The resigning leader receives the follower status in the current election term and becomes a read-only node.
Fencing applies to the instances that have the :ref:`election_mode <repl_leader_elect_config>` set to "candidate" or "manual".

Also, if election is enabled on the node, it won't replicate from any nodes except
the newest leader. This is done to avoid the issue when a new leader is elected,
but the old leader has somehow survived and tries to send more changes
to the other nodes.

Term numbers also work as a kind of a filter.
For example, you can be sure that if election
is enabled on two nodes and ``node1`` has the term number less than ``node2``,
then ``node2`` won't accept any transactions from ``node1``.

.. _repl_leader_elect_config:

Configuration
-------------

.. code-block:: console

   box.cfg({
       election_mode = <string>,
       election_timeout = <seconds>,
       replication_timeout = <seconds>,
       replication_synchro_quorum = <count>,
       election_fencing_enabled = <boolean>
   })

* ``election_mode`` -- specifies the role of a node in the leader election
  process. For the details, refer to the :ref:`option description <cfg_replication-election_mode>`
  in the configuration reference.
* ``election_timeout`` -- specifies the timeout between election rounds if the
  previous round ended up with a split vote. For the details, refer to the
  :ref:`option description <cfg_replication-election_timeout>` in the configuration
  reference.
* ``replication_timeout`` -- reuse of the :ref:`replication_timeout <cfg_replication-replication_timeout>`
  configuration option for the purpose of the leader election process.
  Heartbeats sent by an active leader have a timeout after which a new election
  starts. Heartbeats are sent once per <replication_timeout> seconds.
  Default value is ``1``. The leader is considered dead if it hasn't sent any
  heartbeats for the period of ``replication_timeout * 4``.
* ``replication_synchro_quorum`` -- reuse of the :ref:`replication_synchro_quorum <cfg_replication-replication_synchro_quorum>`
  option for the purpose of configuring the election quorum. The default value is ``1``,
  meaning that each node becomes a leader immediately after voting for itself.
  It is the best to set up this option value to the ``(<cluster size> / 2) + 1``.
  Otherwise, there is no guarantee that there is only one leader at a time.
* ``election_fencing_enabled`` -- switches the :ref:`leader fencing mode <repl_leader_elect_fencing>` on and off.
  For the details, refer to the :ref:`option description <cfg_replication-election_fencing_enabled>`in the configuration reference.


Besides, it is important to know that
being a leader is not the only requirement for a node to be writable.
A leader node should have its :ref:`read_only <cfg_basic-read_only>` option set
to ``false`` (``box.cfg{read_only = false}``),
and its :ref:`connectivity quorum <cfg_replication-replication_connect_quorum>`
should be satisfied (``box.cfg{replication_connect_quorum = <count>}``)
or disabled (``box.cfg{replication_connect_quorum = 0}``).

Nothing prevents from setting the ``read_only`` option to ``true``,
but the leader just won't be writable then. The option doesn't affect the
election process itself, so a read-only instance can still vote and become
a leader.

.. _repl_leader_elect_monitoring:

Monitoring
----------

To monitor the current state of a node regarding the leader election, you can
use the ``box.info.election`` function.
For details,
refer to the :doc:`function description </reference/reference_lua/box_info/election>`.

**Example:**

.. code-block:: console

   tarantool> box.info.election
   ---
   - state: follower
     vote: 0
     leader: 0
     term: 1
   ...

The Raft-based election implementation logs all its actions
with the ``RAFT:`` prefix. The actions are new Raft message handling,
node state changing, voting, term bumping, and so on.

.. _repl_leader_elect_important:

Important notes
---------------

Leader election won't work correctly if the election quorum is set to less or equal
than ``<cluster size> / 2`` because in that case, a split vote can lead to
a state when two leaders are elected at once.

For example, let's assume there are five nodes. When quorum is set to ``2``, ``node1``
and ``node2`` can both vote for ``node1``. ``node3`` and ``node4`` can both vote
for ``node5``. In this case, ``node1`` and ``node5`` both win the election.
When the quorum is set to the cluster majority, that is
``(<cluster size> / 2) + 1`` or bigger, the split vote is not possible.

That should be considered when adding new nodes.
If the majority value is changing, it's better to update the quorum on all the existing nodes
before adding a new one.

Also, the automated leader election won't bring many benefits in terms of data
safety when used *without* :ref:`synchronous replication <repl_sync>`.
If the replication is asynchronous and a new leader gets elected,
the old leader is still active and considers itself the leader.
In such case, nothing stops
it from accepting requests from clients and making transactions.
Non-synchronous transactions will be successfully committed because
they won't be checked against the quorum of replicas.
Synchronous transactions will fail because they won't be able
to collect the quorum -- most of the replicas will reject
these old leader's transactions since it is not a leader anymore.
