===========================================================
                    Module `txn`
===========================================================

.. c:function:: bool box_txn(void)

    Return true if there is an active transaction.

.. c:function:: int box_txn_begin(void)

    Begin a transaction in the current fiber.

    A transaction is attached to caller fiber, therefore one fiber can have
    only one active transaction.

    :return: 0 on success
    :return: -1 on error. Perhaps a transaction has already been started

.. c:function:: int box_txn_commit(void)

    Commit the current transaction.

    :return: 0 on success
    :return: -1 on error. Perhaps a disk write failure

.. c:function:: void box_txn_rollback(void)

    Rollback the current transaction.

.. c:function:: void *box_txn_alloc(size_t size)

    Allocate memory on txn memory pool.

    The memory is automatically deallocated when the transaction is committed
    or rolled back.

    :return: NULL on out of memory
