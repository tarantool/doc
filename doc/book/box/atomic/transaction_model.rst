.. _transaction_model:

Transaction model
=================

The transaction model of Tarantool corresponds to the properties ACID 
(atomicity, consistency, isolation, durability).


Tarantool has two modes of transaction behavior that allow users to choose between 
fast atomic transactions and transactions with :ref:`MVCC <txn_mode_mvcc-tnx-manager>`:

*   :ref:`Default <txn_mode-default>`.

*   :ref:`MVCC <txn_mode_transaction-manager>`.


Each transaction in Tarantool is executed in fibers on a single thread, sees a consistent database state 
and commits all changes atomically. 

All transaction changes are written to the WAL (:ref:`Write Ahead Log <internals-wal>`) 
in a single batch in a specific order at time of the
:doc:`commit </reference/reference_lua/box_txn_management/commit>`.
If needed, transaction changes can also be rolled back --
:doc:`completely </reference/reference_lua/box_txn_management/rollback>` or to
a specified :doc:`savepoint </reference/reference_lua/box_txn_management/rollback_to_savepoint>`.

Therefore, every transaction in Tarantool has the highest 
`transaction isolation level <https://en.wikipedia.org/wiki/Isolation_(database_systems)#Isolation_levels>`_ -- *serializable*.

.. _transaction_model_levels:

Isolation level serializable
----------------------------

By :ref:`default <txn_mode-default>`, Tarantool's isolation level *serializable* is always set,
except in the case of a failure during writing to the WAL, which can occur, for example, 
when the disk space is over. In this case, the isolation level of the transaction 
is set to *read uncommitted*.


Using :ref:`MVСС mode <txn_mode_transaction-manager>` cancels the exception and sets the 
isolation level to *serializable* in any case. This isolation level includes 
*read committed* and *read confirmed*, which :ref:`MVCC <txn_mode_mvcc-tnx-manager>` 
sets independently for each transaction (if the ``best-effort`` option is set). 


The *read committed* isolation level makes visible all transactions that started 
commit (``box.commit()`` was called). By using this transaction level only for 
read-write transactions, you can minimize the conflicts that may occur.


The *read confirmed* isolation level makes visible all transactions that finished 
the commit (``box.commit()`` was returned). By using this transaction level only for 
read-only transactions, you can always get a persistent tuple on disk and 
minimize the conflicts that may occur.


The user can also set these levels for transactions to specify a timepoint 
when the changes must be visible to other transactions. To learn more, 
see :ref:`MVCC options <txn_mode_mvcc-options>`.

















