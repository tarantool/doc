..  _box_protocol-key_list:
..  _internals-iproto-keys:

Keys used in requests and responses
===================================

This section describes ``iproto`` keys that are passed in binary code via the protocol.
They are Tarantool constants that are either defined or mentioned in the
`iproto_constants.h file <https://github.com/tarantool/tarantool/blob/master/src/box/iproto_constants.h>`_.

While the keys are unsigned 8-bit integers, their values can have different types.

Basic description
-----------------

General
~~~~~~~

..  container:: table

    ..  list-table::
        :header-rows: 1
        :widths: 25 10 15 50

        *   -   Name
            -   Binary code
            -   Value type
            -   Description
        *   -   :ref:`IPROTO_VERSION <internals-iproto-keys-version>`
            -   0x54
            -   MP_INT
            -   Binary protocol version supported by the client
        *   -   :ref:`IPROTO_FEATURES <internals-iproto-keys-features>`
            -   0x55
            -   MP_ARRAY
            -   Supported binary protocol features
        *   -   :ref:`IPROTO_SYNC <internals-iproto-keys-sync>`
            -   0x01
            -   MP_UINT
            -   Unique request identifier
        *   -   :ref:`IPROTO_SCHEMA_VERSION <internals-iproto-keys-schema_version>`
            -   0x05
            -   MP_UINT
            -   Identifier that is increased with every major change
        *   -   IPROTO_TIMESTAMP
            -   0x04
            -   MP_DOUBLE 
            -   Time in seconds since the Unix epoch
        *   -   IPROTO_OK
            -   0x00
            -   unsigned, always equals 0
            -   Indicates no error
        *   -   :ref:`IPROTO_CHUNK <internals-iproto-keys-chunk>`
            -   0x80
            -   
            -   Indicates an :ref:`out-of-band message <box_session-push>`
        *   -   :ref:`IPROTO_ERROR <internals-iproto-keys-error>`
            -   0x52
            -   :ref:`MP_ERROR <msgpack_ext-error>`
            -   Error as a string. Used in Tarantool versions prior to :doc:`2.4.1 </release/2.4.1>`
        *   -   :ref:`IPROTO_ERROR_24 <internals-iproto-keys-error_24>`
            -   0x31
            -   MP_STR
            -   
        *   -   IPROTO_DATA
            -   0x30
            -   Any type
            -   Data passed in the transaction. Can be empty. Used in all requests
        *   -   IPROTO_REQUEST_TYPE
            -   0x00
            -   Request type
        *   -   IPROTO_SPACE_ID
            -   0x10
            -   Space identifier
        *   -   IPROTO_INDEX_ID
            -   0x11
            -   Index identifier
        *   -   :ref:`IPROTO_TUPLE <internals-iproto-keys-tuple>`
            -   0x21
            -   MP_ARRAY
            -   Tuple, arguments, operations, or authentication pair.
                :ref:`See details <internals-iproto-keys-tuple>`
        *   -   IPROTO_KEY
            -   0x20
            -   MP_ARRAY
            -   Array of index keys in the request. See :ref:`space_object:select() <box_space-select>`
        *   -   IPROTO_LIMIT
            -   0x12
            -   MP_UINT
            -   Maximum number of tuples in the space
        *   -   IPROTO_OFFSET
            -   0x13
            -   MP_UINT
            -   Number of tuples to skip in the select
        *   -   :ref:`IPROTO_ITERATOR <internals-iproto-keys-iterator>`
            -   0x14
            -   MP_UINT
            -   Iterator type
        *   -   IPROTO_INDEX_BASE
            -   0x15
            -   MP_UINT
            -   Indicates whether the first field number is 1 or 0
        *   -   IPROTO_FUNCTION_NAME
            -   0x22
            -   MP_STR
            -   Name of the called function. Used in :ref:`IPROTO_CALL <box_protocol-call>`
        *   -   IPROTO_USER_NAME
            -   0x23
            -   MP_STR
            -   User name. Used in :ref:`IPROTO_AUTH <box_protocol-auth>`
        *   -   IPROTO_OPS
            -   0x28
            -   MP_ARRAY
            -   Array of operations. Used in :ref:`IPROTO_UPSERT <box_protocol-upsert>`
        *   -   IPROTO_EXPR
            -   0x27
            -   MP_STR
            -   Command argument. Passed within :ref:`IPROTO_EVAL <<box_protocol-eval>>`


