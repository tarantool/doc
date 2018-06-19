.. _box_introspection-box_stat:

--------------------------------------------------------------------------------
Submodule `box.stat`
--------------------------------------------------------------------------------

The ``box.stat`` submodule provides access to request and network statistics.
Show the average number of requests per second, and the total number of
requests since startup, broken down by request type.

Use ``box.stat.net()``  to see network activity: the number of packets sent
and received, and the average number of requests per second.

.. _box_introspection-box_stat_vinyl:

Use ``box.stat.vinyl()`` to see vinyl-storage-engine activity, for example:

* ``box.stat.vinyl().cache`` has the cache limit,
* ``box.stat.vinyl().tx`` has the number of commits and rollbacks,
* ``box.stat.vinyl().quota`` has the number of bytes used.

.. code-block:: tarantoolsession

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
      RECEIVED:
        total: 0
        rps: 0
    ...
    tarantool> box.stat.vinyl().tx.commit -- a selected item of the table
    ---
    - 1047632
    ...

