..  _box_protocol-key_list:
..  _internals-iproto-keys:

Keys used in requests and responses
===================================

This section describes ``iproto`` keys contained in requests and responses.
The keys are Tarantool constants that are either defined or mentioned in the
`iproto_constants.h file <https://github.com/tarantool/tarantool/blob/master/src/box/iproto_constants.h>`_.

While the keys themselves are unsigned 8-bit integers, their values can have different types.

..  _internals-iproto-keys-basic:

Basic description
-----------------

General
~~~~~~~

..  container:: table

    ..  list-table::
        :header-rows: 1
        :widths: 40 20 40

        *   -   Name
            -   Code and |br| value type
            -   Description

        *   -   :ref:`IPROTO_VERSION <internals-iproto-keys-version>`
            -   0x54 |br| MP_UINT
            -   Binary protocol version supported by the client

        *   -   :ref:`IPROTO_FEATURES <internals-iproto-keys-features>`
            -   0x55 |br|  MP_ARRAY
            -   Supported binary protocol features

        *   -   :ref:`IPROTO_SYNC <internals-iproto-keys-sync>`
            -   0x01 |br|  MP_UINT
            -   Unique request identifier

        *   -   :ref:`IPROTO_SCHEMA_VERSION <internals-iproto-keys-schema_version>`
            -   0x05 |br|  MP_UINT
            -   Version of the database schema

        *   -   IPROTO_TIMESTAMP
            -   0x04 |br| MP_DOUBLE 
            -   Time in seconds since the Unix epoch

        *   -   :ref:`IPROTO_REQUEST_TYPE <internals-iproto-keys-request_type>`
            -   0x00 |br| MP_UINT
            -   Request type or response type

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
            -   Command argument. Used in :ref:`IPROTO_EVAL <box_protocol-eval>`

        *   -   IPROTO_AUTH_TYPE
            -   0x5b |br| MP_STR
            -   A :ref:`protocol <authentication-passwords>` used to generate user authentication data

        *   -   IPROTO_AFTER_POSITION
            -   0x2e |br| MP_STR
            -   The position of a tuple after which :ref:`space_object:select() <box_space-select>` starts the search

        *   -   IPROTO_AFTER_TUPLE
            -   0x2f |br| MP_ARRAY
            -   A tuple after which :ref:`space_object:select() <box_space-select>` starts the search

        *   -   IPROTO_FETCH_POSITION
            -   0x1f |br| MP_BOOL
            -   If **true**, :ref:`space_object:select() <box_space-select>` returns the position of the last selected tuple

        *   -   IPROTO_POSITION
            -   0x35 |br| MP_STR
            -   If ``IPROTO_FETCH_POSITION`` is **true**, returns a base64-encoded string representing
                the position of the last selected tuple

..  _internals-iproto-keys-streams:

Streams
~~~~~~~

..  container:: table

    ..  list-table::
        :header-rows: 1
        :widths: 40 20 40

        *   -   Name
            -   Code and |br| value type
            -   Description

        *   -   :ref:`IPROTO_STREAM_ID <box_protocol-iproto_stream_id>`
            -   0x0a |br| MP_UINT
            -   Unique :ref:`stream <txn_mode_stream-interactive-transactions>` identifier

        *   -   IPROTO_TIMEOUT
            -   0x56 |br| MP_DOUBLE
            -   Timeout in seconds, after which the transactions are rolled back

        *   -   :ref:`IPROTO_TXN_ISOLATION <internals-iproto-keys-txn_isolation>`
            -   0x59 |br| MP_UINT
            -   Transaction isolation level


..  _internals-iproto-keys-replication-general:

General replication
~~~~~~~~~~~~~~~~~~~

