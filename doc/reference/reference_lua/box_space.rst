:fullwidth:

.. _box_space:

-------------------------------------------------------------------------------
                             Submodule box.space
-------------------------------------------------------------------------------

**CRUD operations** in Tarantool are implemented by the ``box.space`` submodule.
It has the data-manipulation functions ``select``, ``insert``, ``replace``,
``update``, ``upsert``, ``delete``, ``get``, ``put``. It also has members,
such as id, and whether or not a space is enabled.

..  WARNING::

    Option 1 global Warning:
    The following operations involve full space traversal:

    - :doc:`./box_space/create_index`;
    - :doc:`./box_space/alter`;
    - :doc:`./box_space/format`.

    Full traversal is the process of processing every node or element in the space structure exactly once
    in a systematic manner. Full traversal may leadThese operations introduce replication lag for both 
    synchronous and asynchronous replication and make writes with synchronous replication unavailable
    for the whole duration of operation when initiated at the following conditions:

    - initiated on a space with over 10000 tuples AND
    - when the node is under any load (when it processes user requests/performs business operations).

    To avoid issues:

    - initiate named operations on spaces that do not exceed 10000 tuples OR 
    - initiate named operations when the node is not under any load;
    - instead of the space format change operation, perform the :ref:`box_space-upgrade` operation.

    Safe exceptions for named operations are:

    - changing indexed field type to a more generic one («unsigned» to «number», «decimal» to «scalar»); 
    - turning a unique index into a non-unique one; 
    - changing some of the index parameters which do not require a rebuild (changing page_size of a vinyl space index).
    - changing space format to a more generic one.

    Option 2 global Warning:
    The following operations involve full space traversal and introduce replication lag for both synchronous 
    and asynchronous replication and make writes with synchronous replication unavailable for the whole duration 
    of operation when initiated at certain conditions:

    - :doc:`./box_space/create_index`;
    - :doc:`./box_space/alter`;
    - :doc:`./box_space/format`.

    The issues occur when the operations are initiated at the following conditions:

    - initiated on a space with over 10000 tuples AND
    - when the node is under any load (when it processes user requests/performs business operations).

    To avoid issues:

    - initiate named operations on spaces that do not exceed 10000 tuples OR 
    - initiate named operations when the node is not under any load;
    - instead of the space format change operation, perform the :ref:`box_space-upgrade` operation.

    Safe exceptions for named operations are:
    - changing indexed field type to a more generic one («unsigned» to «number», «decimal» to «scalar»); 
    - turning a unique index into a non-unique one; 
    - changing some of the index parameters which do not require a rebuild (changing page_size of a vinyl space index).
    - changing space format to a more generic one.

