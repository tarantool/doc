.. _box_introspection-box_slab:

--------------------------------------------------------------------------------
Submodule `box.slab`
--------------------------------------------------------------------------------

.. module:: box.slab

The ``box.slab`` submodule provides access to slab allocator statistics. The
slab allocator is the main allocator used to store tuples. This can be used
to monitor the total memory usage and memory fragmentation.

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
    
    This report is useful for assessing out-of-memory risks: the risks are high
    if both ``arena_used_ratio`` and ``quota_used_ratio`` are high (90-95%).
    
    If ``quota_used_ratio`` is low, then high ``arena_used_ratio`` and/or
    ``items_used_ratio`` indicate that the memory fragmentation is low (i.e. the
    memory is used efficiently).
    
    If ``quota_used_ratio`` is high (approaching 100%), then low 
    ``arena_used_ratio`` (50-60%) indicates that the memory is heavily fragmentized.
    Most probably, there is no immediate out-of-memory risk in this case, but
    generally this is an issue to consider. For example, probable risks are that 
    the entire memory quota is used for tuples, and there is are no slabs
    left for a piece of an index. Or that all slabs are allocated for storing
    tuples, but in fact all the slabs are half-empty.

    :return:
      
      * ``items_size`` is the *total* amount of memory (including allocated, but
        currently free slabs) used only for tuples, no indexes;
      * ``items_used_ratio`` = ``items_used`` / ``slab_count`` * ``slab_size``
        (these are slabs used only for tuples, no indexes);
      * ``quota_size`` is the maximum amount of memory that the slab allocator
        can use for both tuples and indexes
        (as configured in :ref:`slab_alloc_arena <cfg_storage-slab_alloc_arena>`
        parameter, e.g. the default is 1 gigabyte = 2^30 bytes = 1,073,741,824 bytes);
      * ``quota_used_ratio`` = ``quota_used`` / ``quota_size``;
      * ``arena_used_ratio`` = ``arena_used`` / ``arena_size``;
      * ``items_used`` is the *efficient* amount of memory (omitting allocated, but
        currently free slabs) used only for tuples, no indexes;
      * ``quota_used`` is the percentage of
        :ref:`slab_alloc_arena <cfg_storage-slab_alloc_arena>` that is already
        distributed to the slab allocator;
      * ``arena_size`` is the *total* memory used for tuples and indexes together
        (including allocated, but currently free slabs);
      * ``arena_used`` is the *efficient* memory used for storing tuples and indexes
        together (omitting allocated, but currently free slabs).

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
