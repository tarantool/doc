.. _engines-memcs:

Storing data with memcs
=======================

..  admonition:: Enterprise Edition
    :class: fact

The `memcs` engine uses a single-threaded transaction processor (TX thread), similar to `memtx`. However, unlike `memtx`,
which stores data in row-wise format, `memcs` stores data in columnar format, allowing for efficient access to individual columns.

Data is stored in spaces, and each column is stored separately. This allows Tarantool to:

* Read only the columns needed for a query.
* Apply compression and encoding per column.
* Efficiently process large datasets using vectorized operations.

.. _memcs-features:

Key Features
------------

* Columnar data organization — data is stored column-wise, enabling efficient aggregations, filters, and scans.
* Apache Arrow support — data can be exported in Arrow format without conversion, enabling zero-copy interoperability.
* Dictionary encoding — reduces memory usage for string columns with repeated values.
* `LZ4 <https://en.wikipedia.org/wiki/LZ4_(compression_algorithm)>`_ compression — compresses column data to reduce memory footprint.
* SQL integration — supports querying via Tarantool SQL engine.

.. _memcs-usage:

Usage
-----

MemCS is used as a storage engine for `space` objects and is created using `box.schema.create_space()`:

..  code-block:: lua

    box.schema.create_space('analytics_data', {
        engine = 'memcs',
        field_count = 4,
        format = {
            {name = 'id', type = 'uint64'},
            {name = 'event_type', type = 'string', compression = 'lz4'},
            {name = 'timestamp', type = 'datetime'},
            {name = 'value', type = 'double', compression = {type = 'lz4', acceleration = 1000}},
        }
    })


.. _memcs-data:

Supported Data Types
--------------------

MemCS supports a wide range of data types, including:

- Integer types: ``uint64``, ``int64``, ``uint32``, ``int32``
- Floating-point types: ``double``, ``float``
- Strings: ``string``
- Boolean: ``boolean``
- Temporal types: ``datetime``
- UUID: ``uuid``
- Decimal: ``decimal``

.. _memcs-dict-encoding:

Dictionary Encoding
-------------------

MemCS supports **dictionary encoding** for string columns. It stores unique string values in a shared dictionary and replaces repeated values with small integer IDs.
Dictionary encoding is enabled via the :ref:`layout <index_opts_layout>` option:

.. code-block:: lua

    local s = box.schema.create_space('test', {
        engine = 'memcs', format = format, field_count = field_count,
    })
    s:create_index('pk', {layout = 'dict'})

**Limitations:**

- Only **non-key string columns** are supported.
- Maximum of ``UINT16_MAX`` (65536) unique values per column.
- Dictionary IDs use ``uint16`` (2 bytes per value).

**Memory usage:**
``2 * space_size + dict_size``

Memory used by the dictionary is included in ``space:bsize()`` statistics.

**ArrowStream guarantees:**

- Dictionary is returned as ``string-view``, indices as ``uint16``
- All batches share the same dictionary unless new unique values are inserted
- Dictionaries are returned by reference (no copying), so ArrowArray export is cheap
- Dictionaries only grow — previously produced batches remain compatible

.. _memcs-column:

Column Layouts
~~~~~~~~~~~~~~

MemCS supports specifying **column layouts** at multiple levels. The precedence is as follows (from highest to lowest):

1. Within :ref:`covers <index_opts_covers>` in index definition
2. Within :ref:`layout <index_opts_layout>` in index definition (default for nullable fields)
3. Within `format` in space definition

.. code-block:: lua

    -- 1. In covers (highest precedence)
    box.space.test:create_index('sk', {
        parts = {'c2', 'c3'},
        covers = {
            {'c4', layout = 'plain'},
            {'c5', layout = 'null_rle'},
        },
    })

    -- 2. In layout (default for nullable fields)
    box.space.test:create_index('sk', {
        parts = {'c2', 'c3'},
        covers = {'c4', 'c5'},
        layout = 'null_rle',
    })

    -- 3. In format (lowest precedence)
    box.space.test:format({
        {name = "c2", type = "number"},
        {name = "c3", type = "number"},
        {name = "c4", type = "number", is_nullable = true, layout = 'null_rle'},
        {name = "c5", type = "number", is_nullable = true},
    })

**Supported layouts:**

- ``plain`` — default layout, no encoding
- ``null_rle`` — RLE encoding for nullable fields

.. _memcs-lz4-compression:

LZ4 Compression
----------------

MemCS supports **column-level compression** using the `LZ4 <https://en.wikipedia.org/wiki/LZ4_(compression_algorithm)>`_, which balances speed and compression ratio.
Compression is configured per column in the space format using the `compression` attribute and can be enabled only at space creation time:

.. code-block:: lua

    local format = {
        {'c1', 'uint64'},
        {'c2', 'string', compression = 'lz4'},
        {'c3', 'double', compression = {type = 'lz4', acceleration = 1000}},
    }

**Parameters:**

- ``type`` — compression algorithm (``lz4``)
- ``acceleration`` — LZ4-specific parameter:
  - range: 1…65537
  - recommended: 10…1000
  - higher values improve speed, but reduce compression ratio

**Limitations:**

- Compression can be enabled **only at space creation**
- Only **non-indexed columns** can be compressed
- Strings longer than **12 bytes** are currently **not compressed**

.. _memcs-perfomance:

Performance
-----------

MemCS is optimized for:

- **Analytical queries** with aggregations and column filters
- **High-speed data transfer** via Arrow
- **Efficient memory usage** through dictionary encoding and compression

Using **dictionary encoding** and **LZ4 compression** together typically reduces memory usage by **8–13x** compared to uncompressed data.

.. _memcs-memory:

Memory Consumption
------------------

MemCS is memory-efficient, especially when dictionary encoding and compression are used together.

**Dictionary-encoded column memory usage:**
``2 * space_size + dict_size``

Where:

- ``space_size`` — number of rows
- ``dict_size`` — memory used by the dictionary

Memory usage is accounted for in ``space:bsize()`` statistics.

.. _memcs-use-cases:

Use Cases
---------

MemCS is ideal for:

- Log analytics
- Time-series data
- Event stream processing
- BI and data science integrations via Arrow
- OLAP-style queries

.. _memcs-limitations:

Limitations and Trade-offs
--------------------------

MemCS is not suitable for:

- OLTP workloads with frequent row-level updates
- Long string compression (strings >12 bytes are not compressed yet)
- Indexing dictionary-encoded columns
- **Community Edition** (MemCS is Enterprise-only)
