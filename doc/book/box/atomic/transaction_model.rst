.. _transaction_model:

Transaction model
=================

The transaction model of Tarantool corresponds to the properties ACID 
(atomicity, consistency, isolation, durability).
And Tarantool has the highest `transaction isolation level <https://en.wikipedia.org/wiki/Isolation_(database_systems)#Isolation_levels>`_ -- *serializable*.
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

The use of other transaction modes provides additional opportunities for transaction isolation.

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


.. _transaction_model-default-settings:

Default: transaction isolation settings
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~  

In this mode, the user does not need to make any additional settings.

.. _transaction_model-mvcc-settings:

MVCC: transaction isolation settings
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Using MVСС mode cancels the exception and sets the isolation level to *serializable* 
in any case. This isolation level includes *read committed* and *read confirmed*, 
which MVCC sets independently for each transaction (if the ``best-effort`` option is set). 
However, the user can also set these levels for transactions.

.. _transaction_model-best-effort:

MVCC best effort
^^^^^^^^^^^^^^^^

The ``best-effort`` option is set by default in ``box-cfg``. 
This allows MVCC to consider the actions of transactions independently and determine the 
best isolation level for them. It increases the successful completion of the transaction 
and helps to avoid possible conflicts.

You can set the default level of isolation with the options ``read-committed`` 
and ``read-confirmed``. For example, to set it to ``read-committed`` 
use the following command:

..  code-block:: default_txn_isolation_level

    box.cfg{default_txn_isolation = 'read-committed'}
 

.. _transaction_model-read-committed:

Read committed
^^^^^^^^^^^^^^

The *read committed* isolation level makes visible all transactions that started 
with the commit (``box.commit()`` was called). If you use this transaction level only for 
read-write transactions, you can minimize the conflicts that may occur.

.. _transaction_model-read-confirmed:

Read confirmed
^^^^^^^^^^^^^^

The *read confirmed* isolation level makes visible all transactions that finished 
the commit (``box.commit()`` returned). If you use this transaction level only for 
read-only transactions, you can always get a persistent tuple on disk and 
minimize the conflicts that may occur.

.. _transaction_model-the-choice:

Which mode should be used?
--------------------------

TBD.








