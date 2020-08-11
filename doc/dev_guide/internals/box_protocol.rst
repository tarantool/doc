.. _box_protocol-iproto_protocol:

.. _internals-box_protocol:

--------------------------------------------------------------------------------
Binary protocol
--------------------------------------------------------------------------------

The binary protocol is called a "request/response" protocol because it is
for sending requests to a Tarantool server and receiving responses.
There is complete access to Tarantool functionality, including:

- request multiplexing, for example ability to issue multiple requests
  asynchronously via the same connection
- response format that supports zero-copy writes

The protocol can be called "binary" because the most-frequently-used database accesses
are done with binary codes instead of Lua request text. Tarantool experts use it
to write their own connectors,
to understand network messages,
to support new features that their favorite connector doesn't support yet,
or to avoid repetitive parsing by the server.

.. _box_protocol-notation:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Binary protocol -- symbols and terms
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

For diagrams in this section, the box borders have special meanings:

.. code-block:: none

    0    X
    +----+
    |    | - X + 1 bytes
    +----+
     TYPE - type of MessagePack value (if it is a MessagePack object)

    +====+
    |    | - Variable size MessagePack object
    +====+
     TYPE - type of MessagePack value

    +~~~~+
    |    | - Variable size MessagePack Array/Map
    +~~~~+
     TYPE - type of MessagePack value

And words that start with **MP_** mean:
a `MessagePack <http://MessagePack.org>`_ type or a range of MessagePack types, including
the signal and possibly including a value, with slight modification:

* **MP_NIL**    nil
* **MP_UINT**   unsigned integer
* **MP_INT**    either integer or unsigned integer
* **MP_STR**    string
* **MP_BIN**    binary string
* **MP_ARRAY**  array
* **MP_MAP**    map
* **MP_BOOL**   boolean
* **MP_FLOAT**  float
* **MP_DOUBLE** double
* **MP_EXT**    extension (including the :ref:`DECIMAL type <msgpack_ext-decimal>`)
* **MP_OBJECT** any MessagePack object

Short descriptions are in MessagePack's `"spec" page <https://github.com/msgpack/msgpack/blob/master/spec.md>`_.

And words that start with **IPROTO_** mean:
a Tarantool constant which is either defined or mentioned in the
`iproto_constants.h file <https://github.com/tarantool/tarantool/blob/master/src/box/iproto_constants.h>`_.
These constants are used as keys within MP_MAP maps.

.. _box_protocol-illustration:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Binary protocol -- illustration
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

To follow the examples in this section,
get a single Linux computer and start three command-line shells ("terminals").

-- On terminal #1, Start monitoring port 3302 with `tcpdump <https://www.tcpdump.org/manpages/tcpdump.1.html>`_: |br|
``sudo tcpdump -i lo 'port 3302' -X``

On terminal #2, start a server with: |br|
``box.cfg{listen=3302}`` |br|
``box.schema.user.grant('guest','read,write,execute,create,drop','universe')`` |br|

On terminal #3, start another server, which will act as a client, with: |br|
``box.cfg{}`` |br|
``net_box = require('net.box')`` |br|
``conn = net_box.connect('localhost:3302')`` |br|
``conn.space._space:select(280)`` |br|

Now look at what tcpdump shows for the job connecting to 3302. -- the "request".
After the words "length 32" is a packet that ends with with these 32 bytes:
(we have added indented comments):

