* :ref:`memtx_memory <cfg_storage-memtx_memory>`
* :ref:`memtx_max_tuple_size <cfg_storage-memtx_max_tuple_size>`
* :ref:`memtx_min_tuple_size <cfg_storage-memtx_min_tuple_size>`
* :ref:`vinyl_bloom_fpr <cfg_storage-vinyl_bloom_fpr>`
* :ref:`vinyl_cache <cfg_storage-vinyl_cache>`
* :ref:`vinyl_max_tuple_size <cfg_storage-vinyl_max_tuple_size>`
* :ref:`vinyl_memory <cfg_storage-vinyl_memory>`
* :ref:`vinyl_page_size <cfg_storage-vinyl_page_size>`
* :ref:`vinyl_range_size <cfg_storage-vinyl_range_size>`
* :ref:`vinyl_run_count_per_level <cfg_storage-vinyl_run_count_per_level>`
* :ref:`vinyl_run_size_ratio <cfg_storage-vinyl_run_size_ratio>`
* :ref:`vinyl_read_threads <cfg_storage-vinyl_read_threads>`
* :ref:`vinyl_write_threads <cfg_storage-vinyl_write_threads>`

.. _cfg_storage-memtx_memory:

.. confval:: memtx_memory

    Since version 1.7.4.
    How much memory Tarantool allocates to actually store tuples.
    When the limit is reached, :ref:`INSERT <box_space-insert>` or
    :ref:`UPDATE <box_space-insert>` requests begin failing with
    error :errcode:`ER_MEMORY_ISSUE`. The server does not go beyond the
    ``memtx_memory`` limit to allocate tuples, but there is additional memory
    used to store indexes and connection information. Depending on actual
    configuration and workload, Tarantool can consume up to 20% more than the
    ``memtx_memory`` limit.

    | Type: float
    | Default: 256 * 1024 * 1024 = 268435456 bytes
    | Dynamic: **yes** but it cannot be decreased

.. _cfg_storage-memtx_max_tuple_size:

.. confval:: memtx_max_tuple_size

    Since version 1.7.4.
    Size of the largest allocation unit, for the memtx storage engine. It can be
    increased if it is necessary to store large tuples.
    See also: :ref:`vinyl_max_tuple_size <cfg_storage-vinyl_max_tuple_size>`.

    | Type: integer
    | Default: 1024 * 1024 = 1048576 bytes
    | Dynamic: no

.. _cfg_storage-memtx_min_tuple_size:

.. confval:: memtx_min_tuple_size

    Since version 1.7.4.
    Size of the smallest allocation unit. It can be decreased if most
    of the tuples are very small. The value must be between 8 and 1048280
    inclusive.

    | Type: integer
    | Default: 16 bytes
    | Dynamic: no

.. _cfg_storage-vinyl_bloom_fpr:

.. confval:: vinyl_bloom_fpr

    Since version 1.7.4.
    Bloom filter false positive rate -- the suitable probability of the
    `bloom filter <https://en.wikipedia.org/wiki/Bloom_filter>`_
    to give a wrong result.
    The ``vinyl_bloom_fpr`` setting is a default value for one of the
    options in the :ref:`Options for space_object:create_index() <box_space-create_index>` chart.

    | Type: float
    | Default = 0.05
    | Dynamic: no

.. _cfg_storage-vinyl_cache:

.. confval:: vinyl_cache

    Since version 1.7.4.
    The cache size for the vinyl storage engine. The cache can
    be resized dynamically.

    | Type: integer
    | Default = 128 * 1024 * 1024 = 134217728 bytes
    | Dynamic: **yes**

.. _cfg_storage-vinyl_max_tuple_size:

.. confval:: vinyl_max_tuple_size

    Since version 1.7.5. Size of the largest allocation unit,
    for the vinyl storage engine. It can be increased if it
    is necessary to store large tuples.
    See also: :ref:`memtx_max_tuple_size <cfg_storage-memtx_max_tuple_size>`.

    | Type: integer
    | Default: 1024 * 1024 = 1048576 bytes
    | Dynamic: no

.. _cfg_storage-vinyl_memory:

.. confval:: vinyl_memory

    Since version 1.7.4. The maximum number of in-memory bytes that vinyl uses.

    | Type: integer
    | Default = 128 * 1024 * 1024 = 134217728 bytes
    | Dynamic: **yes** but it cannot be decreased

.. _cfg_storage-vinyl_page_size:

.. confval:: vinyl_page_size

    Since version 1.7.4.
    Page size. Page is a read/write unit for vinyl disk operations.
    The ``vinyl_page_size`` setting is a default value for one of the
    options in the :ref:`Options for space_object:create_index() <box_space-create_index>` chart.

    | Type: integer
    | Default = 8 * 1024 = 8192 bytes
    | Dynamic: no

.. _cfg_storage-vinyl_range_size:

.. confval:: vinyl_range_size

    Since version 1.7.4.
    The default maximum range size for a vinyl index.
    The maximum range size affects the decision whether to
    :ref:`split <engines-vinyl_split>` a range.

    If ``vinyl_range_size`` is not nil and not 0, then
    it is used as the
    default value for the ``range_size`` option in the
    :ref:`Options for space_object:create_index() <box_space-create_index>` chart.

    If ``vinyl_range_size`` is nil or 0, and ``range_size`` is not specified
    when the index is created, then Tarantool sets a value later depending on
    performance considerations. To see the actual value, use
    :ref:`index_object:stat().range_size <box_index-stat>`.

    In Tarantool versions prior to 1.10.2, ``vinyl_range_size`` default value was 1073741824.

    | Type: integer
    | Default = nil bytes
    | Dynamic: no

.. _cfg_storage-vinyl_run_count_per_level:

.. confval:: vinyl_run_count_per_level

    Since version 1.7.4.
    The maximal number of runs per level in vinyl LSM tree.
    If this number is exceeded, a new level is created.
    The ``vinyl_run_count_per_level`` setting is a default value for one of the
    options in the :ref:`Options for space_object:create_index() <box_space-create_index>` chart.

    | Type: integer
    | Default = 2
    | Dynamic: no

.. _cfg_storage-vinyl_run_size_ratio:

.. confval:: vinyl_run_size_ratio

    Since version 1.7.4.
    Ratio between the sizes of different levels in the LSM tree.
    The ``vinyl_run_size_ratio`` setting is a default value for one of the
    options in the :ref:`Options for space_object:create_index() <box_space-create_index>` chart.

    | Type: float
    | Default = 3.5
    | Dynamic: no

.. _cfg_storage-vinyl_read_threads:

.. confval:: vinyl_read_threads

    Since version 1.8.2
    The maximum number of read threads that vinyl can use for some
    concurrent operations, such as I/O and compression.

    | Type: integer
    | Default = 1
    | Dynamic: no

.. _cfg_storage-vinyl_write_threads:

.. confval:: vinyl_write_threads

    Since version 1.8.2.
    The maximum number of write threads that vinyl can use for some
    concurrent operations, such as I/O and compression.

    | Type: integer
    | Default = 2
    | Dynamic: no

.. _LZ4 algorithm: https://en.wikipedia.org/wiki/LZ4_%28compression_algorithm%29
.. _ZStandard algorithm: http://zstd.net
