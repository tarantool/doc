..  _box_protocol-iproto_protocol:

..  _internals-box_protocol:

Binary protocol
===============

Introduction
------------

The binary protocol, iproto, is called a "request/response" protocol because it is
for sending requests to a Tarantool server and receiving responses.
There is complete access to Tarantool functionality, including:

*   request multiplexing, for example ability to issue multiple requests
    asynchronously via the same connection
*   response format that supports zero-copy writes

The protocol can be called "binary" because the most-frequently-used database accesses
are done with binary codes instead of Lua request text. Tarantool experts use it:

*   to write their own connectors
*   to understand network messages
*   to support new features that their favorite connector doesn't support yet
*   to avoid repetitive parsing by the server

This document describes ``iproto`` :ref:`keys <box_protocol-key_list>` that are passed in binary code
via the protocol.
They are Tarantool constants that are either defined or mentioned in the
`iproto_constants.h file <https://github.com/tarantool/tarantool/blob/master/src/box/iproto_constants.h>`_.

..  _TODO:  shorten the introductory text
            describe the document structure, provide links like in Concepts
            Then goes the Symbols and terms section, and then the toctree


..  _box_protocol-notation:

Symbols and terms
-----------------

MP_*
~~~~

Words that start with **MP_** mean
a `MessagePack <http://MessagePack.org>`_ type or a range of MessagePack types,
including the signal and possibly including a value, with slight modification:

..  container:: table

    ..  list-table::
        :widths: 30 70
        :header-rows: 0

        *   -   **MP_NIL**
            -   nil
        *   -   **MP_UINT**
            -   unsigned integer
        *   -   **MP_INT**
            -   either integer or unsigned integer
        *   -   **MP_STR**
            -   string
        *   -   **MP_BIN**
            -   binary string
        *   -   **MP_ARRAY** 
            -   array
        *   -   **MP_MAP**
            -   map
        *   -   **MP_BOOL**
            -   boolean
        *   -   **MP_FLOAT**
            -   float
        *   -   **MP_DOUBLE**
            -   double
        *   -   **MP_EXT**
            -   extension (including the :ref:`DECIMAL type <msgpack_ext-decimal>` and UUID type)
        *   -   **MP_OBJECT**
            -   any MessagePack object

Short descriptions are in MessagePack's `"spec" page <https://github.com/msgpack/msgpack/blob/master/spec.md>`_.



To denote message descriptions, we will say ``msgpack(...)`` and within it we will use modified
`YAML <https://en.wikipedia.org/wiki/YAML>`_ so: |br|

:code:`{...}` braces enclose an associative array, also called map, which in MsgPack is MP_MAP, |br|
:samp:`{k}: {v}` is a key-value pair, also called map-item, in this section k is always an unsigned-integer value = one of the IPROTO constants, |br|
:samp:`{italics}` are for replaceable text, which is the convention throughout this manual. Usually this is a data type but we do not show types of IPROTO constants
which happen to always be unsigned 8-bit integers, |br|
:code:`[...]` is for non-associative arrays, |br|
:code:`#` starts a comment, especially for the beginning of a section, |br|
everything else is "as is". |br|
Map-items may appear in any order but in examples we usually use the order that ``net_box.c`` happens to use.



..  toctree::

    iproto/format
    iproto/keys
    iproto/requests
    iproto/events
    iproto/streams
    iproto/replication
    Examples <../../how-to/other/iproto>


..  _box_protocol-select:

IPROTO_SELECT = 0x01
~~~~~~~~~~~~~~~~~~~~

See :ref:`space_object:select() <box_space-select>`.
The body is a 6-item map.

..  cssclass:: highlight
..  parsed-literal::

    # <size>
    msgpack(:samp:`{{MP_UINT unsigned integer = size(<header>) + size(<body>)}}`)
    # <header>
    msgpack({
        IPROTO_REQUEST_TYPE: IPROTO_SELECT,
        IPROTO_SYNC: :samp:`{{MP_UINT unsigned integer}}`
    })
    # <body>
    msgpack({
        IPROTO_SPACE_ID: :samp:`{{MP_UINT unsigned integer}}`,
        IPROTO_INDEX_ID: :samp:`{{MP_UINT unsigned integer}}`,
        IPROTO_LIMIT: :samp:`{{MP_UINT unsigned integer}}`,
        IPROTO_OFFSET: :samp:`{{MP_UINT unsigned integer}}`,
        IPROTO_ITERATOR: :samp:`{{MP_UINT unsigned integer}}`,
        IPROTO_KEY: :samp:`{{MP_ARRAY array of key values}}`
    })

Example: if the id of 'tspace' is 512 and this is the fifth message, |br|
:samp:`{conn}.`:code:`space.tspace:select({0},{iterator='GT',offset=1,limit=2})` will cause:

..  code-block:: none

    <size>
    msgpack(21)
    # <header>
    msgpack({
        IPROTO_SYNC: 5,
        IPROTO_REQUEST_TYPE: IPROTO_SELECT
    })
    # <body>
    msgpack({
        IPROTO_SPACE_ID: 512,
        IPROTO_INDEX_ID: 0,
        IPROTO_ITERATOR: 6,
        IPROTO_OFFSET: 1,
        IPROTO_LIMIT: 2,
        IPROTO_KEY: [1]
    })

Later in :ref:`Binary protocol -- illustration <box_protocol-illustration>`
we will show actual byte codes of an IPROTO_SELECT message.


..  _box_protocol-insert:

IPROTO_INSERT = 0x02
~~~~~~~~~~~~~~~~~~~~

See :ref:`space_object:insert()  <box_space-insert>`.
The body is a 2-item map:

..  cssclass:: highlight
..  parsed-literal::

    # <size>
    msgpack(:samp:`{{MP_UINT unsigned integer = size(<header>) + size(<body>)}}`)
    # <header>
    msgpack({
        IPROTO_REQUEST_TYPE: IPROTO_INSERT,
        IPROTO_SYNC: :samp:`{{MP_UINT unsigned integer}}`
    })
    # <body>
    msgpack({
        IPROTO_SPACE_ID: :samp:`{{MP_UINT unsigned integer}}`,
        IPROTO_TUPLE: :samp:`{{MP_ARRAY array of field values}}`
    })

