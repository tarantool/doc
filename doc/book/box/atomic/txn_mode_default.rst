..  _txn_mode-default:

Transaction mode by default
===========================

By default, Tarantool does not allow yielding inside a memtx 
transaction and the transaction manager is disabled. This allows fast 
atomic transactions, but brings some limitations:

*   You cannot use interactive transactions.

*   Any fiber yield leads to the abort of a transaction.

*   All change operations on indexes -- inserts, updates, replacements, deletions -- 
    are performed only after successful completion of the transaction (call ``box.commit()``). 
    If an error occurs, the transaction is rolled back, including the return of previous 
    data to the indexes. The same is true if a yield happens.

To allow yielding inside a memtx transaction, see :ref:`Transaction mode: MVCC <txn_mode_transaction-manager>`.
