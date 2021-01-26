.. _box_info_election:

================================================================================
box.info.election
================================================================================

.. module:: box.info

.. data:: election

   Show the current state of a replica set node in regards to
   :ref:`leader election <repl_leader_elect>`, namely,
   election state (mode), election term, vote in the current term,
   and the leader ID of the current term.

   **Example:**

   .. code-block:: tarantoolsession

      tarantool> box.info.election
      ---
      - state: follower
        vote: 0
        leader: 0
        term: 1
      ...

   IDs in the ``box.info.election`` output are the replica IDs visible in
   the ``box.info.id`` output on each node and in the ``_cluster`` space.

   State can be ``leader``, ``follower``, or ``candidate``. Also, refer to the
   information on `configuring <cfg_replication-election_mode>`
   node's election mode. When election is enabled, the node is writable only in
   the ``leader`` state.

   ``vote`` equals ``0`` means the node didn't vote in the current term.

   ``leader`` equals ``0`` means the node doesn't know who a leader in
   the current term is.
