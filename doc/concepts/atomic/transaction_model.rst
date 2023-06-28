.. _transaction_model:

Transaction model
=================

.. _transaction_model_overview:

Overview
--------

The transaction model of Tarantool corresponds to the properties ACID 
(atomicity, consistency, isolation, durability).


Tarantool has two modes of transaction behavior:

*   :ref:`Default <txn_mode-default>` -- suitable for fast monopolistic atomic transactions

*   :ref:`MVCC <txn_mode_transaction-manager>` -- designed for long-running concurrent transactions


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

By :ref:`default <txn_mode-default>`, the isolation level of Tarantool is *serializable*.
The exception is a failure during writing to the WAL, which can occur, for example, when the disk space is over.
In this case, the isolation level of the concurrent read transaction would be ``read-committed``.

The :ref:`MVСС mode <txn_mode_transaction-manager>` provides several options that enable you to tune
the visibility behavior during transaction execution.


.. _level_read_committed:

Read-committed
~~~~~~~~~~~~~~

The ``read-committed`` isolation level makes visible all transactions that started commit (:ref:`box.commit() <box-commit>` was called).

*   *Write transactions with reads*

    Manual usage of ``read-committed`` for write transactions with reads is completely safe, as this transaction will eventually result in a commit.
    If a previous transactions fails, this transaction will inevitably fail as well due to the *serializable* isolation level.

*   *Read transactions*

    Manual usage of ``read-committed`` for read transactions may be unsafe, as it may lead to phantom reads.


.. _level_read_confirmed:

Read-confirmed
~~~~~~~~~~~~~~

The ``read-confirmed`` isolation level makes visible all transactions that finished
the commit (:ref:`box.commit() <box-commit>` was returned).
This means that new data is already on disk or even on other replicas.

*   *Read transactions*

    The use of ``read-confirmed`` is safe for read transactions given that data
    is on disk (for asynchronous replication) or even in other replicas
    (for synchronous replication).

*   *Write transactions*

    To achieve *serializable*, any write transaction should read all data that has already been committed.
    Otherwise, it may conflict when it reaches its commit.



.. _level_linearizable:

Linearizable read
~~~~~~~~~~~~~~~~~

Linearizability of read operations implies that if a response for a write request arrived earlier than a read request was made, this read request should return the results of the write request.
When called with ``linearizable``, :ref:`box.begin() <box-begin>` yields until the instance receives enough data from remote peers to be sure that the transaction is linearizable.

Linearizable transactions may only perform requests to the following memtx space types:

*   :ref:`synchronous <repl_sync>`
*   local (:doc:`created </reference/reference_lua/box_schema/space_create>` with ``is_local = true``)
*   temporary (:doc:`created </reference/reference_lua/box_schema/space_create>` with ``temporary = true``)

A linearizable transaction can fail with an error in the following cases:

*   If the node can't contact enough remote peers to determine which data is committed.
*   If the data isn't received during the ``timeout`` specified in ``box.begin()``.

.. NOTE::

    To start a linearizable transaction, the node should be the replication source for at least ``N - Q + 1`` remote replicas.
    Here ``N`` is the count of registered nodes in the cluster and ``Q`` is :ref:`replication_synchro_quorum <cfg_replication-replication_synchro_quorum>`.
    So, for example, you can't perform a linearizable transaction on anonymous replicas because they can't be the source of replication for other nodes.


.. _level_best_effort:

Best-effort (default)
~~~~~~~~~~~~~~~~~~~~~

To minimize the possibility of conflicts, MVCC uses what is called ``best-effort`` visibility:

*   for write transactions, MVCC chooses :ref:`read-committed <level_read_committed>`
*   for read transactions, MVCC chooses :ref:`read-confirmed <level_read_confirmed>`

This inevitably leads to the *serializable* isolation level.
Since there is no option for MVCC to analyze the whole transaction to make a decision, it makes the choice on
the first operation.

.. NOTE::

    If the *serializable* isolation level becomes unreachable, the transaction is marked as "conflicted"
    and rolled back.
