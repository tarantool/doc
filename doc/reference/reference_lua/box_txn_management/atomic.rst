.. _box-atomic:

================================================================================
box.atomic()
================================================================================

.. function:: box.atomic(tx-function [, function-arguments])

    Execute a function, acting as if the function starts with an implicit
    :doc:`/reference/reference_lua/box_txn_management/begin` and ends with an implicit
    :doc:`/reference/reference_lua/box_txn_management/commit` if successful, or ends with an implicit
    :doc:`/reference/reference_lua/box_txn_management/rollback` if there is an error.

    :return: the result of the function passed to ``atomic()`` as an argument.

    **Possible errors:**

    * error and abort the transaction in case of a conflict.
    * error if the operation fails to write to disk.
    * error if for some reason memory cannot be allocated.

    **Example**

    ..  literalinclude:: /code_snippets/test/transactions/box_atomic_test.lua
        :language: lua
        :lines: 29-38
        :dedent:
