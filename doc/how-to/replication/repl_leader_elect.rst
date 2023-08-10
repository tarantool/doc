..  _how-to-repl_leader_elect:

Managing leader elections
=========================

Starting from version :doc:`2.6.1 </release/2.6.1>`,
Tarantool has the built-in functionality
managing automated leader election in a replica set.
Learn more about the :ref:`concept of leader election <repl_leader_elect>`.

..  _repl_leader_elect_config:

Configuration
-------------

..  code-block:: console

    box.cfg({
        election_mode = <string>,
        election_fencing_mode = <string>,
        election_timeout = <seconds>,
        replication_timeout = <seconds>,
        replication_synchro_quorum = <count>
    })

*   ``election_mode`` -- specifies the role of a node in the leader election
    process. For the details, refer to the :ref:`option description <cfg_replication-election_mode>`
    in the configuration reference.
*   ``election_fencing_mode`` -- specifies the :ref:`leader fencing mode <repl_leader_elect_fencing>`.
    For the details, refer to the :ref:`option description <cfg_replication-election_fencing_mode>` in the configuration reference.
*   ``election_timeout`` -- specifies the timeout between election rounds if the
    previous round ended up with a split vote. For the details, refer to the
    :ref:`option description <cfg_replication-election_timeout>` in the configuration
    reference.
*   ``replication_timeout`` -- reuse of the :ref:`replication_timeout <cfg_replication-replication_timeout>`
    configuration option for the purpose of the leader election process.
    Heartbeats sent by an active leader have a timeout after which a new election
    starts. Heartbeats are sent once per <replication_timeout> seconds.
    The default value is ``1``. The leader is considered dead if it hasn't sent any
    heartbeats for the period of ``replication_timeout * 4``.
*   ``replication_synchro_quorum`` -- reuse of the :ref:`replication_synchro_quorum <cfg_replication-replication_synchro_quorum>`
    option for the purpose of configuring the election quorum. The default value is ``1``,
    meaning that each node becomes a leader immediately after voting for itself.
    It is best to set up this option value to the ``(<cluster size> / 2) + 1``.
    Otherwise, there is no guarantee that there is only one leader at a time.

It is important to know that being a leader is not the only requirement for a node to be writable.
The leader should also satisfy the following requirements:

*   The :ref:`read_only <cfg_basic-read_only>` option is set to ``false``.

*   The leader shouldn't be in the orphan state.

Nothing prevents you from setting the ``read_only`` option to ``true``,
but the leader just won't be writable then. The option doesn't affect the
election process itself, so a read-only instance can still vote and become
a leader.

..  _repl_leader_elect_monitoring:

Monitoring
----------

To monitor the current state of a node regarding the leader election, you can
use the ``box.info.election`` function.
For details,
refer to the :doc:`function description </reference/reference_lua/box_info/election>`.

**Example:**

..  code-block:: console

    tarantool> box.info.election
    ---
    - state: follower
      vote: 0
      leader: 0
      term: 1
    ...

The Raft-based election implementation logs all its actions
with the ``RAFT:`` prefix. The actions are new Raft message handling,
node state changing, voting, and term bumping.

..  _repl_leader_elect_important:

Important notes
---------------

Leader election doesn't work correctly if the election quorum is set to less or equal
than ``<cluster size> / 2`` because in that case, a split vote can lead to
a state when two leaders are elected at once.

For example, suppose there are five nodes. When the quorum is set to ``2``, ``node1``
and ``node2`` can both vote for ``node1``. ``node3`` and ``node4`` can both vote
for ``node5``. In this case, ``node1`` and ``node5`` both win the election.
When the quorum is set to the cluster majority, that is
``(<cluster size> / 2) + 1`` or greater, the split vote is impossible.

That should be considered when adding new nodes.
If the majority value is changing, it's better to update the quorum on all the existing nodes
before adding a new one.

Also, the automated leader election doesn't bring many benefits in terms of data
safety when used *without* :ref:`synchronous replication <repl_sync>`.
If the replication is asynchronous and a new leader gets elected,
the old leader is still active and considers itself the leader.
In such case, nothing stops
it from accepting requests from clients and making transactions.
Non-synchronous transactions are successfully committed because
they are not checked against the quorum of replicas.
Synchronous transactions fail because they are not able
to collect the quorum -- most of the replicas reject
these old leader's transactions since it is not a leader anymore.