Example: if the id of 'tspace' is 512 and this is the fifth message, |br|
:samp:`{conn}.`:code:`space.tspace:insert{1, 'AAA'}` will cause:

..  code-block:: none

    # <size>
    msgpack(17)
    # <header>
    msgpack({
        IPROTO_REQUEST_TYPE: IPROTO_INSERT,
        IPROTO_SYNC: 5
    })
    # <body>
    msgpack({
        IPROTO_SPACE_ID: 512,
        IPROTO_TUPLE: [1, 'AAA']
    })


..  _box_protocol-replace:

IPROTO_REPLACE = 0x03
~~~~~~~~~~~~~~~~~~~~~

See :ref:`space_object:replace()  <box_space-replace>`.
The body is a 2-item map, the same as for IPROTO_INSERT:

..  cssclass:: highlight
..  parsed-literal::

    # <size>
    msgpack(:samp:`{{MP_UINT unsigned integer = size(<header>) + size(<body>)}}`)
    # <header>
    msgpack({
        IPROTO_REQUEST_TYPE: IPROTO_REPLACE,
        IPROTO_SYNC: :samp:`{{MP_UINT unsigned integer}}`
    })
    # <body>
    msgpack({
        IPROTO_SPACE_ID: :samp:`{{MP_UINT unsigned integer}}`,
        IPROTO_TUPLE: :samp:`{{MP_ARRAY array of field values}}`
    })


..  _box_protocol-update:

IPROTO_UPDATE = 0x04
~~~~~~~~~~~~~~~~~~~~

See :ref:`space_object:update()  <box_space-update>`.

The body is usually a 4-item map:

..  cssclass:: highlight
..  parsed-literal::

    # <size>
    msgpack(:samp:`{{MP_UINT unsigned integer = size(<header>) + size(<body>)}}`)
    # <header>
    msgpack({
        IPROTO_REQUEST_TYPE: IPROTO_UPDATE,
        IPROTO_SYNC: :samp:`{{MP_UINT unsigned integer}}`
    })
    # <body>
    msgpack({
        IPROTO_SPACE_ID: :samp:`{{MP_UINT unsigned integer}}`,
        IPROTO_INDEX_ID: :samp:`{{MP_UINT unsigned integer}}`,
        IPROTO_KEY: :samp:`{{MP_ARRAY array of index keys}}`,
        IPROTO_TUPLE: :samp:`{{MP_ARRAY array of update operations}}`
    })

If the operation specifies no values, then IPROTO_TUPLE is a 2-item array: |br|
:samp:`[{MP_STR OPERATOR = '#', {MP_INT FIELD_NO = field number starting with 1}]`.
Normally field numbers start with 1.

If the operation specifies one value, then IPROTO_TUPLE is a 3-item array: |br|
:samp:`[{MP_STR string OPERATOR = '+' or '-' or '^' or '^' or '|' or '!' or '='}, {MP_INT FIELD_NO}, {MP_OBJECT VALUE}]`. |br|

Otherwise IPROTO_TUPLE is a 5-item array: |br|
:samp:`[{MP_STR string OPERATOR = ':'}, {MP_INT integer FIELD_NO}, {MP_INT POSITION}, {MP_INT OFFSET}, {MP_STR VALUE}]`. |br|

Example: if the id of 'tspace' is 512 and this is the fifth message, |br|
:samp:`{conn}.`:code:`space.tspace:update(999, {{'=', 2, 'B'}})` will cause:

..  code-block:: none

    # <size>
    msgpack(17)
    # <header>
    msgpack({
        IPROTO_REQUEST_TYPE: IPROTO_UPDATE,
        IPROTO_SYNC: 5
    })
    # <body> ... the map-item IPROTO_INDEX_BASE is optional
    msgpack({
        IPROTO_SPACE_ID: 512,
        IPROTO_INDEX_ID: 0,
        IPROTO_INDEX_BASE: 1,
        IPROTO_TUPLE: [['=',2,'B']],
        IPROTO_KEY: [999]
    })

Later in :ref:`Binary protocol -- illustration <box_protocol-illustration>`
we will show actual byte codes of an IPROTO_UPDATE message.


..  _box_protocol-delete:

IPROTO_DELETE = 0x05
~~~~~~~~~~~~~~~~~~~~

See :ref:`space_object:delete()  <box_space-delete>`.
The body is a 3-item map:

..  cssclass:: highlight
..  parsed-literal::

    # <size>
    msgpack(:samp:`{{MP_UINT unsigned integer = size(<header>) + size(<body>)}}`)
    # <header>
    msgpack({
        IPROTO_REQUEST_TYPE: IPROTO_DELETE,
        IPROTO_SYNC: :samp:`{{MP_UINT unsigned integer}}`
    })
    # <body>
    msgpack({
        IPROTO_SPACE_ID: :samp:`{{MP_UINT unsigned integer}}`,
        IPROTO_INDEX_ID: :samp:`{{MP_UINT unsigned integer}}`,
        IPROTO_KEY: :samp:`{{MP_ARRAY array of key values}}`
    })


..  _box_protocol-call16:

IPROTO_CALL_16 = 0x06
~~~~~~~~~~~~~~~~~~~~~

See :ref:`conn:call() <net_box-call>`. The suffix ``_16`` is a hint that this is
for the ``call()`` until Tarantool 1.6. It is deprecated.
Use :ref:`IPROTO_CALL <box_protocol-call>` instead.
The body is a 2-item map:

..  cssclass:: highlight
..  parsed-literal::

    # <size>
    msgpack(:samp:`{{MP_UINT unsigned integer = size(<header>) + size(<body>)}}`)
    # <header>
    msgpack({
        IPROTO_REQUEST_TYPE: IPROTO_CALL_16,
        IPROTO_SYNC: :samp:`{{MP_UINT unsigned integer}}`
    })
    # <body>
    msgpack({
        IPROTO_FUNCTION_NAME: :samp:`{{MP_STR string}}`,
        IPROTO_TUPLE: :samp:`{{MP_ARRAY array of arguments}}`
    })

