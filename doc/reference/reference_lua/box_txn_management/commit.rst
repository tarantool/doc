.. _box-commit:

================================================================================
box.commit()
================================================================================

.. function:: box.commit()

    End the transaction, and make all its data-change operations permanent.

    **Possible errors:**

    * error and abort the transaction in case of a conflict.
    * error if the operation fails to write to disk.
    * error if for some reason memory cannot be allocated.

    **Example**

    ..  literalinclude:: /code_snippets/test/transactions/box_commit_test.lua
        :language: lua
        :lines: 29-38
        :dedent:
