..  _txn_mode-default:

Transaction mode: default
===========================

By default, Tarantool does not allow yielding inside a memtx 
transaction and the transaction manager is disabled. This allows fast 
atomic transactions, but brings some limitations:

*   You cannot use interactive transactions.

*   Any fiber yield leads to the abort of a transaction.

*   All changes are made immediately, but in the event of a yield or error, 
    the transaction is rolled back, including the return of the previous data.


To allow yielding inside a memtx transaction, see :ref:`Transaction mode: MVCC <txn_mode_transaction-manager>`.




