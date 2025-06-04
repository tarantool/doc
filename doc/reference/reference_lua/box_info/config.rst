.. _box_info_config:

================================================================================
box.info.config
================================================================================

.. module:: box.info

.. data:: config

    Since: :doc:`3.2.0 </release/3.2.0>`

    The instance's state in regard to configuration.
    Note that ``box.info.config`` returns the instance's state obtained using :ref:`config:info('v2') <config_api_reference_info>`.

    Since version :doc:`3.3.0 </release/3.3.0>`.
    Returns the ``hierarchy`` table, showing names of the group, replicaset, and the instance itself.
    These names are taken directly from the ``--name`` CLI option (or the ``TT_INSTANCE_NAME`` environment variable) 
    and the cluster configuration. This means they are always present if the YAML configuration flow is in use, 
    disregarding the database status (whether upgraded, writable or not).

    :rtype: table

    **Example**

    ..  code-block:: tarantoolsession

        sharded_cluster_crud:storage-a-002> box.info.config
        ---
        - status: ready
          meta:
            last: &0 []
            active: *0
          alerts: []
          hierarchy:
            group: storages
            replicaset: storage-a
            instance: storage-a-002
        ...
