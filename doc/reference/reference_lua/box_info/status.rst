.. _box_info_status:

================================================================================
box.info.status
================================================================================

.. module:: box.info

.. data:: status

    The current state of the instance. It can be:

    *   ``running`` -- the instance is loaded
    *   ``loading`` -- the instance is either recovering xlogs/snapshots or bootstrapping
    *   ``orphan`` --  the instance has not (yet) succeeded in joining the required number of masters (see :ref:`orphan status <replication-orphan_status>`)
    *   ``hot_standby`` -- the instance is :ref:`standing by <configuration_reference_database_hot_standby>` another instance

    :rtype: string
