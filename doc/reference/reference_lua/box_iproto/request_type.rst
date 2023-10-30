.. _reference_lua-box_iproto_type:

box.iproto.type
===============

..  module:: box.iproto

..  data:: type

    The ``box.iproto.type`` namespace contains all available request types.
    Learn more about the requests: :ref:`Client-server requests and responses <internals-requests_responses>`.

    Available types:

    ..  list-table::
        :header-rows: 1
        :widths: 40 40 20

        *   -   Exported constant
            -   IPROTO constant name
            -   Code

        *   -   OK
            -   :ref:`IPROTO_OK <internals-iproto-ok>`
            -   0

        *   -   SELECT
            -   :ref:`IPROTO_SELECT <box_protocol-select>`
            -   1

        *   -   INSERT
            -   :ref:`IPROTO_INSERT <box_protocol-insert>`
            -   2

        *   -   REPLACE
            -   :ref:`IPROTO_REPLACE <box_protocol-replace>`
            -   3

        *   -   UPDATE
            -   :ref:`IPROTO_REPLACE <box_protocol-update>`
            -   4

        *   -   DELETE
            -   :ref:`IPROTO_REPLACE <box_protocol-delete>`
            -   5

        *   -   CALL_16
            -   :ref:`IPROTO_CALL_16 <box_protocol-call>`
            -   6

        *   -   AUTH
            -   :ref:`IPROTO_AUTH <box_protocol-auth>`
            -   7

        *   -   EVAL
            -   :ref:`IPROTO_EVAL <box_protocol-eval>`
            -   8

        *   -   UPSERT
            -   :ref:`IPROTO_UPSERT <box_protocol-upsert>`
            -   9

        *   -   CALL
            -   :ref:`IPROTO_CALL <box_protocol-call>`
            -   10

        *   -   EXECUTE
            -   :ref:`IPROTO_EXECUTE <box_protocol-execute>`
            -   11

        *   -   NOP
            -   :ref:`IPROTO_NOP <box_protocol-nop>`
            -   12

        *   -   PREPARE
            -   :ref:`IPROTO_PREPARE <box_protocol-prepare>`
            -   13

        *   -   BEGIN
            -   :ref:`IPROTO_BEGIN <box_protocol-begin>`
            -   14

        *   -   COMMIT
            -   :ref:`IPROTO_COMMIT <box_protocol-commit>`
            -   15

        *   -   ROLLBACK
            -   :ref:`IPROTO_ROLLBACK <box_protocol-rollback>`
            -   16

        *   -   RAFT
            -   :ref:`IPROTO_RAFT <box_protocol-raft>`
            -   30

        *   -   RAFT_PROMOTE
            -   :ref:`IPROTO_BALLOT_REGISTERED_REPLICA_UUIDS <internals-iproto-keys-ballot>`
            -   31

        *   -   RAFT_DEMOTE
            -   :ref:`IPROTO_RAFT_DEMOTE <internals-iproto-replication-raft_demote>`
            -   32

        *   -   RAFT_CONFIRM
            -   :ref:`IPROTO_RAFT_CONFIRM <box_protocol-raft_confirm>`
            -   40

        *   -   RAFT_ROLLBACK
            -   :ref:`IPROTO_RAFT_ROLLBACK <box_protocol-raft_rollback>`
            -   41

        *   -   PING
            -   :ref:`IPROTO_PING <box_protocol-ping>`
            -   64

        *   -   JOIN
            -   :ref:`IPROTO_JOIN <box_protocol-join>`
            -   65

        *   -   SUBSCRIBE
            -   :ref:`IPROTO_SUBSCRIBE <internals-iproto-replication-subscribe>`
            -   66

        *   -   VOTE_DEPRECATED
            -   IPROTO_VOTE_DEPRECATED
            -   67

        *   -   VOTE
            -   :ref:`IPROTO_VOTE <internals-iproto-replication-vote>`
            -   68

        *   -   FETCH_SNAPSHOT
            -   :ref:`IPROTO_FETCH_SNAPSHOT <box_protocol-general>`
            -   69

        *   -   REGISTER
            -   :ref:`IPROTO_REGISTER <box_protocol-general>`
            -   70

        *   -   JOIN_META
            -   IPROTO_JOIN_META
            -   71

        *   -   JOIN_SNAPSHOT
            -   IPROTO_JOIN_SNAPSHOT
            -   72

        *   -   ID
            -   :ref:`IPROTO_ID <box_protocol-id>`
            -   73

        *   -   WATCH
            -   :ref:`IPROTO_WATCH <box_protocol-watch>`
            -   74

        *   -   UNWATCH
            -   :ref:`IPROTO_UNWATCH <box_protocol-unwatch>`
            -   75

        *   -   EVENT
            -   :ref:`IPROTO_WATCH <box_protocol-watch>`
            -   76

        *   -   CHUNK
            -   :ref:`IPROTO_CHUNK <internals-iproto-chunk>`
            -   128

        *   -   TYPE_ERROR
            -   :ref:`IPROTO_TYPE_ERROR <internals-iproto-type_error>`
            -   bit.lshift(1, 15)

        *   -   UNKNOWN
            -   :ref:`IPROTO_UNKNOWN <internals-iproto-keys-unknown>`
            -   -1
