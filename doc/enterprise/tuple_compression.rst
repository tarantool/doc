.. _tuple_compression:

Tuple compression
=================

Tuple compression, introduced in Tarantool Enterprise Edition 2.10.0, aims to save memory space.
Typically, it decreases the volume of stored data by 15%.
However, the exact volume saved depends on the type of data.

The following compression algorithms are supported:

*   `lz4 <https://en.wikipedia.org/wiki/LZ4_(compression_algorithm)>`_
*   `zstd <https://en.wikipedia.org/wiki/Zstd>`_
*   `zlib <https://en.wikipedia.org/wiki/Zlib>`_ (since :doc:`2.11.0 </release/2.11.0>`)

To learn about the performance costs of each algorithm,
check :ref:`Tuple compression performance <enterprise-tuple-comp-performance>`.

Tarantool doesn't compress tuples themselves, just the fields inside these tuples.
You can only compress non-indexed fields.
Compression works best when JSON is stored in the field.

.. note::

    The :ref:`compress <compress-module>` module provides the API for compressing and decompressing data.


.. _compression_new_space:

Enabling compression for a new space
------------------------------------

First, create a space:

..  code-block:: lua

    box.schema.space.create('bands')

Then, create an index for this space, for example:

..  code-block:: lua

    box.space.bands:create_index('primary', {parts = {{1, 'unsigned'}}})

Create a format to declare field names and types.
In the example below, the ``band_name`` and ``year`` fields have the ``zstd`` and ``lz4`` compression formats, respectively.
The first field (``id``) has the index, so it cannot be compressed.

..  code-block:: lua

    box.space.bands:format({
               {name = 'id', type = 'unsigned'},
               {name = 'band_name', type = 'string', compression = 'zstd'},
               {name = 'year', type = 'unsigned', compression = 'lz4'}
           })

Now, the new tuples that you add to the space ``bands`` will be compressed.
When you read a compressed tuple, you do not need to decompress it back yourself.



.. _checking_which_fields_are_compressed:

Checking which fields are compressed
------------------------------------

To check which fields in a space are compressed, run
:ref:`space_object:format() <box_space-format>` on the space.
If a field is compressed, the format includes the compression algorithm, for example:

..  code-block:: tarantoolsession

    tarantool> box.space.bands:format()
        ---
        - [{'name': 'id', 'type': 'unsigned'},
           {'type': 'string', 'compression': 'zstd', 'name': 'band_name'},
           {'type': 'unsigned', 'compression': 'lz4', 'name': 'year'}]
        ...



.. _compression_existing_spaces:

Enabling compression for existing spaces
----------------------------------------

You can enable compression for existing fields.
All the tuples added after that will have this field compressed.
However, this doesn't affect the tuples already stored in the space.
You need to make the snapshot and restart Tarantool to compress the existing tuples.

Here's an example of how to compress existing fields:

1.  Create a space without compression and add several tuples:

    ..  code-block:: lua

        box.schema.space.create('bands')

        box.space.bands:format({
            { name = 'id', type = 'unsigned' },
            { name = 'band_name', type = 'string' },
            { name = 'year', type = 'unsigned' }
        })

        box.space.bands:create_index('primary', { parts = { 'id' } })

        box.space.bands:insert { 1, 'Roxette', 1986 }
        box.space.bands:insert { 2, 'Scorpions', 1965 }
        box.space.bands:insert { 3, 'Ace of Base', 1987 }
        box.space.bands:insert { 4, 'The Beatles', 1960 }

2.  Suppose that you want fields 2 and 3 to be compressed from now on.
    To enable compression, change the format as follows:

    ..  code-block:: lua

        local new_format = box.space.bands:format()

        new_format[2].compression = 'zstd'
        new_format[3].compression = 'lz4'

        box.space.bands:format(new_format)

    From now on, all the tuples that you add to the space have fields 2 and 3 compressed.

3.  To finalize the change, create a snapshot by running
    :ref:`box.snapshot() <box-snapshot>` and restart Tarantool.
    As a result, all old tuples will also be compressed in memory during recovery.

..  note::

    :doc:`space:upgrade() <space_upgrade>` provides the ability to enable compression
    and update the existing tuples in the background.
    To achieve this, you need to pass a new space format in the ``format`` argument of ``space:upgrade()``.


..  _enterprise-tuple-comp-performance:

Tuple compression performance
-----------------------------

Below are the results of a `synthetic test <https://github.com/tarantool/doc/blob/latest/doc/code_snippets/test/performance/compression_speed.lua>`_ that illustrate how tuple compression affects performance.
The test was carried out on a simple Tarantool space containing 100,000 tuples,
each having a field with a sample JSON roughly 600 bytes large.
The test compared the speed of running ``select`` and ``replace`` operations on uncompressed and compressed data
as well as the overall data size of the space.
Performance is measured in requests per second.

..  container:: table

    ..  list-table::
        :widths: 25 25 25 25
        :header-rows: 1

        *   -   Compression type
            -   ``select``, RPS
            -   ``replace``, RPS
            -   Space size, bytes
        *   -   None
            -   4,486k
            -   1,109k
            -   41,168,548
        *   -   ``zstd``
            -   308k
            -   26k
            -   21,368,548
        *   -   ``lz4``
            -   1,765k
            -   672k
            -   25,268,548
        *   -   ``zlib``
            -   325k
            -   107k
            -   20,768,548
