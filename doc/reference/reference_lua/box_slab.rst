.. _box_introspection-box_slab:

--------------------------------------------------------------------------------
Submodule `box.slab`
--------------------------------------------------------------------------------

.. module:: box.slab

===============================================================================
                                   Overview
===============================================================================

The ``box.slab`` submodule provides access to slab allocator statistics. The
slab allocator is the main allocator used to store :ref:`tuples <index-box_tuple>`.
This can be used to monitor the total memory usage and memory fragmentation.

===============================================================================
                                    Index
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

.. _box_runtime_info:

.. function:: box.runtime.info()

    Show a memory usage report (in bytes) for the Lua runtime.

    :return:

      * ``lua`` is the heap size of the Lua garbage collector;
      * ``maxalloc`` is the maximal memory quota that can be allocated for Lua;
      * ``used`` is the current memory size used by Lua.

    :rtype:  table

    **Example:**

    .. code-block:: tarantoolsession

      tarantool> box.runtime.info()
      ---
      - lua: 913710
        maxalloc: 4398046510080
        used: 12582912
      ...
      tarantool> box.runtime.info().used
      ---
      - used: 12582912
      ...

.. _box_slab_info:

.. function:: box.slab.info()

    Show an aggregated memory usage report (in bytes) for the slab allocator.
    This report is useful for assessing out-of-memory risks.

    ``box.slab.info`` gives a few ratios:

    * items_used_ratio
    * arena_used_ratio
    * quota_used_ratio

    Here are two possible cases for monitoring memtx memory usage:

    **Case 1:** 0.5 < ``items_used_ratio`` < 0.9

    .. image:: items_used_ratio1.svg
        :align: center

    Apparently your memory is highly fragmented. Check how many
    slab classes you have by looking at ``box.slab.stats()`` and counting the number
    of different classes. If there are many slab classes (more than a few
    dozens), you may run out of memory even though memory utilization is not high.
    While each slab may have few items used, whenever a tuple of a size different
    from any existing slab class size is allocated, Tarantool may need to get a
    new slab from the slab arena, and since the arena has few empty slabs left, it will
    attempt to increase its quota usage, which, in turn, may end up with an out-of-memory
    error due to the low remaining quota.

    **Case 2:** ``items_used_ratio`` > 0.9

    .. image:: items_used_ratio2.svg
        :align: center

    You are running out of memory. All memory utilization indicators
    are high. Your memory is not fragmented, but there are few reserves left on
    each slab allocator level. You should consider increasing Tarantool's
    memory limit (``box.cfg.memtx_memory``).

    **To sum up:** your main out-of-memory indicator is ``quota_used_ratio``.
    However, there are lots of perfectly stable setups with a high ``quota_used_ratio``,
    so you only need to pay attention to it when both arena and item used ratio
    are also high.

    :return:

      * ``quota_size`` - memory limit for slab allocator (as configured in the
        :ref:`memtx_memory <cfg_storage-memtx_memory>` parameter,
        the default is 2^28 bytes = 268,435,456 bytes)
      * ``quota_used`` - used by slab allocator
      * ``items_size`` - allocated only for tuples
      * ``items_used`` - used only for tuples
      * ``arena_size`` - allocated for both tuples and indexes
      * ``arena_used`` - used for both tuples and indexes
      * ``items_used_ratio`` = ``items_used`` / ``items_size``
      * ``quota_used_ratio`` = ``quota_used`` / ``quota_size``
      * ``arena_used_ratio`` = ``arena_used`` / ``arena_size``

    :rtype:  table

    **Example:**

    .. code-block:: tarantoolsession

      tarantool> box.slab.info()
      ---
      - items_size: 228128
        items_used_ratio: 1.8%
        quota_size: 1073741824
        quota_used_ratio: 0.8%
        arena_used_ratio: 43.2%
        items_used: 4208
        quota_used: 8388608
        arena_size: 2325176
        arena_used: 1003632
      ...

      tarantool> box.slab.info().arena_used
      ---
      - 1003632
      ...

.. _box_slab_stats:

.. function:: box.slab.stats()

    Show a detailed memory usage report (in bytes) for the slab allocator.
    The report is broken down into groups by *data item size* as well as by
    *slab size* (64-byte, 136-byte, etc). The report includes the memory
    allocated for storing both tuples and indexes.

    :return:

      * ``mem_free`` is the allocated, but currently unused memory;
      * ``mem_used`` is the memory used for storing data items (tuples and indexes);
      * ``item_count`` is the number of stored items;
      * ``item_size`` is the size of each data item;
      * ``slab_count`` is the number of slabs allocated;
      * ``slab_size`` is the size of each allocated slab.

    :rtype:  table

    **Example:**

    Here is a sample report for the first group:

    .. code-block:: tarantoolsession

        tarantool> box.slab.stats()[1]
        ---
        - mem_free: 16232
          mem_used: 48
          item_count: 2
          item_size: 24
          slab_count: 1
          slab_size: 16384
        ...

    This report is saying that there are 2 data items (``item_count`` = 2) stored
    in one (``slab_count`` = 1) 24-byte slab (``item_size`` = 24), so
    ``mem_used`` = 2 * 24 = 48 bytes. Also, ``slab_size`` is 16384 bytes, of
    which 16384 - 48 = 16232 bytes are free (``mem_free``).

    A complete report would show memory usage statistics for all groups:

    .. code-block:: tarantoolsession

      tarantool> box.slab.stats()
      ---
      - - mem_free: 16232
          mem_used: 48
          item_count: 2
          item_size: 24
          slab_count: 1
          slab_size: 16384
        - mem_free: 15720
          mem_used: 560
          item_count: 14
          item_size: 40
          slab_count: 1
          slab_size: 16384
        <...>
        - mem_free: 32472
          mem_used: 192
          item_count: 1
          item_size: 192
          slab_count: 1
          slab_size: 32768
        - mem_free: 1097624
          mem_used: 999424
          item_count: 61
          item_size: 16384
          slab_count: 1
          slab_size: 2097152
        ...

   The total ``mem_used`` for all groups in this report equals ``arena_used``
   in :ref:`box.slab.info() <box_slab_info>` report.