The return value is an array of tuples.


..  _box_protocol-auth:

IPROTO_AUTH = 0x07
~~~~~~~~~~~~~~~~~~

See :ref:`authentication <authentication-users>`.
See the later section :ref:`Binary protocol -- authentication <box_protocol-authentication>`.


..  _box_protocol-eval:

IPROTO_EVAL = 0x08
~~~~~~~~~~~~~~~~~~

See :ref:`conn:eval() <net_box-eval>`.
Since the argument is a Lua expression, this is
Tarantool's way to handle non-binary with the
binary protocol. Any request that does not have
its own code, for example :samp:`box.space.{space-name}:drop()`,
will be handled either with :ref:`IPROTO_CALL <box_protocol-call>`
or IPROTO_EVAL.
The :ref:`tarantoolctl <tarantoolctl>` administrative utility
makes extensive use of ``eval``.
The body is a 2-item map:

..  cssclass:: highlight
..  parsed-literal::

    # <size>
    msgpack(:samp:`{{MP_UINT unsigned integer = size(<header>) + size(<body>)}}`)
    # <header>
    msgpack({
        IPROTO_REQUEST_TYPE: IPROTO_EVAL,
        IPROTO_SYNC: :samp:`{{MP_UINT unsigned integer}}`
    })
    # <body>
    msgpack({
        IPROTO_EXPR: :samp:`{{MP_STR string}}`,
        IPROTO_TUPLE: :samp:`{{MP_ARRAY array of arguments}}`
    })

Example: if this is the fifth message, :samp:`conn:eval('return 5;')` will cause:

..  code-block:: none

    # <size>
    msgpack(19)
    # <header>
    msgpack({
        IPROTO_SYNC: 5
        IPROTO_REQUEST_TYPE: IPROTO_EVAL
    })
    # <body>
    msgpack({
        IPROTO_EXPR: 'return 5;',
        IPROTO_TUPLE: []
    })


..  _box_protocol-upsert:

IPROTO_UPSERT = 0x09
~~~~~~~~~~~~~~~~~~~~

See :ref:`space_object:upsert()  <box_space-upsert>`.

The body is usually a 4-item map:

..  cssclass:: highlight
..  parsed-literal::

    # <size>
    msgpack(:samp:`{{MP_UINT unsigned integer = size(<header>) + size(<body>)}}`)
    # <header>
    msgpack({
        IPROTO_REQUEST_TYPE: IPROTO_UPSERT,
        IPROTO_SYNC: :samp:`{{MP_UINT unsigned integer}}`
    })
    # <body>
    msgpack({
        IPROTO_SPACE_ID: :samp:`{{MP_UINT unsigned integer}}`,
        IPROTO_INDEX_BASE: :samp:`{{MP_UINT unsigned integer}}`,
        IPROTO_OPS: :samp:`{{MP_ARRAY array of update operations}}`,
        IPROTO_TUPLE: :samp:`{{MP_ARRAY array of primary-key field values}}`
    })

The IPROTO_OPS is the same as the IPROTO_TUPLE of :ref:`IPROTO_UPDATE <box_protocol-update>`.


..  _box_protocol-call:

IPROTO_CALL = 0x0a
~~~~~~~~~~~~~~~~~~

See :ref:`conn:call() <net_box-call>`.
The body is a 2-item map:

..  cssclass:: highlight
..  parsed-literal::

    # <size>
    msgpack(:samp:`{{MP_UINT unsigned integer = size(<header>) + size(<body>)}}`)
    # <header>
    msgpack({
        IPROTO_REQUEST_TYPE: IPROTO_CALL,
        IPROTO_SYNC: :samp:`{{MP_UINT unsigned integer}}`
    })
    # <body>
    msgpack({
        IPROTO_FUNCTION_NAME: :samp:`{{MP_STR string}}`,
        IPROTO_TUPLE: :samp:`{{MP_ARRAY array of arguments}}`
    })

The response will be a list of values, similar to the
:ref:`IPROTO_EVAL <box_protocol-eval>` response.


..  _box_protocol-execute:

IPROTO_EXECUTE = 0x0b
~~~~~~~~~~~~~~~~~~~~~

See :ref:`box.execute() <box-sql_box_execute>`, this is only for SQL.
The body is a 3-item map:

..  cssclass:: highlight
..  parsed-literal::

    # <size>
    msgpack(:samp:`{{MP_UINT unsigned integer = size(<header>) + size(<body>)}}`)
    # <header>
    msgpack({
        IPROTO_REQUEST_TYPE: IPROTO_EXECUTE,
        IPROTO_SYNC: :samp:`{{MP_UINT unsigned integer}}`
    })
    # <body>
    msgpack({
        IPROTO_STMT_ID: :samp:`{{MP_INT integer}}` or IPROTO_SQL_TEXT: :samp:`{{MP_STR string}}`,
        IPROTO_SQL_BIND: :samp:`{{MP_INT integer}}`,
        IPROTO_OPTIONS: :samp:`{{MP_ARRAY array}}`
    })

Use IPROTO_STMT_ID (0x43) and statement-id (MP_INT) if executing a prepared statement,
or use
IPROTO_SQL_TEXT (0x40) and statement-text (MP_STR) if executing an SQL string, then
IPROTO_SQL_BIND (0x41) and array of parameter values to match ? placeholders or
:name placeholders, IPROTO_OPTIONS (0x2b) and array of options (usually empty).

For example, suppose we prepare a statement
with two ? placeholders, and execute with two parameters, thus: |br|
:code:`n = conn:prepare([[VALUES (?, ?);]])` |br|
:code:`conn:execute(n.stmt_id, {1,'a'})` |br|
Then the body will look like this:

