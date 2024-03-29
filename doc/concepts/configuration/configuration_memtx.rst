..  _configuration_memtx:

In-memory storage
=================

**Example on GitHub**: `memtx <https://github.com/tarantool/doc/tree/latest/doc/code_snippets/snippets/config/instances.enabled/memtx>`_

In Tarantool, all data is stored in random-access memory (RAM) by default.
For this purpose, the :ref:`memtx <engines-memtx>` storage engine is used.

This topic describes how to define basic settings related to in-memory storage in the
:ref:`memtx <configuration_reference_memtx>` section of a :ref:`YAML configuration <configuration>`
-- for example, :ref:`memory size <configuration_reference_memtx_memory>` and :ref:`maximum tuple size <configuration_reference_memtx_max_size>`.
For the specific settings related to allocator or sorting threads,
check the corresponding ``memtx`` options in the :ref:`Configuration reference <configuration_reference_memtx>`.

..  NOTE::

    To estimate the required amount of memory, you can use the
    `sizing calculator <https://www.tarantool.io/en/sizing_calculator/>`_.

..  _configuration_memtx-memory:

Memory size
-----------

In Tarantool, data is stored in spaces.
Each space consists of tuples -- the database records.
To specify the amount of memory that Tarantool allocates to store tuples, use the
:ref:`memtx.memory <configuration_reference_memtx_memory>` configuration option.

In the example below, the memory size is set to 1 GB (1073741824 bytes):

..  literalinclude:: /code_snippets/snippets/config/instances.enabled/memtx/config.yaml
    :language: yaml
    :start-at: memtx:
    :end-at: 1073741824
    :dedent:

The server does not exceed this limit to allocate tuples.
For indexes and connection information, additional memory is used.

When the ``memtx.memory`` limit is reached, ``INSERT`` or ``UPDATE`` requests fail with
:ref:`ER_MEMORY_ISSUE <admin-troubleshoot-memory-issues>`.

..  _configuration_memtx-tuple-size:

Tuple size
----------

You can configure the minimum and the maximum tuple sizes in bytes.

*   If the tuples are small, you can decrease the minimum size.
*   If the tuples are large, you can increase the maximum size.

To define the tuple size, use the :ref:`memtx.min_tuple_size <configuration_reference_memtx_min_size>` and
:ref:`memtx.max_tuple_size <configuration_reference_memtx_max_size>` configuration options.

In the example, the minimum size is set to 8 bytes and the maximum size is set to 5 MB:

..  literalinclude:: /code_snippets/snippets/config/instances.enabled/memtx/config.yaml
    :language: yaml
    :start-at: memtx:
    :end-at: 5242880
    :dedent:
