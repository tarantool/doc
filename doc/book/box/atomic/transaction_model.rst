.. _transaction_model:

Transaction model
=================

The transaction model of Tarantool corresponds to the properties ACID 
(atomicity, consistency, isolation, durability).
And Tarantool has the highest `transaction isolation level <https://en.wikipedia.org/wiki/Isolation_(database_systems)#Isolation_levels>`_
 -- *serializable*.
It allows to use transactions with multiple statements to provide 
**isolation**: each transaction executes in fibers on a single thread, sees consistent database state, 
and commits all changes atomically. 


All transaction changes are written to the WAL (:ref:`Write Ahead Log <internals-wal>`) 
in a single batch in a specific order at time of the
:doc:`commit </reference/reference_lua/box_txn_management/commit>`.


The isolation level *serializable* is always set,
except in the case of a failure during writing to the WAL, which can occur, for example, 
when the disk space is over. In this case, the isolation level of the transaction 
is set to *read uncommitted*.

The use of other transaction modes provides additional levels of transaction isolation.

.. _transaction_model-modes:

Transaction modes
-----------------

Tarantool has 2 modes of transaction behavior:

*   :ref:`Default <txn_mode-default>` -- yields are blocked, there are no parallel transactions and no conflicts.

*   :ref:`MVCC  <txn_mode_transaction-manager>` -- enable the transaction manager, provides parallel transactions, 
    conflicts may happen. You can use this mode on the :ref:`memtx <engines-chapter>` storage engine. 
    The :ref:`vinyl <engines-chapter>` storage engine also supports MVCC mode, but has a different realization.

..  note::

    You can’t mix storage engines in a transaction today.

Using MVСС mode cancels the exception and sets the isolation level to *serializable* 
in any case. This isolation level includes *read-committed* and *read-confirmed*, 
which facilitate working with conflicts.


MVСС can look at the transactions independently and determine the level of isolation, 
or it can do the user itself when the transactions start.










