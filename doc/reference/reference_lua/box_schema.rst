.. _box_schema:

-------------------------------------------------------------------------------
                             Submodule box.schema
-------------------------------------------------------------------------------

.. module:: box.schema

The ``box.schema`` submodule has data-definition functions
for spaces, users, roles, function tuples, and sequences.

Below is a list of all ``box.schema`` functions.

..  container:: table

    ..  rst-class:: left-align-column-1
    ..  rst-class:: left-align-column-2

    ..  list-table::
        :widths: 25 75
        :header-rows: 1

        *   - Name
            - Use

        *  - :doc:`./box_schema/space_create`
           - Create a space

        *  - :doc:`./box_schema/upgrade`
           - Upgrade a database

        *  - :doc:`./box_schema/downgrade`
           - Downgrade a database

        *  - :doc:`./box_schema/downgrade_issues`
           - List downgrade issues for the specified Tarantool version

        *  - :doc:`./box_schema/downgrade_versions`
           - List Tarantool versions available for downgrade

        *  - :doc:`./box_schema/user_create`
           - Create a user

        *  - :doc:`./box_schema/user_drop`
           - Drop a user

        *  - :doc:`./box_schema/user_exists`
           - Check if a user exists

        *  - :doc:`./box_schema/user_grant`
           - Grant privileges to a user or a role

        *  - :doc:`./box_schema/user_revoke`
           - Revoke privileges from a user or a role

        *  - :doc:`./box_schema/user_password`
           - Get a hash of a user's password

        *  - :doc:`./box_schema/user_passwd`
           - Associate a password with a user

        *  - :doc:`./box_schema/user_info`
           - Get a description of a user's privileges

        *  - :doc:`./box_schema/role_create`
           - Create a role

        *  - :doc:`./box_schema/role_drop`
           - Drop a role

        *  - :doc:`./box_schema/role_exists`
           - Check if a role exists

        *  - :doc:`./box_schema/role_grant`
           - Grant privileges to a role

        *  - :doc:`./box_schema/role_revoke`
           - Revoke privileges from a role

        *  - :doc:`./box_schema/role_info`
           - Get a description of a role's privileges

        *  - :doc:`./box_schema/func_create`
           - Create a function tuple

        *  - :doc:`./box_schema/func_drop`
           - Drop a function tuple

        *  - :doc:`./box_schema/func_exists`
           - Check if a function tuple exists

        *  - :doc:`./box_schema/func_reload`
           - Reload a C module with all its functions, no restart

.. toctree::
    :hidden:

    box_schema/space_create
    box_schema/upgrade
    box_schema/downgrade
    box_schema/downgrade_versions
    box_schema/downgrade_issues
    box_schema/user_create
    box_schema/user_drop
    box_schema/user_exists
    box_schema/user_grant
    box_schema/user_revoke
    box_schema/user_password
    box_schema/user_passwd
    box_schema/user_info
    box_schema/role_create
    box_schema/role_drop
    box_schema/role_exists
    box_schema/role_grant
    box_schema/role_revoke
    box_schema/role_info
    box_schema/func_create
    box_schema/func_drop
    box_schema/func_exists
    box_schema/func_reload
