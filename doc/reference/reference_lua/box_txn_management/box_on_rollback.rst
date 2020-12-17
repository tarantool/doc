.. _box-on_rollback:

================================================================================
box.on_rollback()
================================================================================

.. function:: box.on_rollback(trigger-function [, old-trigger-function])

    Define a trigger for execution when a transaction ends due to an event
    such as :ref:`box.rollback <box-rollback>`.

    The parameters and warnings are exactly the same as for
    :ref:`box.on_commit <box-on_commit>`.