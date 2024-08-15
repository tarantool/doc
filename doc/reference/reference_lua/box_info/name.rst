.. _box_info_name:

================================================================================
box.info.name
================================================================================

.. module:: box.info

.. data:: name

    Since: :doc:`3.0.0 </release/3.0.0>`

    The name of the current instance.
    You can specify the names of instances when :ref:`configuring <configuration>` a cluster topology.

    :rtype: string

    **Example**

    ..  code-block:: tarantoolsession

        sharded_cluster_crud:storage-a-002> box.info.name
        ---
        - storage-a-002
        ...
