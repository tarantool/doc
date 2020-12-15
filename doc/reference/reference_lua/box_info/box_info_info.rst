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
        - version: 1.7.6-68-g51fcffb77
          id: 2
          ro: true
          vclock: {1: 5}
          uptime: 917
          lsn: 0
          vinyl: []
          cluster:
            uuid: 783e2285-55b1-42d4-b93c-68dcbb7a8c18
          pid: 35341
          status: running
          signature: 5
          replication:
            1:
              id: 1
              uuid: 471cd36e-cb2e-4447-ac66-2d28e9dd3b67
              lsn: 5
              upstream:
                status: follow
                idle: 124.98795700073
                peer: replicator@192.168.0.101:3301
                lag: 0
              downstream:
                vclock: {1: 5}
            2:
              id: 2
              uuid: ac45d5d2-8a16-4520-ad5e-1abba6baba0a
              lsn: 0
          uuid: ac45d5d2-8a16-4520-ad5e-1abba6baba0a
        ...
