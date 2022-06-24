.. _box_info_election:

================================================================================
box.info.election
================================================================================

.. module:: box.info

.. data:: election

   Since version :doc:`2.6.1 </release/2.6.1>`.
   Show the current state of a replica set node in regards to
   :ref:`leader election <repl_leader_elect>`.

   The following information is provided:

   *    ``state`` -- election state (mode) of the node. Possible values are ``leader``, ``follower``, or ``candidate``.
        For more details, refer to description of the :ref:`leader election process <repl_leader_elect_process>`.
        When election is enabled, the node is writable only in the ``leader`` state.

   *    ``term`` -- current election term.

   *    ``vote`` -- ID of a node the current node votes for. If the value is ``0``, it means the node hasn't voted in the current term yet.

   *    ``leader`` -- leader node ID in the current term. If the value is ``0``, it means the node doesn't know which node is the leader in the current term.

   *    ``leader_idle`` -- time in seconds since the last interaction with the known leader.  Since version :doc:`2.10.0 </release/2.10.0>`.

   ..   note::

        IDs in the ``box.info.election`` output are the replica IDs visible in the ``box.info.id`` output on each node and in the ``_cluster`` space.

   **Example:**

   .. code-block:: tarantoolsession

      tarantool> box.info.election
      ---
      - state: follower
        term: 2
        vote: 0
        leader: 0
        leader_idle: 0.45112800000061
      ...
