..  _box_protocol-key_list:
..  _internals-iproto-keys:

Keys used in requests and responses
===================================

This section describes ``iproto`` keys that are passed via the protocol.
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
        :widths: 35 20 45

        *   -   Name
            -   Code, value type
            -   Description

        *   -   :ref:`IPROTO_VERSION <internals-iproto-keys-version>`
            -   0x54 |br| MP_INT
            -   Binary protocol version supported by the client

        *   -   :ref:`IPROTO_FEATURES <internals-iproto-keys-features>`
            -   0x55 |br|  MP_ARRAY
            -   Supported binary protocol features

        *   -   :ref:`IPROTO_SYNC <internals-iproto-keys-sync>`
            -   0x01 |br|  MP_UINT
            -   Unique request identifier

        *   -   :ref:`IPROTO_SCHEMA_VERSION <internals-iproto-keys-schema_version>`
            -   0x05 |br|  MP_UINT
            -   Identifier that is increased with every major change

        *   -   IPROTO_TIMESTAMP
            -   0x04 |br| MP_DOUBLE 
            -   Time in seconds since the Unix epoch

        *   -   :ref:`IPROTO_REQUEST_TYPE <internals-iproto-keys-request_type>`
            -   0x00 |br| MP_UINT
            -   Request type or response type
            
        *   -   :ref:`IPROTO_OK <internals-iproto-keys-ok>`
            -   0x00 |br| MP_UINT
            -   Successful response indicator
        
        *   -   :ref:`IPROTO_CHUNK <internals-iproto-keys-chunk>`
            -   0x80 |br| MP_UINT
            -   Out-of-band response indicator
        
        *   -   :ref:`IPROTO_TYPE_ERROR <internals-iproto-keys-type_error>`
            -   0x8XXX |br| MP_INT
            -   Error response indicator

        *   -   :ref:`IPROTO_ERROR <internals-iproto-keys-error>`
            -   0x52 |br| :ref:`MP_ERROR <msgpack_ext-error>`
            -   Error response

        *   -   :ref:`IPROTO_ERROR_24 <internals-iproto-keys-error_24>`
            -   0x31 |br| MP_STR
            -   Error as a string

        *   -   IPROTO_DATA
            -   0x30 |br| MP_OBJECT
            -   Data passed in the transaction. Can be empty. Used in all requests and responses

        *   -   IPROTO_SPACE_ID
            -   0x10 |br| MP_UINT
            -   Space identifier

        *   -   IPROTO_INDEX_ID
            -   0x11 |br| MP_UINT
            -   Index identifier

        *   -   :ref:`IPROTO_TUPLE <internals-iproto-keys-tuple>`
            -   0x21 |br| MP_ARRAY
            -   Tuple, arguments, operations, or authentication pair.
                :ref:`See details <internals-iproto-keys-tuple>`

        *   -   IPROTO_KEY
            -   0x20 |br| MP_ARRAY
            -   Array of index keys in the request. See :ref:`space_object:select() <box_space-select>`

        *   -   IPROTO_LIMIT
            -   0x12 |br| MP_UINT
            -   Maximum number of tuples in the space

        *   -   IPROTO_OFFSET
            -   0x13 |br| MP_UINT
            -   Number of tuples to skip in the select

        *   -   :ref:`IPROTO_ITERATOR <internals-iproto-keys-iterator>`
            -   0x14 |br| MP_UINT
            -   Iterator type

        *   -   IPROTO_INDEX_BASE
            -   0x15 |br| MP_UINT
            -   Indicates whether the first field number is 1 or 0

        *   -   IPROTO_FUNCTION_NAME
            -   0x22 |br| MP_STR
            -   Name of the called function. Used in :ref:`IPROTO_CALL <box_protocol-call>`

        *   -   IPROTO_USER_NAME
            -   0x23 |br| MP_STR
            -   User name. Used in :ref:`IPROTO_AUTH <box_protocol-auth>`

        *   -   IPROTO_OPS
            -   0x28 |br| MP_ARRAY
            -   Array of operations. Used in :ref:`IPROTO_UPSERT <box_protocol-upsert>`

        *   -   IPROTO_EXPR
            -   0x27 |br| MP_STR
            -   Command argument. Passed within :ref:`IPROTO_EVAL <box_protocol-eval>`


Streams
~~~~~~~

