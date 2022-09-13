..  _how-to-repl_sync:

Configuring synchronous replication
===================================

Since version :doc:`2.5.1 </release/2.5.1>`,
:ref:`synchronous replication <repl_sync>`
can be enabled per-space by using the ``is_sync`` option:

..  code-block:: lua

    box.schema.create_space('test1', {is_sync = true})

Any transaction doing a DML request on this space becomes synchronous.
Notice that DDL on this space (including truncation) is **not** synchronous.

To control the behavior of synchronous transactions, there exist global
``box.cfg`` :ref:`options <cfg_replication-replication_synchro_quorum>`:

..  code-block:: lua

    box.cfg{replication_synchro_quorum = <number of instances>}

..  code-block:: lua

    box.cfg{replication_synchro_quorum = "N / 2 + 1"}

This option tells how many replicas should confirm the receipt of a synchronous transaction before it is committed.
Since version :doc:`2.5.3 </release/2.5.3>`, the parameter supports dynamic evaluation of the quorum number
(see :ref:`reference for the replication_synchro_quorum parameter <cfg_replication-replication_synchro_quorum>` for details).
Since version :doc:`2.10.0 </release/2.10.0>`,
this option does not account for anonymous replicas.
As a usage example, consider this:

..  code-block:: lua

    -- Instance 1
    box.cfg{
        listen = 3313,
        replication_synchro_quorum = 2,
    }
    box.schema.user.grant('guest', 'super')
    _ = box.schema.space.create('sync', {is_sync=true})
    _ = _:create_index('pk')

..  code-block:: lua

    -- Instance 2
    box.cfg{
        listen = 3314,
        replication = 'localhost:3313'
    }

..  code-block:: lua

    -- Instance 1
    box.space.sync:replace{1}

When the first instance makes ``replace()``, it won't finish until the second
instance confirms its receipt and successful appliance. Note that the quorum is
set to 2, but the transaction was still committed even though there is only one
replica. This is because the master instance itself also participates in the quorum.

Now, if the second instance is down, the first one won't be able to commit any
synchronous change.

..  code-block:: lua

    -- Instance 2
    Ctrl+D

..  code-block:: tarantoolsession

    -- Instance 1
    tarantool> box.space.sync:replace{2}
    ---
    - error: Quorum collection for a synchronous transaction is timed out
    ...

The transaction wasn't committed because it failed to achieve the quorum in the
given time. The time is a second configuration option:

..  code-block:: lua

    box.cfg{replication_synchro_timeout = <number of seconds, can be float>}

It tells how many seconds to wait for a synchronous transaction quorum
replication until it is declared failed and is rolled back.

A successful synchronous transaction commit is persisted in the WAL as a special
CONFIRM record. The rollbacks are similarly persisted with a ROLLBACK record.

The ``timeout`` and ``quorum`` options are not used on replicas. It means if
the master dies, the pending synchronous transactions will be kept waiting on
the replicas until a new master is elected.


Tips and tricks
---------------

If a transaction is rolled back, it does not mean the ROLLBACK message reached
the replicas. It still can happen that the master node suddenly dies, so the
transaction will be committed by the new master. Your application logic should be
ready for that.

Synchronous transactions are better to use with full mesh. Then the replicas can
talk to each other in case of the master node's death and still confirm some
pending transactions.
