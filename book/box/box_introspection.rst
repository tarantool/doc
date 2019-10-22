.. _box_introspection-box_cfg:

--------------------------------------------------------------------------------
Submodule `box.cfg`
--------------------------------------------------------------------------------

.. module:: box.cfg

The ``box.cfg`` submodule is for administrators to specify all the server
configuration parameters (see "Configuration reference" for
:ref:`a complete description of all configuration parameters <box_cfg_params>`).
Use ``box.cfg`` without braces to get read-only access to those parameters.

**Example:**

.. code-block:: tarantoolsession

    tarantool> box.cfg
    ---
    - checkpoint_count: 2
      too_long_threshold: 0.5
      slab_alloc_factor: 1.1
      memtx_max_tuple_size: 1048576
      background: false
      <...>
    ...

.. _box_introspection-box_info:

--------------------------------------------------------------------------------
Submodule `box.info`
--------------------------------------------------------------------------------

.. module:: box.info

The ``box.info`` submodule provides access to information about server instance variables.
Some of this information is also available from the :ref:`tarantool module <tarantool-module>`.

* **server.lsn** Log Sequence Number for the latest entry in the :ref:`WAL <internals-wal>`.
* **server.ro**  True if the instance is in "read_only" mode
  (same as :ref:`read_only <cfg_basic-read_only>` in box.cfg).
* **server.uuid** The unique identifier of this instance,
  as stored in the database. This value is also
  in the :ref:`box.space._cluster <box_space-cluster>` system space.
* **server.id** The number of this server's instance within a replica set.
* **version** Tarantool version. This value is also shown by
  :ref:`tarantool --version <index-tarantool_version>`.
* **status** Usually this is 'running', but it can be 'loading', 'orphan', or 'hot_standby'.
* **vclock** Same as :ref:`replication.vclock <replication-vector>`.
* **pid** Process ID. This value is also shown by the
  :ref:`tarantool <tarantool-build>` module.
  This value is also shown by the Linux "ps -A" command.
* **cluster.uuid** UUID of the :ref:`replica set <replication-mechanism>`. Every instance in a replica set will have the same cluster.uuid value.
  This value is also in the :ref:`box.space._schema <box_space-schema>` system space.
* **vinyl()** Returns runtime statistics for the vinyl storage engine.
* **replication.lag** Number of seconds that the replica is behind the master.
* **replication.status** Usually this is 'follow', but it can be
  'off', 'stopped', 'connecting', 'auth', or 'disconnected'.
* **replication.idle** Number of seconds that the instancehas been idle.
* **replication.vclock** See the :ref:`discussion of "vector clock" <replication-vector>` in the Internals section.
* **replication.uuid** The unique identifier of a master to which this instance is connected.
* **replication.uptime** Number of seconds since the instance started.
  This value can also be retrieved with :ref:`tarantool.uptime() <tarantool-build>`.

The replication fields are blank unless the instance is a :ref:`replica <index-box_replication>`.
The replication fields are in an array if the instance is a replica for more than one master.


.. function:: box.info()

    Since ``box.info`` contents are dynamic, it's not possible to iterate over
    keys with the Lua ``pairs()`` function. For this purpose, ``box.info()``
    builds and returns a Lua table with all keys and values provided in the
    submodule.

    :return: keys and values in the submodule.
    :rtype:  table

    **Example:**

    .. code-block:: tarantoolsession

        tarantool> box.info()
        ---
        - server:
            lsn: 158
            ro: false
            uuid: a2684219-b2b1-4334-88ab-50b0722283fd
            id: 1
          version: 1.7.2-435-g6ba8500
          pid: 12932
          status: running
          vclock:
          - 158
          replication:
            status: off
          uptime: 908
        ...
        tarantool> box.info.pid
        ---
        - 12932
        ...
        tarantool> box.info.status
        ---
        - running
        ...
        tarantool> box.info.uptime
        ---
        - 1065
        ...
        tarantool> box.info.version
        ---
        - 1.7.2-435-g6ba8500
        ...

.. _box_introspection-box_slab:

--------------------------------------------------------------------------------
Submodule `box.slab`
--------------------------------------------------------------------------------

.. module:: box.slab

The ``box.slab`` submodule provides access to slab allocator statistics. The
slab allocator is the main allocator used to store tuples. This can be used
to monitor the total memory use and memory fragmentation.

The display of slabs is broken down by the slab size -- 64-byte, 136-byte,
and so on. The example omits the slabs which are empty. The example display
is saying that:
* there are 16 items stored in the 64-byte slab (and 16*64=102 so bytes_used = 1024);
* there is 1 item stored in the 136-byte slab (and 136*1=136 so bytes_used = 136);
* the ``arena_used`` value is the total of all the bytes_used values (1024+136 = 1160);
* the ``arena_size`` value is the ``arena_used`` value plus the total of all the
  bytes_free values (1160+4193200+4194088 = 8388448).

The ``arena_size`` and ``arena_used`` values are the amount of the % of
:ref:`memtx_memory <cfg_storage-memtx_memory>` that is already distributed to the
slab allocator.

**Example:**

.. code-block:: tarantoolsession

    tarantool> box.slab.info().arena_used
    ---
    - 4194304
    ...
    tarantool> box.slab.info().arena_size
    ---
    - 104857600
    ...
    tarantool> box.slab.stats()
    ---
    - - mem_free: 16248
        mem_used: 48
        item_count: 2
        item_size: 24
        slab_count: 1
        slab_size: 16384
      - mem_free: 15736
        mem_used: 560
        item_count: 14
        item_size: 40
        slab_count: 1
        slab_size: 16384
        <...>
    ...
    tarantool> box.slab.stats()[1]
    ---
    - mem_free: 15736
      mem_used: 560
      item_count: 14
      item_size: 40
      slab_count: 1
      slab_size: 16384
    ...

.. _box_introspection-box_stat:

--------------------------------------------------------------------------------
Submodule `box.stat`
--------------------------------------------------------------------------------

The ``box.stat`` submodule provides access to request and network statistics.
Show the average number of requests per second, and the total number of
requests since startup, broken down by request type.
Also, show network activity statistics.

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
      RECEIVED:
        total: 0
        rps: 0
    ...
