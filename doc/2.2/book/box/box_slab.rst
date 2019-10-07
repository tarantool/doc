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
        (as configured in the :ref:`memtx_memory <cfg_storage-memtx_memory>`
        parameter, the default is 2^28 bytes =  268,435,456 bytes);
      * ``quota_used_ratio`` = ``quota_used`` / ``quota_size``;
      * ``arena_used_ratio`` = ``arena_used`` / ``arena_size``;
      * ``items_used`` is the *efficient* amount of memory (omitting allocated, but
        currently free slabs) used only for tuples, no indexes;
      * ``quota_used`` is the amount of memory that is already distributed to
        the slab allocator;
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

.. _box_understanding memory_use:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Understing memory use statistics with memtx
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Inserting a tuple will normally cause increased memory use for the data and for the index.
Let us take an example of a tuple with a 5-digit indexed number and a 5-character string:
:samp:`{nnnnn}, 'abcde'`.

Calculate the tuple size thus: |br|
(Size of data + overhead) rounded up to next 8 |br|
Size of data is the MsgPack size, because Tarantool stores tuples
in MsgPack format,
as described in
`MsgPack specification <http://github.com/msgpack/msgpack/blob/master/spec.md>`_.
and as illustrated in
:ref:`Common Types and MsgPack Encodings <msgpack-common_types_and_msgpack_encodings>`,
and as easily calculated with :ref:`tuple_object:bsize() <box_tuple-bsize>`.
Overhead is always 12.
Rounded **up** (emphasis on up) means always use the next integer divisible by 8.
In Lua terms, then we can calculate our storage requirement with:

.. code-block:: none

    tuple_value = {10000, 'abcde'}
    tuple_size = box.tuple.bsize(box.tuple.new(tuple_value))
    storage_size = math.ceil((tuple_size + 12 + 1) / 8) * 8

In this case tuple_size = 10, storage_size = 24, so we can predict
that this tuple requires 24 bytes.

Calculate the index size thus:
Around 20 to 24 bytes on average.
This cannot be an exact number because storage for a
TREE index is in blocks. So inserting a single tuple
might cause no change to index size, or a large change.
But we can expect that when we add 10,000 tuples the average
will be 20 to 24.

Calculate the initial index overhead thus:
48KB.
That is the amount that will be allocated the first time that a tuple is
inserted, no matter how big the tuple is. Therefore, when monitoring the
growth of memory use, we should ignore the first 48*1024 bytes.

Now let us compare our expectations with Tarantool's statistics.
Start with a completely empty database, add 10,000 tuples (to ignore),
and add 10,000 tuples (to compare the growth).

.. code-block:: tarantoolsession

    box.cfg{}
    box.schema.space.create('T')
    box.space.T:create_index('I')
    for i = 0, 9999 do box.space.T:insert{i, 'abcde'} end
    old_memory_data = box.info.memory().data
    old_memory_index = box.info.memory().index
    old_arena_used = box.slab.info().arena_used
    old_1_item_count = box.slab.stats()[1].item_count
    old_24_item_count = box.slab.stats()[24].item_count
    for i = 10000, 19999 do box.space.T:insert{i, 'abcde'} end
    new_memory_data = box.info.memory().data - old_memory_data
    new_memory_index = box.info.memory().index - old_memory_index
    new_arena_used = box.slab.info().arena_used - old_arena_used
    new_1_item_count = box.slab.stats()[1].item_count - old_1_item_count
    new_24_item_count = box.slab.stats()[24].item_count - old_24_item_count
    print('growth in memory().data = ' .. new_memory_data)
    print('growth in memory().index = ' .. new_memory_index)
    print('growth in arena_used = ' .. new_arena_used)
    print('box.slab.stats()[1].item_size = ' .. box.slab.stats()[1].item_size)
    print('growth in box.slab.stats()[1].item_count = ' .. new_1_item_count)
    print('box.slab.stats()[24].item_size = ' .. box.slab.stats()[24].item_size)
    print('growth in box.slab.stats()[24].item_count = ' .. new_24_item_count)

Running that code will result in a display of these values: |br|
Growth in memory().data =  240000 bytes, which is 24 * 10000. |br|
Growth in memory().index = 229376, which is approximately 23 * 10000. |br|
Growth in arena_used = 469376, which is exactly memory().data + memory().index. |br|
The first slab stats show there are 10000 new items with size = 24 (the data). |br|
The 24th slab stats show that there are 14 new items with size = 16384 (the index blocks).

There are some complications: |br|
* The offset of the slab.stats() where item_size = 24 may differ, and the offset of
the slab.stats() where item_size = 16384 may differ, depending on Tarantool version
and depending on whether there has been any previous activity (for the example we
assumed the database is initially empty). |br|
* The allocated amount can never be less than :ref:`memtx_min_tuple_size <cfg_storage-memtx_min_tuple_size>`. |br|
* If the required size is greater than 128 bytes, then some additional overhead
will exist, usually less than 5% of the total size.
See the slightly-outdated article:
`Memory size calculation <https://github.com/tarantool/tarantool/wiki/Memory-size-calculation>`_.

