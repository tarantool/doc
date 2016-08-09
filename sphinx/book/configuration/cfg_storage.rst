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
          run_age_wm = *number*,
          run_age_period = *number of seconds*,
          memory_limit = *number of gigabytes*,
          compact_wm = *number*,
          threads = *number*,
          run_age = *number*,
          run_prio = *number*,
        }

    This method may change in the future.

    Default values are:

    .. cssclass:: highlight
    .. parsed-literal::

        vinyl = {
          run_age_wm = 0,
          run_age_period = 0,
          memory_limit = 1,
          compact_wm = 2,
          threads = 5,
          run_age = 0,
          run_prio = 2,
        }

.. _LZ4 algorithm: https://en.wikipedia.org/wiki/LZ4_%28compression_algorithm%29
.. _ZStandard algorithm: http://zstd.net
