.. _box_introspection-box_slab:

--------------------------------------------------------------------------------
Submodule `box.slab`
--------------------------------------------------------------------------------

===============================================================================
                                   Overview
===============================================================================

The ``box.slab`` submodule provides access to slab allocator statistics. The
slab allocator is the main allocator used to store :ref:`tuples <index-box_tuple>`.
This can be used to monitor the total memory usage and memory fragmentation.

===============================================================================
                               Contents
===============================================================================

Below is a list of all ``box.slab`` functions.

.. container:: table

    .. rst-class:: left-align-column-1
    .. rst-class:: left-align-column-2

    +--------------------------------------+---------------------------------+
    | Name                                 | Use                             |
    +======================================+=================================+
    | :ref:`box.runtime.info()             | Show a memory usage report for  |
    | <box_runtime_info>`                  | Lua runtime                     |
    +--------------------------------------+---------------------------------+
    | :ref:`box.slab.info()                | Show an aggregated memory usage |
    | <box_slab_info>`                     | report for slab allocator       |
    +--------------------------------------+---------------------------------+
    | :ref:`box.slab.stats()               | Show a detailed memory usage    |
    | <box_slab_stats>`                    | report for slab allocator       |
    +--------------------------------------+---------------------------------+

.. toctree::
    :hidden:

    box_slab/box_runtime_info
    box_slab/box_slab_info
    box_slab/box_slab_stats