..  code-block:: none

    # <body>
    msgpack({
        IPROTO_STMT_ID: 0xd7aa741b,
        IPROTO_SQL_BIND: [1, 'a'],
        IPROTO_OPTIONS: []
    })

Later in :ref:`Binary protocol -- illustration <box_protocol-illustration>`
we will show actual byte codes of the IPROTO_EXECUTE message.

To call a prepared statement with named parameters from a connector pass the
parameters within an array of maps. A client should wrap each element into a map,
where the key holds a name of the parameter (with a colon) and the value holds
an actual value. So, to bind foo and bar to 42 and 43, a client should send
``IPROTO_SQL_TEXT: <...>, IPROTO_SQL_BIND: [{"foo": 42}, {"bar": 43}]``.

If a statement has both named and non-named parameters, wrap only named ones
into a map. The rest of the parameters are positional and will be substituted in order.


..  _box_protocol-nop:

IPROTO_NOP = 0x0c
~~~~~~~~~~~~~~~~~

There is no Lua request exactly equivalent to IPROTO_NOP.
It causes the LSN to be incremented.
It could be sometimes used for updates where the old and new values
are the same, but the LSN must be increased because a data-change
must be recorded.
The body is: nothing.


..  _box_protocol-prepare:

IPROTO_PREPARE = 0x0d
~~~~~~~~~~~~~~~~~~~~~

See :ref:`box.prepare <box-sql_box_prepare>`, this is only for SQL.
The body is a 1-item map:

..  cssclass:: highlight
..  parsed-literal::

    # <size>
    msgpack(:samp:`{{MP_UINT unsigned integer = size(<header>) + size(<body>)}}`)
    # <header>
    msgpack({
        IPROTO_REQUEST_TYPE: IPROTO_PREPARE,
        IPROTO_SYNC: :samp:`{{MP_UINT unsigned integer}}`
    })
    # <body>
    msgpack({
        IPROTO_STMT_ID: :samp:`{{MP_INT integer}}` or IPROTO_SQL_TEXT: :samp:`{{MP_STR string}}`
    })

IPROTO_STMT_ID (0x43) and statement-id (MP_INT) if executing a prepared statement
or
IPROTO_SQL_TEXT (0x40) and statement-text (string) if executing an SQL string.
Thus the IPROTO_PREPARE map item is the same as the first item of the
:ref:`IPROTO_EXECUTE <box_protocol-execute>` body.

..  _box_protocol-begin:

IPROTO_BEGIN = 0x0e
~~~~~~~~~~~~~~~~~~~

Begin a transaction in the specified stream.
See :ref:`stream:begin() <net_box-stream_begin>`.
The body is optional and can contain two items:

..  cssclass:: highlight
..  parsed-literal::

    # <size>
    msgpack(:samp:`{{MP_UINT unsigned integer = size(<header>) + size(<body>)}}`)
    # <header>
    msgpack({
        IPROTO_REQUEST_TYPE: IPROTO_BEGIN,
        IPROTO_SYNC: :samp:`{{MP_UINT unsigned integer}}`,
        IPROTO_STREAM_ID: :samp:`{{MP_UINT unsigned integer}}`
    })
    # <body>
    msgpack({
        IPROTO_TIMEOUT: :samp:`{{MP_DOUBLE}}`,
        IPROTO_TXN_ISOLATION: :samp:`{{MP_UINT unsigned integer}}`
    })

IPROTO_TIMEOUT is an optional timeout (in seconds). After it expires,
the transaction will be rolled back automatically.

IPROTO_TXN_ISOLATION is the :ref:`transaction isolation level <txn_mode_mvcc-options>`.
It can take the following values:

- ``TXN_ISOLATION_DEFAULT = 0``	-- use the default level from ``box.cfg`` (default value)
- ``TXN_ISOLATION_READ_COMMITTED = 1`` -- read changes that are committed but not confirmed yet
- ``TXN_ISOLATION_READ_CONFIRMED = 2`` -- read confirmed changes
- ``TXN_ISOLATION_BEST_EFFORT = 3`` -- determine isolation level automatically

See :ref:`Binary protocol -- streams <box_protocol-streams>` to learn more about
stream transactions in the binary protocol.

..  _box_protocol-commit:

IPROTO_COMMIT = 0x0f
~~~~~~~~~~~~~~~~~~~~

Commit the transaction in the specified stream.
See :ref:`stream:commit() <net_box-stream_commit>`.

..  cssclass:: highlight
..  parsed-literal::

    # <size>
    msgpack(7)
    # <header>
    msgpack({
        IPROTO_REQUEST_TYPE: IPROTO_COMMIT,
        IPROTO_SYNC: :samp:`{{MP_UINT unsigned integer}}`,
        IPROTO_STREAM_ID: :samp:`{{MP_UINT unsigned integer}}`
    })

See :ref:`Binary protocol -- streams <box_protocol-streams>` to learn more about
stream transactions in the binary protocol.


..  _box_protocol-rollback:

IPROTO_ROLLBACK = 0x10
~~~~~~~~~~~~~~~~~~~~~~

Rollback the transaction in the specified stream.
See :ref:`stream:rollback() <net_box-stream_rollback>`.

..  cssclass:: highlight
..  parsed-literal::

    # <size>
    msgpack(7)
    # <header>
    msgpack({
        IPROTO_REQUEST_TYPE: IPROTO_ROLLBACK,
        IPROTO_SYNC: :samp:`{{MP_UINT unsigned integer}}`,
        IPROTO_STREAM_ID: :samp:`{{MP_UINT unsigned integer}}`
    })

See :ref:`Binary protocol -- streams <box_protocol-streams>` to learn more about
stream transactions in the binary protocol.


..  _box_protocol-ping:

IPROTO_PING = 0x40
~~~~~~~~~~~~~~~~~~

See :ref:`conn:ping() <conn-ping>`. The body will be an empty map because IPROTO_PING
in the header contains all the information that the server instance needs.

..  cssclass:: highlight
..  parsed-literal::

    # <size>
    msgpack(5)
    # <header>
    msgpack({
        IPROTO_REQUEST_TYPE: IPROTO_PING,
        IPROTO_SYNC: :samp:`{{MP_UINT unsigned integer}}`
    })

