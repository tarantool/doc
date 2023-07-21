.. _box-atomic:

================================================================================
box.atomic()
================================================================================

.. function:: box.atomic([opts,] tx-function [, function-arguments])

    Execute a function, acting as if the function starts with an implicit
    :doc:`/reference/reference_lua/box_txn_management/begin` and ends with an implicit
    :doc:`/reference/reference_lua/box_txn_management/commit` if successful, or ends with an implicit
    :doc:`/reference/reference_lua/box_txn_management/rollback` if there is an error.

    :param table opts: (optional) transaction options:

                       *   ``txn_isolation`` -- the :ref:`transaction isolation level <txn_mode_mvcc-options>`
                       *   ``timeout`` -- a timeout (in seconds), after which the transaction is rolled back

    :param string tx-function: the function name

    :param function-arguments: (optional) arguments passed to the function

    :return: the result of the function passed to ``atomic()`` as an argument

    **Possible errors:**

    * error and abort the transaction in case of a conflict.
    * error and abort the transaction if the timeout is exceeded.
    * error if the operation fails to write to disk.
    * error if for some reason memory cannot be allocated.


    **Example**

    ..  literalinclude:: /code_snippets/test/transactions/box_atomic_test.lua
        :language: lua
        :lines: 28-47
        :dedent:
