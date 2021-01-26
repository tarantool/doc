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

    **Example:**

    .. code-block:: lua

        function f()
          box.begin()           -- start transaction
          box.space.t:insert{1} -- this will not be rolled back
          local s = box.savepoint()
          box.space.t:insert{2} -- this will be rolled back
          box.rollback_to_savepoint(s)
          box.commit()          -- end transaction
        end