..  container:: table

    ..  list-table::
        :header-rows: 1
        :widths: 35 20 45

        *   -   Name
            -   Code, value type
            -   Description

        *   -   :ref:`IPROTO_STREAM_ID <box_protocol-iproto_stream_id>`
            -   0x0a |br| MP_UINT
            -   Unique :ref:`stream <txn_mode_stream-interactive-transactions>` identifier

        *   -   :ref:`IPROTO_TXN_ISOLATION <internals-iproto-keys-txn_isolation>`
            -   0x59 |br| MP_UINT
            -   Transaction isolation level


..  _internals-iproto-keys-replication-general:

General replication
~~~~~~~~~~~~~~~~~~~

..  container:: table

    ..  list-table::
        :header-rows: 1
        :widths: 35 20 45

        *   -   Name
            -   Code, value type
            -   Description

        *   -   IPROTO_REPLICA_ID
            -   0x02 |br| MP_INT
            -   Replica ID

        *   -   IPROTO_INSTANCE_UUID
            -   0x24 |br| :ref:`MP_UUID <msgpack_ext-uuid>`
            -   Instance UUID

        *   -   IPROTO_VCLOCK
            -   0x26 |br| MP_UINT
            -   The instance's vector clock (vclock)

        *   -   IPROTO_CLUSTER_UUID
            -   0x25 |br| :ref:`MP_UUID <msgpack_ext-uuid>`
            -   Cluster UUID

        *   -   IPROTO_LSN
            -   0x03 |br| MP_UINT
            -   Log sequence number of the transaction

        *   -   IPROTO_BALLOT_IS_RO_CFG
            -   0x01 |br| MP_BOOL
            -   True if the instance is configured as :ref:`read_only <cfg_basic-read_only>`.
                Since :doc:`2.6.1 </release/2.6.1>`

        *   -   IPROTO_BALLOT_VCLOCK
            -   0x02 |br| MP_ARRAY
            -   Current vector clock of the instance.
                Since :doc:`2.6.1 </release/2.6.1>`

        *   -   IPROTO_BALLOT_GC_VCLOCK
            -   0x03 |br| MP_ARRAY
            -   Vclock of the instance’s oldest WAL entry. Corresponds to :ref:`box.info.gc().vclock <box_info_gc>`.
                Since :doc:`2.6.1 </release/2.6.1>`

        *   -   IPROTO_BALLOT_IS_RO
            -   0x04 |br| MP_BOOL
            -   True if the instance is not writable: configured as :ref:`read_only <cfg_basic-read_only>`,
                has :ref:`orphan status <internals-replication-orphan_status>`, or
                is a :ref:`Raft follower <repl_leader_elect>`.
                Since :doc:`2.6.1 </release/2.6.1>`

        *   -   IPROTO_BALLOT_IS_ANON
            -   0x05 |br| MP_BOOL
            -   True if the replica is anonymous.
                Corresponds to :ref:`box.cfg.replication_anon <cfg_replication-replication_anon>`.
                Since :doc:`2.7.1 </release/2.7.1>`

        *   -   IPROTO_BALLOT_IS_BOOTED
            -   0x06 |br| MP_BOOL
            -   True if the instance has finished its bootstrap or recovery process.
                Since :doc:`2.7.3 </release/2.7.3>`, :doc:`2.8.2 </release/2.8.2>`, :doc:`2.10.0 </release/2.10.0>`

        *   -   IPROTO_BALLOT_CAN_LEAD
            -   0x07 |br| MP_BOOL
            -   True if :ref:`box.cfg.election_mode <cfg_replication-election_mode>` is ``candidate`` or ``manual``.
                Since v. :doc:`2.7.3 </release/2.7.3>` and :doc:`2.8.2 </release/2.8.2>`

        *   -   IPROTO_ID_FILTER
            -   0x51 |br| MP_ARRAY
            -   Optional key used in :ref:`SUBSCRIBE request <internals-iproto-replication-subscribe>`,
                followed by an array of ids of instances whose rows won't be relayed to the replica

There have been some name changes starting with versions 2.7.3, 2.8.2, and 2.10.0:

*   IPROTO_BALLOT_IS_RO_CFG was formerly called IPROTO_BALLOT_IS_RO
*   IPROTO_BALLOT_IS_RO was formerly called IPROTO_BALLOT_IS_LOADING


Synchronous replication
~~~~~~~~~~~~~~~~~~~~~~~

..  container:: table

    ..  list-table::
        :header-rows: 1
        :widths: 35 20 45

        *   -   Name
            -   Code, value type
            -   Description

        *   -   :ref:`IPROTO_FLAGS <internals-iproto-keys-flags>`
            -   0x09 |br| MP_UINT
            -   Auxiliary data to indicate the last transaction message state

        *   -   IPROTO_RAFT_TERM
            -   0x00 |br| MP_UINT
            -   :ref:`RAFT term <repl_leader_elect>` on an instance
        
        *   -   IPROTO_RAFT_VOTE
            -   0x01 |br| MP_UINT
            -   Instance vote in the current term (if any)
        
        *   -   IPROTO_RAFT_STATE
            -   0x02 |br| MP_UINT
            -   RAFT state. Possible values: ``1`` -- follower, ``2`` -- candidate, ``3`` -- leader
        
        *   -   IPROTO_RAFT_VCLOCK
            -   0x03 |br| MP_ARRAY
            -   Current vclock of the instance.
                Present only on the instances in the "candidate" state (IPROTO_RAFT_STATE == 2).
        
        *   -   IPROTO_RAFT_LEADER_ID
            -   0x04 |br| MP_UINT
            -   Current leader node ID as seen by the node that issues the request. Since version :doc:`2.10.0 </release/2.10.0>`
        
        *   -   IPROTO_RAFT_IS_LEADER_SEEN
            -   0x05 |br| MP_BOOL
            -   True if the node has a direct connection to the leader node. Since version :doc:`2.10.0 </release/2.10.0>`

Events and subscriptions
~~~~~~~~~~~~~~~~~~~~~~~~

..  container:: table

    ..  list-table::
        :header-rows: 1
        :widths: 35 20 45

        *   -   Name
            -   Code, value type
            -   Description

        *   -   IPROTO_EVENT_KEY
            -   0x56 |br| MP_STR
            -   :ref:`Event <box-protocol-watchers>` key name

        *   -   IPROTO_EVENT_DATA
            -   0x57 |br| MP_OBJECT
            -   :ref:`Event <box-protocol-watchers>` data sent to a remote watcher

:ref:`Learn more about events and subscriptions in iproto <box-protocol-watchers>`.

SQL-specific
~~~~~~~~~~~~

These keys are used with SQL within :ref:`SQL-specific requests and responses <internals-iproto-sql>`
like :ref:`IPROTO_EXECUTE <box_protocol-execute>`
and :ref:`IPROTO_PREPARE <box_protocol-prepare>`.

..  container:: table

    ..  list-table::
        :header-rows: 1
        :widths: 35 20 45

        *   -   Name
            -   Code, value type
            -   Description
        
        *   -   IPROTO_SQL_TEXT
            -   0x40 |br| MP_STR
            -   SQL statement text
            
        *   -   IPROTO_STMT_ID
            -   0x43 |br| MP_INT
            -   Identifier of the prepared statement

        *   -   IPROTO_OPTIONS
            -   0x2b |br| MP_ARRAY
            -   SQL transaction options. Usually empty

        *   -   :ref:`IPROTO_METADATA <internals-iproto-keys-metadata>`
            -   0x32 |br| MP_ARRAY of MP_MAP items
            -   SQL transaction metadata

        *   -   IPROTO_FIELD_NAME
            -   0x00 |br| MP_STR
            -   Field name. Nested in :ref:`IPROTO_METADATA <internals-iproto-keys-metadata>`

        *   -   IPROTO_FIELD_TYPE
            -   0x01 |br| MP_STR
            -   Field type. Nested in :ref:`IPROTO_METADATA <internals-iproto-keys-metadata>`

        *   -   IPROTO_FIELD_COLL
            -   0x02 |br| MP_STR
            -   Field collation. Nested in :ref:`IPROTO_METADATA <internals-iproto-keys-metadata>`

        *   -   IPROTO_FIELD_IS_NULLABLE
            -   0x03 |br| MP_BOOL
            -   True if the field is nullable. Nested in :ref:`IPROTO_METADATA <internals-iproto-keys-metadata>`.
        
        *   -   IPROTO_FIELD_IS_AUTOINCREMENT
            -   0x04 |br| MP_BOOL
            -   True if the field is auto-incremented.
                Nested in :ref:`IPROTO_METADATA <internals-iproto-keys-metadata>`.
        
        *   -   IPROTO_FIELD_SPAN
            -   0x05 |br| MP_STR or MP_NIL
            -   Original expression under SELECT.
                Nested in :ref:`IPROTO_METADATA <internals-iproto-keys-metadata>`.
                See :ref:`box.execute() <box-sql_if_full_metadata>`
        
        *   -   IPROTO_BIND_METADATA
            -   0x33 |br| MP_ARRAY
            -   Bind variable names and types
        
        *   -   IPROTO_BIND_COUNT
            -   0x34 |br| MP_INT
            -   Number of parameters to bind
        
        *   -   IPROTO_SQL_BIND
            -   0x41 |br| MP_ARRAY
            -   Parameter values to match ? placeholders or :name placeholders
        
        *   -   :ref:`IPROTO_SQL_INFO <internals-iproto-keys-sql_info>`
            -   0x42 |br| MP_MAP
            -   Additional SQL-related parameters

        *   -   :ref:`SQL_INFO_ROW_COUNT <internals-iproto-keys-sql_info>`
            -   0x00 |br| MP_UINT
            -   Number of changed rows. Nested in :ref:`IPROTO_SQL_INFO <internals-iproto-keys-sql_info>`

        *   -   :ref:`SQL_INFO_AUTO_INCREMENT_IDS <internals-iproto-keys-sql_info>`
            -   0x01 |br| MP_ARRAY of MP_UINT items
            -   New primary key value (or values) for an INSERT in a table
                defined with PRIMARY KEY AUTOINCREMENT.
                Nested in :ref:`IPROTO_SQL_INFO <internals-iproto-keys-sql_info>`


Details on specific keys
------------------------

..  _internals-iproto-keys-version:

IPROTO_VERSION
~~~~~~~~~~~~~~

Code: 0x54.

IPROTO_VERSION is an integer number reflecting the version of protocol that the
client supports. The latest IPROTO_VERSION is |iproto_version|.


..  _internals-iproto-keys-features:

IPROTO_FEATURES
~~~~~~~~~~~~~~~

Code: 0x55.

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

Code: 0x01.

This is an unsigned integer that should be incremented so that it is unique in every
request. This integer is also returned from :doc:`/reference/reference_lua/box_session/sync`.

The IPROTO_SYNC value of a response should be the same as
the IPROTO_SYNC value of a request.

..  _internals-iproto-keys-schema_version:

IPROTO_SCHEMA_VERSION
~~~~~~~~~~~~~~~~~~~~~

Code: 0x05.

An unsigned number that goes up when there is a major change in the schema.

In a *request* header, IPROTO_SCHEMA_VERSION is optional, so the version will not
be checked if it is absent.

In a *response* header, IPROTO_SCHEMA_VERSION is always present, and it is up to
the client to check if it has changed.

..  _internals-iproto-keys-iterator:

IPROTO_ITERATOR
~~~~~~~~~~~~~~~

Code: 0x14.

Possible values (see `iterator_type.h <https://github.com/tarantool/tarantool/blob/master/src/box/iterator_type.h>`_):

..  container:: table

    ..  list-table::
        :header-rows: 0
        :widths: 15 85

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

Code: 0x0a.

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


..  _internals-iproto-keys-request_type:

IPROTO_REQUEST_TYPE
~~~~~~~~~~~~~~~~~~~

Code: 0x00.

The key is used both in requests and responses. It indicates the request or response type.
It can have the following values:

*   :ref:`IPROTO_OK <internals-iproto-keys-ok>`.
*   :ref:`IPROTO_CHUNK <internals-iproto-keys-chunk>`.
*   :ref:`IPROTO_TYPE_ERROR <internals-iproto-keys-type_error>`, where the value depends on the error code.
*   Any request or response name (example: IPROTO_AUTH).
    See requests and responses for :ref:`client-server communication <internals-requests_responses>`,
    :ref:`replication <internals-iproto-replication>`,
    :ref:`events and subscriptions <box-protocol-watchers>`,
    :ref:`streams and interactive transactions <internals-iproto-streams>`.

The first three types are described below.

..  _internals-iproto-keys-ok:

IPROTO_OK
~~~~~~~~~