Below is a list of all ``box.space`` functions and members.

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

        *  - :doc:`./box_space/alter`
           - Alter a space

        *  - :doc:`./box_space/auto_increment`
           - Generate key + Insert a tuple

        *  - :doc:`./box_space/bsize`
           - Get count of bytes

        *  - :doc:`./box_space/count`
           - Get count of tuples

        *  - :doc:`./box_space/create_index`
           - 	Create an index

        *  - :doc:`./box_space/delete`
           - Delete a tuple

        *  - :doc:`./box_space/drop`
           - 	Destroy a space

        *  - :doc:`./box_space/format`
           - Declare field names and types

        *  - :doc:`./box_space/frommap`
           - Convert from map to tuple or table

        *  - :doc:`./box_space/get`
           - Select a tuple

        *  - :doc:`./box_space/insert`
           - Insert a tuple

        *  - :doc:`./box_space/len`
           - Get count of tuples

        *  - :doc:`./box_space/on_replace`
           - Create a replace trigger with a function that cannot change the tuple

        *  - :doc:`./box_space/before_replace`
           - Create a replace trigger with a function that can change the tuple

        *  - :doc:`./box_space/pairs`
           - Prepare for iterating

        *  - :doc:`./box_space/put`
           - Insert or replace a tuple

        *  - :doc:`./box_space/rename`
           - Rename a space

        *  - :doc:`./box_space/replace`
           - Insert or replace a tuple

        *  - :doc:`./box_space/run_triggers`
           - Enable/disable a replace trigger

        *  - :doc:`./box_space/select`
           - Select one or more tuples

        *  - :doc:`./box_space/stat`
           - Get statistics on memory usage

        *  - :doc:`./box_space/truncate`
           - Delete all tuples

        *  - :doc:`./box_space/update`
           - Update a tuple

        *  - :ref:`box_space-upgrade`
           - Upgrade the space format and tuples

        *  - :doc:`./box_space/upsert`
           - Update a tuple

        *  - :doc:`./box_space/user_defined`
           - Any function / method that any user wants to add

        *  - :doc:`./box_space/create_check_constraint`
           - Create a check constraint

        *  - :doc:`./box_space/enabled`
           - Flag, true if space is enabled

        *  - :doc:`./box_space/field_count`
           - Required number of fields

        *  - :doc:`./box_space/id`
           - Numeric identifier of space

        *  - :doc:`./box_space/index_data`
           - Container of space's indexes

        *  - :doc:`./box_space/_cluster`
           - (Metadata) List of replica sets

        *  - :doc:`./box_space/_func`
           - (Metadata) List of function tuples

        *  - :doc:`./box_space/_index`
           - (Metadata) List of indexes

        *  - :doc:`./box_space/_vindex`
           - (Metadata) List of indexes accessible for the current user

        *  - :doc:`./box_space/_priv`
           - (Metadata) List of privileges

        *  - :doc:`./box_space/_vpriv`
           - (Metadata) List of privileges accessible for the current user

        *  - :doc:`./box_space/_schema`
           - (Metadata) List of schemas

        *  - :doc:`./box_space/_sequence`
           - (Metadata) List of sequences

        *  - :doc:`./box_space/_sequence_data`
           - (Metadata) List of sequences

        *  - :doc:`./box_space/_space`
           - (Metadata) List of spaces

        *  - :doc:`./box_space/_vspace`
           - (Metadata) List of spaces accessible for the current user

        *  - :doc:`./box_space/_space_sequence`
           - (Metadata) List of connections between spaces and sequences

        *  - :doc:`./box_space/_vspace_sequence`
           - (Metadata) List of connections between spaces and sequences accessible
             for the current user

        *  - :doc:`./box_space/_user`
           - (Metadata) List of users

        *  - :doc:`./box_space/_vuser`
           - (Metadata) List of users accessible for the current user

        *  - :doc:`./box_space/_ck_constraint`
           - (Metadata) List of check constraints

        *  - :doc:`./box_space/_collation`
           - (Metadata) List of collations

        *  - :doc:`./box_space/_vcollation`
           - (Metadata) List of collations accessible for the current user

        *  - :doc:`./box_space/system_views`
           - (Metadata) Spaces whose names begin with _v

        *  - :doc:`./box_space/_session_settings`
           - (Metadata) List of settings affecting behavior of the current session

To see examples, visit the :ref:`how-to guide on CRUD operations <box_space_examples>`.

.. toctree::
    :hidden:

    box_schema/space_create
    box_space/alter
    box_space/auto_increment
    box_space/bsize
    box_space/count
    box_space/create_index
    box_space/delete
    box_space/drop
    box_space/format
    box_space/frommap
    box_space/get
    box_space/insert
    box_space/len
    box_space/on_replace
    box_space/before_replace
    box_space/pairs
    box_space/put
    box_space/rename
    box_space/replace
    box_space/run_triggers
    box_space/select
    box_space/stat
    box_space/truncate
    box_space/update
    box_space/upsert
    box_space/user_defined
    box_space/create_check_constraint
    box_space/enabled
    box_space/field_count
    box_space/id
    box_space/index_data
    box_space/_cluster
    box_space/_func
    box_space/_index
    box_space/_vindex
    box_space/_priv
    box_space/_vpriv
    box_space/_schema
    box_space/_sequence
    box_space/_sequence_data
    box_space/_space
    box_space/_vspace
    box_space/_space_sequence
    box_space/_vspace_sequence
    box_space/_user
    box_space/_vuser
    box_space/_ck_constraint
    box_space/_collation
    box_space/_vcollation
    box_space/system_views
    box_space/_session_settings
