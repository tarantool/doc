.. _box_schema-role_grant:

===============================================================================
box.schema.role.grant()
===============================================================================

.. module:: box.schema

.. function:: box.schema.role.grant(role-name, privilege, object-type, object-name [, option])
              box.schema.role.grant(role-name, privilege, 'universe' [, nil, option])
              box.schema.role.grant(role-name, role-name [, nil, nil, option])

    Grant :ref:`privileges <authentication-owners_privileges>` to a role.

    :param string role-name: the name of the role.
    :param string privilege: 'read' or 'write' or 'execute' or 'create' or
                             'alter' or 'drop' or a combination.
    :param string object-type: 'space' or 'function' or 'sequence' or 'role'.
    :param string object-name: the name of a function or space or sequence or role.
    :param table option: ``if_not_exists`` = ``true|false`` (default = ``false``) - boolean;
                         ``true`` means there should be no error if the role already
                         has the privilege.

    The role must exist, and the object must exist.

    **Variation:** instead of ``object-type, object-name`` say 'universe'
    which means 'all object-types and all objects'. In this case, object name is omitted.

    **Variation:** instead of ``privilege, object-type, object-name`` say
    ``role-name`` -- to grant a role to a role.

    **Example:**

    .. code-block:: lua

        box.schema.role.grant('Accountant', 'read', 'space', 'tester')
        box.schema.role.grant('Accountant', 'execute', 'function', 'f')
        box.schema.role.grant('Accountant', 'read,write', 'universe')
        box.schema.role.grant('public', 'Accountant')
        box.schema.role.grant('role1', 'role2', nil, nil, {if_not_exists=false})
