Up-to-date parameters:

* :ref:`memtx_memory <cfg_storage-memtx_memory>`
* :ref:`memtx_max_tuple_size <cfg_storage-memtx_max_tuple_size>`
* :ref:`memtx_min_tuple_size <cfg_storage-memtx_min_tuple_size>`
* :ref:`slab_alloc_factor <cfg_storage-slab_alloc_factor>`
* :ref:`vinyl_bloom_fpr <cfg_storage-vinyl_bloom_fpr>`
* :ref:`vinyl_cache <cfg_storage-vinyl_cache>`
* :ref:`vinyl_memory <cfg_storage-vinyl_memory>`
* :ref:`vinyl_page_size <cfg_storage-vinyl_page_size>`
* :ref:`vinyl_range_size <cfg_storage-vinyl_range_size>`
* :ref:`vinyl_run_count_per_level <cfg_storage-vinyl_run_count_per_level>`
* :ref:`vinyl_run_size_ratio <cfg_storage-vinyl_run_size_ratio>`
* :ref:`vinyl_threads <cfg_storage-vinyl_threads>`

Deprecated parameters:

* :ref:`slab_alloc_arena <cfg_storage-slab_alloc_arena_deprecated>`
* :ref:`slab_alloc_maximal <cfg_storage-slab_alloc_maximal_deprecated>`
* :ref:`slab_alloc_minimal <cfg_storage-slab_alloc_minimal_deprecated>`
* :ref:`vinyl <cfg_storage-vinyl_deprecated>`
* :ref:`vinyl.bloom_fpr <cfg_storage-vinyl_bloom_fpr_deprecated>`
* :ref:`vinyl.compact_wm <cfg_storage-vinyl_compact_wm_deprecated>`
* :ref:`vinyl.cache <cfg_storage-vinyl_cache_deprecated>`
* :ref:`vinyl.memory_limit <cfg_storage-vinyl_memory_limit_deprecated>`
* :ref:`vinyl.page_size <cfg_storage-vinyl_page_size_deprecated>`
* :ref:`vinyl.range_size <cfg_storage-vinyl_range_size_deprecated>`
* :ref:`vinyl.run_count_per_level <cfg_storage-vinyl_run_count_per_level_deprecated>`
* :ref:`vinyl.run_size_ratio <cfg_storage-vinyl_run_size_ratio_deprecated>`
* :ref:`vinyl.threads <cfg_storage-vinyl_threads_deprecated>`

.. _cfg_storage-memtx_memory:

.. confval:: memtx_memory

    How much memory Tarantool allocates to actually store tuples, in bytes.
    When the limit is reached, INSERT or UPDATE requests begin failing with
    error :errcode:`ER_MEMORY_ISSUE`. While the server does not go beyond the
    defined limit to allocate tuples, there is additional memory used to store
    indexes and connection information. Depending on actual configuration and
    workload, Tarantool can consume up to 20% more than the limit set here.

    | Type: float
    | Default: 256 * 1024 * 1024 = 268435456
    | Dynamic: no
    
.. _cfg_storage-memtx_max_tuple_size:

.. confval:: memtx_max_tuple_size

    Size of the largest allocation unit, in bytes. It can be increased if it
    is necessary to store large tuples.

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

.. _cfg_storage-slab_alloc_factor:

.. confval:: slab_alloc_factor

    Use ``slab_alloc_factor`` as the multiplier for computing the sizes of memory
    chunks that tuples are stored in. A lower value may result in less wasted
    memory depending on the total amount of memory available and the
    distribution of item sizes.

    | Type: float
    | Default: 1.1
    | Dynamic: no

.. _cfg_storage-vinyl_bloom_fpr:

.. confval:: vinyl_bloom_fpr

    Bloom filter false positive rate -- the suitable probability of the bloom
    filter to give a wrong result.

    | Type: float
    | Default = 0.05
    | Dynamic: no

.. _cfg_storage-vinyl_cache:

.. confval:: vinyl_cache

    The maximal cache size for vinyl, in bytes.

    | Type: integer
    | Default = 128 * 1024 * 1024 = 134217728
    | Dynamic: no

.. _cfg_storage-vinyl_memory:

.. confval:: vinyl_memory

    The maximum number of in-memory bytes that vinyl uses.

    | Type: integer
    | Default = 128 * 1024 * 1024 = 134217728
    | Dynamic: no

.. _cfg_storage-vinyl_page_size:

.. confval:: vinyl_page_size

    Page size, in bytes. Page is a R/W unit for vinyl disk operations.

    | Type: integer
    | Default = 8 * 1024
    | Dynamic: no

.. _cfg_storage-vinyl_range_size:

.. confval:: vinyl_range_size

    The maximal range size for vinyl, in bytes.

    | Type: integer
    | Default = 1024 * 1024 * 1024
    | Dynamic: no

.. _cfg_storage-vinyl_run_count_per_level:

.. confval:: vinyl_run_count_per_level

    The maximal number of runs per level in vinyl LSM tree.
    If this number is exceeded, a new level is created.

    | Type: integer
    | Default = 2
    | Dynamic: no

.. _cfg_storage-vinyl_run_size_ratio:

