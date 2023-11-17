.. _box_info_election:

================================================================================
box.info.election
================================================================================

..  module:: box.info

..  data:: election

    Since version :doc:`2.6.1 </release/2.6.1>`.

    Show the current state of a replica set node in regards to :ref:`leader election <repl_leader_elect>`.
    The following information is provided:

    *   ``state`` -- the election state (mode) of the node. Possible values are ``leader``, ``follower``, or ``candidate``.
        For more details, refer to description of the :ref:`leader election process <repl_leader_elect_process>`.
        When :ref:`replication.failover <configuration_reference_replication_failover>` is set to ``election``, the node is writable only in the ``leader`` state.

    *   ``term`` -- the current election term.

    *   ``vote`` -- the ID of a node the current node votes for. If the value is ``0``, it means the node hasn't voted in the current term yet.

    *   ``leader`` -- a leader node ID in the current term. If the value is ``0``, it means the node doesn't know which node is the leader in the current term.

    *   ``leader_name`` -- a leader name. Returns ``nil`` if there is no leader in a cluster or :ref:`box.NULL <box-null>` if a leader does not have a name. Since version :doc:`3.0.0 </release/3.0.0>`.

    *   ``leader_idle`` -- time in seconds since the last interaction with the known leader. Since version :doc:`2.10.0 </release/2.10.0>`.

    ..  note::

        IDs in the ``box.info.election`` output are the replica IDs visible in the ``box.info.id`` output on each node and in the ``_cluster`` space.

    **Example:**

    .. code-block:: tarantoolsession

        auto_leader:instance001> box.info.election
        ---
        - leader_idle: 0
          leader_name: instance001
          state: leader
          vote: 2
          term: 3
          leader: 2
        ...

    See also: :ref:`Master-replica: automated failover <replication-bootstrap-auto>`.