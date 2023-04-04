.. _box_index:

-------------------------------------------------------------------------------
Submodule box.index
-------------------------------------------------------------------------------

The ``box.index`` submodule provides read-only access for index definitions and
index keys. Indexes are contained in :samp:`box.space.{space-name}.index` array
within each space object. They provide an API for ordered iteration over tuples.
This API is a direct binding to corresponding methods of index objects of type
``box.index`` in the storage engine.

Below is a list of all ``box.index`` functions and members.

..  container:: table

    ..  rst-class:: left-align-column-1
    ..  rst-class:: left-align-column-2

    ..  list-table::
        :widths: 25 75
        :header-rows: 1

        *   - Name
            - Use

        *  - :doc:`./box_index/examples`
           - Some useful examples

        *  - :doc:`./box_space/create_index`
           - Create an index

        *  - :doc:`./box_index/unique`
           - Flag, true if an index is unique

        *  - :doc:`./box_index/type`
           - Index type

        *  - :doc:`./box_index/parts`
           - Array of index key fields

        *  - :doc:`./box_index/pairs`
           - Prepare for iterating

        *  - :doc:`./box_index/select`
           - Select one or more tuples via index

        *  - :doc:`./box_index/get`
           - Select a tuple via index

        *  - :doc:`./box_index/min`
           - Find the minimum value in index

        *  - :doc:`./box_index/max`
           - Find the maximum value in index

        *  - :doc:`./box_index/random`
           - Find a random value in index

        *  - :doc:`./box_index/count`
           - Count tuples matching key value

        *  - :doc:`./box_index/update`
           - Update a tuple

        *  - :doc:`./box_index/delete`
           - Delete a tuple by key

        *  - :doc:`./box_index/alter`
           - Alter an index

        *  - :doc:`./box_index/drop`
           - Drop an index

        *  - :doc:`./box_index/rename`
           - Rename an index

        *  - :doc:`./box_index/bsize`
           - Get count of bytes for an index

        *  - :doc:`./box_index/stat`
           - Get statistics for an index

        *  - :doc:`./box_index/compact`
           - Remove unused index space

        *  - :doc:`./box_index/tuple_pos`
           - Return a tuple's position for an index

        *  - :doc:`./box_index/user_defined`
           - Any function / method that any user wants to add

..  toctree::
    :hidden:

    box_index/examples
    box_space/create_index
    box_index/unique
    box_index/type
    box_index/parts
    box_index/pairs
    box_index/select
    box_index/get
    box_index/min
    box_index/max
    box_index/random
    box_index/count
    box_index/update
    box_index/delete
    box_index/alter
    box_index/drop
    box_index/rename
    box_index/bsize
    box_index/stat
    box_index/tuple_pos
    box_index/compact
    box_index/user_defined
