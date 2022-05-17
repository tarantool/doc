.. _box_introspection-box_slab:

--------------------------------------------------------------------------------
Submodule box.slab
--------------------------------------------------------------------------------

The ``box.slab`` submodule provides access to slab allocator statistics. The
slab allocator is the main allocator used to store :ref:`tuples <index-box_tuple>`.
This can be used to monitor the total memory usage and memory fragmentation.

Below is a list of all ``box.slab`` functions.

..  container:: table

    ..  rst-class:: left-align-column-1
    ..  rst-class:: left-align-column-2

    ..  list-table::
        :widths: 25 75
        :header-rows: 1

        *   - Name
            - Use

        *  - :doc:`./box_slab/runtime_info`
           - Show a memory usage report for Lua runtime

        *  - :doc:`./box_slab/slab_info`
           - Show an aggregated memory usage report for slab allocator

        *  - :doc:`./box_slab/slab_stats`
           - Show a detailed memory usage report for slab allocator

.. toctree::
    :hidden:

    box_slab/runtime_info
    box_slab/slab_info
    box_slab/slab_stats
