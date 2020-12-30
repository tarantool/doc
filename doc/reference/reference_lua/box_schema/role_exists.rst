.. _box_schema-role_exists:

===============================================================================
box.schema.role.exists()
===============================================================================

.. module:: box.schema

.. function:: box.schema.role.exists(role-name)

    Return ``true`` if a role exists; return ``false`` if a role does not exist.

    :param string role-name: the name of the role
    :rtype: bool

    **Example:**

    .. code-block:: lua

        box.schema.role.exists('Accountant')
