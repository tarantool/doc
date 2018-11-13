===========================================================
                    Module `txn`
===========================================================

.. c:function:: bool box_txn(void)

    Return true if there is an active transaction.

.. _txn-box_txn_begin:

.. c:function:: int box_txn_begin(void)

    Begin a transaction in the current fiber.

    A transaction is attached to caller fiber, therefore one fiber can have
    only one active transaction. See also :ref:`box.begin()<box-begin>`.

    :return: 0 on success
    :return: -1 on error. Perhaps a transaction has already been started.

.. _txn-box_txn_commit:

.. c:function:: int box_txn_commit(void)

    Commit the current transaction. See also :ref:`box.commit() <box-commit>`.

    :return: 0 on success
    :return: -1 on error. Perhaps a disk write failure

.. c:function:: void box_txn_rollback(void)

    Roll back the current transaction. See also :ref:`box.rollback() <box-rollback>`.

.. c:function:: box_txn_savepoint_t * savepoint(void)

    Return a descriptor of a savepoint.

.. c:function:: void box_txn_rollback_to_savepoint(box_txn_savepoint_t *savepoint)

    Roll back the current transaction as far as the specified savepoint.

.. c:function:: void *box_txn_alloc(size_t size)

    Allocate memory on txn memory pool.

    The memory is automatically deallocated when the transaction is committed
    or rolled back.

    :return: NULL on out of memory