Streams
~~~~~~~

..  container:: table

    ..  list-table::
        :header-rows: 1
        :widths: 25 10 15 50

        *   -   Name
            -   Binary code
            -   Type
            -   Description

        *   -   :ref:`IPROTO_STREAM_ID <box_protocol-iproto_stream_id>`
            -   0x0a
            -   unsigned
            -   Unique :ref:`stream <txn_mode_stream-interactive-transactions>` identifier
        *   -   :ref:`IPROTO_TXN_ISOLATION <internals-iproto-keys-txn_isolation>`
            -   0x59
            -   unsigned
            -   Transaction isolation level, used in :ref:`streams <txn_mode_stream-interactive-transactions>`


General replication
~~~~~~~~~~~~~~~~~~~

..  container:: table

    ..  list-table::
        :header-rows: 1
        :widths: 25 10 15 50

        *   -   Name
            -   Binary code
            -   Type
            -   Description
        *   -   IPROTO_REPLICA_ID
            -   0x02
            -   MP_INT
            -   Replica ID.
        *   -   IPROTO_INSTANCE_UUID
            -   0x24
            -   :ref:`MP_UUID <msgpack_ext-uuid>`
            -   Instance UUID.
        *   -   IPROTO_VCLOCK
            -   0x26
            -   MP_UINT
            -   The instance's vector clock (vclock).
        *   -   IPROTO_CLUSTER_UUID
            -   0x25
            -   :ref:`MP_UUID <msgpack_ext-uuid>`
            -
        *   -   IPROTO_LSN
            -   0x03
            -   MP_UINT
            -   Log sequence number of the transaction
        *   -   IPROTO_BALLOT_IS_RO_CFG
            -   0x01
            -   MP_BOOL
            -
        *   -   IPROTO_BALLOT_VCLOCK
            -   0x02
            -   MP_ARRAY
            -   
        *   -   IPROTO_BALLOT_GC_VCLOCK
            -   0x03
            -   MP_ARRAY
            -   
        *   -   IPROTO_BALLOT_IS_RO
            -   0x04
            -   MP_BOOL
            -
        *   -   IPROTO_BALLOT_IS_ANON
            -   0x05
            -   MP_BOOL
            -
        *   -   IPROTO_BALLOT_IS_BOOTED
            -   0x06
            -   MP_BOOL
            -
        *   -   IPROTO_BALLOT_CAN_LEAD
            -   0x07
            -   MP_BOOL
        *   -   IPROTO_ID_FILTER
            -   0x51
            -   MP_ARRAY
            -   Optional key used in SUBSCRIBE request followed by an array
                of ids of instances whose rows won't be relayed to the replica

Synchronous replication
~~~~~~~~~~~~~~~~~~~~~~~

..  container:: table

    ..  list-table::
        :header-rows: 1
        :widths: 25 10 15 50

        *   -   IPROTO_FLAGS
            -   0x09
            -
            -
        *   -   IPROTO_FLAG_COMMIT
            -   0x01
            -   
            -
        *   -   IPROTO_FLAG_WAIT_SYNC
            -   0x02
            -   
            -
        *   -   IPROTO_FLAG_WAIT_ACK
            -   0x04
            -
            -
        *   -   IPROTO_RAFT_TERM
            -   0x00
            -   MP_UINT
            -   :ref:`RAFT term <repl_leader_elect>` on an instance. Used in :ref:`IPROTO_RAFT <box_protocol-raft>`.
        *   -   IPROTO_RAFT_VOTE
            -   0x01
            -   MP_UINT
            -   Instance vote in the current term (if any).  Used in :ref:`IPROTO_RAFT <box_protocol-raft>`.
        *   -   IPROTO_RAFT_STATE
            -   0x02
            -   MP_UINT
            -   RAFT state. Possible values: ``1`` -- follower, ``2`` -- candidate, ``3`` -- leader.
                Used in :ref:`IPROTO_RAFT <box_protocol-raft>`.
        *   -   IPROTO_RAFT_VCLOCK
            -   0x03
            -   MP_ARRAY
            -   Current vclock of the instance. Present only on the instances in the "candidate" state (IPROTO_RAFT_STATE == 2).
        *   -   IPROTO_RAFT_LEADER_ID
            -   0x04
            -   MP_UINT
            -   Current leader node ID as seen by the node that issues the request. Since version :doc:`2.10.0 </release/2.10.0>`.
        *   -   IPROTO_RAFT_IS_LEADER_SEEN
            -   0x05
            -   MP_BOOL
            -   Shows whether the node has a direct connection to the leader node. Since version :doc:`2.10.0 </release/2.10.0>`.

