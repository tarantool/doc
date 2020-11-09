.. _box_space:

-------------------------------------------------------------------------------
                             Submodule `box.space`
-------------------------------------------------------------------------------

===============================================================================
                                   Overview
===============================================================================

**CRUD operations** in Tarantool are implemented by the ``box.space`` submodule.
It has the data-manipulation functions ``select``, ``insert``, ``replace``,
``update``, ``upsert``, ``delete``, ``get``, ``put``. It also has members,
such as id, and whether or not a space is enabled. Submodule source code
is available in file
`src/box/lua/schema.lua <https://github.com/tarantool/tarantool/blob/1.7/src/box/lua/schema.lua>`_.

===============================================================================
                                    Index
===============================================================================

Below is a list of all ``box.space`` functions and members.

.. container:: table

    .. rst-class:: left-align-column-1
    .. rst-class:: left-align-column-2

    +--------------------------------------+---------------------------------+
    | Name                                 | Use                             |
    +======================================+=================================+
    | :ref:`space_object:auto_increment()  | Generate key + Insert a tuple   |
    | <box_space-auto_increment>`          |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`space_object:bsize()           | Get count of bytes              |
    | <box_space-bsize>`                   |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`space_object:count()           | Get count of tuples             |
    | <box_space-count>`                   |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`space_object:create_index()    | Create an index                 |
    | <box_space-create_index>`            |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`space_object:delete()          | Delete a tuple                  |
    | <box_space-delete>`                  |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`space_object:drop()            | Destroy a space                 |
    | <box_space-drop>`                    |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`space_object:format()          | Declare field names and types   |
    | <box_space-format>`                  |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`space_object:frommap()         | Convert from map to tuple or    |
    | <box_space-frommap>`                 | table                           |
    +--------------------------------------+---------------------------------+
    | :ref:`space_object:get()             | Select a tuple                  |
    | <box_space-get>`                     |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`space_object:insert()          | Insert a tuple                  |
    | <box_space-insert>`                  |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`space_object:len()             | Get count of tuples             |
    | <box_space-len>`                     |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`space_object:on_replace()      | Create a replace trigger        |
    | <box_space-on_replace>`              | with a function that cannot     |
    |                                      | change the tuple                |
    +--------------------------------------+---------------------------------+
    | :ref:`space_object:before_replace()  | Create a replace trigger        |
    | <box_space-before_replace>`          | with a function that can        |
    |                                      | change the tuple                |
    +--------------------------------------+---------------------------------+
    | :ref:`space_object:pairs()           | Prepare for iterating           |
    | <box_space-pairs>`                   |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`space_object:put()             | Insert or replace a tuple       |
    | <box_space-replace>`                 |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`space_object:rename()          | Rename a space                  |
    | <box_space-rename>`                  |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`space_object:replace()         | Insert or replace a tuple       |
    | <box_space-replace>`                 |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`space_object:run_triggers()    | Enable/disable a replace        |
    | <box_space-run_triggers>`            | trigger                         |
    +--------------------------------------+---------------------------------+
    | :ref:`space_object:select()          | Select one or more tuples       |
    | <box_space-select>`                  |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`space_object:truncate()        | Delete all tuples               |
    | <box_space-truncate>`                |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`space_object:update()          | Update a tuple                  |
    | <box_space-update>`                  |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`space_object:upsert()          | Update a tuple                  |
    | <box_space-upsert>`                  |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`space_object:user_defined()    | Any function / method that any  |
    | <box_space-user_defined>`            | user wants to add               |
    +--------------------------------------+---------------------------------+
    | :ref:`space_object.enabled           | Flag, true if space is enabled  |
    | <box_space-enabled>`                 |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`space_object.field_count       | Required number of fields       |
    | <box_space-field_count>`             |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`space_object.id                | Numeric identifier of space     |
    | <box_space-id>`                      |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`space_object.index             | Container of space's indexes    |
    | <box_space-space_index>`             |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`box.space._cluster             | (Metadata) List of replica sets |
    | <box_space-cluster>`                 |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`box.space._func                | (Metadata) List of function     |
    | <box_space-func>`                    | tuples                          |
    +--------------------------------------+---------------------------------+
    | :ref:`box.space._index               | (Metadata) List of indexes      |
    | <box_space-index>`                   |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`box.space._vindex              | (Metadata) List of indexes      |
    | <box_space-vindex>`                  | accessible for the current user |
    +--------------------------------------+---------------------------------+
    | :ref:`box.space._priv                | (Metadata) List of privileges   |
    | <box_space-priv>`                    |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`box.space._vpriv               | (Metadata) List of privileges   |
    | <box_space-vpriv>`                   | accessible for the current user |
    +--------------------------------------+---------------------------------+
    | :ref:`box.space._schema              | (Metadata) List of schemas      |
    | <box_space-schema>`                  |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`box.space._sequence            | (Metadata) List of sequences    |
    | <box_space-sequence>`                |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`box.space._sequence_data       | (Metadata) List of sequences    |
    | <box_space-sequence_data>`           |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`box.space._space               | (Metadata) List of spaces       |
    | <box_space-space>`                   |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`box.space._vspace              | (Metadata) List of spaces       |
    | <box_space-vspace>`                  | accessible for the current user |
    +--------------------------------------+---------------------------------+
    | :ref:`box.space._user                | (Metadata) List of users        |
    | <box_space-user>`                    |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`box.space._vuser               | (Metadata) List of users        |
    | <box_space-vuser>`                   | accessible for the current user |
    +--------------------------------------+---------------------------------+

.. toctree::
    :hidden:

    box_space/box_space_auto_increment
    box_space/box_space_bsize
    box_space/box_space_count
    box_space/box_space_create_index
    box_space/box_space_delete
    box_space/box_space_drop
    box_space/box_space_format
    box_space/box_space_frommap
    box_space/box_space_get
    box_space/box_space_insert
    box_space/box_space_len
    box_space/box_space_on_replace
    box_space/box_space_before_replace
    box_space/box_space_pairs
    box_space/box_space_put
    box_space/box_space_rename
    box_space/box_space_replace
    box_space/box_space_run_triggers
    box_space/box_space_select
    box_space/box_space_truncate
    box_space/box_space_update
    box_space/box_space_upsert
    box_space/box_space_user_defined
    box_space/box_space_enabled
    box_space/box_space_field_count
    box_space/box_space_id
    box_space/box_space_index
    box_space/box_space__cluster
    box_space/box_space__func
    box_space/box_space__index
    box_space/box_space__vindex
    box_space/box_space__priv
    box_space/box_space__vpriv
    box_space/box_space__schema
    box_space/box_space__sequence
    box_space/box_space__sequence_data
    box_space/box_space__space
    box_space/box_space__vspace
    box_space/box_space__user
    box_space/box_space__vuser
    box_space/box_space_examples
