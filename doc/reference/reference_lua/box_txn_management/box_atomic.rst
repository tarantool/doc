.. _box-atomic:

================================================================================
box.atomic()
================================================================================

.. function:: box.atomic(tx-function [, function-arguments])

    Execute a function, acting as if the function starts with an implicit
    :ref:`box.begin() <box-begin>` and ends with an implicit
    :ref:`box.commit() <box-commit>` if successful, or ends with an implicit
    :ref:`box.rollback() <box-rollback>` if there is an error.

    :return: the result of the function passed to ``atomic()`` as an argument.

    **Possible errors:** any error that :ref:`box.begin() <box-begin>` and
                        :ref:`box.commit() <box-commit>` can return.