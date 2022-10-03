.. _transaction_model:

Transaction model
=================

The transaction model of Tarantool corresponds to the properties ACID 
(atomicity, consistency, isolation, durability).


Tarantool has two modes of transaction behavior that allow users to choose between 
fast monopolistic atomic transactions and long-running concurrent transactions with 
:ref:`MVCC <txn_mode_mvcc-tnx-manager>`:

*   :ref:`Default <txn_mode-default>`.

*   :ref:`MVCC <txn_mode_transaction-manager>`.


Each transaction in Tarantool is executed in a single fiber on a single thread, sees a consistent database state 
and commits all changes atomically. 

All transaction changes are written to the WAL (:ref:`Write Ahead Log <internals-wal>`) 
in a single batch in a specific order at the time of the
:doc:`commit </reference/reference_lua/box_txn_management/commit>`.
If needed, transaction changes can also be rolled back --
:doc:`completely </reference/reference_lua/box_txn_management/rollback>` or to
a specified :doc:`savepoint </reference/reference_lua/box_txn_management/rollback_to_savepoint>`.

Therefore, every transaction in Tarantool has the highest 
`transaction isolation level <https://en.wikipedia.org/wiki/Isolation_(database_systems)#Isolation_levels>`_ -- *serializable*.

.. _transaction_model_levels:

Isolation level
---------------

By :ref:`default <txn_mode-default>`, the isolation level of Tarantool is *serializable*,
except in the case of a failure during writing to the WAL, which can occur, for example, 
when the disk space is over. In this case, the isolation level of the concurrent read transaction 
would be *read committed*.


The :ref:`MVСС mode <txn_mode_transaction-manager>` provides several options that allow you to tune
the visibility behavior during transaction execution. To achieve *serializable*, any write transaction 
should read all data that has already been committed (otherwise it may conflict 
when it reaches its commit). For read transactions, however, it is sufficient 
and safe to *read confirmed* data that is on disk (for asynchronous replication) or even in other replicas 
(for synchronous replication).


So, during transaction execution, the MVCC must choose between *read-committed* or *read-confirmed* visibility,
which inevitably leads to the *serializable* isolation level.


The *read committed* isolation level makes visible all transactions that started 
commit (``box.commit()`` was called). By using this transaction level only for 
read-write transactions, you can minimize the conflicts that may occur.


The *read confirmed* isolation level makes visible all transactions that finished 
the commit (``box.commit()`` was returned), meaning it is already on disk or even on other replicas. 


If the *serializable* isolation level becomes unreachable, the transaction is marked as "conflicted" 
and can no longer be committed.


To minimize the possibility of conflicts, MVCC uses what is called *best-effort* visibility: 
for write transactions it chooses *read-committed*, for read transactions it chooses *read-confirmed*.
Since there is no option for MVCC to analyze the whole transaction to make a decision, it makes the choice on 
the first operation. The author of the transaction has more knowledge about the whole transaction and could give 
a hint to minimize conflicts.

Manual usage of *read-committed* for write transactions with reads is completely safe, as this
transaction will eventually result in a commit. And if some previous transactions fail, this 
transaction will inevitably fail as well due to the *serializable* isolation level.

Manual usage of *read-committed* for pure read transactions may be unsafe, as it may lead to phantom reads.
















