.. _cfg_storage-slab_alloc_arena:

.. confval:: slab_alloc_arena

    How much memory Tarantool allocates to actually store tuples, in gigabytes.
    When the limit is reached, INSERT or UPDATE requests begin failing with
    error :errcode:`ER_MEMORY_ISSUE`. While the server does not go beyond the defined
    limit to allocate tuples, there is additional memory used to store indexes
    and connection information. Depending on actual configuration and workload,
    Tarantool can consume up to 20% more than the limit set here.

    Type: float |br|
    Default: 1.0 |br|
    Dynamic: no |br|

.. _cfg_storage-slab_alloc_factor:

.. confval:: slab_alloc_factor

    Use slab_alloc_factor as the multiplier for computing the sizes of memory
    chunks that tuples are stored in. A lower value may result in less wasted
    memory depending on the total amount of memory available and the
    distribution of item sizes.

    Type: float |br|
    Default: 1.1 |br|
    Dynamic: no |br|

.. _cfg_storage-slab_alloc_maximal:

.. confval:: slab_alloc_maximal

    Size of the largest allocation unit. It can be increased if it
    is necessary to store large tuples.

    Type: integer |br|
    Default: 1048576 |br|
    Dynamic: no |br|

.. _cfg_storage-slab_alloc_minimal:

.. confval:: slab_alloc_minimal

    Size of the smallest allocation unit. It can be decreased if most
    of the tuples are very small. The value must be between 8 and 1048280 inclusive.

    Type: integer |br|
    Default: 16 |br|
    Dynamic: no |br|

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

    ``memory_limit`` |br|
    Type: integer. Default = 1. Dynamic: no |br|
    The maximum number of in-memory bytes that vinyl uses.

    ``compact_wm`` |br|
    Type: integer. Default: 2. Dynamic: no |br|
    The "compaction watermark". If the number of runs
    becomes greater than compact_wm, then compaction occurs.

    ``threads`` |br|
    Type: integer. Default = 1. Dynamic: no |br|
    The maximum number of threads that vinyl can use for some
    concurrent operations, such as I/O and compression.

    This method may change in the future.

.. _LZ4 algorithm: https://en.wikipedia.org/wiki/LZ4_%28compression_algorithm%29
.. _ZStandard algorithm: http://zstd.net
