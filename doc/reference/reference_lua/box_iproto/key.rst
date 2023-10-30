.. _reference_lua-box_iproto_key:

box.iproto.key
==============

..  module:: box.iproto

..  data:: key

    The ``box.iproto.key`` namespace contains the request keys.

    Available keys:

    ..  list-table::
        :header-rows: 1
        :widths: 40 40 20

        *   -   Exported flag
            -   IPROTO flag name
            -   Code

        *   -   REQUEST_TYPE
            -   :ref:`IPROTO_REQUEST_TYPE <internals-iproto-keys-request_type>`
            -   0x00

        *   -   SYNC
            -   :ref:`IPROTO_SYNC <internals-iproto-keys-sync>`
            -   0x01

        *   -   REPLICA_ID
            -   :ref:`IPROTO_REPLICA_ID <internals-iproto-keys-replication-general>`
            -   0x02

        *   -   LSN
            -   :ref:`IPROTO_LSN <internals-iproto-keys-replication-general>`
            -   0x03

        *   -   TIMESTAMP
            -   :ref:`IPROTO_TIMESTAMP <internals-iproto-keys-basic>`
            -   0x04

        *   -   SCHEMA_VERSION
            -   :ref:`IPROTO_SCHEMA_VERSION <internals-iproto-keys-schema_version>`
            -   0x05

        *   -   SERVER_VERSION
            -   :ref:`IPROTO_SERVER_VERSION <internals-iproto-keys-replication-general>`
            -   0x06

        *   -   GROUP_ID
            -   IPROTO_GROUP_ID
            -   0x07

        *   -   TSN
            -   :ref:`IPROTO_TSN <internals-iproto-keys-replication-general>`
            -   0x08

        *   -   FLAGS
            -   :ref:`IPROTO_FLAGS <internals-iproto-keys-flags>`
            -   0x09

        *   -   STREAM_ID
            -   :ref:`IPROTO_STREAM_ID <box_protocol-iproto_stream_id>`
            -   0x0a

        *   -   SPACE_ID
            -   :ref:`IPROTO_SPACE_ID <internals-iproto-keys-basic>`
            -   0x10

        *   -   INDEX_ID
            -   :ref:`IPROTO_INDEX_ID <internals-iproto-keys-basic>`
            -   0x11

        *   -   LIMIT
            -   :ref:`IPROTO_LIMIT <internals-iproto-keys-basic>`
            -   0x12

        *   -   OFFSET
            -   :ref:`IPROTO_OFFSET <internals-iproto-keys-basic>`
            -   0x13

        *   -   ITERATOR
            -   :ref:`IPROTO_ITERATOR <internals-iproto-keys-iterator>`
            -   0x14

        *   -   INDEX_BASE
            -   :ref:`IPROTO_INDEX_BASE <internals-iproto-keys-basic>`
            -   0x15

        *   -   FETCH_POSITION
            -   :ref:`IPROTO_FETCH_POSITION <internals-iproto-keys-basic>`
            -   0x1f

        *   -   KEY
            -   :ref:`IPROTO_KEY <internals-iproto-keys-basic>`
            -   0x20

        *   -   TUPLE
            -   :ref:`IPROTO_TUPLE <internals-iproto-keys-tuple>`
            -   0x21

        *   -   FUNCTION_NAME
            -   :ref:`IPROTO_FUNCTION_NAME <internals-iproto-keys-basic>`
            -   0x22

        *   -   USER_NAME
            -   :ref:`IPROTO_USER_NAME <internals-iproto-keys-basic>`
            -   0x23

        *   -   INSTANCE_UUID
            -   :ref:`IPROTO_INSTANCE_UUID <internals-iproto-keys-replication-general>`
            -   0x24

        *   -   REPLICASET_UUID
            -   :ref:`IPROTO_REPLICASET_UUID <internals-iproto-keys-replication-general>`
            -   0x25

        *   -   VCLOCK
            -   :ref:`IPROTO_VCLOCK <internals-iproto-keys-vclock>`
            -   0x26

        *   -   EXPR
            -   :ref:`IPROTO_EXPR <internals-iproto-keys-basic>`
            -   0x27

        *   -   OPS
            -   :ref:`IPROTO_OPS <internals-iproto-keys-basic>`
            -   0x28

        *   -   BALLOT
            -   :ref:`IPROTO_BALLOT <box_protocol-ballots>`
            -   0x29

        *   -   TUPLE_META
            -   IPROTO_TUPLE_META
            -   0x2a

        *   -   OPTIONS
            -   :ref:`IPROTO_OPTIONS <internals-iproto-keys-sql-specific>`
            -   0x2b

        *   -   OLD_TUPLE
            -   IPROTO_OLD_TUPLE
            -   0x2c

        *   -   NEW_TUPLE
            -   IPROTO_NEW_TUPLE
            -   0x2d

        *   -   AFTER_POSITION
            -   :ref:`IPROTO_AFTER_POSITION <internals-iproto-keys-basic>`
            -   0x2e

        *   -   AFTER_TUPLE
            -   :ref:`IPROTO_AFTER_TUPLE <internals-iproto-keys-basic>`
            -   0x2f

        *   -   DATA
            -   :ref:`IPROTO_DATA <box_protocol-body>`
            -   0x30

        *   -   ERROR_24
            -   :ref:`IPROTO_ERROR_24 <internals-iproto-keys-error_24>`
            -   0x31

        *   -   METADATA
            -   :ref:`IPROTO_METADATA <internals-iproto-keys-metadata>`
            -   0x32

        *   -   BIND_METADATA
            -   :ref:`IPROTO_BIND_METADATA <internals-iproto-keys-sql-specific>`
            -   0x33

        *   -   BIND_COUNT
            -   :ref:`IPROTO_BIND_COUNT <internals-iproto-keys-sql-specific>`
            -   0x34

        *   -   POSITION
            -   :ref:`IPROTO_POSITION <internals-iproto-keys-basic>`
            -   0x35

        *   -   SQL_TEXT
            -   :ref:`IPROTO_SQL_TEXT <internals-iproto-keys-sql-specific>`
            -   0x40

        *   -   SQL_BIND
            -   :ref:`IPROTO_SQL_BIND <internals-iproto-keys-sql_bind>`
            -   0x41

        *   -   SQL_INFO
            -   :ref:`IPROTO_SQL_INFO <internals-iproto-keys-sql-specific>`
            -   0x42

        *   -   STMT_ID
            -   :ref:`IPROTO_STMT_ID <internals-iproto-keys-sql-specific>`
            -   0x43

        *   -   REPLICA_ANON
            -   :ref:`IPROTO_REPLICA_ANON <internals-iproto-keys-replication-general>`
            -   0x50

        *   -   ID_FILTER
            -   :ref:`IPROTO_ID_FILTER <internals-iproto-keys-replication-general>`
            -   0x51

        *   -   ERROR
            -   :ref:`IPROTO_ERROR <internals-iproto-keys-error>`
            -   0x52

        *   -   TERM
            -   :ref:`IPROTO_TERM <internals-iproto-keys-term>`
            -   0x53

        *   -   VERSION
            -   :ref:`IPROTO_VERSION <internals-iproto-keys-version>`
            -   0x54

        *   -   FEATURES
            -   :ref:`IPROTO_FEATURES <internals-iproto-keys-features>`
            -   0x55

        *   -   TIMEOUT
            -   :ref:`IPROTO_TIMEOUT <internals-iproto-keys-streams>`
            -   0x56

        *   -   EVENT_KEY
            -   :ref:`IPROTO_EVENT_KEY <internals-iproto-keys-events>`
            -   0x57

        *   -   EVENT_DATA
            -   :ref:`IPROTO_EVENT_DATA <internals-iproto-keys-events>`
            -   0x58

        *   -   TXN_ISOLATION
            -   :ref:`IPROTO_TXN_ISOLATION <internals-iproto-keys-txn_isolation>`
            -   0x59

        *   -   VCLOCK_SYNC
            -   :ref:`IPROTO_VCLOCK_SYNC <internals-iproto-keys-vclock>`
            -   0x5a

        *   -   AUTH_TYPE
            -   :ref:`IPROTO_AUTH_TYPE <internals-iproto-keys-basic>`
            -   0x5b

**Example**

..  code-block:: lua

    box.iproto.key.SYNC = 0x01
    -- ...