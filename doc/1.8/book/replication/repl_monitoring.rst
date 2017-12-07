.. _replication-monitoring:

================================================================================
Monitoring a replica set
================================================================================

To learn what instances belong in the replica set, and obtain statistics for all
these instances, use ``box.info.replication`` request:

.. code-block:: tarantoolsession

   box.info.replication
   ---
     replication:
       1:
         id: 1
         uuid: b8a7db60-745f-41b3-bf68-5fcce7a1e019
         lsn: 88
       2:
         id: 2
         uuid: cd3c7da2-a638-4c5d-ae63-e7767c3a6896
         lsn: 31
         upstream:
           status: follow
           idle: 43.187747001648
           peer: replicator@192.168.0.102:3301
           lag: 0
         downstream:
        vclock: {1: 31}
       3:
         id: 3
         uuid: e38ef895-5804-43b9-81ac-9f2cd872b9c4
         lsn: 54
         upstream:
           status: follow
           idle: 43.187621831894
           peer: replicator@192.168.0.103:3301
           lag: 2
         downstream:
           vclock: {1: 54}
   ...

This report is for a master-master replica set of three instances, each having
its own instance id, UUID and log sequence number.

.. image:: mm-3m-mesh.svg
    :align: center

The request was issued at master #1, and the reply includes statistics for the
other two masters, given in regard to master #1.

The primary indicators of replication health are ``idle`` and ``lag`` parameters
(see reference on :ref:`box.info.replication <box_info_replication>` for details).
