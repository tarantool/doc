.. _repl_sync:

================================================================================
Synchronous replication
================================================================================

--------------------------------------------------------------------------------
Overview
--------------------------------------------------------------------------------

By default, replication in Tarantool is **asynchronous**: if a transaction
is committed locally on a master node, it does not mean it is replicated onto any
replicas. If a master responds success to a client and then dies, after failover
to a replica, from the client's point of view the transaction will disappear.

**Synchronous** replication exists to solve this problem. Synchronous transactions
are not considered committed and are not responded to a client until they are
replicated onto some number of replicas.

--------------------------------------------------------------------------------
Usage
--------------------------------------------------------------------------------

In Tarantool, it can be enabled per-space using the ``is_sync`` option:

.. code-block:: lua

    box.schema.create_space('test1', {is_sync = true})

Any transaction doing a DML request on this space becomes synchronous.
Notice that DDL on this space (including truncation) is **not** synchronous.

To control the behavior of synchronous transactions, there exist global
``box.cfg`` :ref:`options <cfg_replication-replication_synchro_quorum>`:

.. code-block:: lua

    box.cfg{replication_synchro_quorum = <number of instances>}

This option tells how many replicas should confirm the receipt of a synchronous
transaction before it can finish its commit. So far this option accounts all
replicas, including anonymous. As a usage example, consider this:

.. code-block:: lua

    -- Instance 1
    box.cfg{
        listen = 3313,
        replication_synchro_quorum = 2,
    }
    box.schema.user.grant('guest', 'super')
    _ = box.schema.space.create('sync', {is_sync=true})
    _ = _:create_index('pk')

.. code-block:: lua

    -- Instance 2
    box.cfg{
        listen = 3314,
        replication = 'localhost:3313'
    }

.. code-block:: lua

    -- Instance 1
    box.space.sync:replace{1}

When the first instance makes ``replace()``, it won't finish until the second
instance confirms its receipt and successful appliance. Note that the quorum is
set to 2, but the transaction was still committed even though there is only one
replica. This is because the master instance itself also participates in the quorum.

Now if the second instance is down, the first one won't be able to commit any
synchronous change.

.. code-block:: lua

    -- Instance 2
    Ctrl+D

.. code-block:: tarantoolsession

    -- Instance 1
    tarantool> box.space.sync:replace{2}
    ---
    - error: Quorum collection for a synchronous transaction is timed out
    ...

The transaction wasn't committed because it failed to achieve the quorum in the
given time. The time is a second configuration option:

.. code-block:: lua

    box.cfg{replication_synchro_timeout = <number of seconds, can be float>}

It tells how many seconds to wait for a synchronous transaction quorum
replication until it is declared failed and is rolled back.

A successful synchronous transaction commit is persisted in the WAL as a special
CONFIRM record. The rollbacks are similarly persisted with a ROLLBACK record.

The ``timeout`` and ``quorum`` options are not used on replicas. It means if
the master dies, the pending synchronous transactions will be kept waiting on
the replicas until a new master is elected.

--------------------------------------------------------------------------------
Synchronous and asynchronous transactions
--------------------------------------------------------------------------------

A killer feature of Tarantool's synchronous replication is its being *per-space*.
So, if you need it only rarely for some critical data changes, you won't pay for
it in performance terms.

When there is more than one synchronous transaction, they all wait for being
replicated. Moreover, if an asynchronous transaction appears, it will
also be blocked by the existing synchronous transactions. This behavior is very
similar to a regular queue of asynchronous transactions because all the transactions
finish their commits in the same order as they start them.
So, here comes **the commit rule**:
transactions always finish their commits in the same order as they start
them  -- regardless of being synchronous or asynchronous.

If one of the waiting synchronous transactions times out and is rolled back, it
will first roll back all the newer pending transactions. Again, just like how
asynchronous transactions are rolled back when WAL write fails.
So, here comes **the rollback rule:**
transactions are always rolled back in the order reversed from the commit start
order -- regardless of being synchronous or asynchronous.

One more important thing is that if an asynchronous transaction is blocked on
a synchronous transaction, it does not become synchronous as well.
This just means it will wait for the synchronous transaction to be committed.
But once it is done, the asynchronous transaction will finish its commit
immediately -- it won't wait for being replicated itself.

--------------------------------------------------------------------------------
Limitations and known problems
--------------------------------------------------------------------------------

Currently, there is no way to enable synchronous replication for existing spaces,
but this limitation is only temporary.

Synchronous transactions work only for master-slave topology. You can have multiple
replicas, anonymous replicas, but only one node can make synchronous transactions.

Anonymous replicas participate in the quorum. This will change: it won't be possible
for a synchronous transaction to gather quorum using anonymous replicas in future.

--------------------------------------------------------------------------------
Master election
--------------------------------------------------------------------------------

There is no automatic master election so far. For now it is expected to be done
by an external tool or manually.

When the master node dies, you need to find the replica which received the latest
changes from the master compared to all the other replicas, i.e. with the biggest
LSN in the old master's ``vclock`` component.

On this replica, you need to call the function ``box.ctl.clear_synchro_queue()``.
This function will try to successfully confirm and commit the pending synchronous
transactions. If it couldn't be done in the ``box.cfg.replication_synchro_timeout``,
the non-confirmed transactions are rolled back. From this moment, this instance
can become a new master and make new synchronous transactions.

--------------------------------------------------------------------------------
Tips and tricks
--------------------------------------------------------------------------------

If a transaction is rolled back, it does not mean the ROLLBACK message reached
the replicas. It still can happen that the master node suddenly dies, so the
transaction will be committed by the new master. Your application logic should be
ready for that.

Synchronous transactions are better to use with full mesh. Then the replicas can
talk to each other in case of the master node's death, and still confirm some
pending transactions.
