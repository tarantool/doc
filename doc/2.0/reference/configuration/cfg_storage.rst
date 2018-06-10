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

    How much memory Tarantool allocates to actually store tuples, in bytes.
    When the limit is reached, :ref:`INSERT <box_space-insert>` or
    :ref:`UPDATE <box_space-insert>` requests begin failing with
    error :errcode:`ER_MEMORY_ISSUE`. The server does not go beyond the
    ``memtx_memory`` limit to allocate tuples, but there is additional memory
    used to store indexes and connection information. Depending on actual
    configuration and workload, Tarantool can consume up to 20% more than the
    ``memtx_memory`` limit.

    | Type: float
    | Default: 256 * 1024 * 1024 = 268435456
    | Dynamic: **yes** but it cannot be decreased

.. _cfg_storage-memtx_max_tuple_size:

.. confval:: memtx_max_tuple_size

    Size of the largest allocation unit, in bytes,
    for the memtx storage engine. It can be increased if it
    is necessary to store large tuples.
    See also: :ref:`vinyl_max_tuple_size <cfg_storage-vinyl_max_tuple_size>`.

    | Type: integer
    | Default: 1024 * 1024 = 1048576
    | Dynamic: no

.. _cfg_storage-memtx_min_tuple_size:

.. confval:: memtx_min_tuple_size

    Size of the smallest allocation unit, in bytes. It can be decreased if most
    of the tuples are very small. The value must be between 8 and 1048280
    inclusive.

    | Type: integer
    | Default: 16
    | Dynamic: no

.. _cfg_storage-vinyl_bloom_fpr:

.. confval:: vinyl_bloom_fpr

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

    The maximal cache size for the vinyl storage engine, in bytes.

    | Type: integer
    | Default = 128 * 1024 * 1024 = 134217728
    | Dynamic: no

.. _cfg_storage-vinyl_max_tuple_size:

.. confval:: vinyl_max_tuple_size

    Size of the largest allocation unit, in bytes,
    for the vinyl storage engine. It can be increased if it
    is necessary to store large tuples.
    See also: :ref:`memtx_max_tuple_size <cfg_storage-memtx_max_tuple_size>`.

    | Type: integer
    | Default: 1024 * 1024 = 1048576
    | Dynamic: no

.. _cfg_storage-vinyl_memory:

.. confval:: vinyl_memory

    The maximum number of in-memory bytes that vinyl uses.

    | Type: integer
    | Default = 128 * 1024 * 1024 = 134217728
    | Dynamic: **yes** but it cannot be decreased

.. _cfg_storage-vinyl_page_size:

.. confval:: vinyl_page_size

    Page size, in bytes. Page is a read/write unit for vinyl disk operations.
    The ``vinyl_page_size`` setting is a default value for one of the
    options in the :ref:`Options for space_object:create_index() <box_space-create_index>` chart.

    | Type: integer
    | Default = 8 * 1024 = 8192
    | Dynamic: no

.. _cfg_storage-vinyl_range_size:

.. confval:: vinyl_range_size

    The maximal range size for vinyl, in bytes.
    The ``vinyl_range_size`` setting is a default value for one of the
    options in the :ref:`Options for space_object:create_index() <box_space-create_index>` chart.

    | Type: integer
    | Default = 1024 * 1024 * 1024 = 1073741824
    | Dynamic: no

.. _cfg_storage-vinyl_run_count_per_level:

.. confval:: vinyl_run_count_per_level

    The maximal number of runs per level in vinyl LSM tree.
    If this number is exceeded, a new level is created.
    The ``vinyl_run_count_per_level`` setting is a default value for one of the
    options in the :ref:`Options for space_object:create_index() <box_space-create_index>` chart.

    | Type: integer
    | Default = 2
    | Dynamic: no

.. _cfg_storage-vinyl_run_size_ratio:

.. confval:: vinyl_run_size_ratio

    Ratio between the sizes of different levels in the LSM tree.
    The ``vinyl_run_size_ratio`` setting is a default value for one of the
    options in the :ref:`Options for space_object:create_index() <box_space-create_index>` chart.

    | Type: float
    | Default = 3.5
    | Dynamic: no

.. _cfg_storage-vinyl_read_threads:

.. confval:: vinyl_read_threads

    The maximum number of read threads that vinyl can use for some
    concurrent operations, such as I/O and compression.

    | Type: integer
    | Default = 1
    | Dynamic: no

.. _cfg_storage-vinyl_write_threads:

.. confval:: vinyl_write_threads

    The maximum number of write threads that vinyl can use for some
    concurrent operations, such as I/O and compression.

    | Type: integer
    | Default = 2
    | Dynamic: no

.. _LZ4 algorithm: https://en.wikipedia.org/wiki/LZ4_%28compression_algorithm%29
.. _ZStandard algorithm: http://zstd.net