..  container:: table

    ..  list-table::
        :header-rows: 1
        :widths: 40 20 40

        *   -   Name
            -   Code and |br| value type
            -   Description

        *   -   IPROTO_REPLICA_ID
            -   0x02 |br| MP_INT
            -   Replica ID

        *   -   IPROTO_INSTANCE_UUID
            -   0x24 |br| MP_STR
            -   Instance UUID

        *   -   :ref:`IPROTO_VCLOCK <internals-iproto-keys-vclock>`
            -   0x26 |br| MP_MAP
            -   The instance's vclock

        *   -   :ref:`IPROTO_VCLOCK_SYNC <internals-iproto-keys-vclock>`
            -   0x5a |br| MP_UINT
            -   ID of the vclock synchronization request.
                Since 2.11

        *   -   IPROTO_REPLICASET_UUID
            -   0x25 |br| MP_STR
            -   Before Tarantool version 2.11, IPROTO_REPLICASET_UUID was called IPROTO_CLUSTER_UUID.

        *   -   IPROTO_LSN
            -   0x03 |br| MP_UINT
            -   Log sequence number of the transaction

        *   -   IPROTO_TSN
            -   0x08 |br| MP_UINT
            -   Transaction sequence number

        *   -   :ref:`IPROTO_BALLOT_IS_RO_CFG <internals-iproto-keys-ballot>`
            -   0x01 |br| MP_BOOL
            -   True if the instance is configured as :ref:`read_only <cfg_basic-read_only>`.
                Since :doc:`2.6.1 </release/2.6.1>`

        *   -   :ref:`IPROTO_BALLOT_VCLOCK <internals-iproto-keys-vclock>`
            -   0x02 |br| MP_MAP
            -   Current vclock of the instance

        *   -   :ref:`IPROTO_BALLOT_GC_VCLOCK <internals-iproto-keys-vclock>`
            -   0x03 |br| MP_MAP
            -   Vclock of the instance’s oldest WAL entry

        *   -   :ref:`IPROTO_BALLOT_IS_RO <internals-iproto-keys-ballot>`
            -   0x04 |br| MP_BOOL
            -   True if the instance is not writable: configured as :ref:`read_only <cfg_basic-read_only>`,
                has :ref:`orphan status <internals-replication-orphan_status>`, or
                is a :ref:`Raft follower <repl_leader_elect>`.
                Since :doc:`2.6.1 </release/2.6.1>`

        *   -   :ref:`IPROTO_BALLOT_IS_ANON <internals-iproto-keys-ballot>`
            -   0x05 |br| MP_BOOL
            -   True if the replica is anonymous.
                Corresponds to :ref:`replication.anon <configuration_reference_replication_anon>`.
                Since :doc:`2.7.1 </release/2.7.1>`

        *   -   :ref:`IPROTO_BALLOT_IS_BOOTED <internals-iproto-keys-ballot>`
            -   0x06 |br| MP_BOOL
            -   True if the instance has finished its bootstrap or recovery process.
                Since :doc:`2.7.3 </release/2.7.3>`, :doc:`2.8.2 </release/2.8.2>`, :doc:`2.10.0 </release/2.10.0>`

        *   -   :ref:`IPROTO_BALLOT_CAN_LEAD <internals-iproto-keys-ballot>`
            -   0x07 |br| MP_BOOL
            -   True if :ref:`box.cfg.election_mode <cfg_replication-election_mode>` is ``candidate`` or ``manual``.
                Since v. :doc:`2.7.3 </release/2.7.3>` and :doc:`2.8.2 </release/2.8.2>`

        *   -   :ref:`IPROTO_BALLOT_BOOTSTRAP_LEADER_UUID <internals-iproto-keys-ballot>`
            -   0x08 |br| MP_STR
            -   UUID of the bootstrap leader. The UUID is encoded as a 36-byte string.
                Since v. 2.11

        *   -   :ref:`IPROTO_BALLOT_REGISTERED_REPLICA_UUIDS <internals-iproto-keys-ballot>`
            -   0x09 |br| MP_ARRAY
            -   An array of MP_STR elements that contains the UUIDs of members registered in the replica set.
                Each UUID is encoded as a 36-byte string.
                Since v. 2.11
        
        *   -   :ref:`IPROTO_FLAGS <internals-iproto-keys-flags>`
            -   0x09 |br| MP_UINT
            -   Auxiliary data to indicate the last transaction message state.
                Included in the header of any DML request that is recorded in the WAL.

        *   -   IPROTO_SERVER_VERSION
            -   0x06 |br| MP_UINT
            -   Tarantool version of the subscribing node,
                in a compact representation

        *   -   IPROTO_REPLICA_ANON
            -   0x50 |br| MP_BOOL
            -   Optional key used in :ref:`SUBSCRIBE request <internals-iproto-replication-subscribe>`.
                True if the subscribing replica is anonymous

        *   -   IPROTO_ID_FILTER
            -   0x51 |br| MP_ARRAY
            -   Optional key used in :ref:`SUBSCRIBE request <internals-iproto-replication-subscribe>`,
                followed by an array of ids of instances whose rows won't be relayed to the replica.
                Since v. :doc:`2.10.0 </release/2.10.0>`

..  _internals-iproto-keys-synchro-replication:

Synchronous replication
~~~~~~~~~~~~~~~~~~~~~~~

..  container:: table

    ..  list-table::
        :header-rows: 1
        :widths: 40 20 40

        *   -   Name
            -   Code and |br| value type
            -   Description

        *   -   :ref:`IPROTO_TERM <internals-iproto-keys-term>`
            -   0x53 |br| MP_UINT
            -   :ref:`RAFT term <repl_leader_elect>` on an instance

        *   -   IPROTO_RAFT_TERM
            -   0x00 |br| MP_UINT
            -   :ref:`RAFT term <repl_leader_elect>` on an instance.
                The key is only used for requests with the :ref:`IPROTO_RAFT <box_protocol-raft>` type.
        
        *   -   IPROTO_RAFT_VOTE
            -   0x01 |br| MP_UINT
            -   Instance vote in the current term (if any)
        
        *   -   IPROTO_RAFT_STATE
            -   0x02 |br| MP_UINT
            -   :ref:`RAFT state <repl_leader_elect>`. Possible values: ``1`` -- follower, ``2`` -- candidate, ``3`` -- leader
        
        *   -   :ref:`IPROTO_RAFT_VCLOCK <internals-iproto-keys-vclock>`
            -   0x03 |br| MP_MAP
            -   Current vclock of the instance
        
        *   -   IPROTO_RAFT_LEADER_ID
            -   0x04 |br| MP_UINT
            -   Current leader node ID as seen by the node that issues the request
                Since version :doc:`2.10.0 </release/2.10.0>`
        
        *   -   IPROTO_RAFT_IS_LEADER_SEEN
            -   0x05 |br| MP_BOOL
            -   True if the node has a direct connection to the leader node. 
                Since version :doc:`2.10.0 </release/2.10.0>`

All ``IPROTO_RAFT_*`` keys are used only in ``IPROTO_RAFT*`` requests.

..  _internals-iproto-keys-events:

Events and subscriptions
~~~~~~~~~~~~~~~~~~~~~~~~

..  container:: table

    ..  list-table::
        :header-rows: 1
        :widths: 40 20 40

        *   -   Name
            -   Code and |br| value type
            -   Description

        *   -   IPROTO_EVENT_KEY
            -   0x57 |br| MP_STR
            -   :ref:`Event <box-protocol-watchers>` key name

        *   -   IPROTO_EVENT_DATA
            -   0x58 |br| MP_OBJECT
            -   :ref:`Event <box-protocol-watchers>` data sent to a remote watcher

:ref:`Learn more about events and subscriptions in iproto <box-protocol-watchers>`.

..  _internals-iproto-keys-sql-specific:

SQL-specific
~~~~~~~~~~~~

These keys are used with SQL within :ref:`SQL-specific requests and responses <internals-iproto-sql>`
like :ref:`IPROTO_EXECUTE <box_protocol-execute>`
and :ref:`IPROTO_PREPARE <box_protocol-prepare>`.

..  container:: table

    ..  list-table::
        :header-rows: 1
        :widths: 40 20 40

        *   -   Name
            -   Code and |br| value type
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
        
        *   -   :ref:`IPROTO_SQL_BIND <internals-iproto-keys-sql_bind>`
            -   0x41 |br| MP_ARRAY
            -   Parameter values to match ? placeholders or :name placeholders
        
        *   -   IPROTO_SQL_INFO
            -   0x42 |br| MP_MAP
            -   Additional SQL-related parameters

        *   -   SQL_INFO_ROW_COUNT
            -   0x00 |br| MP_UINT
            -   Number of changed rows. Is ``0`` for statements that do not change rows. Nested in IPROTO_SQL_INFO

        *   -   SQL_INFO_AUTO_INCREMENT_IDS
            -   0x01 |br| MP_ARRAY of MP_UINT items
            -   New primary key value (or values) for an INSERT in a table
                defined with PRIMARY KEY AUTOINCREMENT.
                Nested in IPROTO_SQL_INFO


Details on individual keys
--------------------------

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
    MsgPack extension support. Clients that don't support this feature receive
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

Version of the database schema --
an unsigned number that goes up when there is a major change in the schema.

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

The key is used both in requests and responses. It indicates the request or response type
and has any request or response name for the value (example: IPROTO_AUTH).
See requests and responses for :ref:`client-server communication <internals-requests_responses>`,
:ref:`replication <internals-iproto-replication>`,
:ref:`events and subscriptions <box-protocol-watchers>`,
:ref:`streams and interactive transactions <internals-iproto-streams>`.

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
    
IPROTO_ERROR_24 is used in Tarantool versions before :doc:`2.4.1 </release/2.4.1>`.
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
        *   -   :ref:`IPROTO_UPDATE <box_protocol-update>`
            -   Operations to perform
        *   -   :ref:`IPROTO_AUTH <box_protocol-auth>`
            -   Array of 2 fields:
                authentication mechanism and scramble, encrypted according to the specified mechanism.
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

*   IPROTO_FLAG_COMMIT (0x01) is set if this is the last message for a transaction.
*   IPROTO_FLAG_WAIT_SYNC (0x02) is set if this is the last message
    for a transaction which cannot be completed immediately.
*   IPROTO_FLAG_WAIT_ACK (0x04) is set if this is the last message for a synchronous transaction.

Example:

..  raw:: html
    :file: images/flags_example.svg

..  _internals-iproto-keys-term:

IPROTO_TERM
~~~~~~~~~~~

Code: 0x53.

*   The key is used in the :ref:`IPROTO_RAFT_PROMOTE <internals-iproto-replication-raft_promote>`
    and :ref:`IPROTO_RAFT_DEMOTE <internals-iproto-replication-raft_demote>` requests.

*   Since version 2.11, the key is included in response to a :ref:`heartbeat message <box_protocol-heartbeat>`.
    The term corresponds to the value of :ref:`box.info.synchro.queue.term <box_info_synchro>` on the sender instance.

..  _internals-iproto-keys-vclock:

Vclock keys
~~~~~~~~~~~

The vclock (vector clock) is a log sequence number map that defines the version of the dataset stored on the node.
In fact, it represents the number of logical operations executed on a specific node. A vclock looks like this:

..  raw:: html
    :file: images/vclock.svg

There are five keys that correspond to vector clocks in different contexts of replication.
They all have the MP_MAP type:

*   IPROTO_VCLOCK (0x26) is passed to a new instance :ref:`joining the replica set <box_protocol-join>`.

