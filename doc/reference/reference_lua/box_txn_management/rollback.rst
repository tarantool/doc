.. _box-rollback:

================================================================================
box.rollback()
================================================================================

.. function:: box.rollback()

    End the transaction, but cancel all its data-change operations.
    An explicit call to functions outside ``box.space`` that always
    yield, such as :ref:`fiber.sleep() <fiber-sleep>` or
    :ref:`fiber.yield() <fiber-yield>`, will have the same effect.

    **Example**

    ..  literalinclude:: /code_snippets/test/transactions/box_rollback_test.lua
        :language: lua
        :lines: 29-38
        :dedent:
