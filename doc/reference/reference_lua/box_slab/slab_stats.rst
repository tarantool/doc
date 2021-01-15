.. _box_slab_stats:

================================================================================
box.slab.stats()
================================================================================

.. module:: box.slab

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
   in :doc:`/reference/reference_lua/box_slab/slab_info` report.