..  _box_protocol-join:

..  code-block:: lua

    IPROTO_JOIN = 0x41 -- for replication
    IPROTO_SUBSCRIBE = 0x42 -- for replication SUBSCRIBE
    IPROTO_VOTE_DEPRECATED = 0x43 -- for old style vote, superseded by IPROTO_VOTE
    IPROTO_VOTE = 0x44 -- for master election
    IPROTO_FETCH_SNAPSHOT = 0x45 -- for starting anonymous replication
    IPROTO_REGISTER = 0x46 -- for leaving anonymous replication.

Tarantool constants 0x41 to 0x46 (decimal 65 to 70) are for replication.
Connectors and clients do not need to send replication packets.
See :ref:`Binary protocol -- replication <box_protocol-replication>`.

The next two IPROTO messages are used in replication connections between
Tarantool nodes in :ref:`synchronous replication <repl_sync>`.
The messages are not supposed to be used by any client applications in their
regular connections.

..  _box_protocol-raft_confirm:

IPROTO_RAFT_CONFIRM = 0x28
~~~~~~~~~~~~~~~~~~~~~~~~~~

This message confirms that the transactions originated from the instance
with id = IPROTO_REPLICA_ID have achieved quorum and can be committed,
up to and including LSN = IPROTO_LSN.
Prior to Tarantool :tarantool-release:`2.10.0`, IPROTO_RAFT_CONFIRM was called IPROTO_CONFIRM.

The body is a 2-item map:

..  cssclass:: highlight
..  parsed-literal::

    # <size>
    msgpack(:samp:`{{MP_UINT unsigned integer = size(<header>) + size(<body>)}}`)
    # <header>
    msgpack({
        IPROTO_REQUEST_TYPE: IPROTO_RAFT_CONFIRM,
        IPROTO_SYNC: :samp:`{{MP_UINT unsigned integer}}`
    })
    # <body>
    msgpack({
        IPROTO_REPLICA_ID: :samp:`{{MP_INT integer}}`,
        IPROTO_LSN: :samp:`{{MP_INT integer}}`
    })


..  _box_protocol-raft_rollback:

IPROTO_RAFT_ROLLBACK = 0x29
~~~~~~~~~~~~~~~~~~~~~~~~~~~

This message says that the transactions originated from the instance
with id = IPROTO_REPLICA_ID couldn't achieve quorum for some reason
and should be rolled back, down to LSN = IPROTO_LSN and including it.
Prior to Tarantool version 2.10, IPROTO_RAFT_ROLLBACK was called IPROTO_ROLLBACK.

The body is a 2-item map:

..  cssclass:: highlight
..  parsed-literal::

    # <size>
    msgpack(:samp:`{{MP_UINT unsigned integer = size(<header>) + size(<body>)}}`)
    # <header>
    msgpack({
        IPROTO_REQUEST_TYPE: IPROTO_RAFT_ROLLBACK,
        IPROTO_SYNC: :samp:`{{MP_UINT unsigned integer}}`
    })
    # <body>
    msgpack({
        IPROTO_REPLICA_ID: :samp:`{{MP_INT integer}}`,
        IPROTO_LSN: :samp:`{{MP_INT integer}}`
    })

..  _box_protocol-id:

IPROTO_ID = 0x49
~~~~~~~~~~~~~~~~

Clients send this message to inform the server about the protocol version and
features they support. Based on this information, the server can enable or
disable certain features in interacting with these clients.

The body is a 2-item map:

..  cssclass:: highlight
..  parsed-literal::

    # <size>
    msgpack(:samp:`{{MP_UINT unsigned integer = size(<header>) + size(<body>)}}`)
    # <header>
    msgpack({
        IPROTO_REQUEST_TYPE: IPROTO_ID,
        IPROTO_SYNC: :samp:`{{MP_UINT unsigned integer}}`
    })
    # <body>
    msgpack({
        IPROTO_VERSION: :samp:`{{MP_UINT unsigned integer}}}`,
        IPROTO_FEATURES: :samp:`{{MP_ARRAY array of unsigned integers}}}`
    })

IPROTO_VERSION is an integer number reflecting the version of protocol that the
client supports. The latest IPROTO_VERSION is |iproto_version|.

Available IPROTO_FEATURES are the following:

- ``IPROTO_FEATURE_STREAMS = 0`` -- streams support: :ref:`IPROTO_STREAM_ID <box_protocol-iproto_stream_id>`
  in the request header.
- ``IPROTO_FEATURE_TRANSACTIONS = 1`` -- transaction support: IPROTO_BEGIN,
  IPROTO_COMMIT, and IPROTO_ROLLBACK commands (with :ref:`IPROTO_STREAM_ID <box_protocol-iproto_stream_id>`
  in the request header). Learn more about :ref:`sending transaction commands <box_protocol-stream_transactions>`.
- ``IPROTO_FEATURE_ERROR_EXTENSION = 2`` -- :ref:`MP_ERROR <msgpack_ext-error>`
  MsgPack extension support. Clients that don't support this feature will receive
  error responses for :ref:`IPROTO_EVAL <box_protocol-eval>` and
  :ref:`IPROTO_CALL <box_protocol-call>` encoded to string error messages.
- ``IPROTO_FEATURE_WATCHERS = 3`` -- remote watchers support: :ref:`IPROTO_WATCH <box_protocol-watch>`,
  :ref:`IPROTO_UNWATCH <box_protocol-unwatch>`, and :ref:`IPROTO_EVENT <box_protocol-event>` commands.

IPROTO_ID requests can be processed without authentication.

IPROTO_WATCH = 0x4a
~~~~~~~~~~~~~~~~~~~

See the :ref:`Watchers <box-protocol-watchers>` section below.

IPROTO_UNWATCH = 0x4b
~~~~~~~~~~~~~~~~~~~~~

See the :ref:`Watchers <box-protocol-watchers>` section below.

IPROTO_EVENT = 0x4c
~~~~~~~~~~~~~~~~~~~

