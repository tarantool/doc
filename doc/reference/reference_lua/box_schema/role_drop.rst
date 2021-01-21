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

    .. code-block:: lua

        box.schema.role.drop('Accountant')
