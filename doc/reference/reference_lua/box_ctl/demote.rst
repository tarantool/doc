.. _box_ctl-demote:

box.ctl.demote()
=================

..  function:: demote()

    Revoke the leader role of the instance.

    The function is NOP (No operation) on any instance but the
    :ref:`synchronous transaction queue owner <box_info_synchro>`.
    If the node is not the owner, the function does nothing and returns immediately.

    On synchronous transaction queue owner, the function works in the following way:

    *   If :ref:`box.cfg.election_mode <cfg_replication-election_mode>` is ``off``,
        the function writes a ``DEMOTE`` request to WAL.
        The ``DEMOTE`` request clears the ownership of the synchronous transaction queue,
        while the ``PROMOTE`` request assigns it to a new instance.

    *   If :ref:`box.cfg.election_mode <cfg_replication-election_mode>` is enabled in any mode, then the function
        makes the instance start a new term and give up the leader role.

    Parameters: none

    :return: nil or error

    Added in release :doc:`2.10.0 </release/2.10.0>`.
