..  _txn_mode-default:

Transaction mode: default
===========================

By default, Tarantool does not allow :ref:`"yielding" <app-yields>` inside a :ref:`memtx <engines-chapter>` 
transaction and the :ref:`transaction manager <txn_mode_mvcc-txn-manager>` is disabled. This allows fast
atomic transactions without conflicts, but brings some limitations:

*   You cannot use :ref:`interactive transactions <txn_mode_interactive_transaction>`.

*   Any fiber yield leads to the abort of a transaction.

*   All changes are made immediately, but in the event of a yield or error, 
    the transaction is rolled back, including the return of the previous data.


To learn how to enable yielding inside a :ref:`memtx <engines-chapter>` transaction, see :ref:`Transaction mode: MVCC <txn_mode_transaction-manager>`.

To switch back to the default mode, disable the transaction manager:

..  code-block:: lua

    box.cfg { memtx_use_mvcc_engine = false }



