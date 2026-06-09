.. _engines-memcs:

Storing data with memcs
=======================

..  admonition:: Enterprise Edition
    :class: fact

The ``memcs`` engine uses a single-threaded transaction processor (TX thread), similar to ``memtx``,
and stores data in the memtx arena but in contrast to memtx it doesn’t organize data in tuples.
Instead, it stores data in columns. Each format field is assigned its own BPS tree-like structure (BPS vector), which stores values only of that field.
If the field type fits in 32 bytes, raw field values are stored directly in tree leaves without any encoding.
The strings are stored in the format similar to "Arrow Variable-size Binary View Layout", also called "German Strings".

The main benefit of such data organization is a significant performance boost of columnar data sequential scans compared to memtx thanks to CPU cache locality.
That’s why memcs supports a special C api for such columnar scans: see ``box_index_arrow_stream()`` and ``box_raw_read_view_arrow_stream()``.
Peak performance is achieved when scanning embedded field types.

Querying full tuples, like in memtx, is also supported, but the performance is worse compared to memtx,
because a tuple has to be constructed on the runtime arena from individual field values gathered from each column tree.

Other features include:

* Point lookup
* Stable iterators
* Insert / replace / delete / update
* Batch insertion in the Arrow format
* Transactions, including cross-engine transactions with ``memtx`` (with
  ``memtx_use_mvcc_engine = false``)
* Read view support
* Secondary indexes with the ability to specify covered columns and sequentially scan
  indexed + covered columns

.. _memcs-features:

Key features
------------

* Columnar data organization — data is stored column-wise, enabling efficient aggregations, filters, and scans.
* Apache Arrow support — data can be exported in Arrow format without conversion, enabling zero-copy interoperability.
* Dictionary encoding — reduces memory usage for string columns with repeated values.
* `LZ4 <https://en.wikipedia.org/wiki/LZ4_(compression_algorithm)>`_ compression — compresses column data to reduce memory footprint.

.. _memcs-usage:

Usage
-----

MemCS is used as a storage engine for `space` objects and is created using :ref:`box.schema.space.create() <box_schema-space_create>` :

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

Supported data types
--------------------

MemCS supports a wide range of data types, including:

- Integer types: ``int8``, ``uint8``, ``int16``, ``uint16``, ``int32``, ``uint32``, ``int64``, ``uint64``
- Floating-point types: ``double``, ``float``, ``float32``, ``float64``
- Strings: ``string``
- Decimal: ``decimal``, ``decimal32``, ``decimal64``, ``decimal128``, and ``decimal256``

.. _memcs-dict-encoding:

Dictionary encoding
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

Column layouts
~~~~~~~~~~~~~~

MemCS supports specifying **column layouts** at multiple levels. The precedence is as follows (from highest to lowest):

1. Within :ref:`covers <index_opts_covers>` in index definition
2. Within :ref:`layout <index_opts_layout>` in index definition (default for nullable fields)
3. Within `format` in space definition

.. code-block:: lua

    -- 1. In covers
    box.space.test:create_index('sk', {
        parts = {'c2', 'c3'},
        covers = {
            {'c4', layout = 'plain'},
            {'c5', layout = 'null_rle'},
        },
    })

    -- 2. In layout
    box.space.test:create_index('sk', {
        parts = {'c2', 'c3'},
        covers = {'c4', 'c5'},
        layout = 'null_rle',
    })

    -- 3. In format
    box.space.test:format({
        {name = "c2", type = "number"},
        {name = "c3", type = "number"},
        {name = "c4", type = "number", is_nullable = true, layout = 'null_rle'},
        {name = "c5", type = "number", is_nullable = true},
    })

**Supported layouts:**

- ``plain`` — default layout, no encoding
- ``null_rle`` — RLE encoding for nullable fields
- ``dict`` – dictionary encoding for string fields

.. _memcs-column-rle_encoding:

RLE encoding of NULLs
^^^^^^^^^^^^^^^^^^^^^

By default, NULL values are stored explicitly and consume the same amount of memory as any other valid column value (1, 2, 4, 8, 16, or 32 bytes depending on the exact field type).
However, RLE encoding of NULLs is also supported via the ``null_rle`` layout.
For example, in a column with 90% evenly distributed NULL values, RLE encoding reduces memory consumption by approximately 5 times.

The ``null_rle`` layout can be specified at three levels:

* Within ``covers`` in an index definition (highest precedence)
* Within ``layout`` in an index definition (default for nullable fields)
* Within ``format`` when defining a space (lowest precedence)


.. _memcs-lz4-compression:

LZ4 compression
----------------

MemCS supports **column-level compression** using the `LZ4 <https://en.wikipedia.org/wiki/LZ4_(compression_algorithm)>`_, which balances speed and compression ratio.
All the details on the engines you can find in :ref:`Column compression <column_compression>` chapter.