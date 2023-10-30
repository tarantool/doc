.. _reference_lua-box_iproto_raft:

box.iproto.raft
===============

..  module:: box.iproto

..  data:: raft_key

    The ``box.iproto.raft_key`` namespace contains the keys from the ``IPROTO_RAFT_*`` requests.
    Learn more: :ref:`Synchronous replication keys <internals-iproto-keys-synchro-replication>`.

    Available keys:

    ..  list-table::
        :header-rows: 1
        :widths: 40 40 20

        *   -   Exported constant
            -   IPROTO constant name
            -   Code

        *   -   TERM
            -   :ref:`IPROTO_RAFT_TERM <internals-iproto-keys-syncro-replication>`
            -   0

        *   -   VOTE
            -   :ref:`IPROTO_RAFT_VOTE <internals-iproto-keys-syncro-replication>`
            -   1

        *   -   STATE
            -   :ref:`IPROTO_RAFT_STATE <internals-iproto-keys-syncro-replication>`
            -   2

        *   -   VCLOCK
            -   :ref:`IPROTO_RAFT_VCLOCK <internals-iproto-keys-vclock>`
            -   3

        *   -   LEADER_ID
            -   :ref:`IPROTO_RAFT_LEADER_ID <internals-iproto-keys-syncro-replication>`
            -   4

        *   -   IS_LEADER_SEEN
            -   :ref:`IPROTO_RAFT_IS_LEADER_SEEN <internals-iproto-keys-syncro-replication>`
            -   5

**Example**

..  code-block:: lua

    box.iproto.raft_key.TERM = 0
    -- ...
    box.iproto.raft_key.VOTE = 1
    -- ...
