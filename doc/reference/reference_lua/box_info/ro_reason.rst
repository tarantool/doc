.. _box_info_ro-reason:

================================================================================
box.info.ro_reason
================================================================================

..  module:: box.info

    Possible error reasons:

    *   ``election`` -- the instance is not a leader.
        That is, ``box.cfg.election_mode`` is not ``off``.
        See :ref:`box.info.election <box_info_election>` for details.

    *   ``synchro`` -- the instance is not the owner of the synchronous transaction queue.
        For details, see :ref:`box.info.synchro <box_info_synchro>`.

    *   ``config`` -- the server instance is in read-only mode.
        That is, :ref:`box.cfg.read_only <cfg_basic-read_only>` is ``true``.

    *   ``orphan`` -- the instance is in ``orphan`` state.
        For details, see :ref:`the orphan status page <internals-replication-orphan_status>`.
