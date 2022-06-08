.. _transaction_model:

Transaction model
=================

The transaction model is about using transactions with multiple statements to provide 
**isolation**: each transaction executes in fibers on a single thread, sees consistent database state, 
and commits all changes atomically. Without transactions, any function containing yield points can see 
changes in database state caused by fibers that trigger a preempt.

At the :doc:`commit </reference/reference_lua/box_txn_management/commit>` time, all transaction changes are 
written to the WAL (:ref:`Write Ahead Log <internals-wal>`) in a single batch in a specific order. Therefore, in Tarantool 
the `transaction isolation level <https://en.wikipedia.org/wiki/Isolation_(database_systems)#Isolation_levels>`_
is *serializable* with the clause "if no failure during writing to the WAL". In case of such failure, which can occur 
for example when the disk space is over, the isolation level of the transaction is set to *read uncommitted*.

If you need to make some changes, the transaction can be rolled back -- :doc:`completely </reference/reference_lua/box_txn_management/rollback>` 
or up to a specific :doc:`savepoint </reference/reference_lua/box_txn_management/rollback_to_savepoint>`.

.. _transaction_model-engines:

Vinyl or memtyx
---------------

..  note::

    You can’t mix storage engines in a transaction today.
    
When choosing one of the storage engines that support transactions, pay attention to its features.


.. _transaction_model-vinyl:

Vinyl modes
-----------

In :ref:`vinyl <engines-chapter>` you can only use the default mode.
Tarantool uses a simple optimistic scheduler to implement isolation:
the first transaction to commit wins. If a concurrently active transaction
has read a value that has been modified by a committed transaction, it is aborted.

The cooperative scheduler ensures that, in absence of yields,
a multi-statement transaction is not preempted and hence is never aborted.
Therefore, understanding yields is essential for writing abort-free code.

When testing the transaction mechanism in Tarantool, you may sometimes find that 
yielding after ``box.begin()`` but before any read/write operation does not
cause an abort as it should according to the description. This is because
``box.begin()`` does not actually start a transaction. It is a mark telling
Tarantool to start a transaction after some database request that follows.

.. _transaction_model-memtx:

Memtx modes
-----------

In :ref:`memtx <engines-chapter>`, if an instruction that implies yields, 
explicit or implicit, is executed during a transaction, the transaction is completely rolled back. 

Starting with version 2.6.1, memtx allows you to use :ref:`mode by default <txn_mode-default>` or 
:ref:`MVCC mode <txn_mode_transaction-manager>`.
