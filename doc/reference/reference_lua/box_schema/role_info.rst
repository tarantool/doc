.. _box_schema-role_info:

===============================================================================
box.schema.role.info()
===============================================================================

.. module:: box.schema

.. function:: box.schema.role.info(role-name)

    Return a description of a role's privileges.

    :param string role-name: the name of the role.

    **Example:**

    .. code-block:: lua

        box.schema.role.info('Accountant')
