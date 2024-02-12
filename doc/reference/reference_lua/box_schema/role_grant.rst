.. _box_schema-role_grant:

===============================================================================
box.schema.role.grant()
===============================================================================

.. module:: box.schema

.. function:: box.schema.role.grant(role-name, privilege, object-type, object-name [, option])
              box.schema.role.grant(role-name, privilege, 'universe' [, nil, option])
              box.schema.role.grant(role-name, role-name [, nil, nil, option])

    Grant :ref:`privileges <authentication-owners_privileges>` to a role.

    :param string role-name: the name of the role
    :param string privilege: one or more :ref:`privileges <access_control_list_privileges>` to grant to the role (for example, ``read`` or ``read,write``)
    :param string object-type: a database :ref:`object type <access_control_list_objects>` to grant privileges to (for example, ``space``, ``role``, or ``function``)
    :param string object-name: the name of a function or space or sequence or role
    :param table option: ``if_not_exists`` = ``true|false`` (default = ``false``) - boolean;
                         ``true`` means there should be no error if the role already
                         has the privilege

    The role must exist, and the object must exist.

    **Variation:** instead of ``object-type, object-name`` say ``universe``
    which means 'all object-types and all objects'. In this case, object name is omitted.

    **Variation:** instead of ``privilege, object-type, object-name`` say
    ``role-name`` -- to grant a role to a role.

    **Example:**

    ..  literalinclude:: /code_snippets/test/access_control/grant_roles_test.lua
        :language: lua
        :start-after: Grant read/write privileges to a role
        :end-before: Grant write privileges to a role
        :dedent:

    See also: :ref:`access_control_roles`.
