.. _box_info_info:

================================================================================
box.info()
================================================================================

.. module:: box.info

.. function:: box.info()

    Get all keys and values provided by the ``box.info`` submodule.
    Since ``box.info`` contents are dynamic, it's not possible to iterate over
    keys with the Lua ``pairs()`` function. For this purpose, ``box.info()``
    builds and returns a Lua table with all keys and values provided in the
    submodule.

    :return: keys and values in the submodule
    :rtype:  table

    **Example**

    This example is for a master-replica set that contains one master instance
    and one replica instance. The request was issued at the replica instance.

    ..  code-block:: tarantoolsession

        sharded_cluster_crud:storage-a-002> box.info()
        ---
        - version: 3.2.0-entrypoint-218-gf8d77dbec
          id: 2
          ro: true
          uuid: 5a879b0e-9b53-4053-980a-be1a39ad1166
          pid: 12059
          replicaset:
            uuid: 90dc4d6c-3f7d-45e5-aa5a-55903b0a79c9
            name: storage-a
          schema_version: 87
          listen: 127.0.0.1:3303
          replication_anon:
            count: 0
          replication:
            1:
              id: 1
              uuid: ffb1b8bb-d59f-4eee-ad3e-91058e6f5486
              lsn: 1092
              upstream:
                status: follow
                idle: 0.99728900000082
                peer: replicator@127.0.0.1:3302
                lag: 0.00025296211242676
              name: storage-a-001
              downstream:
                status: follow
                idle: 0.18575600000077
                vclock: {1: 1092}
                lag: 0
            2:
              id: 2
              uuid: 5a879b0e-9b53-4053-980a-be1a39ad1166
              lsn: 0
              name: storage-a-002
          package: Tarantool
          hostname: demo.example.com
          election:
            state: follower
            vote: 0
            leader: 0
            term: 1
          signature: 1092
          synchro:
            queue:
              owner: 0
              confirm_lag: 0
              term: 0
              age: 0
              len: 0
              busy: false
            quorum: 2
          status: running
          sql: []
          vclock: {1: 1092}
          uptime: 229
          lsn: 0
          vinyl: []
          ro_reason: config
          memory: []
          gc: []
          cluster:
            name: null
          name: storage-a-002
          config:
            status: ready
            meta:
              last: &0 []
              active: *0
            alerts: []
        ...
