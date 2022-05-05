.. _atomic-transactions:

--------------------------------------------------------------------------------
Transactions
--------------------------------------------------------------------------------

Transactions in Tarantool occur in **fibers** on a single **thread**.
That is why Tarantool has a guarantee of atomicity of execution.
That requires emphasis.

Since :tarantool-release:`2.10.0-beta1`, Tarantool supports streams and interactive transactions over them.
See :ref:`Streams <box_stream>`.

In the absence of transactions, any function containing yield points can see
changes in database state caused by fibers that preempt.
Multi-statement transactions exist to provide **isolation**: each transaction
sees consistent database state and commits all changes atomically.
At the :doc:`commit </reference/reference_lua/box_txn_management/commit>` time,
a yield happens and all transaction changes
are written to the :ref:`write ahead log <internals-wal>` in a single batch.
Or, if needed, transaction changes can be rolled back --
:doc:`completely </reference/reference_lua/box_txn_management/rollback>` or to
a specific
:doc:`savepoint </reference/reference_lua/box_txn_management/rollback_to_savepoint>`.

In Tarantool, the `transaction isolation level <https://en.wikipedia.org/wiki/Isolation_(database_systems)#Isolation_levels>`_
is *serializable* with the clause "if no failure during writing to the WAL". In
case of such a failure that can happen, for example, if the disk space
is over, the transaction isolation level becomes *read uncommitted*.

In :ref:`vinyl <engines-chapter>`, Tarantool uses a simple optimistic scheduler to implement the isolation:
the first transaction to commit wins. If a concurrently active transaction
has read a value that has been modified by a committed transaction, it is aborted.

The cooperative scheduler ensures that, in absence of yields,
a multi-statement transaction is not preempted and hence is never aborted.
Therefore, understanding yields is essential for writing abort-free code.

Sometimes while testing the transaction mechanism in Tarantool, you can notice
that yielding after ``box.begin()`` but before any read/write operation does not
cause an abort as it should according to the description. This is because
``box.begin()`` does not actually start a transaction. It is a mark telling
Tarantool to start a transaction after some database request that follows.

In memtx, if an instruction that implies yields, explicit or implicit, is
executed during a transaction, the transaction is fully rolled back. In vinyl,
we use more complex transactional manager that allows yields.

.. note::

   You can’t mix storage engines in a transaction today.
