.. _box-on_rollback:

================================================================================
box.on_rollback()
================================================================================

.. function:: box.on_rollback(trigger-function [, old-trigger-function])

    Define a trigger for execution when a transaction ends due to an event
    such as :doc:`/reference/reference_lua/box_txn_management/rollback`.

    The parameters and warnings are exactly the same as for
    :doc:`/reference/reference_lua/box_txn_management/on_commit`.