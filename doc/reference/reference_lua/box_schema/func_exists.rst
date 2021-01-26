.. _box_schema-func_exists:

===============================================================================
box.schema.func.exists()
===============================================================================

.. module:: box.schema

.. function:: box.schema.func.exists(func-name)

    Return true if a function tuple exists; return false if a function tuple
    does not exist.

    :param string func-name: the name of the function
    :rtype: bool

    **Example:**

    .. code-block:: lua

        box.schema.func.exists('calculate')
