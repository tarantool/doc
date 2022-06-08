.. _transaction_model:

Transaction model
=================

The transaction model of Tarantool corresponds to the properties ACID 
(Atomicity, Consistency, Isolation, Durability).
It allows to use transactions with multiple statements to provide 
**isolation**: each transaction executes in fibers on a single thread, sees consistent database state, 
and commits all changes atomically. Without transactions, any function containing yield points can see 
changes in database state caused by fibers that trigger a preempt.

At the :doc:`commit </reference/reference_lua/box_txn_management/commit>` time, all transaction changes are 
written to the WAL (:ref:`Write Ahead Log <internals-wal>`) in a single batch in a specific order. Therefore, in Tarantool 
the `transaction isolation level <https://en.wikipedia.org/wiki/Isolation_(database_systems)#Isolation_levels>`_
is *serializable* with the clause "if no failure during writing to the WAL". In case of such failure, which can occur, 
for example, when the disk space is over, the isolation level of the transaction is set to *read uncommitted*.

If you need to make some changes, the transaction can be rolled back -- :doc:`completely </reference/reference_lua/box_txn_management/rollback>` 
or up to a specific :doc:`savepoint </reference/reference_lua/box_txn_management/rollback_to_savepoint>`.

.. _transaction_model-serialization:

Serialization
-------------

Tarantool has 2 modes for serialization:

*   :ref:`Default <txn_mode-default>` -- yields are blocked, there are no parallel transactions and no conflicts.

*   :ref:`MVCC  <txn_mode_transaction-manager>` -- enable the transaction manager, provides parallel transactions, 
    conflicts may happen. You can use this mode on the :ref:`memtx <engines-chapter>` storage engine. 
    The :ref:`vinyl <engines-chapter>` storage engine also supports MVCC mode, but has a different realization.

..  note::

    You can’t mix storage engines in a transaction today.

Using MVСС mode has two important criteria for the isolation level of the transaction -- 
*read committed* and *read confirmed*. 


MVСС can look at the transactions independently and determine these criteria, 
or it can do the user itself when the transactions start.
