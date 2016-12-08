* :ref:`slab_alloc_arena <cfg_storage-slab_alloc_arena>`
* :ref:`slab_alloc_factor <cfg_storage-slab_alloc_factor>`
* :ref:`slab_alloc_maximal <cfg_storage-slab_alloc_maximal>`
* :ref:`slab_alloc_minimal <cfg_storage-slab_alloc_minimal>`
* :ref:`vinyl.memory_limit <cfg_storage-vinyl_memory_limit>`
* :ref:`vinyl.compact_wm <cfg_storage-vinyl_compact_wm>`
* :ref:`vinyl.threads <cfg_storage-vinyl_threads>`

.. _cfg_storage-slab_alloc_arena:

.. confval:: slab_alloc_arena

    How much memory Tarantool allocates to actually store tuples, in gigabytes.
    When the limit is reached, INSERT or UPDATE requests begin failing with
    error :errcode:`ER_MEMORY_ISSUE`. While the server does not go beyond the
    defined limit to allocate tuples, there is additional memory used to store
    indexes and connection information. Depending on actual configuration and
    workload, Tarantool can consume up to 20% more than the limit set here.

    | Type: float
    | Default: 1.0
    | Dynamic: no

.. _cfg_storage-slab_alloc_factor:

.. confval:: slab_alloc_factor

    Use slab_alloc_factor as the multiplier for computing the sizes of memory
    chunks that tuples are stored in. A lower value may result in less wasted
    memory depending on the total amount of memory available and the
    distribution of item sizes.

    | Type: float
    | Default: 1.1
    | Dynamic: no

.. _cfg_storage-slab_alloc_maximal:

.. confval:: slab_alloc_maximal

    Size of the largest allocation unit. It can be increased if it
    is necessary to store large tuples.

    | Type: integer
    | Default: 1048576
    | Dynamic: no

.. _cfg_storage-slab_alloc_minimal:

.. confval:: slab_alloc_minimal

    Size of the smallest allocation unit. It can be decreased if most of the
    tuples are very small. The value must be between 8 and 1048280 inclusive.

    | Type: integer
    | Default: 16
    | Dynamic: no

.. _cfg_storage-vinyl:

.. confval:: vinyl

    The default vinyl configuration can be changed with

    .. cssclass:: highlight
    .. parsed-literal::

        vinyl = {
            memory_limit = *number*,
            compact_wm = *number*,
            threads = *number*,
        }

    .. _cfg_storage-vinyl_memory_limit:

    .. confval:: memory_limit

        The maximum number of in-memory bytes that vinyl uses.

        | Type: integer.
        | Default = 1.
        | Dynamic: no

    .. _cfg_storage-vinyl_compact_wm:

    .. confval:: compact_wm

        The "compaction watermark". If the number of runs
        becomes greater than compact_wm, then compaction occurs.

        | Type: integer.
        | Default: 2.
        | Dynamic: no

    .. _cfg_storage-vinyl_threads:

    .. confval:: threads

        The maximum number of threads that vinyl can use for some
        concurrent operations, such as I/O and compression.

        | Type: integer.
        | Default = 1.
        | Dynamic: no

    This method may change in the future.

.. _LZ4 algorithm: https://en.wikipedia.org/wiki/LZ4_%28compression_algorithm%29
.. _ZStandard algorithm: http://zstd.net
