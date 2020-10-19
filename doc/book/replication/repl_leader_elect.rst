.. _repl_leader_elect:

================================================================================
Leader election
================================================================================

Starting from the version 2.6.1, Tarantool has the built-in functionality/feature
ensuring/guaranteeing the automated leader election
[in case of the leader node's falling down in a cluster].
This functionality increases fault tolerance of the systems
built on the base of Tarantool and decreases/removes dependency on
the external tools for cluster management
[?which is another big step for being a self-sufficient platform for building /practical software solutions].

The description that follows has mainly two parts.
The first one are some excerpts from the description of the :ref:`consensus algorithm <consensus_algorithm>`
that is the basis of this functionality/feature
(for more detailed information, you can refer to the complete article https://raft.github.io/raft.pdf)
where it is briefly explained its basics and main principles.
Next, we describe the details of the :ref:`algorithm implementation in Tarantool <algorithm implement>`.

.. _consensus_algorithm:

--------------------------------------------------------------------------------
Raft consensus algorithm
--------------------------------------------------------------------------------

[TODO] TBD if we need such a detailed intro in our doc; if not, it should be shorten


Currently, the algorithm used for implementing automatic failover
in a replica set is Raft.

Raft is a consensus algorithm for managing a replicated log.
Raft separates the key elements of consensus, such as leader election,
log replication, and safety, and it enforces a stronger degree of coherency
to reduce the number of states that must be considered.

Consensus algorithm allows a collection of machines to work as a coherent group
that can survive the failures of some of its members.

Consensus algorithms typically arise in the context of replicated state machines.
State machines on a collection of servers compute identical copies of the same state
and can continue operating even if some of the servers are down.
Replicated state machines are used to solve a variety of fault tolerance problems
in distributed systems. Replicated state machines are typically implemented using
a replicated log, as shown in the figure below [todo].


Each server stores a log containing a series of commands, which its state machine
executes in order. Each log contains the same commands in the same order,
so each state machine processes the same sequence of commands.
Since the state machines are deterministic, each computes the same state and
the same sequence of outputs.

Keeping the replicated log consistent is the job of the consensus algorithm.
The process is the following:

* the consensus module on a server receives commands from clients and adds them
  to its log;
* it communicates with the consensus modules on other servers to ensure
  that every log eventually contains the same requests in the same order,
  even if some servers fail;
* once commands are properly replicated, each server’s state machine processes
  them in log order, and the outputs are returned to clients.

As a result, the servers appear to form a single, highly reliable state machine.

Raft implements consensus by first electing a distinguished leader,
then giving the leader complete responsibility for managing the replicated log.
The leader accepts log entries from clients, replicates them on other servers,
and tells servers when it is safe to apply log entries to their state machines.
A leader can fail or become disconnected from the other servers,
in which case a new leader is elected.

Given the leader approach, Raft decomposes the consensus problem
into three relatively independent subproblems,
which are discussed in the subsections that follow:

1. Leader election [link to the section]: a new leader must be chosen
   when an existing leader fails.
2. Log replication [link to the section]: the leader must accept log entries
   from clients and replicate them across the cluster, forcing the other logs
   to agree with its own.
3. Safety [link to the section]: the key safety property for Raft is
   the State Machine Safety property: if any server has applied a particular
   log entry to its state machine, then no other server may apply a different
   command for the same log index.

Raft ensures the consistency of the data on different servers in the cluster
by guaranteeing that each of these properties is true at all times:

* Election Safety: at most one leader can be elected in a given term.
* Leader Append-Only: a leader never overwrites or deletes entries in its log;
  it only appends new entries.
* Log Matching: if two logs contain an entry with the same index and term,
  then the logs are identical in all entries up through the given index.
* Leader Completeness: if a log entry is committed in a given term, then that
  entry will be present in the logs of the leaders for all higher-numbered terms.
* State Machine Safety: if a server has applied a log entry at a given index
  to its state machine, no other server will ever apply a different log entry
  for the same index.

~~~~~~~~~~~~~
Raft Basics
~~~~~~~~~~~~~

A Raft cluster contains several servers; five is a typical number,
which allows the system to tolerate failure of two servers.

^^^^^^^^^
States
^^^^^^^^^

At any given time each server is in one of three states:

* leader
* follower
* or candidate.

In normal operation there is exactly one leader and all of the other servers are
followers.

Followers are passive: they issue no requests on their own but simply respond
to requests from leaders and candidates. The leader handles all client requests
(if a client contacts a follower, the follower redirects it to the leader).

The third state, candidate, is used to elect a new leader [link to section abt. election].
The figure below shows the states and their transitions [todo].

^^^^^^^^^
Terms
^^^^^^^^^

Raft divides time into terms of arbitrary length, as shown in the figure below.
Terms are numbered with consecutive integers. Each term begins with an election,
in which one or more candidates attempt to become leader [link to section abt. election].
If a candidate wins the election, then it serves as leader for the rest of the term.

[todo - diagram]

In some situations an election will result in a split vote. In this case
the term will end with no leader; a new term (with a new election)
will begin shortly. Raft ensures that there is at most one leader in a given term.

Terms act as a logical clock in Raft, and they allow servers to detect obsolete
information such as stale leaders. Each server stores a current term number,
which increases monotonically over time. Current terms are exchanged whenever
servers communicate; if one server’s current term is smaller than the other’s,
then it updates its current term to the larger value. If a candidate or leader
discovers that its term is out of date, it immediately reverts
to the follower state. If a server receives a request with a stale term number,
it rejects the request.


^^^^^^^^^^^^^^^^
Types of RPCs
^^^^^^^^^^^^^^^^

Raft servers communicate using remote procedure calls (RPCs), and the basic
consensus algorithm requires only two types of RPCs:

* ``RequestVote`` RPCs are initiated by candidates during elections
* ``Append-Entries`` RPCs are initiated by leaders to replicate log entries
  and to provide a form of heartbeat.

Servers retry RPCs if they do not receive a response in a timely manner,
and they issue RPCs in parallel for best performance.

~~~~~~~~~~~~~~~~~
Electing a leader
~~~~~~~~~~~~~~~~~

Raft uses a heartbeat mechanism to trigger a leader election.
When servers start up, they begin as followers. A server remains in follower
state as long as it receives valid RPCs from a leader or candidate.
Leaders send periodic heartbeats (AppendEntriesRPCs that carry no log entries)
to all followers in order to maintain their authority. If a follower receives
no communication over a period of time called the election timeout,
then it assumes there is no viable leader and begins an election to choose a new leader.

To begin an election, a follower increments its current term and transitions
to candidate state. It then votes for itself and issues RequestVote RPCs
in parallel to each of the other servers in the cluster.
A candidate continues in this state until one of three outcomes happens:

1. it wins the election
2. another server establishes itself as leader
3. a period of time goes by with no winner.

A candidate wins an election if it receives votes from a majority of the servers
in the full cluster for the same term. Each server will vote
for at most one candidate in a given term, on a first-come-first-served basis.
The majority rule ensures that at most one candidate can win the election
for a particular term (the Election Safety property).
Once a candidate wins an election, it becomes a leader. It then sends heartbeat
messages to all of the other servers to establish its authority and prevent new elections.

While waiting for votes, a candidate may receive an AppendEntries RPC
from another server claiming to be leader. If the leader’s term (included in its RPC)
is at least as large as the candidate’s current term, then the candidate
recognizes the leader as legitimate and returns to follower state.
If the term in the RPC is smaller than the candidate’s current term,
then the candidate rejects the RPC and continues in candidate state.

The third possible outcome is that a candidate neither wins nor loses the election:
if many followers become candidates at the same time, votes could be split
so that no candidate obtains a majority.When this happens, each candidate
will time out and start a new election by incrementing its term and initiating
another round of Request-Vote RPCs. However, without extra measures split votes
could repeat indefinitely.

Raft uses randomized election timeouts to ensure that split votes are rare and
that they are resolved quickly. To prevent split votes in the first place,
election timeouts are chosen randomly from a fixed interval (e.g., 150–300ms).
This spreads out the servers so that in most cases only a single server
will time out; it wins the election and sends heartbeats before any other
servers time out. The same mechanism is used to handle split votes.
Each candidate restarts its randomized election timeout at the start of an election,
and it waits for that timeout to elapse before starting the next election.
This reduces the likelihood of another split vote in the new election.

~~~~~~~~~~~~~~~~~
Log replication
~~~~~~~~~~~~~~~~~

Once a leader has been elected, it begins servicing client requests. Each client request contains a command to be executed by the replicated state machines. The leader appends the command to its log as a new entry, then issues AppendEntries RPCs in parallel to each of the other servers to replicate the entry. When the entry has been safely replicated, the leader applies the entry to its state machine and returns the result of that execution to the client. If followers crash or run slowly, or if network packets are lost, the leader retries Append-
Entries RPCs indefinitely (even after it has responded to the client) until all followers eventually store all log entries.

The leader decides when it is safe to apply a log entry to the state machines; such an entry is called committed. Raft guarantees that committed entries are durable and will eventually be executed by all of the available state machines.

A log entry is committed once the leader that created the entry has replicated it on a majority of the servers. This also commits all preceding entries in the leader’s log, including entries
created by previous leaders. The leader keeps track of the highest index it knows to be committed, and it includes that index in future AppendEntries RPCs (including heartbeats) so that the other servers eventually find out. Once a follower learns that a log entry is committed, it applies the entry to its local state machine (in log order).

Raft log mechanism is designed in a way to maintain a high level of coherency
between the logs on different servers. Raft maintains the following properties,
which together constitute the Log Matching property [link to the list of properties]:

* If two entries in different logs have the same index and term, then they store the same command.
* If two entries in different logs have the same index and term, then the logs are identical in all preceding entries.

~~~~~~~
Safety
~~~~~~~

The previous sections described how Raft elects leaders and replicates log entries. However, the mechanisms described so far are not quite sufficient to ensure that each state machine executes exactly the same commands in the same order. For example, a follower might be unavailable while the leader commits several log entries, then it could be elected leader and overwrite these entries with new ones; as a result, different state machines might execute different command sequences.

This section completes the Raft algorithm by adding a restriction on which servers may be elected leader. The restriction ensures that the leader for any given term contains all of the entries committed in previous terms [the Leader Completeness property - link].

^^^^^^^^^^^^^^^^^^^^^
Election restriction
^^^^^^^^^^^^^^^^^^^^^

In any leader-based consensus algorithm, the leader must eventually store all of the committed log entries.  Raft uses an approach where it guarantees that all the committed entries from previous terms are present on each new leader from the moment of its election, without the need to transfer those entries to the leader. This means that log entries only flow in one direction,from leaders to followers, and leaders never overwrite existing entries in their logs.

Raft uses the voting process to prevent a candidate from winning an election unless its log contains all committed entries. A candidate must contact a majority of the cluster in order to be elected, which means that every committed entry must be present in at least one of those servers.

If the candidate’s log is at least as up-to-date as any other log in that majority, then it will hold all the committed entries. The RequestVote RPC implements this restriction: the RPC
includes information about the candidate’s log, and the voter denies its vote if its own log is more up-to-date than that of the candidate.

Raft determines which of two logs is more up-to-date by comparing the index and term of the last entries in the logs. If the logs have last entries with different terms, then the log with the later term is more up-to-date. If the logs end with the same term, then whichever log is longer is more up-to-date.
Committing entries from previous terms
As described previously, a leader knows that an entry from its current term is committed once that entry is stored on a majority of the servers. If a leader crashes before committing an entry, future leaders will attempt to finish replicating the entry. However, a leader cannot immediately conclude that an entry from a previous term is committed once it is stored on a majority of servers.

To eliminate problems like this, Raft never commits log entries from previous terms by counting replicas. Only log entries from the leader’s current term are committed by counting replicas; once an entry from the current term has been committed in this way, then all prior entries are committed indirectly because of the Log Matching property [link to the list of properties].
Follower and candidate crashes
Until this point we have focused on leader failures. Follower and candidate crashes are much simpler to handle than leader crashes, and they are both handled in the same way.

If a follower or candidate crashes, then future RequestVote and AppendEntries RPCs sent to it will fail. Raft handles these failures by retrying indefinitely; if the crashed server restarts, then the RPC will complete successfully. If a server crashes after completing an RPC
but before responding, then it will receive the same RPC again after it restarts. Raft RPCs are idempotent, so this causes no harm. For example, if a follower receives an AppendEntries request that includes log entries already present in its log, it ignores those entries in the new request.

^^^^^^^^^^^^^^^^^^^^^^^^^
Timing and availability
^^^^^^^^^^^^^^^^^^^^^^^^^

One of our requirements for Raft is that safety must not depend on timing: the system must not produce incorrect results just because some event happens more quickly or slowly than expected. However, availability (the ability of the system to respond to clients in a timely manner) must inevitably depend on timing.

Leader election is the aspect of Raft where timing is most critical. Raft will be able to elect and maintain a steady leader as long as the system satisfies the following timing requirement:

``broadcastTime`` << ``electionTimeout`` << ``MTBF``

where

* ``broadcastTime`` is the average time it takes a server to send RPCs in parallel to every server in the cluster and receive their responses
* ``electionTimeout`` is the election timeout described in Leader Election section [link]
* ``MTBF`` is the average time between failures for a single server.

The broadcast time should be an order of magnitude less than the election timeout so that leaders can reliably send the heartbeat messages required to keep followers from starting elections; given the randomized approach used for election timeouts, this inequality also
makes split votes unlikely. The election timeout should be a few orders of magnitude less than MTBF so that the system makes steady progress. When the leader crashes, the system will be unavailable for roughly the election timeout.

Raft’s RPCs typically require the recipient to persist information to stable storage, so the broadcast time may range from 0.5ms to 20ms, depending on storage technology.

As a result, the election timeout is likely to be somewhere between 10ms and 500ms.

Typical server MTBFs are several months or more, which easily satisfies the timing requirement.

?Cluster membership changes [TODO] if we need this point in the intro?

~~~~~~~~~~~~~~~~~~~
Client interaction
~~~~~~~~~~~~~~~~~~~

This section describes how clients interact with Raft.
These issues apply to all consensus-based systems, and Raft’s solutions
are similar to other systems.

Clients of Raft send all of their requests to the leader.
When a client first starts up, it connects to a randomly chosen server.
If the client’s first choice is not the leader, that server will reject
the client’s request and supply information about the most recent leader
it has heard from (AppendEntries requests include the network address of the leader).
If the leader crashes, client requests will time out; clients
then try again with randomly-chosen servers.

.. _algorithm_implement:

--------------------------------------------------------------------------------
Implementation of consensus algorithm in Tarantool
--------------------------------------------------------------------------------

Implementation of the Raft consensus algorithm in Tarantool has
a number of details that are important and described below.

1. [TODO] move the detailed description of parameters into reference and edit the content here accordingly

First of all, there are a number of configuration options that regulate
functioning of Raft algorithm for a given cluster node (server),
specifically the leader election process:


``election_role`` –- specifies the role of a cluster node during leader election.

Possible values:

* off -- means the election is disabled on the node.
  In this case, the node works as if Raft does not exist. It may be useful
  when you need a node that can be a part of a cluster but can't impact
  the leader election at the same time. For example, such a node can process
  long time  requests, and if it participated in the election and its vote
  became decisive, it could have affected the election process.
* voter -- means the node can vote but is never writable. It can be useful,
  for example, in a case of a remote data center that has cluster nodes that
  should participate in the leader election but you do not want
  to write the data on them.
* candidate -- means the node is a full-featured cluster member which eventually
  may become a leader. Note that a node with the candidate role
  also votes during the leader election.

``election_timeout`` -- how long to wait until election ends, in seconds.

2. During the leader election, there should be a quorum of votes to elect
the leader. To define the quorum, already exiting option
for synchronous replication is reused: ``replication_synchro_quorum`` [link to the option description].

The election quorum should be the strict majority of the nodes' votes
which means minimum N/2+1 where N is the number of nodes in the cluster.

3. We reuse the ``replication_timeout option`` [https://www.tarantool.io/en/doc/latest/reference/configuration/#cfg-replication-replication-timeout]
to define the timeout when a follower does not receive a heartbeat
from the current leader and assumes there is no viable leader and begins
an election to choose a new one.

4. While selecting a leader during the election, besides comparing the terms of
the candidates we also compare their vclock [link to vclock description in doc].

The original Raft algorithm assumes that all nodes share the same log record numbers.
In Tarantool they are called LSN [link to lsn section in doc].
But in the case of Tarantool, each node has its own LSN in its own component of vclock.
That makes the election messages a bit heavier because the nodes need to send
and compare complete vclocks of each other instead of a single number
like in the original Raft. But eventually the election logic becomes simpler:
in the original Raft there is a problem of uncertainty about what to do with
records of an old leader right after a new leader is elected.
They could be rolled back or confirmed depending on circumstances.
The issue disappears when vclock is used.

5. Leader election works differently during the cluster bootstrap
until number of bootstrapped replicas becomes equal or greater
than the election quorum [link to p.2 above]. This arises from the specifics
of the replica bootstrap and order of systems initialization.
In a nutshell, during bootstrap the leader election
may use a smaller election quorum than the configured one.

6. Tarantool's WAL [link to the wal section in doc] serves as a replication log [link to log repl. section above].



--------------------------------------------------------------------------------
Leader election and synchronous replication
--------------------------------------------------------------------------------

[TODO] Vlad's notes on the topic -- to merge with the content above


In Tarantool both are implemented as a modification of Raft.
Raft is an algorithm of synchronous replication and automatic leader election.
Its complete description can be found here: https://raft.github.io/raft.pdf.
In Tarantool synchronous replication and leader election are supported
as two separate subsystems. So it is possible to get synchronous replication,
but use something non-Raft for leader election. And vice versa -- elect a leader
in the cluster, but not use synchronous spaces at all.
Synchronous replication has a separate documentation section [todo - link].
Leader election is described here.

~~~~~~~~~~~~~~~~~~~~~~~~~~~
Automated leader election
~~~~~~~~~~~~~~~~~~~~~~~~~~~

Automated leader election in Tarantool helps to guarantee that in a cluster
there is at most one leader at any given moment of time.
Leader is a writable node, and all other nodes are non-writable --
they accept exclusively read-only requests. This can be useful when an application
does not want to support master-master replication, and it is necessary to somehow
ensure only one node will accept new transactions and commit them successfully.

When election is enabled life cycle of the cluster is divided into so called 'terms'.
Each term is described by a monotonically growing number.
Each node, after first boot, has it equal 1. When a node sees that it is not a leader,
and there is no a leader available for some time, it increases the term,
and starts new leader election round. Leader election happens via votes.
Nodes, who started the election, vote for self, and send vote requests to other nodes.
The ones, who got a vote request, vote for a first of them, and then can't do
anything in the same term but wait for a leader being elected.
If there is a node collected a quorum of votes, it becomes a leader,
and notifies other nodes about that. Also a split-vote can happen,
when no nodes got a quorum of votes. Then all the nodes, after a random timeout,
bump the term again and start a new election round. Eventually a leader is elected.
All the non-leader nodes are called 'followers'. The nodes, who start a new election round,
are called 'candidates'. The elected leader sends heartbeats to the non-leader
nodes to let them know it is alive. So if no heartbeats for too long time --
new election is started. Terms and votes are persisted by each instance
in order to preserve certain Raft guarantees.

During election the nodes prefer to vote for those who has the newest data.
So as if an old leader managed to send something before death to a quorum of replicas,
that data wouldn't be lost.

When election is enabled, it is required to have connections between each node pair,
so as it would be a fullmesh. This is needed because election messages
for voting and other internal things need direct connection between the nodes.
Also if election is enabled on the node, it won't replicate from any nodes except
the newest leader. This is done to avoid the issue, when a new leader is elected,
but the old leader still somehow survived and tries to send more changes
to the other nodes. Term numbers also work as a kind of a filter.
You can be sure, that if election is enabled on 2 nodes,
and node1 has term number less than node2, then node2 won't accept any transactions from node1.

~~~~~~~~~~~~~~~~~~~~~~~~~~~
Configuration
~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. code-block:: console

   box.cfg({
       election_mode = <string>,
       election_timeout = <seconds>,
       replication_timeout = <seconds>,
       replication_synchro_quorum = <count>,
   })

Leader election can be turned on by an option election_mode.
Default is off, not active. All nodes, having this option != off,
run Raft state machine internally, talking to other nodes according to the Raft
leader election protocol. When the option is off, the node accepts Raft messages
from other nodes, but it does not participate in the election activities,
and it does not affect the node's state.
So, for example, if a node is not a leader, but it has election_mode = 'off',
it is writable anyway.

You can control which nodes can become a leader, if you want them participate
in the election process, but don't want some of them to become leaders.
For that use election_mode = 'voter'. When the mode is set to voter,
the election works as usual, but this particular node won't become a leader
(still will vote for other nodes). If the node should be able to become a leader, use election_mode = 'candidate'.

As it was mentioned, the election has a timeout, for the case of split-vote.
The timeout can be configured using election_timeout option. Default is 5 seconds.
It is quite big, and for most of the cases can be freely lowered to 300-400ms.
It can be a floating point value (300 ms would be box.cfg{election_timeout = 0.3}.
To avoid the split vote repeat, the timeout is randomized on each node on every new election,
from 100% to 110% of the original timeout value. For example, if the timeout is 300ms,
and there are 3 nodes started the election simultaneously in the same term,
they can set their election timeouts to 300, 310, 320 respectively, or to 305, 302, 324, and so on.
In that way the votes won't be split forever, because the election on different nodes won't be restarted simultaneously.

There are other options which affect leader election indirectly.

Heartbeats sent by an active leader have a timeout, after which a new election is started.
Heartbeats are sent once per replication_timeout seconds. Default is 1.
The leader is considered dead, if it didn't sent any heartbeats for replication_timeout seconds * 4.

You can also configure the election quorum. For that the election reuses
the synchronous replication quorum: replication_synchro_quorum.
Default is 1 meaning that each node becomes a leader immediately after it votes for self.
It is best to set this option's value to the (cluster size / 2) + 1.
Otherwise there is no a guarantee that there is only one leader at a time.

Besides, it is necessary to take into account, that being a leader is not
the only requirement to be writable. A leader should have box.cfg{read_only = false},
and its connectivity quorum should be satisfied (box.cfg{replication_connect_quorum = <count>})
or disabled (box.cfg{replication_connect_quorum = 0}).
Nothing prevents from setting box.cfg{read_only = true},
but the leader just won't be writable then.
The option does not affect the election process though, so a read-only instance
still can vote, become a leader.

~~~~~~~~~~~~
Monitoring
~~~~~~~~~~~~

To see the current state of the node regarding leader election there is ``box.info.election``.

.. code-block:: console

   tarantool> box.info.election
   ---
   - state: follower
     vote: 0
     leader: 0
     term: 1
   ...

It shows the node state, term, vote in the current term,
and leader ID of the current term. IDs in the info output are the replica IDs
visible in ``box.info.id`` output on each node and in _cluster space.
0 vote means the node didn't vote in the current term.
0 leader means the node does not know who is a leader in the current term.
State can be follower, candidate, leader.
When election is enabled, only in leader state the node is writable.

Election implementation based on Raft logs all its actions with 'RAFT:' prefix. Actions such as new Raft message handling, state change, vote, term bump, and so on.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Important notes to keep in mind
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Leader election won't work properly if the election quorum is set <= ``cluster size / 2``
because in that case a split brain can happen, when 2 leaders are elected.
For example, assume there were 5 nodes. When quorum is set to 2, node1 and node2
can both vote for node1. Node3 and node4 can both vote for node5.
Node1 and node5 both win the election. When the quorum is set
to the cluster majority, it won't ever happen.

That must be especially actual when add new nodes. If the majority value is going
to change, better update the quorum on all the existing nodes before adding a new one.

Also the automated leader election won't bring many benefits in terms of data safety
when used without synchronous replication. Because if after a new leader is elected,
the old leader still is active and thinks he is a leader, nothing stops
it from accepting requests from the clients and making transactions.
Non-synchronous transactions will be successfully committed, because
they won't be checked against the quorum of replicas.
Synchronous transactions will fail, because they won't be able
to collect the quorum -- most of the replicas will reject
these old leader's transactions, because it is not a leader anymore.

Another issue to remember is that when a new leader is elected,
it won't automatically finalize synchronous transactions
left from the previous leader. That must be done manually using
``box.ctl.clear_synchro_queue()`` function. In future it is going to be done automatically.