Watchers
~~~~~~~~

    IPROTO_EVENT_KEY=0x57
    IPROTO_EVENT_DATA=0x58

SQL-specific
~~~~~~~~~~~~

These keys are used with SQL within :ref:`SQL-specific requests <internals-iproto-sql>`
like :ref:`IPROTO_EXECUTE <box_protocol-execute>`
and :ref:`IPROTO_PREPARE <box_protocol-prepare>`.

..  container:: table

    ..  list-table::
        :header-rows: 1
        :widths: 25 10 15 50

        *   -   Name
            -   Binary code
            -   Type
            -   Description
        *   -   IPROTO_OPTIONS
            -   0x2b
            -   MP_ARRAY
            -   SQL transaction options.
        *   -   :ref:`IPROTO_METADATA <internals-iproto-keys-metadata>`
            -   0x32
            -   MP_ARRAY, contains MP_MAP items
            -   SQL transaction metadata.
        *   -   IPROTO_FIELD_NAME
            -   0x00
            -   MP_STR
            -   Field name. Nested in :ref:`IPROTO_METADATA <internals-iproto-keys-metadata>`.
        *   -   IPROTO_FIELD_TYPE
            -   0x01
            -   MP_STR
            -   Field type. Nested in :ref:`IPROTO_METADATA <internals-iproto-keys-metadata>`.
        *   -   IPROTO_FIELD_COLL
            -   0x02
            -   MP_STR
            -   Field collation. Nested in :ref:`IPROTO_METADATA <internals-iproto-keys-metadata>`.
        *   -   IPROTO_FIELD_IS_NULLABLE
            -   0x03
            -   MP_BOOL
            -   Indicates whether the field is nullable. Nested in :ref:`IPROTO_METADATA <internals-iproto-keys-metadata>`.
        *   -   IPROTO_FIELD_IS_AUTOINCREMENT
            -   0x04
            -   MP_BOOL
            -   Indicates whether the field is auto-incremented.
                Nested in :ref:`IPROTO_METADATA <internals-iproto-keys-metadata>`.
        *   -   IPROTO_FIELD_SPAN
            -   0x05
            -   MP_STR or MP_NIL
            -   Original expression under SELECT.
                Nested in :ref:`IPROTO_METADATA <internals-iproto-keys-metadata>`.
                See :ref:`box.execute() <box-sql_if_full_metadata>`
        *   -   IPROTO_BIND_METADATA
            -   0x33
            -
            -
        *   -   IPROTO_BIND_COUNT
            -   0x34
            -
            -
        *   -   IPROTO_SQL_TEXT
            -   0x40
            -
            -
        *   -   IPROTO_SQL_BIND
            -   0x41
            -   
            -
        *   -   :ref:`IPROTO_SQL_INFO <internals-iproto-keys-sql_info>`
            -   0x42
            -   
            -
        *   -   IPROTO_STMT_ID
            -   0x43
            -
            -

Details on specific keys
------------------------

..  _internals-iproto-keys-version:

IPROTO_VERSION
~~~~~~~~~~~~~~

Binary code: 0x54.

IPROTO_VERSION is an integer number reflecting the version of protocol that the
client supports. The latest IPROTO_VERSION is |iproto_version|.


..  _internals-iproto-keys-features:

IPROTO_FEATURES
~~~~~~~~~~~~~~~

Binary code: 0x55.

Available IPROTO_FEATURES are the following:

-   ``IPROTO_FEATURE_STREAMS = 0`` -- streams support: :ref:`IPROTO_STREAM_ID <box_protocol-iproto_stream_id>`
    in the request header.

-   ``IPROTO_FEATURE_TRANSACTIONS = 1`` -- transaction support: IPROTO_BEGIN,
    IPROTO_COMMIT, and IPROTO_ROLLBACK commands (with :ref:`IPROTO_STREAM_ID <box_protocol-iproto_stream_id>`
    in the request header). Learn more about :ref:`sending transaction commands <box_protocol-stream_transactions>`.