.. code-block:: none

    ce 00 00 00 1b   MP_UINT = decimal 27 = number of bytes after this
    82               MP_MAP, size 2 (we'll call this "Main-Map")
    01                 IPROTO_SYNC (Main-Map Item#1)
    04                 MP_INT = 4 = number that gets incremented with each request
    00                 IPROTO_REQUEST_TYPE (Main-Map Item#2)
    01                 IPROTO_SELECT
    86                 MP_MAP, size 6 (we'll call this "Select-Map")
    10                   IPROTO_SPACE_ID (Select-Map Item#1)
    cd 01 18             MP_UINT = decimal 280 = id of _space
    11                   IPROTO_INDEX_ID (Select-Map Item#2)
    00                   MP_INT = 0 = id of index within _space
    14                   IPROTO_ITERATOR (Select-Map Item#3)
    00                   MP_INT = 0 = Tarantool iterator_type.h constant ITER_EQ
    13                   IPROTO_OFFSET (Select-Map Item#4)
    00                   MP_INT = 0 = amount to offset
    12                   IPROTO_LIMIT (Select-Map Item#5)
    ce ff ff ff ff       MP_UINT = 4294967295 = biggest possible limit
    20                   IPROTO_KEY (Select-Map Item#6)
    91                   MP_ARRAY, size 1 (we'll call this "Key-Array")
    cd 01 18               MP_UINT = 280 (Select-Map Item#6, Key-Array Item#1)
                           -- 280 is the key value that we are searching for

Now read the source code file
`net_box.c <https://github.com/tarantool/tarantool/blob/master/src/box/lua/net_box.c>`_
and skip to the line ``netbox_encode_select(lua_State *L)``.
From the comments and from simple function calls like "mpstream_encode_uint(&stream, IPROTO_SPACE_ID);"
you will be able to see how net_box put together the packet contents that you
have just observed with tcpdump.

There are libraries for reading and writing MessagePack objects.
C programmers sometimes include `msgpuck.h <https://github.com/rtsisyk/msgpuck>`_.

Now you know how Tarantool itself makes requests with the binary protocol.
When in doubt about a detail, consult net_box.c -- it has routines for each request.
Some :ref:`connectors <index-box_connectors>` have similar code.

.. _internals-unified_packet_structure:

.. _box_protocol-header:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Binary protocol -- header and body
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Except during connection (which involves a greeting from the server
and optional :ref:`authentication <box_protocol-authentication>` that we will discuss later in this section),
the protocol is pure request/response (the client requests and
the server responds). It is legal to put more than one request in a packet.

Almost all requests and responses contain both a header and a body.

.. code-block:: none

    Normal Request/Response header and body:

    0        5
    +--------+ +============+ +===================================+
    | HEADER | |            | |                                   |
    | + BODY | |   HEADER   | |               BODY                |
    |  SIZE  | |            | |                                   |
    +--------+ +============+ +===================================+
      MP_INT       MP_MAP                     MP_MAP

HEADER + BODY SIZE is the size of the header plus the size of the body.
It may be useful to compare it with the number of bytes remaining in the packet.

HEADER may contain, in any order:

.. code-block:: none

    HEADER:

    +====================================+=====================+===============================+
    |                                    |                     |                               |
    |   0x00: IPROTO_REQUEST_TYPE        |   0x01: IPROTO_SYNC |   0x05: IPROTO_SCHEMA_VERSION |
    |         or Response-Code-Indicator | MP_INT: MP_INT      | MP_INT: MP_INT                |
    | MP_INT: MP_INT                     |                     |                               |
    |                                    |                     |                               |
    +====================================+=====================+===============================+
                              MP_MAP

**IPROTO_SYNC** = 0x01.
An unsigned integer that should be incremented so that it is unique in every request.
This integer is also returned from :ref:`box.session.sync() <box_session-sync>`.
The IPROTO_SYNC value of a response should be the same as the IPROTO_SYNC value of a request.

**IPROTO_SCHEMA_VERSION** = 0x05.
An unsigned number, sometimes called SCHEMA_ID, that goes up when there is a
major change.
In a request header IPROTO_SCHEMA_VERSION is optional, so the version will not
be checked if it is absent.
In a response header IPROTO_SCHEMA_VERSION is always present, and it is up to
the client to check if it has changed.

**IPROTO_REQUEST_TYPE** or Response-Code-Indicator = 0x00.
An unsigned number that indicates what will be in the BODY.
In requests IPROTO_REQUEST_TYPE will be followed by IPROTO_SELECT etc.
In responses Response-Code-Indicator will be followed by IPROTO_OK etc.

The BODY has the details of the request or response. In a request, it can also
be absent or be an empty map. Both these states will be interpreted equally.
Responses will contain the BODY anyway even if it is
a :ref:`IPROTO_PING <box_protocol-ping>` request.

Have a look at file
`xrow.c <https://github.com/tarantool/tarantool/blob/master/src/box/xrow.c>`_
function xrow_header_encode, to see how Tarantool encodes the header.
Have a look at file net_box.c, function netbox_decode_data, to see how Tarantool decodes the header.
For example, in a successful response to ``box.space:select()``,
the Response-Code-Indicator value will be 0 = IPROTO_OK and the
array will have all the tuples of the result.

.. _box_protocol-requests:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Binary protocol -- requests
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

After the :ref:`HEADER <box_protocol-header>`, for a request, there will be a body
that begins with these request-type IPROTO codes.

**IPROTO_SELECT** = 0x01.

See :ref:`space_object:select()  <box_space-select>`.
The body is a 6-item map:

.. code-block:: none

    +=========================+=========================+=========================+
    |                         |                         |                         |
    |   0x10: IPROTO_SPACE_ID |   0x11: IPROTO_INDEX_ID |   0x12: IPROTO_LIMIT    |
    | MP_INT: MP_INT          | MP_INT: MP_INT          | MP_INT: MP_INT          |
    |                         |                         |                         |
    +=========================+=========================+=========================+
    |                         |                         |                         |
    |   0x13: IPROTO_OFFSET   |   0x14: IPROTO_ITERATOR |   0x20: IPROTO_KEY      |
    | MP_INT: MP_INT          | MP_INT: MP_INT          | MP_INT: MP_ARRAY        |
    |                         |                         |                         |
    +=========================+=========================+=========================+
                 MP_MAP

IPROTO_SPACE_ID (0x10) + MP_INT,
IPROTO_INDEX_ID (0x11) + MP_INT,
IPROTO_ITERATOR (0x14) + MP_INT,
IPROTO_OFFSET (0x13) + MP_INT,
IPROTO_LIMIT (0x12) + MP_INT,
IPROTO_KEY (0x20) + MP_ARRAY (array of key values).
See the illustration of IPROTO_SELECT in the earlier section,
:ref:`Binary protocol -- illustration <box_protocol-illustration>`.

**IPROTO_INSERT** = 0x02.

See :ref:`space_object:insert()  <box_space-insert>`.
The body is a 2-item map:

.. code-block:: none

    +=========================+======================+
    |                         |                      |
    |   0x10: IPROTO_SPACE_ID |   0x21: IPROTO_TUPLE |
    | MP_INT: MP_INT          | MP_INT: MP_ARRAY     |
    |                         |                      |
    +=========================+======================+
                     MP_MAP

IPROTO_SPACE_ID (0x10) + MP_INT,
IPROTO_TUPLE + MP_ARRAY (array of field values).

**IPROTO_REPLACE** = 0x03,
See :ref:`space_object:replace()  <box_space-replace>`.
The body is a 2-item map, the same as for IPROTO_INSERT:

.. code-block:: none

    +=========================+======================+
    |                         |                      |
    |   0x10: IPROTO_SPACE_ID |   0x21: IPROTO_TUPLE |
    | MP_INT: MP_INT          | MP_INT: MP_ARRAY     |
    |                         |                      |
    +=========================+======================+
                   MP_MAP

IPROTO_SPACE_ID (0x10) + MP_INT,
IPROTO_TUPLE (0x21) + MP_ARRAY (array of field values).

.. _box_protocol-update:

**IPROTO_UPDATE** = 0x04.

See :ref:`space_object:update()  <box_space-update>`.
The body is usually a 4-item map,

.. code-block:: none

    +=========================+===============================+
    |                         |                               |
    |   0x10: IPROTO_SPACE_ID |   0x11: IPROTO_INDEX_ID       |
    | MP_INT: MP_INT          | MP_INT: MP_INT                |
    |                         |                               |
    +=========================+===============================+
    |                         |                 +~~~~~~~~~~~+ |
    |                         |                 | usually   | |
    |                         |                 | OPERATOR, | |
    |                         | (IPROTO_TUPLE)  | FIELD_NO, | |
    |   0x20: IPROTO_KEY      |    0x21:        | VALUE     | |
    | MP_INT: MP_ARRAY        |  MP_INT:        +~~~~~~~~~~~+ |
    |                         |                   MP_ARRAY    |
    +=========================+===============================+
                    MP_MAP

IPROTO_SPACE_ID (0x10) + MP_INT,
IPROTO_INDEX_ID (0x11) + MP_INT with index number starting with 0,
IPROTO_KEY (0x20) + MP_ARRAY (array of index keys),
IPROTO_TUPLE (0x21) + MP_ARRAY (array of update operations). |br|
If the operation specifies no values, it is a 2-item array:
OPERATOR MP_STR = ``"#"``,
FIELD_NO MP_INT = field number starting with 1. |br|
If the operation specifies one value, it is a 3-item array: |br|

.. code-block:: none

    0           2
    +-------------+==========+===========+
    |             |          |           |
    | OPERATOR    | FIELD_NO | VALUE     |
    | MP_STR      | MP_INT   | MP_OBJECT |
    |             |          |           |
    +-------------+==========+===========+
              MP_ARRAY

OPERATOR MP_STR = ``"+"`` or ``"-"`` or ``"&"`` or ``"^"`` or ``"|"`` or ``"!"`` or ``"="``),
FIELD_NO MP_INT = field number starting with 1,
VALUE MP_OBJECT, that is, any type, MP_INT, MP_STR, etc.. |br|
Otherwise the operation is a 5-item array: |br|

.. code-block:: none

    0           2
    +-----------+==========+==========+========+==========+
    |           |          |          |        |          |
    | ':'       | FIELD_NO | POSITION | OFFSET | VALUE    |
    | MP_STR    | MP_INT   | MP_INT   | MP_INT | MP_STR   |
    |           |          |          |        |          |
    +-----------+==========+==========+========+==========+
                          MP_ARRAY

OPERATOR MP_STR = ``":"``,
FIELD_NO MP_INT = field number starting with 1,
POSITION MP_INT,
OFFSET MP_INT,
VALUE MP_STR.

For example, suppose a user changes field #2 in tuple #2
in space #256 to 'BBBB'. The body will look like this:
(notice that in this case there is an extra map item
IPROTO_INDEX_BASE, to emphasize that field numbers
start with 1, which is optional and can be omitted):

.. code-block:: none

    04               IPROTO_UPDATE
    85               IPROTO_MAP, size 5
    10                 IPROTO_SPACE_ID, Map Item#1
    cd 02 00           MP_UINT 256
    11                 IPROTO_INDEX_ID, Map Item#2
    00                 MP_INT 0 = primary-key index number
    15                 IPROTO_INDEX_BASE, Map Item#3
    01                 MP_INT = 1 i.e. field numbers start at 1
    21                 IPROTO_TUPLE, Map Item#4
    91                 MP_ARRAY, size 1, for array of operations
    93                   MP_ARRAY, size 3
    a1 3d                   MP_STR = OPERATOR = '='
    02                      MP_INT = FIELD_NO = 2
    a5 42 42 42 42 42       MP_STR = VALUE = 'BBBB'
    20                 IPROTO_KEY, Map Item#5
    91                 MP_ARRAY, size 1, for array of key values
    02                   MP_UINT = primary-key value = 2

**IPROTO_DELETE** = 0x05.

See :ref:`space_object:delete()  <box_space-delete>`.
The body is a 3-item map:

.. code-block:: none

    +=========================+=========================+====================+
    |                         |                         |                    |
    |   0x10: IPROTO_SPACE_ID |   0x11: IPROTO_INDEX_ID |   0x20: IPROTO_KEY |
    | MP_INT: MP_INT          | MP_INT: MP_INT          | MP_INT: MP_ARRAY   |
    |                         |                         |                    |
    +=========================+=========================+====================+
                              MP_MAP

IPROTO_SPACE_ID (0x10) + MP_INT,
IPROTO_INDEX_ID (0x11) + MP_INT,
IPROTO_KEY (0x20) + MP_ARRAY (array of key values).

**IPROTO_CALL_16** = 0x06.

See :ref:`conn:call() <net_box-call>`. The suffix ``_16`` is a hint that this is for the
``call()`` until Tarantool 1.6. It is deprecated.
Use :ref:`IPROTO_CALL <box_protocol-call>` instead.
The body is a 2-item map:

.. code-block:: none

    +==============================+=======================+
    |                              |                       |
    |   0x22: IPROTO_FUNCTION_NAME |   0x21: IPROTO_TUPLE  |
    | MP_INT: MP_STRING            | MP_INT: MP_ARRAY      |
    |                              |                       |
    +==============================+=======================+
                        MP_MAP

IPROTO_FUNCTION_NAME (0x22) +  function name (MP_STRING),
IPROTO_TUPLE (0x22) + array of arguments (MP_ARRAY).
The return value is an array of tuples.

**IPROTO_AUTH** = 0x07.

See :ref:`authentication <authentication-users>`.
See the later section :ref:`Binary protocol -- authentication <box_protocol-authentication>`.

.. _box_protocol-eval:

**IPROTO_EVAL** = 0x08.

See :ref:`conn:eval() <net_box-eval>`.
Since the argument is a Lua expression, this is
Tarantool's way to handle non-binary with the
binary protocol. Any request that does not have
its own code, for example :samp:`box.space.{space-name}:drop()`,
will be handled either with :ref:`IPROTO_CALL <box_protocol-call>`
or IPROTO_EVAL.
Some client-like utilities, such as :ref:`tarantoolctl <tarantoolctl>`,
make extensive use of ``eval``.
The body is a 2-item map:

.. code-block:: none

    +=======================+======================+
    |                       |                      |
    |   0x27: IPROTO_EXPR   |   0x21: IPROTO_TUPLE |
    | MP_INT: MP_STRING     | MP_INT: MP_ARRAY     |
    |                       |                      |
    +=======================+======================+
                    MP_MAP

IPROTO_EXPR (0x27) + expression (MP_STRING),
IPROTO_TUPLE (0x21) + array of arguments to match placeholders.

**IPROTO_UPSERT** = 0x09.

See :ref:`space_object:upsert()  <box_space-upsert>`.
The body is the same as the body of :ref:`IPROTO_UPDATE <box_protocol-update>`.

.. _box_protocol-call:

**IPROTO_CALL** = 0x0a.

See :ref:`conn:call() <net_box-call>`.
The body is a 2-item map:

.. code-block:: none

    +==============================+======================+
    |                              |                      |
    |   0x22: IPROTO_FUNCTION_NAME |   0x21: IPROTO_TUPLE |
    | MP_INT: MP_STRING            | MP_INT: MP_ARRAY     |
    |                              |                      |
    +==============================+======================+
                            MP_MAP

IPROTO_FUNCTION_NAME (0x22) +  function name (MP_STRING),
IPROTO_TUPLE (0x22) + array of arguments (MP_ARRAY).
The response will be a list of values, similar to the :ref:`IPROTO_EVAL <box_protocol-eval>` response.

.. _box_protocol-execute:

**IPROTO_EXECUTE** = 0x0b.

See :ref:`box.execute() <box-sql_box_execute>`, this is only for SQL.
The body is a 3-item map:

.. code-block:: none

    +=========================+=========================+========================+
    |                         |                         |                        |
    |   0x43: IPROTO_STMT_ID  |   0x11: IPROTO_SQL_BIND |   0x20: IPROTO_OPTIONS |
    | MP_INT: MP_INT          | MP_INT: MP_INT          | MP_INT: MP_ARRAY       |
    |   or                    |                         |                        |
    |   0x40: IPROTO_SQL_TEXT |                         |                        |
    | MP_INT: MP_STR          |                         |                        |
    |                         |                         |                        |
    +=========================+=========================+========================+
                              MP_MAP

IPROTO_STMT_ID (0x43) + statement-id (MP_INT) if executing a prepared statement
or
IPROTO_SQL_TEXT (0x40) + statement-text (MP_STR) if executing an SQL string,
IPROTO_SQL_BIND (0x41) + array of parameter values to match ? placeholders or :name placeholders,
IPROTO_OPTIONS (0x2b) + array of options (usually empty).

For example, suppose we prepare a statement
with two ? placeholders, and execute with two parameters, thus: |br|
:code:`n = conn:prepare([[VALUES (?, ?);]])` |br|
:code:`conn:execute(n.stmt_id, {1,'a'})` |br|
Then the body will look like this:

.. code-block:: none

    0b               IPROTO_EXECUTE
    83               MP_MAP, size 3
    43                 IPROTO_STMT_ID Map Item#1
    ce d7 aa 74 1b     MP_UINT value of n.stmt_id
    41                 IPROTO_SQL_BIND Map Item#2
    92                 MP_ARRAY, size 2
    01                   MP_INT = 1 = value for first parameter
    a1 61                MP_STR = 'a' = value for second parameter
    2b                 IPROTO_OPTIONS Map Item#3
    90                 MP_ARRAY, size 0 (there are no options)

**IPROTO_NOP** = 0x0c.

There is no Lua request exactly equivalent to IPROTO_NOP.
It causes the LSN to be incremented.
It could be sometimes used for updates where the old and new values
are the same, but the LSN must be increased because a data-change
must be recorded.
The body is: nothing.

**IPROTO_PREPARE** = 0x0d.

See :ref:`box.prepare <box-sql_box_prepare>`, this is only for SQL.
The body is a 1-item map:

.. code-block:: none

    +=========================+
    |                         |
    |   0x10: IPROTO_STMT_ID  |
    | MP_INT: MP_INT          |
    |   or                    |
    |   0x10: IPROTO_SQL_TEXT |
    | MP_INT: MP_STR          |
    |                         |
    +=========================+
         MP_MAP

IPROTO_STMT_ID (0x43) + statement-id (MP_INT) if executing a prepared statement
or
IPROTO_SQL_TEXT (0x40) + statement-text (string) if executing an SQL string.
Thus the IPROTO_PREPARE map item is the same as the first item of the
:ref:`IPROTO_EXECUTE <box_protocol-execute>` map.

.. _box_protocol-ping:

**IPROTO_PING** = 0x40.

See :ref:`conn:ping() <conn-ping>`. The BODY will be an empty map because IPROTO_PING
in the HEADER contains all the information that the server instance needs.

**IPROTO_JOIN** = 0x41, for replication  |br|
**IPROTO_SUBSCRIBE** = 0x42, for replication SUBSCRIBE |br|
**IPROTO_VOTE_DEPRECATED** = 0x43, for old style vote, superseded by IPROTO_VOTE |br|
**IPROTO_VOTE** = 0x44, for master election |br|
**IPROTO_FETCH_SNAPSHOT** = 0x45, for starting anonymous replication |br|
**IPROTO_REGISTER** =0x46, for leaving anonymous replication.

Tarantool constants 0x41 to 0x46 (decimal 65 to 70) are for replication.
Connectors and clients do not need to send replication packets.
See :ref:`Binary protocol -- replication <box_protocol-replication>`.

Next two IProto messages are used in the replication connections between
Tarantool nodes in :ref:`synchronous replication <repl_sync>`.
The messages are not supposed to be used by any client applications in their
regular connections.

.. _box_protocol-confirm:

**IPROTO_CONFIRM** = 0x28

This message confirms that the transactions originated from the instance
with id = IPROTO_REPLICA_ID have achieved quorum and can be committed,
up to LSN = IPROTO_LSN and including it.

The body is a 2-item map:

.. code-block:: none

    +===========================+====================+
    |                           |                    |
    |   0x02: IPROTO_REPLICA_ID |   0x03: IPROTO_LSN |
    | MP_UINT: MP_UINT          | MP_UINT: MP_UINT   |
    |                           |                    |
    +===========================+====================+
                        MP_MAP

.. _box_protocol-rollback:

**IPROTO_ROLLBACK** = 0x29

This message tells that the transactions originated from the instance
with id = IPROTO_REPLICA_ID couldn't achieve quorum by some reason
and should be rolled back, down to LSN = IPROTO_LSN and including it.

The body is a 2-item map:

.. code-block:: none

    +===========================+====================+
    |                           |                    |
    |   0x02: IPROTO_REPLICA_ID |   0x03: IPROTO_LSN |
    | MP_UINT: MP_UINT          | MP_UINT: MP_UINT   |
    |                           |                    |
    +===========================+====================+
                        MP_MAP


.. _box_protocol-responses:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Binary protocol -- responses if no error and no SQL
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

After the :ref:`HEADER <box_protocol-header>`, for a response,
there will be a body.
It will contain IPROTO_OK (0x00) (there was no error),
or an error code other than IPROTO_OK (there was an error).
Responses to SQL statements are slightly different and will be described
in the later section,
:ref:`Binary protocol -- responses for SQL <box_protocol-sql_protocol>`.

For IPROTO_OK, the header Response-Code-Indicator will be 0 and the body will be:

.. code-block:: none

    ++=====================+
    ||                     |
    ||   0x30: IPROTO_DATA |
    || MP_INT: MP_OBJECT   |
    ||                     |
    ++=====================+
        MP_MAP

For :ref:`IPROTO_PING <box_protocol-ping>` the body will be an empty map.
For most data-access requests (IPROTO_SELECT IPROTO_INSERT IPROTO_DELETE etc.)
it will be an array of tuples that contain an array of fields.
For :ref:`IPROTO_EVAL <box_protocol-eval>` and :ref:`IPROTO_CALL <box_protocol-call>` it will usually be an array but, since
Lua requests can result in a wide variety of structures,
bodies can have a wide variety of structures.

For example, after :codenormal:`box.space.`:codeitalic:`space-name`:codenormal:`:insert{6}` a successful
response will look like this:

.. code-block:: none

    ce 00 00 00 20                MP_UINT = HEADER + BODY SIZE
    83                            MP_MAP, size 3
    00                              Response-Code-Indicator
    ce 00 00 00 00                  MP_UINT = IPROTO_OK
    01                              IPROTO_SYNC
    cf 00 00 00 00 00 00 00 53      MP_UINT = sync value
    05                              IPROTO_SCHEMA_VERSION
    ce 00 00 00 68                  MP_UINT = schema version
    81                            MP_MAP, size 1
    30                              IPROTO_DATA
    dd 00 00 00 01                  MP_ARRAY, size 1 (row count)
    91                              MP_ARRAY, size 1 (field count)
    06                              MP_INT = 6 = the value that was inserted

IPROTO_DATA is what we get with net_box and :ref:`Module buffer <buffer-module>`
so if we were using net_box we could decode with
:ref:`msgpack.decode_unchecked() <msgpack-decode_unchecked_string>`,
or we could convert to a string with :samp:`ffi.string({pointer},{length})`.
The :ref:`pickle.unpack() <pickle-unpack>` function might also be helpful.

.. _box_protocol-responses_error:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Binary protocol -- responses for errors
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

For a response other than IPROTO_OK, the header Response-Code-Indicator will be 0x8XXX and the body will be:

.. code-block:: none

    ++=========================+
    ||                         |
    ||   0x31: IPROTO_ERROR_24 |
    || MP_INT: MP_STRING       |
    ||                         |
    ++=========================+
          MP_MAP

where 0x8XXX is the indicator for an error and XXX is a value in
`src/box/errcode.h <https://github.com/tarantool/tarantool/blob/master/src/box/errcode.h>`_.
``src/box/errcode.h`` also has some convenience macros which define hexadecimal constants for return codes.

For example, in version 2.4.0 or earlier, if we try to create a duplicate space with |br|
``conn:eval([[box.schema.space.create('_space');]])`` |br|
the server response will look like this:

.. code-block:: none

    ce 00 00 00 3b                  MP_UINT = HEADER + BODY SIZE
    83                              MP_MAP, size 3 (i.e. 3 items in header)
      00                              Response-Code-Indicator
      ce 00 00 80 0a                  MP_UINT = hexadecimal 800a
      01                              IPROTO_SYNC
      cf 00 00 00 00 00 00 00 26      MP_UINT = sync value
      05                              IPROTO_SCHEMA_VERSION
      ce 00 00 00 78                  MP_UINT = schema version value
      81                              MP_MAP, size 1
        31                              IPROTO_ERROR_24
        db 00 00 00 1d 53 70 61 63 etc. MP_STR = "Space '_space' already exists"

Looking in errcode.h we find that error code 0x0a (decimal 10) is
ER_SPACE_EXISTS, and the string associated with ER_SPACE_EXISTS is
"Space '%s' already exists".

Beginning in version 2.4.1, responses for errors have extra information
following what was described above. This extra information is given via
MP_ERROR extension type. See details in :ref:`MessagePack extensions
<msgpack_ext-error>` section.

.. _box_protocol-sql_protocol:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Binary protocol -- responses for SQL
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

After the :ref:`HEADER <box_protocol-header>`, for a response to an SQL statement,
there will be a body that is slightly different from the body for
:ref:`Binary protocol -- responses if no error and no SQL <box_protocol-responses>`.

If the SQL request is not SELECT or VALUES or PRAGMA, then the response body contains only IPROTO_SQL_INFO (0x42).
Usually IPROTO_SQL_INFO is a map with only one item -- SQL_INFO_ROW_COUNT (0x00) -- which is the number of
changed rows.

.. code-block:: none

    +=========================================================+
    |                                                         |
    |   0x42: IPROTO_SQL_INFO                                 |
    | MP_MAP: usually 1 item  +~~~~~~~~~~~~~~~~~~~~~~~~~~~~~+ |
    |                         |                             | |
    |                         |    0x00: SQL_INFO_ROW_COUNT | |
    |                         | MP_UINT: changed row count  | |
    |                         |                             | |
    |                         +~~~~~~~~~~~~~~~~~~~~~~~~~~~~~+ |
    |                                                         |
    +=========================================================+

For example, if the request is
:samp:`INSERT INTO {table-name} VALUES (1), (2), (3)`, then the response body contains
an IPROTO_SQL_INFO map with SQL_INFO_ROW_COUNT = 3.
SQL_INFO_ROW_COUNT can be 0 for statements that do not change rows,
but can be 1 for statements that create new objects.

The IPROTO_SQL_INFO map may contain a second item -- SQL_INFO_AUTO_INCREMENT_IDS (0x01) -- which is the
new primary-key value (or values) for an INSERT in a table defined with PRIMARY KEY
AUTOINCREMENT. In this case the MP_MAP will have two keys, and  one of the two keys
will be 0x01: SQL_INFO_AUTO_INCREMENT_IDS, which is an array of unsigned integers.

For example, if we use the same net.box connection that
we used for :ref:`Binary protocol -- illustration <box_protocol-illustration>`
and we say |br|
``conn:execute([[CREATE TABLE t1 (dd INT PRIMARY KEY AUTOINCREMENT, дд STRING COLLATE "unicode");]])`` |br|
``conn:execute([[INSERT INTO t1 VALUES (NULL, 'a'), (NULL, 'b');]])`` |br|
and we watch what tcpdump displays, we will see two noticeable things:
(1) the CREATE statement caused a schema change so the response has
a new IPROTO_SCHEMA_VERSION value and the body includes
the new contents of some system tables (caused by requests from net.box which users will not see);
(2) the final bytes of the response to the INSERT will be:

.. code-block:: none

    81   MP_MAP, size 1
    42     IPROTO_SQL_INFO
    82     MP_MAP, size 2
    00       Tarantool constant (not in iproto_constants.h) = SQL_INFO_ROW_COUNT
    02       1 = row count
    01       Tarantool constant (not in iproto_constants.h) = SQL_INFO_AUTOINCREMENT_ID
    92       MP_ARRAY, size 2
    01         first autoincrement number
    02         second autoincrement number

If the SQL statement is SELECT or VALUES or PRAGMA, the response contains:

* IPROTO_METADATA + array of column maps, with each column map containing
  at least IPROTO_FIELD_NAME (0x00) + MP_STR, and IPROTO_FIELD_TYPE (0x01) + MP_STR.
  Additionally, if ``sql_full_metadata`` in the :ref:`_session_settings <box_space-session_settings>` system space
  is TRUE, then the array will have these additional column maps
  which correspond to components described in the :ref:`box.execute() <box-sql_if_full_metadata>` section:
  IPROTO_FIELD_COLL (0x02) + MP_STR, IPROTO_FIELD_IS_NULLABLE (0x03) + MP_BOOL,
  IPROTO_FIELD_IS_AUTOINCREMENT (0x04) + MP_BOOL,
  IPROTO_FIELD_SPAN (0x05) + MP_STR or MP_NIL.

* IPROTO_DATA + array of tuples = the result set "rows"

.. code-block:: none

    EXECUTE SELECT RESPONSE BODY:
                                  MAP
    +=============================================+===========================+
    |                                             |                           |
    |     0x32: IPROTO_METADATA                   |                           |
    | MP_ARRAY: array of maps:                    |                           |
    |           +~~~~~~~~~~~~~~~~~~~~~~-------~~+ |                           |
    |           | +~~~~~~~~~~~~~-------~~~~~~~+ | |     0x30: IPROTO_DATA     |
    |           | |   0x00: IPROTO_FIELD_NAME | | | MP_ARRAY: array of tuples |
    |           | | MP_STR: field name        | | |                           |
    |           | |   0x01: IPROTO_FIELD_TYPE | | |                           |
    |           | | MP_STR: field type        | | |                           |
    |           | | + more if full metadata   | | |                           |
    |           | +~~~~~~~~~~~~~~~~~~~~~~~~~~~+ | |                           |
    |           |        MP_MAP                 | |                           |
    |           +~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~+ |                           |
    |                   MP_ARRAY                  |                           |
    |                                             |                           |
    +=============================================+===========================+

For example, if we use the same net_box connection that
we used for :ref:`Binary protocol -- illustration <box_protocol-illustration>`
and we ask for full metadata by saying |br|
:code:`conn.space._session_settings:update('sql_full_metadata', {{'=', 'value', true}})` |br|
and we select the two rows from the table that we just created |br|
:code:`conn:execute([[SELECT dd, дд AS д FROM t1;]])` |br|
then tcpdump will show this response, after the header:

.. code-block:: none

    82                       MP_MAP, size 2 (i.e. metadata and rows)
    32                         IPROTO_METADATA
    92                         MP_ARRAY, size 2 (i.e. 2 columns)
    85                           MP_MAP, size 5 (i.e. 5 items for column#1)
    00 a2 44 44                    IPROTO_FIELD_NAME + 'DD'
    01 a7 69 6e 74 65 67 65 72     IPROTO_FIELD_TYPE + 'integer'
    03 c2                          IPROTO_FIELD_IS_NULLABLE + false
    04 c3                          IPROTO_FIELD_IS_AUTOINCREMENT + true
    05 c0                          PROTO_FIELD_SPAN + nil
    85                           MP_MAP, size 5 (i.e. 5 items for column#2)
    00 a2 d0 94                    IPROTO_FIELD_NAME + 'Д' upper case
    01 a6 73 74 72 69 6e 67        IPROTO_FIELD_TYPE + 'string'
    02 a7 75 6e 69 63 6f 64 65     IPROTO_FIELD_COLL + 'unicode'
    03 c3                          IPROTO_FIELD_IS_NULLABLE + true
    05 a4 d0 b4 d0 b4              IPROTO_FIELD_SPAN + 'дд' lower case
    30                         IPROTO_DATA
    92                         MP_ARRAY, size 2
    92                           MP_ARRAY, size 2
    01                             MP_INT = 1 i.e. contents of row#1 column#1
    a1 61                          MP_STR = 'a' i.e. contents of row#1 column#2
    92                           MP_ARRAY, size 2
    02                             MP_INT = 2 i.e. contents of row#2 column#1
    a1 62                          MP_STR = 'b' i.e. contents of row#2 column#2

If instead we said |br|
:code:`conn:prepare([[SELECT dd, дд AS д FROM t1;]])` |br|
then tcpdump would should show almost the same response, but there would
be no IPROTO_DATA and there would be two additional items: |br|
34 00 = IPROTO_BIND_COUNT + MP_UINT = 0 (there are no parameters to bind), |br|
33 90 = IPROTO_BIND_METADATA + MP_ARRAY, size 0 (there are no parameters to bind).

.. code-block:: none

    84                       MP_MAP, size 4
    43                         IPROTO_STMT_ID
    ce c2 3c 2c 1e             MP_UINT = statement id
    34                         IPROTO_BIND_COUNT
    00                         MP_INT = 0 = number of parameters to bind
    33                         IPROTO_BIND_METADATA
    90                         MP_ARRAY, size 0 = there are no parameters to bind
    32                         IPROTO_METADATA
    92                         MP_ARRAY, size 2 (i.e. 2 columns)
    85                           MP_MAP, size 5 (i.e. 5 items for column#1)
    00 a2 44 44                    IPROTO_FELD_NAME + 'DD'
    01 a7 69 6e 74 65 67 65 72     IPROTO_FIELD_TYPE + 'integer'
    03 c2                          IPROTO_FIELD_IS_NULLABLE + false
    04 c3                          IPROTO_FIELD_IS_AUTOINCREMENT + true
    05 c0                          PROTO_FIELD_SPAN + nil
    85                           MP_MAP, size 5 (i.e. 5 items for column#2)
    00 a2 d0 94                    IPROTO_FIELD_NAME + 'Д' upper case
    01 a6 73 74 72 69 6e 67        IPROTO_FIELD_TYPE + 'string'
    02 a7 75 6e 69 63 6f 64 65     IPROTO_FIELD_COLL + 'unicode'
    03 c3                          IPROTO_FIELD_IS_NULLABLE + true
    05 a4 d0 b4 d0 b4              IPROTO_FIELD_SPAN + 'дд' lower case

Now read the source code file `net_box.c <https://github.com/tarantool/tarantool/blob/master/src/box/lua/net_box.c>`_
where the function "decode_metadata_optional" is an example of how Tarantool
itself decodes extra items.

.. _box_protocol-authentication:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Binary protocol -- authentication
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

When a client connects to the server instance, the instance responds with a 128-byte
text greeting message, like this:

.. code-block:: none

    Greeting packet sent by server after connect:

    0                                     63
    +--------------------------------------+
    |                                      |
    | Tarantool Greeting (server version)  |
    |               64 bytes               |
    +---------------------+----------------+
    |                     |                |
    | BASE64 encoded SALT |      NULL      |
    |      44 bytes       |                |
    +---------------------+----------------+
    64                  107              127

The greeting contains two 64-byte lines of ASCII text.
Each line ends with a newline character (:code:`\n`). The first line contains the instance
version and protocol type. The second line contains up to 44 bytes of base64-encoded
random string, to use in the authentication packet, and ends with up to 23 spaces.

Part of the greeting is a base-64-encoded session salt -
a random string which can be used for authentication. The maximum length of an encoded
salt (44 bytes) is more than the amount necessary to create the authentication
message. An excess is reserved for future authentication
schemas.

Authentication is optional -- if it is skipped, then the session user is ``'guest'``
(the ``'guest'`` user does not need a password).

If authentication is not skipped, then at any time an authentication packet
can be prepared using the greeting, the user's name and password,
and `sha-1 <https://en.wikipedia.org/wiki/SHA-1>`_ functions, as follows.

.. code-block:: none

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

    AUTHORIZATION BODY: CODE = IPROTO_AUTH (0x07)

    +==========================+=====================================+
    |                          |        +-------------+------------+ |
    |  (KEY)                   | (TUPLE)| size == 9   | size == 20 | |
    |   0x23: IPROTO_USER_NAME |   0x21:| "chap-sha1" |  SCRAMBLE  | |
    | MP_INT: MP_STRING        | MP_INT:|  MP_STRING  |  MP_STRING | |
    |                          |        +-------------+------------+ |
    |                          |                   MP_ARRAY          |
    +==========================+=====================================+
                            MP_MAP

:code:`<key>` holds the user name. :code:`<tuple>` must be an array of 2 fields:
authentication mechanism ("chap-sha1" is the only supported mechanism right now)
and scramble, encrypted according to the specified mechanism.

The server instance responds to an authentication packet with a standard response with 0 tuples.

To see how Tarantool handles this, look at
`net_box.c <https://github.com/tarantool/tarantool/blob/master/src/box/lua/net_box.c>`_
function netbox_encode_auth.

.. _box_protocol-replication:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Binary protocol -- replication
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. code-block:: none

    -- replication keys
    <server_id>    ::= 0x02
    <lsn>          ::= 0x03
    <timestamp>    ::= 0x04
    <server_uuid>  ::= 0x24
    <cluster_uuid> ::= 0x25
    <vclock>       ::= 0x26

.. code-block:: none

    -- replication codes
    <join>         ::= 0x41
    <subscribe>    ::= 0x42


.. code-block:: none

    JOIN:

    In the beginning you must send an initial IPROTO_JOIN request (0x41)
                   HEADER                      BODY
    +================+=======================++========================+
    |                |                       ||   IPROTO_INSTANCE_UUID |
    |   0x00: 0x41   |   0x01: IPROTO_SYNC   ||   0x24: UUID           |
    | MP_INT: MP_INT | MP_INT: MP_INT        || MP_INT: MP_STRING      |
    |                |                       ||                        |
    +================+=======================++========================+
                   MP_MAP                     MP_MAP

    Then the instance which you want to connect to will send its last SNAP file, by simply
    creating a number of INSERTs (with additional LSN and ServerID)
    (do not reply to this). Then that instance will send a vclock's MP_MAP and close a socket.

    +================+=======================++============================+
    |                |                       ||        +~~~~~~~~~~~~~~~~~+ |
    |                |                       ||        |                 | |
    |   0x00: 0x00   |   0x01: IPROTO_SYNC   ||   0x26:| SRV_ID: SRV_LSN | |
    | MP_INT: MP_INT | MP_INT: MP_INT        || MP_INT:| MP_INT: MP_INT  | |
    |                |                       ||        +~~~~~~~~~~~~~~~~~+ |
    |                |                       ||               MP_MAP       |
    +================+=======================++============================+
                   MP_MAP                      MP_MAP

    SUBSCRIBE:

    Then you must send an IPROTO_SUBSCRIBE request (0x42)

                                  HEADER
    +=========================+========================+
    |                         |                        |
    |     0x00: 0x42          |    0x01: IPROTO_SYNC   |
    |   MP_INT: MP_INT        |  MP_INT: MP_INT        |
    |                         |                        |
    +=========================+========================+
    |    IPROTO_INSTANCE_UUID |    IPROTO_CLUSTER_UUID |
    |   0x24: UUID            |   0x25: UUID           |
    | MP_INT: MP_STRING       | MP_INT: MP_STRING      |
    |                         |                        |
    +=========================+========================+
                     MP_MAP

          BODY
    +=======================+
    |                       |
    |   0x26: IPROTO_VCLOCK |
    | MP_INT: MP_INT        |
    |                       |
    +=======================+
          MP_MAP

    Then you must process every request that could come through other masters.
    Every request between masters will have Additional LSN and SERVER_ID.

.. _box_protocol-heartbeat:

Frequently a master sends a :ref:`heartbeat <heartbeat>` message to a replica.
For example, if there is a replica with id = 2,
and a timestamp with a moment in 2020, a master might send this:

.. code-block:: none

    83                      MP_MAP, size 3
    00                        Main-Map Item #1 IPROTO_REQUEST_TYPE
    00                          MP_UINT = 0
    02                        Main-Map Item #2 IPROTO_REPLICA_ID
    02                          MP_UINT = 2 = id
    04                        Main-Map Item #3 IPROTO_TIMESTAMP
    cb                          MP_DOUBLE (MessagePack "Float 64")
    41 d7 ba 06 7b 3a 03 21     8-byte timestamp

and the replica might send back this:

.. code-block:: none

    81                       MP_MAP, size 1
    00                         Main-Map Item #1 Response-code-indicator
    00                         MP_UINT = 0 = IPROTO_OK
    81                         Main-Map Item #2, MP_MAP, size 1
    26                           Sub-Map Item #1 IPROTO_VCLOCK
    81                           Sub-Map Item #2, MP_MAP, size 1
    01                             MP_UINT = 1 = id (part 1 of vclock)
    06                             MP_UINT = 6 = lsn (part 2 of vclock)

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
XLOG / SNAP
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.xlog and .snap files have nearly the same format. The header looks like:

.. code-block:: none

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

.. code-block:: none

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