.. confval:: vinyl_run_size_ratio

    Ratio between the sizes of different levels in the LSM tree.
    
    | Type: float
    | Default = 3.5
    | Dynamic: no

.. _cfg_storage-vinyl_threads:

.. confval:: vinyl_threads

    The maximum number of threads that vinyl can use for some
    concurrent operations, such as I/O and compression.

    | Type: integer
    | Default = 1
    | Dynamic: no

*********************
Deprecated parameters
*********************

.. _cfg_storage-slab_alloc_arena_deprecated:

.. confval:: slab_alloc_arena

    **Deprecated since 1.7.3** in favor of
    :ref:`memtx_memory <cfg_storage-memtx_memory>`.
    
    How much memory Tarantool allocates to actually store tuples, **in gigabytes**.
    When the limit is reached, INSERT or UPDATE requests begin failing with
    error :errcode:`ER_MEMORY_ISSUE`. While the server does not go beyond the
    defined limit to allocate tuples, there is additional memory used to store
    indexes and connection information. Depending on actual configuration and
    workload, Tarantool can consume up to 20% more than the limit set here.

    | Type: float
    | Default: 1.0
    | Dynamic: no

.. _cfg_storage-slab_alloc_maximal_deprecated:

.. confval:: slab_alloc_maximal

    **Deprecated since 1.7.3** in favor of
    :ref:`memtx_max_tuple_size <cfg_storage-memtx_max_tuple_size>`.
    The parameter was only renamed,
    while the type, values and semantics remained intact.

.. _cfg_storage-slab_alloc_minimal_deprecated:

.. confval:: slab_alloc_minimal

    **Deprecated since 1.7.3** in favor of
    :ref:`memtx_min_tuple_size <cfg_storage-memtx_min_tuple_size>`.
    The parameter was only renamed,
    while the type, values and semantics remained intact.

.. _cfg_storage-vinyl_deprecated:

.. confval:: vinyl

    **Deprecated since 1.7.3** in favor of standalone parameters.

    Previously, vinyl configuration was defined with a section of nested
    parameters:

    .. cssclass:: highlight
    .. parsed-literal::

        vinyl = {
            compact_wm = *number*,
            memory_limit = *number*,
            threads = *number*,
            <...>
        }
        
    See all nested parameters below.

    .. _cfg_storage-vinyl_bloom_fpr_deprecated:

    .. confval:: bloom_fpr

        **Deprecated since 1.7.3**.

        Bloom filter false positive rate -- the suitable probability of the bloom
        filter to give a wrong result.

        | Type: float
        | Default = 0.05
        | Dynamic: no

    .. _cfg_storage-vinyl_cache_deprecated:

    .. confval:: cache

        **Deprecated since 1.7.3**.
        
        The maximal cache size for vinyl, in bytes.

        | Type: integer
        | Default = 128 * 1024 * 1024 = 134217728
        | Dynamic: no

    .. _cfg_storage-vinyl_compact_wm_deprecated:

    .. confval:: compact_wm

        **Deprecated since 1.7.3**.
        
        The "compaction watermark" for vinyl. If the number of runs
        becomes greater than ``compact_wm``, then compaction occurs.

        | Type: integer
        | Default: 2
        | Dynamic: no

    .. _cfg_storage-vinyl_memory_limit_deprecated:

    .. confval:: memory_limit

        **Deprecated since 1.7.3**.
        
        The maximum number of in-memory bytes that vinyl uses.

        | Type: integer
        | Default = 1
        | Dynamic: no

    .. _cfg_storage-vinyl_page_size_deprecated:

    .. confval:: page_size

        **Deprecated since 1.7.3**.
        
        Page size, in bytes. Page is a R/W unit for vinyl disk operations.


        | Type: integer
        | Default = 8 * 1024
        | Dynamic: no

    .. _cfg_storage-vinyl_range_size_deprecated:

    .. confval:: range_size

        **Deprecated since 1.7.3**.
        
        The maximal range size for vinyl, in bytes.

        | Type: integer
        | Default = 1024 * 1024 * 1024
        | Dynamic: no

    .. _cfg_storage-vinyl_run_count_per_level_deprecated:

    .. confval:: run_count_per_level

        **Deprecated since 1.7.3**.
        
        The maximal number of runs per level in vinyl LSM tree.
        If this number is exceeded, a new level is created.

        | Type: integer
        | Default = 2
        | Dynamic: no

    .. _cfg_storage-vinyl_run_size_ratio_deprecated:

    .. confval:: run_size_ratio

        **Deprecated since 1.7.3**.
        
        Ratio between the sizes of different levels in the LSM tree.

        | Type: float
        | Default = 3.5
        | Dynamic: no

    .. _cfg_storage-vinyl_threads_deprecated:

    .. confval:: threads

        **Deprecated since 1.7.3**.
        
        The maximum number of threads that vinyl can use for some
        concurrent operations, such as I/O and compression.

        | Type: integer
        | Default = 1
        | Dynamic: no

.. _LZ4 algorithm: https://en.wikipedia.org/wiki/LZ4_%28compression_algorithm%29
.. _ZStandard algorithm: http://zstd.net
