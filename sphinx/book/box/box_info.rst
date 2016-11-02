.. _box_introspection-box_info:

--------------------------------------------------------------------------------
Submodule `box.info`
--------------------------------------------------------------------------------

.. module:: box.info

The ``box.info`` submodule provides access to information about server variables.

* **server.lsn** Log Sequence Number for the latest entry in the WAL.
* **server.ro**  True if the server is in "read_only" mode
  (same as :ref:`read_only <cfg_basic-read_only>` in box.cfg).
* **server.uuid** The unique identifier of this server,
  as stored in the database. This value is also
  in the :ref:`box.space._cluster <box_space-cluster>` system space.
* **server.id** The number of this server within a cluster.
* **version** Tarantool version. This value is also shown by
  :ref:`tarantool --version <index-tarantool_version>`.
* **status** Usually this is 'running', but it can be 'loading', 'orphan', or 'hot_standby'.
* **vclock** Same as replication.vclock.
* **pid** Process ID. This value is also shown by the
  :ref:`tarantool <tarantool-build>` module.
  This value is also shown by the Linux "ps -A" command.
* **cluster.uuid** UUID of the cluster. Every server in a cluster will have the same cluster.uuid value.
  This value is also in the :ref:`box.space._schema <box_space-schema>` system space.
* **vinyl()** Returns runtime statistics for the vinyl storage engine.
* **replication.lag** Number of seconds that the replica is behind the master.
* **replication.status** Usually this is 'follow', but it can be
  'off', 'stopped', 'connecting', 'auth', or 'disconnected'.
* **replication.idle** Number of seconds that the server has been idle.
* **replication.vclock** See the :ref:`discussion of "vector clock" <internals-vector>` in the Internals section.
* **replication.uuid** The unique identifier of a master to which this server is connected.
* **replication.uptime** Number of seconds since the server started.
  This value can also be retrieved with :ref:`tarantool.uptime() <tarantool-build>`.

The replication fields are blank unless the server is a :ref:`replica <index-box_replication>`.
The replication fields are in an array if the server is a replica for more than one master.

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

