.. _box_info_config:

================================================================================
box.info.config
================================================================================

.. module:: box.info

.. data:: config

    Since: :doc:`3.2.0 </release/3.2.0>`

    The instance's state in regard to configuration.
    Note that ``box.info.config`` returns the instance's state obtained using :ref:`config:info('v2') <config_api_reference_info>`.

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
        ...