See the :ref:`Watchers <box-protocol-watchers>` section.


..  _box-protocol-watchers:

Watchers
--------

The commands below support asynchronous server-client notifications signalled
with :ref:`box.broadcast() <box-broadcast>`.
Servers that support the new feature set the ``IPROTO_FEATURE_WATCHERS`` feature in reply to the ``IPROTO_ID`` command.
When the connection is closed, all watchers registered for it are unregistered.

The remote :ref:`watcher <box-watchers>` protocol works in the following way:

#.  The client sends an ``IPROTO_WATCH`` packet to subscribe to the updates of a specified key defined on the server.

#.  The server sends an ``IPROTO_EVENT`` packet to the subscribed client after registration.
    The packet contains the key name and its current value.
    After that, the packet is sent every time the key value is updated with
    ``box.broadcast()``, provided that the last notification was acknowledged (see below).

#.  After receiving the notification, the client sends an ``IPROTO_WATCH`` packet to acknowledge the notification.

#.  If the client doesn't want to receive any more notifications, it unsubscribes by sending
    an ``IPROTO_UNWATCH`` packet.

All the three request types are asynchronous -- the receiving end doesn't send a packet in reply to any of them.
Therefore, neither of them has a sync number.

..  _box_protocol-watch:

IPROTO_WATCH = 0x4a
~~~~~~~~~~~~~~~~~~~

Registers a new watcher for the given notification key or confirms a notification if the watcher is
already subscribed.
The watcher is notified after registration.
After that, the notification is sent every time the key is updated.
The server doesn't reply to the request unless it fails to parse the packet.

The body is a 2-item map:

..  cssclass:: highlight
..  parsed-literal::

    # <size>
    msgpack(:samp:`{{MP_UINT unsigned integer = size(<header>) + size(<body>)}}`)
    # <header>
    msgpack({
        IPROTO_REQUEST_TYPE: IPROTO_WATCH
    })
    # <body>
    msgpack({
        IPROTO_EVENT_KEY: :samp:`{{MP_STR string}}}`
    })

``IPROTO_EVENT_KEY`` (code 0x56) contains the key name.

..  _box_protocol-unwatch:

IPROTO_UNWATCH = 0x4b
~~~~~~~~~~~~~~~~~~~~~

Unregisters a watcher subscribed to the given notification key.
The server doesn't reply to the request unless it fails to parse the packet.

The body is a 2-item map:

..  cssclass:: highlight
..  parsed-literal::

    # <size>
    msgpack(:samp:`{{MP_UINT unsigned integer = size(<header>) + size(<body>)}}`)
    # <header>
    msgpack({
        IPROTO_REQUEST_TYPE: IPROTO_UNWATCH
    })
    # <body>
    msgpack({
        IPROTO_EVENT_KEY: :samp:`{{MP_STR string}}}`
    })

``IPROTO_EVENT_KEY`` (code 0x56) contains a key name.

..  _box_protocol-event:

IPROTO_EVENT = 0x4c
~~~~~~~~~~~~~~~~~~~

Sent by the server to notify a client about an update of a key.

The body is a 2-item map:

..  cssclass:: highlight
..  parsed-literal::

    # <size>
    msgpack(:samp:`{{MP_UINT unsigned integer = size(<header>) + size(<body>)}}`)
    # <header>
    msgpack({
        IPROTO_REQUEST_TYPE: IPROTO_EVENT
    })
    # <body>
    msgpack({
        IPROTO_EVENT_KEY: :samp:`{{MP_STR string}}}`,
        IPROTO_EVENT_DATA: :samp:`{{MP_OBJECT value}}}`
    })

``IPROTO_EVENT_KEY`` (code 0x56) contains the key name.

``IPROTO_EVENT_DATA`` (code 0x57) contains data sent to a remote watcher.
The parameter is optional, the default value is ``nil``.

..  _box_protocol-responses:

Responses if no error and no SQL
--------------------------------

After the :ref:`header <box_protocol-header>`, for a response,
there will be a body.
If there was no error, it will contain IPROTO_OK (0x00).
If there was an error, it will contain an error code other than IPROTO_OK.
Responses to SQL statements are slightly different and will be described
in the later section,
:ref:`Binary protocol -- responses for SQL <box_protocol-sql_protocol>`.

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

- For :ref:`IPROTO_PING <box_protocol-ping>` the body will be an empty map.

- For most data-access requests (:ref:`IPROTO_SELECT <box_protocol-select>`,
  :ref:`IPROTO_INSERT <box_protocol-insert>`, :ref:`IPROTO_DELETE <box_protocol-delete>`
  , etc.) the body is an IPROTO_DATA map with an array of tuples that contain
  an array of fields.

- For :ref:`IPROTO_EVAL <box_protocol-eval>` and :ref:`IPROTO_CALL <box_protocol-call>`
  it will usually be an array but, since Lua requests can result in a wide variety
  of structures, bodies can have a wide variety of structures.

- For :ref:`IPROTO_ID <box_protocol-id>`, the response body has the same structure as
  the request body. It informs the client about the protocol version and features
  that the server supports.

Example: if this is the fifth message and the request is
:codenormal:`box.space.`:codeitalic:`space-name`:codenormal:`:insert{6}`,
and the previous schema version was 100,
a successful response will look like this:

..  code-block:: none

    # <size>
    msgpack(32)
    # <header>
    msgpack({
        Response-Code-Indicator: IPROTO_OK,
        IPROTO_SYNC: 5,
        IPROTO_SCHEMA_VERSION: 100
    })
    # <body>
    msgpack({
        IPROTO_DATA: [[6]]
    })

Later in :ref:`Binary protocol -- illustration <box_protocol-illustration>`
we will show actual byte codes of the response to the IPROTO_INSERT message.

IPROTO_DATA is what we get with net_box and :ref:`Module buffer <buffer-module>`
so if we were using net_box we could decode with
:ref:`msgpack.decode_unchecked() <msgpack-decode_unchecked_string>`,
or we could convert to a string with :samp:`ffi.string({pointer},{length})`.
The :ref:`pickle.unpack() <pickle-unpack>` function might also be helpful.

