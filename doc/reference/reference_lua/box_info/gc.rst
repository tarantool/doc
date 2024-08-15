.. _box_info_gc:

================================================================================
box.info.gc()
================================================================================

.. module:: box.info

.. function:: gc()

    Get information about the :ref:`Tarantool garbage collector <configuration_persistence_garbage_collector>`.
    The garbage collector compares vclock (:ref:`vector clock <replication-vector>`)
    values of users and checkpoints, so a look at ``box.info.gc()`` may show why the
    garbage collector has not removed old WAL files, or show what it may soon remove.

    * ``consumers`` -- a list of users whose requests might affect the garbage collector.
    * ``checkpoints`` -- a list of preserved checkpoints.
    * ``checkpoints[n].references`` -- a list of references to a checkpoint.
    * ``checkpoints[n].vclock`` -- a checkpoint's vclock value.
    * ``checkpoints[n].signature`` -- a sum of a checkpoint's vclock's components.
    * ``checkpoint_is_in_progress`` -- true if a checkpoint is in progress, otherwise false
    * ``vclock`` -- the garbage collector's vclock.
    * ``signature`` -- the sum of the garbage collector's checkpoint's components.
    * ``wal_retention_vclock`` -- a vclock value of the oldest write-ahead log file protected from removing by the garbage collector by using the :ref:`wal.retention_period <configuration_reference_wal_retention_period>` option.
