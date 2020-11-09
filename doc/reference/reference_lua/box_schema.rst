.. _box_schema:

-------------------------------------------------------------------------------
                             Submodule `box.schema`
-------------------------------------------------------------------------------

.. module:: box.schema

===============================================================================
                                   Overview
===============================================================================

The ``box.schema`` submodule has data-definition functions
for spaces, users, roles, function tuples, and sequences.

===============================================================================
                                    Index
===============================================================================

Below is a list of all ``box.schema`` functions.

.. container:: table

    .. rst-class:: left-align-column-1
    .. rst-class:: left-align-column-2

    +--------------------------------------+---------------------------------+
    | Name                                 | Use                             |
    +======================================+=================================+
    | :ref:`box.schema.space.create()      | Create a space                  |
    | <box_schema-space_create>` or        |                                 |
    | :ref:`box.schema.create_space()      |                                 |
    | <box_schema-space_create>`           |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`box.schema.upgrade             | Upgrade a database              |
    | <admin-upgrades>`                    |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`box.schema.user.create()       | Create a user                   |
    | <box_schema-user_create>`            |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`box.schema.user.drop()         | Drop a user                     |
    | <box_schema-user_drop>`              |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`box.schema.user.exists()       | Check if a user exists          |
    | <box_schema-user_exists>`            |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`box.schema.user.grant()        | Grant privileges to a user or   |
    | <box_schema-user_grant>`             | a role                          |
    +--------------------------------------+---------------------------------+
    | :ref:`box.schema.user.revoke()       | Revoke privileges from a user   |
    | <box_schema-user_revoke>`            | or a role                       |
    +--------------------------------------+---------------------------------+
    | :ref:`box.schema.user.password()     | Get a hash of a user's password |
    | <box_schema-user_password>`          |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`box.schema.user.passwd()       | Associate a password with       |
    | <box_schema-user_passwd>`            | a user                          |
    +--------------------------------------+---------------------------------+
    | :ref:`box.schema.user.info()         | Get a description of a user's   |
    | <box_schema-user_info>`              | privileges                      |
    +--------------------------------------+---------------------------------+
    | :ref:`box.schema.role.create()       | Create a role                   |
    | <box_schema-role_create>`            |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`box.schema.role.drop()         | Drop a role                     |
    | <box_schema-role_drop>`              |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`box.schema.role.exists()       | Check if a role exists          |
    | <box_schema-role_exists>`            |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`box.schema.role.grant()        | Grant privileges to a role      |
    | <box_schema-role_grant>`             |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`box.schema.role.revoke()       | Revoke privileges from a role   |
    | <box_schema-role_revoke>`            |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`box.schema.role.info()         | Get a description of a role's   |
    | <box_schema-role_info>`              | privileges                      |
    +--------------------------------------+---------------------------------+
    | :ref:`box.schema.func.create()       | Create a function tuple         |
    | <box_schema-func_create>`            |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`box.schema.func.drop()         | Drop a function tuple           |
    | <box_schema-func_drop>`              |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`box.schema.func.exists()       | Check if a function tuple       |
    | <box_schema-func_exists>`            | exists                          |
    +--------------------------------------+---------------------------------+
    | :ref:`box.schema.func.reload()       | Reload a C module with all its  |
    | <box_schema-func_reload>`            | functions, no restart           |
    +--------------------------------------+---------------------------------+
    | :ref:`box.schema.sequence.create()   | Create a new sequence generator |
    | <box_schema-sequence_create>`        |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`sequence_object:next()         | Generate and return the next    |
    | <box_schema-sequence_next>`          | value                           |
    +--------------------------------------+---------------------------------+
    | :ref:`sequence_object:alter()        | Change sequence options         |
    | <box_schema-sequence_alter>`         |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`sequence_object:reset()        | Reset sequence state            |
    | <box_schema-sequence_reset>`         |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`sequence_object:set()          | Set the new value               |
    | <box_schema-sequence_set>`           |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`sequence_object:drop()         | Drop the sequence               |
    | <box_schema-sequence_drop>`          |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`space_object:create_index()    | Create an index                 |
    | <box_schema-sequence_create_index>`  |                                 |
    +--------------------------------------+---------------------------------+

.. toctree::
    :hidden:

    box_schema/box_schema_space_create
    box_schema/box_schema_upgrade
    box_schema/box_schema_user_create
    box_schema/box_schema_user_drop
    box_schema/box_schema_user_exists
    box_schema/box_schema_user_grant
    box_schema/box_schema_user_revoke
    box_schema/box_schema_user_password
    box_schema/box_schema_user_passwd
    box_schema/box_schema_user_info
    box_schema/box_schema_role_create
    box_schema/box_schema_role_drop
    box_schema/box_schema_role_exists
    box_schema/box_schema_role_grant
    box_schema/box_schema_role_revoke
    box_schema/box_schema_role_info
    box_schema/box_schema_func_create
    box_schema/box_schema_func_drop
    box_schema/box_schema_func_exists
    box_schema/box_schema_func_reload
    box_schema/box_schema_sequences
    box_schema/box_schema_sequence_create
    box_schema/box_schema_sequence_next
    box_schema/box_schema_sequence_alter
    box_schema/box_schema_sequence_reset
    box_schema/box_schema_sequence_set
    box_schema/box_schema_sequence_drop
    box_schema/box_schema_sequence_create_index
