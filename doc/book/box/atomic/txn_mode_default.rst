..  _txn_mode-default:

Transaction mode by default
===========================

By default, Tarantool does not allow yielding inside a memtx transaction and the transaction manager is disabled. 
This allows fast atomic transactions similar to vinyl.

..  code-block:: enabling

    box.cfg{memtx_use_mvcc_engine = false}
