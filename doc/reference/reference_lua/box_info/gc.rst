.. _box_info_gc:

================================================================================
box.info.gc()
================================================================================

.. module:: box.info

.. function:: gc()

    The **gc** function of ``box.info`` gives the ``admin`` user a
    picture of the factors that affect the
    :ref:`Tarantool garbage collector <cfg_checkpoint_daemon-garbage-collector>`.
    The garbage collector compares vclock (:ref:`vector clock <replication-vector>`)
    values of users and checkpoints, so a look at ``box.info.gc()`` may show why the
    garbage collector has not removed old WAL files, or show what it may soon remove.

    * **gc().consumers** -- a list of users whose requests might affect the garbage collector.
    * **gc().checkpoints** -- a list of preserved checkpoints.
    * **gc().checkpoints[n].references** -- a list of references to a checkpoint.
    * **gc().checkpoints[n].vclock** -- a checkpoint's vclock value.
    * **gc().checkpoints[n].signature** -- a sum of a checkpoint's vclock's components.
    * **gc().checkpoint_is_in_progress** -- true if a checkpoint is in progress, otherwise false
    * **gc().vclock** -- the garbage collector's vclock.
    * **gc().signature** -- the sum of the garbage collector's checkpoint's components.
    * **gc().wal_retention_vclock** -- the minimum vclock value. See also: :ref:`wal.retention_period <configuration_reference_wal_retention_period>`.
