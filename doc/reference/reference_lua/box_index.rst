.. _box_index:

-------------------------------------------------------------------------------
Submodule `box.index`
-------------------------------------------------------------------------------

===============================================================================
Overview
===============================================================================

The ``box.index`` submodule provides read-only access for index definitions and
index keys. Indexes are contained in :samp:`box.space.{space-name}.index` array
within each space object. They provide an API for ordered iteration over tuples.
This API is a direct binding to corresponding methods of index objects of type
``box.index`` in the storage engine.

===============================================================================
Contents
===============================================================================

Below is a list of all ``box.index`` functions and members.

.. container:: table

    .. rst-class:: left-align-column-1
    .. rst-class:: left-align-column-2

    +--------------------------------------+---------------------------------+
    | Name                                 | Use                             |
    +======================================+=================================+
    | :ref:`index_object.unique            | Flag, true if an index is       |
    | <box_index-unique>`                  | unique                          |
    +--------------------------------------+---------------------------------+
    | :ref:`index_object.type              | Index type                      |
    | <box_index-type>`                    |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`index_object.parts             | Array of index key fields       |
    | <box_index-parts>`                   |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`index_object:pairs()           | Prepare for iterating           |
    | <box_index-pairs>`                   |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`index_object:select()          | Select one or more tuples       |
    | <box_index-select>`                  | via index                       |
    +--------------------------------------+---------------------------------+
    | :ref:`index_object:get()             | Select a tuple via index        |
    | <box_index-get>`                     |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`index_object:min()             | Find the minimum value in index |
    | <box_index-min>`                     |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`index_object:max()             | Find the maximum value in index |
    | <box_index-max>`                     |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`index_object:random()          | Find a random value in index    |
    | <box_index-random>`                  |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`index_object:count()           | Count tuples matching key value |
    | <box_index-count>`                   |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`index_object:update()          | Update a tuple                  |
    | <box_index-update>`                  |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`index_object:delete()          | Delete a tuple by key           |
    | <box_index-delete>`                  |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`index_object:alter()           | Alter an index                  |
    | <box_index-alter>`                   |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`index_object:drop()            | Drop an index                   |
    | <box_index-drop>`                    |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`index_object:rename()          | Rename an index                 |
    | <box_index-rename>`                  |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`index_object:bsize()           | Get count of bytes for an index |
    | <box_index-bsize>`                   |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`index_object:stat()            | Get statistics for an index     |
    | <box_index-stat>`                    |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`index_object:compact()         | Remove unused index space       |
    | <box_index-compact>`                 |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`index_object:user_defined()    | Any function / method that any  |
    | <box_index-user_defined>`            | user wants to add               |
    +--------------------------------------+---------------------------------+

.. toctree::
   :hidden:

    box_index/box_index_unique
    box_index/box_index_type
    box_index/box_index_parts
    box_index/box_index_pairs
    box_index/box_index_select
    box_index/box_index_get
    box_index/box_index_min
    box_index/box_index_max
    box_index/box_index_random
    box_index/box_index_count
    box_index/box_index_update
    box_index/box_index_delete
    box_index/box_index_alter
    box_index/box_index_drop
    box_index/box_index_rename
    box_index/box_index_bsize
    box_index/box_index_stat
    box_index/box_index_compact
    box_index/box_index_user_defined
    box_index/box_index_examples
