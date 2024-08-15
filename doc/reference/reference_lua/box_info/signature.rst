.. _box_info_signature:

================================================================================
box.info.signature
================================================================================

.. module:: box.info

.. data:: signature

    The sum of all ``lsn`` values from each :ref:`vector clock <replication-vector>` (**vclock**) for all instances in the replica set the current instance belongs to.

    :rtype: number
