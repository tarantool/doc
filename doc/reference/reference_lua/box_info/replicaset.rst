.. _box_info_replicaset:

================================================================================
box.info.replicaset
================================================================================

.. module:: box.info

.. data:: replicaset

    Since: :doc:`3.0.0 </release/3.0.0>`

    Information about the replica set to which the current instance belongs.
    The returned table contains the following fields:

    *   ``name`` -- the replica set name
    *   ``uuid`` -- the replica set UUID

    You can specify the names of replica sets when :ref:`configuring <configuration>` a cluster topology.

    :rtype: table