Code: 0x00.

The request type is contained in the header and signifies success. Here is an example:

..  cssclass:: highlight
..  parsed-literal::

    # <size>
    msgpack(:samp:`{{MP_UINT unsigned integer = size(<header>) + size(<body>)}}`)
    # <header>
    msgpack({
        IPROTO_REQUEST_TYPE: IPROTO_OK,
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

Code: 0x80.

If the response is out-of-band, due to use of :ref:`box.session.push() <box_session-push>`,
then IPROTO_REQUEST_TYPE is IPROTO_CHUNK instead of IPROTO_OK.

..  _internals-iproto-keys-type_error:

IPROTO_TYPE_ERROR
~~~~~~~~~~~~~~~~~

Code: 0x8XXX (see below).

Instead of :ref:`IPROTO_OK <internals-iproto-keys-ok>`, an error response header
has ``0x8XXX`` for IPROTO_REQUEST_TYPE. ``XXX`` is the error code -- a value in
`src/box/errcode.h <https://github.com/tarantool/tarantool/blob/master/src/box/errcode.h>`_.
``src/box/errcode.h`` also has some convenience macros which define hexadecimal
constants for return codes.

To learn more about error responses,
check the section :ref:`Request and response format <box_protocol-responses_error>`.

..  _internals-iproto-keys-error:

IPROTO_ERROR
~~~~~~~~~~~~

Code: 0x52.

In case of error, the response body contains IPROTO_ERROR and :ref:`IPROTO_ERROR_24 <internals-iproto-keys-error_24>`
instead of IPROTO_DATA.

To learn more about error responses, check the section :ref:`Request and response format <box_protocol-responses_error>`.

..  _internals-iproto-keys-error_24:

IPROTO_ERROR_24
~~~~~~~~~~~~~~~

Code: 0x31.
    
IPROTO_ERROR_24 is used in Tarantool versions prior to :doc:`2.4.1 </release/2.4.1>`.
The key contains the error in the string format.

Since :doc:`Tarantool 2.4.1 </release/2.4.1>`,
Tarantool packs errors as the :ref:`MP_ERROR <msgpack_ext-error>` MessagePack extension,
which includes extra information. Two keys are passed in the error response body: IPROTO_ERROR and IPROTO_ERROR_24.

To learn more about error responses, check the section :ref:`Request and response format <box_protocol-responses_error>`.

..  _internals-iproto-keys-tuple:

IPROTO_TUPLE
~~~~~~~~~~~~

Code: 0x21.

Multiple operations make use of this key in different ways:

..  container:: table

    ..  list-table::
        :widths: 25 75
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

..  _internals-iproto-keys-flags:
..  _box_protocol-flags:

IPROTO_FLAGS
~~~~~~~~~~~~

Code: 0x09.

When it comes to replicating synchronous transactions, the IPROTO_FLAGS key is included in the header.
The key contains an MP_UINT value of one or more bits:

*   IPROTO_FLAG_COMMIT (0x01) will be set if this is the last message for a transaction.
*   IPROTO_FLAG_WAIT_SYNC (0x02) will be set if this is the last message
    for a transaction which cannot be completed immediately.
*   IPROTO_FLAG_WAIT_ACK (0x04) will be set if this is the last message for a synchronous transaction.

Example:

..  cssclass:: highlight
..  parsed-literal::

    # <size>
    msgpack(:samp:`{{MP_UINT unsigned integer = size(<header>) + size(<body>)}}`)
    # <header>
    msgpack({
        # ... other header items ...,
        IPROTO_FLAGS: :samp:`{{MP_UINT unsigned integer}}`
    })
    # <body>
    msgpack({
        # ... message for a transaction ...
    })


..  _internals-iproto-keys-metadata:
    
IPROTO_METADATA
~~~~~~~~~~~~~~~

Code: 0x32.

Used with SQL within IPROTO_EXECUTE.

The key contains an array of column maps, with each column map containing
at least IPROTO_FIELD_NAME (0x00) and MP_STR, and IPROTO_FIELD_TYPE (0x01) and MP_STR.

Additionally, if ``sql_full_metadata`` in the
:ref:`_session_settings <box_space-session_settings>` system space
is TRUE, then the array will have these additional column maps
which correspond to components described in the :ref:`box.execute() <box-sql_if_full_metadata>` section.

