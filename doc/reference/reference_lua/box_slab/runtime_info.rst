.. _box_runtime_info:

================================================================================
box.runtime.info()
================================================================================

.. module:: box.slab

.. function:: box.runtime.info()

    Show a memory usage report (in bytes) for the Lua runtime.

    :return:

      * ``lua`` is the heap size of the Lua garbage collector;
      * ``maxalloc`` is the maximal memory quota that can be allocated for Lua;
      * ``used`` is the current memory size used by Lua.

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