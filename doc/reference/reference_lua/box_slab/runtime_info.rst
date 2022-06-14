.. _box_runtime_info:

================================================================================
box.runtime.info()
================================================================================

.. module:: box.slab

.. function:: box.runtime.info()

    Show runtime memory usage report in bytes.

    The runtime memory encompasses internal Lua memory as well as the runtime arena.
    The Lua memory stores Lua objects.
    The runtime arena stores Tarantool-specific objects -- for example, runtime tuples, network buffers
    and other objects associated with the application server subsystem.

    :return:

      * ``lua`` is the size of the Lua heap that is controlled by the Lua garbage collector.
      * ``maxalloc`` is the maximum size of the runtime memory.
      * ``used`` is the current number of bytes used by the runtime memory.

    :rtype:  table

    **Example:**

    .. code-block:: tarantoolsession

      tarantool> box.runtime.info()
      ---
      - lua: 913710
        maxalloc: 4398046510080
        used: 12582912
      ...
      tarantool> box.runtime.info().used
      ---
      - used: 12582912
      ...