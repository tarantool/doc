.. _box_introspection-box_stat:

--------------------------------------------------------------------------------
Submodule `box.stat`
--------------------------------------------------------------------------------

The ``box.stat`` submodule provides access to request and network statistics.
Show the average number of requests per second, and the total number of
requests since startup, broken down by request type and network events statistics.

.. code-block:: tarantoolsession

    tarantool> type(box.stat), type(box.stat.net) -- virtual tables
    ---
    - table
    - table
    ...
    tarantool> box.stat, box.stat.net
    ---
    - net: []
    - []
    ...
    tarantool> box.stat()
    ---
    - DELETE:
        total: 1873949
        rps: 123
      SELECT:
        total: 1237723
        rps: 4099
      INSERT:
        total: 0
        rps: 0
      EVAL:
        total: 0
        rps: 0
      CALL:
        total: 0
        rps: 0
      REPLACE:
        total: 1239123
        rps: 7849
      UPSERT:
        total: 0
        rps: 0
      AUTH:
        total: 0
        rps: 0
      ERROR:
        total: 0
        rps: 0
      UPDATE:
        total: 0
        rps: 0
    ...
    tarantool> box.stat().DELETE -- a selected item of the table
    ---
    - total: 0
      rps: 0
    ...
    tarantool> box.stat.net()
    ---
    - SENT:
        total: 0
        rps: 0
      EVENTS:
        total: 2
        rps: 0
      LOCKS:
        total: 6
        rps: 0
      RECEIVED:
        total: 0
        rps: 0
    ...
