..  _internals-replication-orphan_status:
..  _replication-orphan_status:

Orphan status
=============

Starting with Tarantool version 1.9, there is a change to the
procedure when an instance joins a replica set.
During ``box.cfg()`` the instance will try to join all masters listed
in :ref:`box.cfg.replication <cfg_replication-replication>`.
If the instance does not succeed with at least
the number of masters specified in
:ref:`replication_connect_quorum <cfg_replication-replication_connect_quorum>`,
then it will switch to **orphan status**.
While an instance is in orphan status, it is read-only.

To "join" a master, a replica instance must "connect" to the
master node and then "sync".

"Connect" means contact the master over the physical network
and receive acknowledgment. If there is no acknowledgment after
:ref:`box.replication_connect_timeout <cfg_replication-replication_connect_timeout>`
seconds (usually 4 seconds), and retries fail, then the connect step fails.

"Sync" means receive updates
from the master in order to make a local database copy.
Syncing is complete when the replica has received all the
updates, or at least has received enough updates that the replica's lag
(see
:ref:`replication.upstream.lag <box_info_replication_upstream_lag>`
in ``box.info()``)
is less than or equal to the number of seconds specified in
:ref:`box.cfg.replication_sync_lag <cfg_replication-replication_sync_lag>`.
If ``replication_sync_lag`` is unset (nil) or set to TIMEOUT_INFINITY, then
the replica skips the "sync" state and switches to "follow" immediately.

In order to leave orphan mode you need to sync with a sufficient number
(:ref:`replication_connect_quorum <cfg_replication-replication_connect_quorum>`) of
instances. To do so, you may either:

*   Set :ref:`replication_connect_quorum <cfg_replication-replication_connect_quorum>`
    to a lower value.
*   Reset ``box.cfg.replication`` to exclude instances that cannot be reached
    or synced with.
*   Set ``box.cfg.replication`` to ``""`` (empty string).

The following situations are possible.

..  _replication-leader:

**Situation 1: bootstrap**

Here ``box.cfg{}`` is being called for the first time.
A replica is joining but no replica set exists yet.

    1.  Set status to 'orphan'.
    2.  Try to connect to all nodes from ``box.cfg.replication``,
        or to the number of nodes required by
        :ref:`replication_connect_quorum <cfg_replication-replication_connect_quorum>`.
        Retrying up to 3 times in 30 seconds is possible because this is bootstrap,
        :ref:`replication_connect_timeout <cfg_replication-replication_connect_timeout>`
        is overridden.

    3.  Abort and throw an error if not connected to all nodes in ``box.cfg.replication`` or
        :ref:`replication_connect_quorum <cfg_replication-replication_connect_quorum>`.

    4.  This instance might be elected as the replica set 'leader'.
        Criteria for electing a leader include vclock value (largest is best),
        and whether it is read-only or read-write (read-write is best unless there is no other choice).
        The leader is the master that other instances must join.
        The leader is the master that executes
        :doc:`box.once() </reference/reference_lua/box_once>` functions.

    5.  If this instance is elected as the replica set leader,
        then
        perform an "automatic bootstrap":

        a.  Set status to 'running'.
        b.  Return from ``box.cfg{}``.

        Otherwise this instance will be a replica joining an existing replica set,
        so:

        a.  Bootstrap from the leader.
            See examples in section :ref:`Bootstrapping a replica set <replication-bootstrap>`.
        b.  In background, sync with all the other nodes in the replication set.

**Situation 2: recovery**

Here ``box.cfg{}`` is not being called for the first time.
It is being called again in order to perform recovery.

    1.  Perform :ref:`recovery <internals-recovery_process>` from the last local
        snapshot and the WAL files.

    2.  Connect to at least
        :ref:`replication_connect_quorum <cfg_replication-replication_connect_quorum>`
        nodes. If failed -- set status to 'orphan'.
        (Attempts to sync will continue in the background and when/if they succeed
        then 'orphan' will be changed to 'connected'.)

    3.  If connected - sync with all connected nodes, until the difference is not more than
        :ref:`replication_sync_lag <cfg_replication-replication_sync_lag>` seconds.

..  _replication-configuration_update:

**Situation 3: configuration update**

Here ``box.cfg{}`` is not being called for the first time.
It is being called again because some replication parameter
or something in the replica set has changed.

    1.  Try to connect to all nodes from ``box.cfg.replication``,
        or to the number of nodes required by
        :ref:`replication_connect_quorum <cfg_replication-replication_connect_quorum>`,
        within the time period specified in
        :ref:`replication_connect_timeout <cfg_replication-replication_connect_timeout>`.

    2.  Try to sync with the connected nodes,
        within the time period specified in
        :ref:`replication_sync_timeout <cfg_replication-replication_sync_timeout>`.

    3.  If earlier steps fail, change status to 'orphan'.
        (Attempts to sync will continue in the background and when/if they succeed
        then 'orphan' status will end.)

    4.  If earlier steps succeed, set status to 'running' (master) or 'follow' (replica).

..  _replication-configuration_rebootstrap:

**Situation 4: rebootstrap**

Here ``box.cfg{}`` is not being called. The replica connected successfully
at some point in the past, and is now ready for an update from the master.
But the master cannot provide an update.
This can happen by accident, or more likely can happen because the replica
is slow (its :ref:`lag <cfg_replication-replication_sync_lag>` is large),
and the WAL (.xlog) files containing the
updates have been deleted. This is not crippling. The replica can discard
what it received earlier, and then ask for the master's latest snapshot
(.snap) file contents. Since it is effectively going through the bootstrap
process a second time, this is called "rebootstrapping". However, there has
to be one difference from an ordinary bootstrap -- the replica's
:ref:`replica id <replication-replica-id>` will remain the same.
If it changed, then the master would think that the replica is a
new addition to the cluster, and would maintain a record of an
instance ID of a replica that has ceased to exist. Rebootstrapping was
introduced in Tarantool version 1.10.2 and is completely automatic.
