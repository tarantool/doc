.. _box_info_info:

================================================================================
box.info()
================================================================================

.. module:: box.info

.. function:: box.info()

    Since ``box.info`` contents are dynamic, it's not possible to iterate over
    keys with the Lua ``pairs()`` function. For this purpose, ``box.info()``
    builds and returns a Lua table with all keys and values provided in the
    submodule.

    :return: keys and values in the submodule
    :rtype:  table

    **Example:**

    This example is for a master-replica set that contains one master instance
    and one replica instance. The request was issued at the replica instance.

    .. code-block:: tarantoolsession

        tarantool> box.info()
        ---
        - version: 2.4.0-251-gc44ed3c08
          id: 1
          ro: false
          uuid: 1738767b-afa3-4987-b485-c333cf83415b
          package: Tarantool
          cluster:
            uuid: 40ee7f0f-7070-4650-8883-801e7014407c
          listen: '[::1]:57122'
          replication:
            1:
              id: 1
              uuid: 1738767b-afa3-4987-b485-c333cf83415b
              lsn: 16
          signature: 16
          status: running
          vinyl: []
          uptime: 21
          lsn: 16
          sql: []
          gc: []
          pid: 20293
          memory: []
          vclock: {1: 16}
        ...
