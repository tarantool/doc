.. _box_schema-role_drop:

===============================================================================
box.schema.role.drop()
===============================================================================

.. module:: box.schema

.. function:: box.schema.role.drop(role-name [, {options}])

    Drop a role.
    For explanation of how Tarantool maintains role data, see
    section :ref:`Roles <authentication-roles>`.

    :param string role-name: the name of the role
    :param table options: ``if_exists`` = ``true|false`` (default = ``false``) - boolean;
                          ``true`` means there should be no error if the role does not exist.

    **Example:**

    ..  literalinclude:: /code_snippets/test/access_control/grant_roles_test.lua
        :language: lua
        :start-after: Dropping a role
        :end-before: End: Dropping a role
        :dedent:

    See also: :ref:`access_control_roles`.
