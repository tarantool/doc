.. _box_runtime_info:

================================================================================
box.runtime.info()
================================================================================

.. module:: box.slab

.. function:: box.runtime.info()

    Show a memory usage report (in bytes) for the runtime arena.
    The runtime arena encompasses internal Lua memory as well as network buffers
    and other memory expenses associated with the application server subsystem.

    :return:

      * ``lua`` is the heap size of the Lua garbage collector.
      * ``maxalloc`` is the maximum size of the runtime arena.
      * ``used`` is the current memory size used by the runtime arena.

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