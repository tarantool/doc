.. _box_info_sql:

================================================================================
box.info.sql
================================================================================

.. module:: box.info

.. data:: sql

    Get information about the cache for all :ref:`SQL prepared statements <box-sql_box_prepare>`.
    The returned table contains the following fields:

    -   ``cache.size`` -- the actual cache size (in bytes) for all SQL prepared statements.
        To configure the maximum cache size, use the :ref:`sql.cache_size <configuration_reference_sql_cache_size>` option.
    -   ``cache.stmt_count`` -- the number of statements in the SQL prepared statement cache.

    :rtype: table
