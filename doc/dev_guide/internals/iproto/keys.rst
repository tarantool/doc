..  _box_protocol-key_list:
..  _internals-iproto-keys:

List of IPROTO keys
===================

This section describes all the iproto keys used to pass request arguments.
Все типы ключей, используемых для передачи аргументов, с их типами и кратким описанием
(например, `IPROTO_SPACE_ID` - идентификато таблицы, unsigned integer).
(всё, что встречается внутри запросов)

..  container:: table

    ..  list-table::
        :header-rows: 1
        :widths: 17 16 17 50

        *   -   Name
            -   Binary code
            -   Type
            -   Description
        *   -   IPROTO_SPACE_ID
            -   0x10
            -   unsigned
            -   Space identifier
        *   -   IPROTO_INDEX_ID
            -   0x11
            -   unsigned
            -   Index identifier
        *   -   IPROTO_REQUEST_TYPE
            -   0x00
            -   unsigned
            -   Request type
        *   -   
        used with SQL within IPROTO_EXECUTE:
    IPROTO_OPTIONS=0x2b
    IPROTO_METADATA=0x32
    * :samp:`IPROTO_METADATA: {array of column maps}` = array of column maps, with each column map containing
  at least IPROTO_FIELD_NAME (0x00) and MP_STR, and IPROTO_FIELD_TYPE (0x01) and MP_STR.
  Additionally, if ``sql_full_metadata`` in the
  :ref:`_session_settings <box_space-session_settings>` system space
  is TRUE, then the array will have these additional column maps
  which correspond to components described in the
  :ref:`box.execute() <box-sql_if_full_metadata>` section:

..  code-block:: none

    IPROTO_FIELD_COLL (0x02) and MP_STR
    IPROTO_FIELD_IS_NULLABLE (0x03) and MP_BOOL
    IPROTO_FIELD_IS_AUTOINCREMENT (0x04) and MP_BOOL
    IPROTO_FIELD_SPAN (0x05) and MP_STR or MP_NIL
    IPROTO_BIND_METADATA=0x33
    IPROTO_BIND_COUNT=0x34
    IPROTO_SQL_TEXT=0x40
    IPROTO_SQL_BIND=0x41
    IPROTO_SQL_INFO=0x42
    IPROTO_STMT_ID=0x43

    "No error" constant
    IPROTO_OK=0x00
For IPROTO_OK, the header Response-Code-Indicator will be 0 and the body is a 1-item map.

..  cssclass:: highlight
..  parsed-literal::

    # <size>
    msgpack(:samp:`{{MP_UINT unsigned integer = size(<header>) + size(<body>)}}`)
    # <header>
    msgpack({
        Response-Code-Indicator: IPROTO_OK,
        IPROTO_SYNC: :samp:`{{MP_UINT unsigned integer, may be 64-bit}}`,
        IPROTO_SCHEMA_VERSION: :samp:`{{MP_UINT unsigned integer}}`
    })
    # <body>
    msgpack({
        IPROTO_DATA: :samp:`{{any type}}`
    })
    
    box.session.sync(), like a clock, must be same for response and request
    IPROTO_SYNC=0x01

    Replication
    IPROTO_REPLICA_ID=0x02
    IPROTO_INSTANCE_UUID=0x24
    IPROTO_RAFT_TERM=0x00
    IPROTO_RAFT_VOTE=0x01
    IPROTO_RAFT_STATE=0x02
    IPROTO_RAFT_VCLOCK=0x03
    IPROTO_RAFT_LEADER_ID=0x04
    IPROTO_RAFT_IS_LEADER_SEEN=0x05
    IPROTO_VCLOCK=0x26
    IPROTO_CLUSTER_UUID=0x25
    IPROTO_BALLOT=0x29
    IPROTO_BALLOT_IS_RO_CFG=0x01
    IPROTO_BALLOT_VCLOCK=0x02
    IPROTO_BALLOT_GC_VCLOCK=0x03
    IPROTO_BALLOT_IS_RO=0x04
    IPROTO_BALLOT_IS_ANON=0x05
    IPROTO_BALLOT_IS_BOOTED=0x06
    IPROTO_BALLOT_CAN_LEAD=0x07
    IPROTO_REQUEST_TYPE
    IPROTO_KEY=0x20
    Maximum number of tuples in the space
    IPROTO_LIMIT=0x12
    Number of tuples to skip in the select
    IPROTO_OFFSET=0x13
    iterator type (gt, lt, eq...)
    IPROTO_ITERATOR=0x14
    what is the first field number (like 1 or 0)
    IPROTO_INDEX_BASE=0x15
    IPROTO_TUPLE=0x21
    IPROTO_TUPLE_META=0x2a
    IPROTO_LSN=0x03
    IPROTO_TIMESTAMP=0x04 Float 64 MP_DOUBLE 8-byte timestamp
    IPROTO_SCHEMA_VERSION=0x05
    Stream transactions
    IPROTO_STREAM_ID=0x0a Дать ссылку на подраздел про стримы
    IPROTO_TXN_ISOLATION=0x59
    IPROTO_FUNCTION_NAME=0x22
    user name
    IPROTO_USER_NAME=0x23
    IPROTO_FIELD_NAME=0x00
    IPROTO_FIELD_TYPE=0x01
    IPROTO_FIELD_COLL=0x02
    IPROTO_FIELD_IS_NULLABLE=0x03
    IPROTO_FIELD_IS_AUTOINCREMENT=0x04
    IPROTO_FIELD_SPAN=0x05
    array of operations
    IPROTO_OPS=0x28
    OPERATOR
    Command argument (passed within IPROTO_EVAL)
    IPROTO_EXPR=0x27
    used by all requests, contains response data
    IPROTO_DATA=0x30
    IPROTO_ERROR=0x52
    IPROTO_ERROR_24=0x31

    IPROTO_CHUNK=0x80
    If the response is out-of-band, due to use of
:ref:`box.session.push() <box_session-push>`,
then the header Response-Code-Indicator will be IPROTO_CHUNK instead of IPROTO_OK.

    IPROTO_TIMEOUT=0x56

    Synchronous replication
    IPROTO_FLAGS=0x09
    IPROTO_FLAG_COMMIT=0x01
    IPROTO_FLAG_WAIT_SYNC=0x02
    IPROTO_FLAG_WAIT_ACK=0x04
    -- parts of IPROTO_ID
    IPROTO_VERSION=0x54
    IPROTO_FEATURES=0x55

    IPROTO_EVENT_KEY=0x57
    IPROTO_EVENT_DATA=0x58

    IPROTO_SQL_INFO (0x42)
    Usually IPROTO_SQL_INFO is a map with only one item -- SQL_INFO_ROW_COUNT (0x00) -- which is the number of changed rows
    The IPROTO_SQL_INFO map may contain a second item -- :samp:`SQL_INFO_AUTO_INCREMENT_IDS
(0x01)` -- which is the new primary-key value (or values) for an INSERT in a table
defined with PRIMARY KEY AUTOINCREMENT.
        SQL_INFO_ROW_COUNT (0x00)
        SQL_INFO_AUTO_INCREMENT_IDS (0x01)