.. _box-savepoint:

================================================================================
box.savepoint()
================================================================================

.. function:: box.savepoint()

    Return a descriptor of a savepoint (type = table), which can be used later
    by :doc:`box.rollback_to_savepoint(savepoint) </reference/reference_lua/box_txn_management/rollback_to_savepoint>`.
    Savepoints can only be created while a transaction is active, and they are
    destroyed when a transaction ends.

    :return: savepoint table
    :rtype:  Lua object

    :return: error if the savepoint cannot be set in absence of active
             transaction.

    **Possible errors:** error if for some reason memory cannot be allocated.

    **Example**

    ..  literalinclude:: /code_snippets/test/transactions/box_rollback_savepoint_test.lua
        :language: lua
        :lines: 29-40
        :dedent:
