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

.. toctree::
    :maxdepth: 1
    :numbered: 0

    index_object.unique - Flag, true if an index is unique <box_index/box_index_unique>
    index_obect.type - Index type <box_index/box_index_type>
    index_obect.parts - Array of index key fields <box_index/box_index_parts>
    index_object.pairs() - Prepare for iterating <box_index/box_index_pairs>
    index_object.select() - Select one or more tuples via index <box_index/box_index_select>
    index_object.get() - Select a tuple via index <box_index/box_index_get>
    index_object.min() - Find the minimum value in index <box_index/box_index_min>
    index_object.max() - Find the maximum value in index <box_index/box_index_max>
    index_object.random() - Find a random value in index <box_index/box_index_random>
    index_object.count() - Count tuples matching key value <box_index/box_index_count>
    index_object.update() - Update a tuple <box_index/box_index_update>
    index_object.delete() - Delete a tuple by key <box_index/box_index_delete>
    index_object.alter() - Alter an index <box_index/box_index_alter>
    index_object.drop() - Drop an index <box_index/box_index_drop>
    index_object.rename() - Rename an index <box_index/box_index_rename>
    index_object.bsize() - Get count of bytes for an index <box_index/box_index_bsize>
    index_object.stat() - Get statistics for an index <box_index/box_index_stat>
    index_object.compact() - Remove unused index space <box_index/box_index_compact>
    index_object.user_defined() - Any function / method that any user wants to add <box_index/box_index_user_defined>
    box_index/box_index_examples