*   IPROTO_VCLOCK_SYNC (0x5a) is used by :ref:`replication heartbeats <box_protocol-heartbeat>`.
    The master sends its heartbeats, including this monotonically growing key, to a replica.
    Once the replica receives a heartbeat with a non-zero IPROTO_VCLOCK_SYNC value,
    it starts responding with the same value in all its acknowledgements.
    This key was introduced in version 2.11.

*   IPROTO_BALLOT_VCLOCK (0x02) is included in the :ref:`IPROTO_BALLOT <box_protocol-ballots>` message.
    IPROTO_BALLOT is sent in response to the :ref:`IPROTO_VOTE <internals-iproto-replication-vote>` request.
    This key was introduced in :doc:`/release/2.6.1`.

*   IPROTO_BALLOT_GC_VCLOCK (0x03) is also included in the :ref:`IPROTO_BALLOT <box_protocol-ballots>` message.
    IPROTO_BALLOT is sent in response to the :ref:`IPROTO_VOTE <internals-iproto-replication-vote>` request.
    It is the vclock of the oldest WAL entry on the instance.
    Corresponds to :ref:`box.info.gc().vclock <box_info_gc>`.
    This key was introduced in :doc:`/release/2.6.1`.

*   IPROTO_RAFT_VCLOCK (0x03) is included in the :ref:`IPROTO_RAFT <box_protocol-raft>` message.
    It is present only on the instances in the :ref:`"candidate" state <cfg_replication-election_mode>`
    (IPROTO_RAFT_STATE == 2).

..  _internals-iproto-keys-ballot:

IPROTO_BALLOT keys
~~~~~~~~~~~~~~~~~~

All IPROTO_BALLOT_* keys are only used in the :ref:`IPROTO_BALLOT <box_protocol-ballots>` requests.
There have been the following name changes starting with versions :doc:`/release/2.7.3`, :doc:`/release/2.8.2`,
and :doc:`/release/2.10.0`:

*   IPROTO_BALLOT_IS_RO_CFG (0x01) was formerly called IPROTO_BALLOT_IS_RO.
*   IPROTO_BALLOT_IS_RO (0x04) was formerly called IPROTO_BALLOT_IS_LOADING.

..  _internals-iproto-keys-metadata:
    
IPROTO_METADATA
~~~~~~~~~~~~~~~

Code: 0x32.

Used with SQL within :ref:`IPROTO_EXECUTE <box_protocol-execute>`.

The key contains an array of column maps, with each column map containing
at least IPROTO_FIELD_NAME (0x00) and MP_STR, and IPROTO_FIELD_TYPE (0x01) and MP_STR.

Additionally, if ``sql_full_metadata`` in the
:ref:`_session_settings <box_space-session_settings>` system space
is TRUE, then the array has these additional column maps
which correspond to components described in the :ref:`box.execute() <box-sql_if_full_metadata>` section.

..  _internals-iproto-keys-sql_bind:

IPROTO_SQL_BIND
~~~~~~~~~~~~~~~

Code: 0x41.

Used with SQL within :ref:`IPROTO_EXECUTE <box_protocol-execute>`.

IPROTO_SQL_BIND is an array of parameter values to match ? placeholders or :name placeholders.
It can contain values of any type, including MP_MAP.

*   Values that are not MP_MAP replace the ``?`` placeholders in the request.

*   MP_MAP values must have the format ``{[name] = value}``,
    where ``name`` is the named parameter in the request. Here is an example of such a request:

    ..  code-block:: tarantoolsession

        tarantool> conn:execute('SELECT ?, ?, :name1, ?, :name2, :name1', {1, 2, {[':name1'] = 5}, 'str', {[':name2'] = true}})
        ---
        - metadata:
        - name: COLUMN_1
            type: integer
        - name: COLUMN_2
            type: integer
        - name: COLUMN_3
            type: integer
        - name: COLUMN_4
            type: text
        - name: COLUMN_5
            type: boolean
        - name: COLUMN_6
            type: boolean
        rows:
        - [1, 2, 5, 'str', true, 5]  
