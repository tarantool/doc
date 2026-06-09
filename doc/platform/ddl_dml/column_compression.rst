.. _column_compression:

Column compression
==================

..  admonition:: Enterprise Edition
    :class: fact

    Column compression is available exclusively in the `Enterprise Edition <https://www.tarantool.io/compare/>`_.
    Now supported only by the MemCS engine.

Column compression, introduced in Tarantool Enterprise Edition 3.7.0, aims
to save memory space. It compresses a range of consecutive values and
stores them in a compressed block. Default block size is 50-100 values.

The following compression algorithms are supported:

* `lz4 <https://en.wikipedia.org/wiki/LZ4_(compression_algorithm)>`_
* `zstd <https://en.wikipedia.org/wiki/Zstd>`_
* `zlib <https://en.wikipedia.org/wiki/Zlib>`_

A column of any type can be compressed, however the "external" values
(the strings that are longer than 12 characters) are not yet compressed.

..  note::

    Only non-indexed columns can be compressed.
    The compression can be enabled only during the space creation.
    Strings longer than **12 bytes** are currently **not compressed**


Compression settings:

*   `acceleration` – LZ4-specific configuration parameter:

    -   allowed range: 1…65537
    -   recommended: 10…1000
    -   higher values improve compression and decompression speed, but reduce the compression ratio

Example:

..  code-block:: lua

    local format = {
        {'c1', 'uint64'},
        {'c2', 'string', is_nullable = true, compression = 'lz4'},
        {'c3', 'int32', compression = {type = 'lz4', acceleration = 1000}},
    }
    box.schema.create_space('test', {
        engine = 'memcs', field_count = #format, format = format,
    })
