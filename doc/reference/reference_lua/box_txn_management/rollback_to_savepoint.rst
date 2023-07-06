.. _box-rollback_to_savepoint:

================================================================================
box.rollback_to_savepoint()
================================================================================

.. function:: box.rollback_to_savepoint(savepoint)

    Do not end the transaction, but cancel all its data-change
    and :ref:`box.savepoint() <box-savepoint>` operations that were done after
    the specified savepoint.

    :return: error if the savepoint cannot be set in absence of active
             transaction.

    **Possible errors:** error if the savepoint does not exist.

    **Example**

    ..  literalinclude:: /code_snippets/test/transactions/box_rollback_savepoint_test.lua
        :language: lua
        :lines: 29-40
        :dedent:
