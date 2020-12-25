.. _box_schema-role_revoke:

===============================================================================
box.schema.role.revoke()
===============================================================================

.. module:: box.schema

.. function:: box.schema.role.revoke(role-name, privilege, object-type, object-name)

    Revoke :ref:`privileges <authentication-owners_privileges>` from a role.

    :param string role-name: the name of the role.
    :param string privilege: 'read' or 'write' or 'execute' or 'create' or
                             'alter' or 'drop' or a combination.
    :param string object-type: 'space' or 'function' or 'sequence' or 'role'.
    :param string object-name: the name of a function or space or sequence or role.

    The role must exist, and the object must exist,
    but it is not an error if the role does not have the privilege.

    **Variation:** instead of ``object-type, object-name`` say 'universe'
    which means 'all object-types and all objects'.

    **Variation:** instead of ``privilege, object-type, object-name`` say
    ``role-name``.

    **Example:**

    .. code-block:: lua

        box.schema.role.revoke('Accountant', 'read', 'space', 'tester')
        box.schema.role.revoke('Accountant', 'execute', 'function', 'f')
        box.schema.role.revoke('Accountant', 'read,write', 'universe')
        box.schema.role.revoke('public', 'Accountant')
