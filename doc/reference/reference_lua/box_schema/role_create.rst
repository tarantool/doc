.. _box_schema-role_create:

===============================================================================
box.schema.role.create()
===============================================================================

.. module:: box.schema

.. function:: box.schema.role.create(role-name [, {options}])

    Create a role.
    For explanation of how Tarantool maintains role data, see
    section :ref:`Roles <authentication-roles>`.

    :param string role-name: name of role, which should
                             conform to the :ref:`rules for object names <app_server-names>`
    :param table options: ``if_not_exists`` = ``true|false`` (default = ``false``) - boolean;
                          ``true`` means there should be no error if the
                          role already exists

    :return: nil

    **Example:**

    ..  literalinclude:: /code_snippets/test/access_control/grant_roles_test.lua
        :language: lua
        :start-after: Create roles
        :end-before: End: Create roles
        :dedent:

    See also: :ref:`access_control_roles`.
