.. _box_ctl-demote:

box.ctl.demote()
=================

..  function:: demote()

    Revoke the leader role of the instance.

    The function is used only for the :ref:`owner of the synchronous transaction queue <box_info_synchro>`.
    In other words, it may be issued only on the leader when the elections are enabled.

    The ``demote()`` function is similar to :ref:`box.ctl.promote() <box_ctl-promote>` with a few differences.
    It works in the following way:

    *   If :ref:`box.cfg.election_mode <cfg_replication-election_mode>` is ``off``,
        the function writes a ``DEMOTE`` request to WAL.
        The ``DEMOTE`` request clears the ownership of the synchronous transaction queue,
        while the ``PROMOTE`` request assigns it to a new instance.

    *   If :ref:`box.cfg.election_mode <cfg_replication-election_mode>` is enabled in any mode, then the function
        makes the instance give up the leader role.

    Parameters: none

    :return: nil or function pointer

    Added in release :doc:`2.10.0 </release/2.10.0>`.
