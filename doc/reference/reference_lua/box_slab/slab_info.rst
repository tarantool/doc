.. _box_slab_info:

================================================================================
box.slab.info()
================================================================================

.. module:: box.slab

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