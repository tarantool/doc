.. _box_index-stat:

===============================================================================
index_object:stat()
===============================================================================

.. class:: index_object

    .. method:: stat()

        Return statistics about actions taken that affect the index.

        This is for use with the vinyl engine.

        Some detail items in the output from ``index_object:stat()`` are:

        * ``index_object:stat().latency`` -- timings subdivided by percentages;
        * ``index_object:stat().bytes`` -- the number of bytes total;
        * ``index_object:stat().disk.rows`` -- the approximate number of tuples in each range;
        * ``index_object:stat().disk.statement`` -- counts of inserts|updates|upserts|deletes;
        * ``index_object:stat().disk.compaction`` -- counts of compactions and their amounts;
        * ``index_object:stat().disk.dump`` -- counts of dumps and their amounts;
        * ``index_object:stat().disk.iterator.bloom`` -- counts of bloom filter hits|misses;
        * ``index_object:stat().disk.pages`` -- the size in pages;
        * ``index_object:stat().disk.last_level`` -- size of data in the last LSM tree level;
        * ``index_object:stat().cache.evict`` -- number of evictions from the cache;
        * ``index_object:stat().range_size`` -- maximum number of bytes in a range;
        * ``index_object:stat().dumps_per_compaction`` -- average number of dumps required to trigger major compaction in any range of the LSM tree.

        Summary index statistics are also available via
        :ref:`box.stat.vinyl() <box_introspection-box_stat_vinyl>`.

        :param index_object index_object: an :ref:`object reference
                                          <app_server-object_reference>`.

        :return: statistics
        :rtype: table