..  _box_protocol-responses_out_of_band:

Responses for no error and out-of-band
--------------------------------------

If the response is out-of-band, due to use of
:ref:`box.session.push() <box_session-push>`,
then the header Response-Code-Indicator will be IPROTO_CHUNK instead of IPROTO_OK.

..  _box_protocol-responses_error:

Responses for errors
--------------------

For a response other than IPROTO_OK, the header Response-Code-Indicator will be
``0x8XXX`` and the body will be a 1-item map.

..  cssclass:: highlight
..  parsed-literal::

    # <size>
    msgpack(32)
    # <header>
    msgpack({
        Response-Code-Indicator: :samp:`{{0x8XXX}}`,
        IPROTO_SYNC: :samp:`{{MP_UINT unsigned integer, may be 64-bit}}`,
        IPROTO_SCHEMA_VERSION: :samp:`{{MP_UINT unsigned integer}}`
    })
    # <body>
    msgpack({
        IPROTO_ERROR: :samp:`{{MP_STRING string}}`
    })

where ``0x8XXX`` is the indicator for an error and ``XXX`` is a value in
`src/box/errcode.h <https://github.com/tarantool/tarantool/blob/master/src/box/errcode.h>`_.
``src/box/errcode.h`` also has some convenience macros which define hexadecimal
constants for return codes.

Example: in version 2.4.0 and earlier,
if this is the fifth message and the request is to create a duplicate
space with
``conn:eval([[box.schema.space.create('_space');]])``
the unsuccessful response will look like this:

..  code-block:: none

    # <size>
    msgpack(32)
    # <header>
    msgpack({
        Response-Code-Indicator: 0x800a,
        IPROTO_SYNC: 5,
        IPROTO_SCHEMA_VERSION: 0x78
    })
    # <body>
    msgpack({
        IPROTO_ERROR:  "Space '_space' already exists"
    })

Later in :ref:`Binary protocol -- illustration <box_protocol-illustration>`
we will show actual byte codes of the response to the IPROTO_EVAL message.

Looking in errcode.h we find that error code 0x0a (decimal 10) is
ER_SPACE_EXISTS, and the string associated with ER_SPACE_EXISTS is
"Space '%s' already exists".

Since version :doc:`2.4.1 </release/2.4.1>`, responses for errors have extra information
following what was described above. This extra information is given via
MP_ERROR extension type. See details in :ref:`MessagePack extensions
<msgpack_ext-error>` section.


..  _box_protocol-sql_protocol:

Responses for SQL
-----------------

After the :ref:`header <box_protocol-header>`, for a response to an SQL statement,
there will be a body that is slightly different from the body for
:ref:`Binary protocol -- responses if no error and no SQL <box_protocol-responses>`.

If the SQL request is not SELECT or VALUES or PRAGMA, then the response body
contains only IPROTO_SQL_INFO (0x42). Usually IPROTO_SQL_INFO is a map with only
one item -- SQL_INFO_ROW_COUNT (0x00) -- which is the number of changed rows.

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
        IPROTO_SQL_INFO: {
            SQL_INFO_ROW_COUNT: :samp:`{{MP_UINT}}`
        }
    })

For example, if the request is
:samp:`INSERT INTO {table-name} VALUES (1), (2), (3)`, then the response body
contains an :samp:`IPROTO_SQL_INFO map with SQL_INFO_ROW_COUNT = 3`.
:samp:`SQL_INFO_ROW_COUNT` can be 0 for statements that do not change rows,
but can be 1 for statements that create new objects.

The IPROTO_SQL_INFO map may contain a second item -- :samp:`SQL_INFO_AUTO_INCREMENT_IDS
(0x01)` -- which is the new primary-key value (or values) for an INSERT in a table
defined with PRIMARY KEY AUTOINCREMENT. In this case the MP_MAP will have two
keys, and  one of the two keys will be 0x01: SQL_INFO_AUTO_INCREMENT_IDS, which
is an array of unsigned integers.

If the SQL statement is SELECT or VALUES or PRAGMA, the response contains:

..  cssclass:: highlight
..  parsed-literal::

    # <size>
    msgpack(32)
    # <header>
    msgpack({
        Response-Code-Indicator: IPROTO_OK,
        IPROTO_SYNC: :samp:`{{MP_UINT unsigned integer, may be 64-bit}}`,
        IPROTO_SCHEMA_VERSION: :samp:`{{MP_UINT unsigned integer}}`
    })
    # <body>
    msgpack({
        IPROTO_METADATA: :samp:`{{array of column maps}}`,
        IPROTO_DATA: :samp:`{{array of tuples}}`
    })

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

* :samp:`IPROTO_DATA:{array of tuples}` = the result set "rows".

Example:
If we ask for full metadata by saying |br|
:code:`conn.space._session_settings:update('sql_full_metadata', {{'=', 'value', true}})` |br|
and we select the two rows from a table named t1 that has columns named DD and Д, with |br|
:code:`conn:execute([[SELECT dd, дд AS д FROM t1;]])` |br|
we could get this response, in the body:

..  code-block:: none

    # <body>
    msgpack({
        IPROTO_METADATA: [
            IPROTO_FIELD_NAME: 'DD',
            IPROTO_FIELD_TYPE: 'integer',
            IPROTO_FIELD_IS_NULLABLE: false,
            IPROTO_FIELD_IS_AUTOINCREMENT: true,
            IPROTO_FIELD_SPAN: nil,
            IPROTO_FIELD_NAME: 'Д',
            IPROTO_FIELD_TYPE: 'string',
            IPROTO_FIELD_COLL: 'unicode',
            IPROTO_FIELD_IS_NULLABLE: true,
            IPROTO_FIELD_SPAN: 'дд'
        ],
        IPROTO_DATA: [
            [1,'a'],
            [2,'b']'
        ]
    })