-   ``IPROTO_FEATURE_ERROR_EXTENSION = 2`` -- :ref:`MP_ERROR <msgpack_ext-error>`
    MsgPack extension support. Clients that don't support this feature will receive
    error responses for :ref:`IPROTO_EVAL <box_protocol-eval>` and
    :ref:`IPROTO_CALL <box_protocol-call>` encoded to string error messages.

-   ``IPROTO_FEATURE_WATCHERS = 3`` -- remote watchers support: :ref:`IPROTO_WATCH <box_protocol-watch>`,
    :ref:`IPROTO_UNWATCH <box_protocol-unwatch>`, and :ref:`IPROTO_EVENT <box_protocol-event>` commands.

..  _internals-iproto-keys-sync:

IPROTO_SYNC
~~~~~~~~~~~

Binary code: 0x01.

This is an unsigned integer that should be incremented so that it is unique in every
request. This integer is also returned from :doc:`/reference/reference_lua/box_session/sync`.

The IPROTO_SYNC value of a response should be the same as
the IPROTO_SYNC value of a request.

..  _internals-iproto-keys-schema_version:

IPROTO_SCHEMA_VERSION
~~~~~~~~~~~~~~~~~~~~~

Binary code: 0x05.

An unsigned number that goes up when there is a major change.

In a request header, IPROTO_SCHEMA_VERSION is optional, so the version will not
be checked if it is absent.

In a response header, IPROTO_SCHEMA_VERSION is always present, and it is up to
the client to check if it has changed.

..  _internals-iproto-keys-iterator:

IPROTO_ITERATOR
~~~~~~~~~~~~~~~

Binary code: 0x14.

Possible values (see `iterator_type.h <https://github.com/tarantool/tarantool/blob/master/src/box/iterator_type.h>`_):

..  container:: table

    ..  list-table::
        :header-rows: 0
        :widths: 20 80

        *   -   ``0``
            -   :ref:`EQ <box_index-pairs>`
        *   -   ``1``
            -   :ref:`REQ <box_index-pairs>`
        *   -   ``2``
            -   :ref:`ALL <box_index-pairs>`, all tuples
        *   -   ``3``
            -   :ref:`LT <box_index-pairs>`, less than
        *   -   ``4``
            -   :ref:`LE <box_index-pairs>`, less than or equal
        *   -   ``5``
            -   :ref:`GE <box_index-pairs>`, greater than or equal
        *   -   ``6``
            -   :ref:`GT <box_index-pairs>`, greater than
        *   -   ``7``
            -   :ref:`BITS_ALL_SET <box_index-pairs>`, all bits of the value are set in the key
        *   -   ``8``
            -   :ref:`BITS_ANY_SET <box_index-pairs>`, at least one bit of the value is set
        *   -   ``9``
            -   :ref:`BITS_ALL_NOT_SET <box_index-pairs>`, no bits are set
        *   -   ``10``
            -   :ref:`OVERLAPS <box_index-pairs>`, overlaps the rectangle or box
        *   -   ``11``
            -   :ref:`NEIGHBOR <box_index-pairs>`, neighbors the rectangle or box


..  _box_protocol-iproto_stream_id:

IPROTO_STREAM_ID
~~~~~~~~~~~~~~~~

Binary code: 0x0a.

Only used in :ref:`streams <txn_mode_stream-interactive-transactions>`.
This is an unsigned number that should be unique in every stream.

In requests, IPROTO_STREAM_ID is useful for two things:
ensuring that requests within transactions are done in separate groups,
and ensuring strictly consistent execution of requests (whether or not they are within transactions).

In responses, IPROTO_STREAM_ID does not appear.

See :ref:`Binary protocol -- streams <box_protocol-streams>`.


..  _internals-iproto-keys-txn_isolation:

IPROTO_TXN_ISOLATION
~~~~~~~~~~~~~~~~~~~~

IPROTO_TXN_ISOLATION is the :ref:`transaction isolation level <txn_mode_mvcc-options>`.
It can take the following values:

- ``TXN_ISOLATION_DEFAULT = 0``	-- use the default level from ``box.cfg`` (default value)
- ``TXN_ISOLATION_READ_COMMITTED = 1`` -- read changes that are committed but not confirmed yet
- ``TXN_ISOLATION_READ_CONFIRMED = 2`` -- read confirmed changes
- ``TXN_ISOLATION_BEST_EFFORT = 3`` -- determine isolation level automatically

See :ref:`Binary protocol -- streams <box_protocol-streams>` to learn more about
stream transactions in the binary protocol.


..  _internals-iproto-keys-ok:

IPROTO_OK
~~~~~~~~~

Binary code: 0x00.

The key is contained in the header and signifies success.

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

..  _internals-iproto-keys-chunk:

IPROTO_CHUNK
~~~~~~~~~~~~

Binary code: 0x80.

Out-of-band? -> IPROTO_CHUNK
If the response is out-of-band, due to use of
:ref:`box.session.push() <box_session-push>`,
then the header Response-Code-Indicator will be IPROTO_CHUNK instead of IPROTO_OK.

..  _internals-iproto-keys-error:

IPROTO_ERROR
~~~~~~~~~~~~

Error? -> 0x8xxx where xxx is a value from errcode.h
Instead of IPROTO_DATA... IPROTO_ERROR: :samp:`{{MP_STRING string}}`

..  _internals-iproto-keys-error_24:

IPROTO_ERROR_24
~~~~~~~~~~~~~~~
    
IPROTO_ERROR_24 - это ключ для старого типа ошибки.
Перед 2.4 ошибки возвращались как строки.
Начиная с 2.4 появилась возможность паковать ошибки в новом фомате (MP_EXT/MP_ERROR) 
о стеком и чем-то там еще.
Чтобы сохранить обратную совместимость мы возвращаем два ключа в случае ошибки:
IPROTO_ERROR_24 со строкой и IPROTO_ERROR с MP_EXT,
так что новые клиенты могут использовать всю информацию из нового формата,
а старые клиенты продолжат работать с простыми строками.    

..  _internals-iproto-keys-tuple:

IPROTO_TUPLE
~~~~~~~~~~~~

Multiple operations make use of this key in different ways:

..  container:: table

    ..  list-table::
        :widths: 30 70
        :header-rows: 0

        *   -   :ref:`IPROTO_INSERT <box_protocol-insert>`,
                :ref:`IPROTO_REPLACE <box_protocol-replace>`,
                :ref:`IPROTO_UPSERT <box_protocol-upsert>`
            -   Tuple to be inserted
        *   -   :ref:`IPROTO_UPSERT <box_protocol-update>`
            -   Operations to perform
        *   -   :ref:`IPROTO_AUTH <box_protocol-auth>`
            -   Array of 2 fields:
                authentication mechanism ("chap-sha1" is the only supported mechanism right now)
                and scramble, encrypted according to the specified mechanism.
                See more on the :ref:`authentication <box_protocol-authentication_sequence>` sequence.
        *   -   :ref:`IPROTO_CALL <box_protocol-call>`, :ref:`IPROTO_EVAL <box_protocol-eval>`
            -   Array of arguments

..  _internals-iproto-keys-metadata:
    
IPROTO_METADATA
~~~~~~~~~~~~~~~

Binary code: 0x32.

Used with SQL within IPROTO_EXECUTE.

    * :samp:`IPROTO_METADATA: {array of column maps}` = array of column maps, with each column map containing
  at least IPROTO_FIELD_NAME (0x00) and MP_STR, and IPROTO_FIELD_TYPE (0x01) and MP_STR.

  Additionally, if ``sql_full_metadata`` in the
  :ref:`_session_settings <box_space-session_settings>` system space
  is TRUE, then the array will have these additional column maps
  which correspond to components described in the
  :ref:`box.execute() <box-sql_if_full_metadata>` section.

..  _internals-iproto-keys-sql_info:

IPROTO_SQL_INFO
~~~~~~~~~~~~~~~

Binary code: 0x42.

    Usually IPROTO_SQL_INFO is a map with only one item -- SQL_INFO_ROW_COUNT (0x00) --
    which is the number of changed rows
    The IPROTO_SQL_INFO map may contain a second item --
    :samp:`SQL_INFO_AUTO_INCREMENT_IDS (0x01)` --
    which is the new primary-key value (or values) for an INSERT in a table
defined with PRIMARY KEY AUTOINCREMENT.
