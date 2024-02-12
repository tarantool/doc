..  _configuration_memtx:

In-memory storage
=================

**Example on GitHub**: `snapshot <https://github.com/tarantool/doc/tree/latest/doc/code_snippets/snippets/config/instances.enabled/memtx>`_

In Tarantool, all data is stored in random-access memory (RAM) by default.
For this purpose, the :ref:`memtx <engines-memtx>` storage engine is used.

This topic describes how to define settings related to in-memory storage in the
:ref:`memtx <configuration_reference_memtx>` section of a :ref:`YAML configuration <configuration>`.

..  NOTE::

    To calculate the required amount of memory, you can use the
    `sizing calculator <https://www.tarantool.io/en/sizing_calculator/>`_.

..  _configuration_memtx-memory:

Configure the memory size
-------------------------

In Tarantool, data is stored in spaces.
Each space consists of tuples -- the database records.
To specify the amount of memory that Tarantool allocates to actually store tuples, use the
:ref:`memtx.memory <configuration_reference_snapshot_dir>` configuration option.

In the example below, the memory size is 100000000 bytes, which is about 95 MB.
The server does not exceeds this limit to allocate tuples.
For indexes and connection information, the additional memory is used.

When the ``memtx.memory`` limit is reached, ``INSERT`` or ``UPDATE`` requests fail with
:ref:`ER_MEMORY_ISSUE <admin-troubleshoot-memory-issues>`.

..  literalinclude:: /code_snippets/snippets/config/instances.enabled/memtx/config.yaml
    :language: yaml
    :start-at: memtx:
    :end-at: 100000000
    :dedent:

..  _configuration_memtx-allocator:

Specify the allocator type
--------------------------

The allocators are the memory managers used for different purposes.
To set the allocator type that manages memory for ``memtx`` tuples, use the :ref:`memtx.allocator <configuration_reference_memtx_allocator>`
configuration option.

Possible types:

*   ``system`` -- the memory is allocated as needed, checking that the quota is not exceeded.

*   ``small`` (default) -- a `slab allocator <https://github.com/tarantool/small>`_ mechanism is used.

The example below shows how to specify the ``small`` allocator type:

..  literalinclude:: /code_snippets/snippets/config/instances.enabled/memtx/config.yaml
    :language: yaml
    :start-at: allocator:
    :end-at: 'small'
    :dedent:

..  _configuration_memtx-min-max:

Specify the size limitations of the allocation unit
---------------------------------------------------

You can configure the sizes of the smallest and the largest units to allocate.

To set the minimum size in bytes, use the :ref:`memtx.min_tuple_size <configuration_reference_memtx_min_size>` configuration option.
The setting can be useful if the tuples that you store are small.
The minimum size is a value between 8 and 1048280 inclusive.

..  literalinclude:: /code_snippets/snippets/config/instances.enabled/memtx/config.yaml
    :language: yaml
    :start-at: min_tuple_size: 8
    :end-at: min_tuple_size: 8
    :dedent:

To set the maximum size in bytes, use the :ref:`memtx.max_tuple_size <configuration_reference_memtx_max_size>` configuration option.
The setting can be useful if the tuples that you store are large.

..  literalinclude:: /code_snippets/snippets/config/instances.enabled/memtx/config.yaml
    :language: yaml
    :start-at: max_tuple_size:
    :end-at: 1048576
    :dedent:


..  _configuration_memtx-slab-alloc-granularity:

Specify the granularity for slab allocation
-------------------------------------------

If you use the :ref:`small <configuration_reference_memtx_allocator>` type of allocator, you can set the granularity of
memory allocation in it.
The granularity value should meet the following conditions:

*   The value is a power of two.
*   The value is greater than or equal to 4.

If the tuples in space are small and have about the same size, set the option to 4 bytes to save memory.
If the tuples are different-sized, increase the option value to allocate tuples from the same ``mempool`` (memory pool).

In the example below, the value is increased to store different-sized tuples:

..  literalinclude:: /code_snippets/snippets/config/instances.enabled/memtx/config.yaml
    :language: yaml
    :start-at: slab_alloc_granularity:
    :end-at: 8
    :dedent:

..  _configuration_memtx-slab-alloc-factor:

Specify the slab allocation factor
----------------------------------

The size and number of memory pools depends on allocation factor and granularity.
The allocation factor is a multiplier used to calculate the sizes of memory chunks that tuples are stored in.
To configure the allocation factor, use the :ref:`memtx.slab_alloc_factor <configuration_reference_memtx_slab_alloc_factor>`
configuration option.
The option is a value between 1 and 2.

In the example below, the option is set to the default value:

..  literalinclude:: /code_snippets/snippets/config/instances.enabled/memtx/config.yaml
    :language: yaml
    :start-at: slab_alloc_factor:
    :end-at: 1.05
    :dedent:

..  _configuration_memtx-sort-threads:

Set the number of the sorting threads
-------------------------------------

It is possible to configure the number of threads that are used to sort keys of secondary indexes on loading
``memtx`` database.
To do it, use the :ref:`memtx.sort_threads <configuration_reference_memtx_sort_threads>` configuration option.

In the example, the maximum number of threads is used (256):

..  literalinclude:: /code_snippets/snippets/config/instances.enabled/memtx/config.yaml
    :language: yaml
    :start-at: sort_threads:
    :end-at: 256
    :dedent:

..  _configuration_memtx-statistics:

Check the database statistics
-----------------------------

Tarantool provides the statistics about memory consumption for the given space or specific tuples.
Available statistics:

*   The amount of memory used for the data of the specified space.
*   The amount of additional memory used for the supplementary information.
*   The total memory usage.

..  _configuration_memtx-statistics-space:

Space
~~~~~

To get the get the amount of memory in bytes occupied by the specified space, use the :ref:`space_object:bsize() <box_space-bsize>` method.
The function returns the total number of bytes in all tuples.

..  code-block:: console

    memtx:instance001> box.space.books:bsize()
    ---
    - 70348673
    ...

..  _configuration_memtx-statistics-additional:

Additional memory
~~~~~~~~~~~~~~~~~

To check the usage of the additional memory (5 Mb), use the ``space_object:stat()`` method.
The following information is provided:

-   ``header_size`` and ``field_map_size``: the size of service information.
-   ``data_size``: the actual size of data, which equals to ``space_object:bsize()``.
-   ``waste_size``: the size of memory wasted due to internal fragmentation in the `slab allocator <https://github.com/tarantool/small>`_.

.. code-block:: console

    memtx:instance001> box.space.books:stat()
    ---
    - tuple:
        memtx:
          waste_size: 1744011
          data_size: 70348673
          header_size: 2154132
          field_map_size: 0
        malloc:
          waste_size: 0
          data_size: 0
          header_size: 0
          field_map_size: 0
    ...

To get the usage of the additional memory (5 Mb) for the specified tuple, use ``tuple_object:info()``:

.. code-block:: console

    memtx:instance001> box.space.books:get('1853260622'):info()
    ---
    - data_size: 277
      waste_size: 9
      arena: memtx
      field_map_size: 0
      header_size: 10
    ...

..  _configuration_memtx-statistics-total:

Total memory usage
~~~~~~~~~~~~~~~~~~

To get the total memory usage in bytes for the slab allocator, use the :ref:`box.slab.info() <box_slab_info>` function:

..  code-block:: console

    memtx:instance001> box.slab.info().items_used
    ---
    - 75302024
    ...