If instead we said |br|
:code:`conn:prepare([[SELECT dd, дд AS д FROM t1;]])` |br|
then we could get almost the same response, but there would
be no IPROTO_DATA and there would be two additional items: |br|
``34 00 = IPROTO_BIND_COUNT and MP_UINT = 0`` (there are no parameters to bind), |br|
``33 90 = IPROTO_BIND_METADATA and MP_ARRAY, size 0`` (there are no parameters to bind).

..  cssclass:: highlight
..  parsed-literal::

    # <body>
    msgpack({
        IPROTO_STMT_ID: :samp:`{{MP_UINT unsigned integer}}`,
        IPROTO_BIND_COUNT: :samp:`{{MP_INT integer}}`,
        IPROTO_BIND_METADATA: :samp:`{{array of parameter descriptors}}`,
            IPROTO_METADATA: [
                IPROTO_FIELD_NAME: 'DD',
                IPROTO_FIELD_TYPE: 'integer',
                IPROTO_FIELD_IS_NULLABLE: false
                IPROTO_FIELD_IS_AUTOINCREMENT: true
                IPROTO_FIELD_SPAN: nil,
                IPROTO_FIELD_NAME: 'Д',
                IPROTO_FIELD_TYPE: 'string',
                IPROTO_FIELD_COLL: 'unicode',
                IPROTO_FIELD_IS_NULLABLE: true,
                IPROTO_FIELD_SPAN: 'дд'
            ]
        })

Now read the source code file `net_box.c <https://github.com/tarantool/tarantool/blob/master/src/box/lua/net_box.c>`_
where the function "decode_metadata_optional" is an example of how Tarantool
itself decodes extra items.

Later in :ref:`Binary protocol -- illustration <box_protocol-illustration>`
we will show actual byte codes of responses to the above SQL messages.


..  _box_protocol-authentication:

Authentication
--------------

Greeting message
~~~~~~~~~~~~~~~~

When a client connects to the server instance, the instance responds with
a 128-byte text greeting message, not in MsgPack format: |br|
64-byte Greeting text line 1 |br|
64-byte Greeting text line 2 |br|
44-byte base64-encoded salt |br|
20-byte NULL

The greeting contains two 64-byte lines of ASCII text.
Each line ends with a newline character (:code:`\n`). The first line contains
the instance version and protocol type. The second line contains up to 44 bytes
of base64-encoded random string, to use in the authentication packet, and ends
with up to 23 spaces.

Part of the greeting is a base64-encoded session salt -
a random string which can be used for authentication. The maximum length of an encoded
salt (44 bytes) is more than the amount necessary to create the authentication
message. An excess is reserved for future authentication
schemas.

Authentication is optional -- if it is skipped, then the session user is ``'guest'``
(the ``'guest'`` user does not need a password).

If authentication is not skipped, then at any time an authentication packet
can be prepared using the greeting, the user's name and password,
and `sha-1 <https://en.wikipedia.org/wiki/SHA-1>`_ functions, as follows.

..  code-block:: none

    PREPARE SCRAMBLE:

        size_of_encoded_salt_in_greeting = 44;
        size_of_salt_after_base64_decode = 32;
         /* sha1() will only use the first 20 bytes */
        size_of_any_sha1_digest = 20;
        size_of_scramble = 20;

    prepare 'chap-sha1' scramble:

        salt = base64_decode(encoded_salt);
        step_1 = sha1(password);
        step_2 = sha1(step_1);
        step_3 = sha1(first_20_bytes_of_salt, step_2);
        scramble = xor(step_1, step_3);
        return scramble;

IPROTO_AUTH = 0x07
~~~~~~~~~~~~~~~~~~

The client sends an authentication packet as an IPROTO_AUTH message:

..  cssclass:: highlight
..  parsed-literal::

    # <size>
    msgpack(:samp:`{{MP_UINT unsigned integer = size(<header>) + size(<body>)}}`)
    # <header>
    msgpack({
        IPROTO_REQUEST_TYPE: IPROTO_AUTH,
        IPROTO_SYNC: :samp:`{{MP_UINT unsigned integer, usually = 1}}`
    })
    # <body>
    msgpack({
        IPROTO_USER_NAME: :samp:`{{MP_STRING string <key>}}`,
        IPROTO_TUPLE: ['chap-sha1', :samp:`{{MP_STRING 20-byte string}}`]
    })

:code:`<key>` holds the user name. :code:`<tuple>` must be an array of 2 fields:
authentication mechanism ("chap-sha1" is the only supported mechanism right now)
and scramble, encrypted according to the specified mechanism.

The server instance responds to an authentication packet with a standard response with 0 tuples.

To see how Tarantool handles this, look at
`net_box.c <https://github.com/tarantool/tarantool/blob/master/src/box/lua/net_box.c>`_
function ``netbox_encode_auth``.






..  _box_protocol-xlog:

XLOG / SNAP
-----------

.xlog and .snap files have nearly the same format. The header looks like:

..  code-block:: none

    <type>\n                  SNAP\n or XLOG\n
    <version>\n               currently 0.13\n
    Server: <server_uuid>\n   where UUID is a 36-byte string
    VClock: <vclock_map>\n    e.g. {1: 0}\n
    \n

After the file header come the data tuples.
Tuples begin with a row marker ``0xd5ba0bab`` and
the last tuple may be followed by an EOF marker
``0xd510aded``.
Thus, between the file header and the EOF marker, there
may be data tuples that have this form:

..  code-block:: none

    0            3 4                                         17
    +-------------+========+============+===========+=========+
    |             |        |            |           |         |
    | 0xd5ba0bab  | LENGTH | CRC32 PREV | CRC32 CUR | PADDING |
    |             |        |            |           |         |
    +-------------+========+============+===========+=========+
       MP_FIXEXT2    MP_INT     MP_INT       MP_INT      ---

    +============+ +===================================+
    |            | |                                   |
    |   HEADER   | |                BODY               |
    |            | |                                   |
    +============+ +===================================+
         MP_MAP                     MP_MAP

See the example in the :ref:`File formats <internals-data_persistence>` section.

