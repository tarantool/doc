.. _box_protocol-iproto_protocol:

--------------------------------------------------------------------------------
Tarantool's binary protocol
--------------------------------------------------------------------------------

Tarantool's binary protocol is a binary request/response protocol.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Notation in diagrams
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. code-block:: none

    0    X
    +----+
    |    | - X + 1 bytes
    +----+
     TYPE - type of MsgPack value (if it is a MsgPack object)

    +====+
    |    | - Variable size MsgPack object
    +====+
     TYPE - type of MsgPack value

    +~~~~+
    |    | - Variable size MsgPack Array/Map
    +~~~~+
     TYPE - type of MsgPack value


MsgPack data types:

* **MP_INT** - Integer
* **MP_MAP** - Map
* **MP_ARR** - Array
* **MP_STRING** - String
* **MP_FIXSTR** - Fixed size string
* **MP_OBJECT** - Any MsgPack object
* **MP_BIN** - MsgPack binary format

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Greeting packet
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. code-block:: none

    TARANTOOL'S GREETING:

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

The server instance begins the dialogue by sending a fixed-size (128-byte) text greeting
to the client. The greeting always contains two 64-byte lines of ASCII text, each
line ending with a newline character (:code:`\n`). The first line contains the instance
version and protocol type. The second line contains up to 44 bytes of base64-encoded
random string, to use in the authentication packet, and ends with up to 23 spaces.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Unified packet structure
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Once a greeting is read, the protocol becomes pure request/response and features
a complete access to Tarantool functionality, including:

- request multiplexing, e.g. ability to asynchronously issue multiple requests
  via the same connection
- response format that supports zero-copy writes

The protocol uses `msgpack <http://msgpack.org>`_ for data structures
and encoding.

The protocol uses maps that contain some integer constants as keys.
These constants are defined in `src/box/iproto_constants.h
<https://github.com/tarantool/tarantool/blob/1.9/src/box/iproto_constants.h>`_.
We list common constants here:

.. code-block:: none

    -- user keys
    <iproto_sync>          ::= 0x01
    <iproto_schema_id>     ::= 0x05  /* also known as schema_version */
    <iproto_space_id>      ::= 0x10
    <iproto_index_id>      ::= 0x11
    <iproto_limit>         ::= 0x12
    <iproto_offset>        ::= 0x13
    <iproto_iterator>      ::= 0x14
    <iproto_key>           ::= 0x20
    <iproto_tuple>         ::= 0x21
    <iproto_function_name> ::= 0x22
    <iproto_username>      ::= 0x23
    <iproto_expr>          ::= 0x27 /* also known as expression */
    <iproto_ops>           ::= 0x28
    <iproto_data>          ::= 0x30
    <iproto_error>         ::= 0x31

.. code-block:: none

    -- -- Value for <code> key in request can be:
    -- User command codes
    <iproto_select>       ::= 0x01
    <iproto_insert>       ::= 0x02
    <iproto_replace>      ::= 0x03
    <iproto_update>       ::= 0x04
    <iproto_delete>       ::= 0x05
    <iproto_call_16>      ::= 0x06 /* as used in version 1.6 */
    <iproto_auth>         ::= 0x07
    <iproto_eval>         ::= 0x08
    <iproto_upsert>       ::= 0x09
    <iproto_call>         ::= 0x0a
    -- Admin command codes
    -- (including codes for replica-set initialization and master election)
    <iproto_ping>         ::= 0x40
    <iproto_join>         ::= 0x41 /* i.e. replication join */
    <iproto_subscribe>    ::= 0x42
    <iproto_request_vote> ::= 0x43

    -- -- Value for <code> key in response can be:
    <iproto_ok>           ::= 0x00
    <iproto_type_error>   ::= 0x8XXX /* where XXX is a value in errcode.h */


Both :code:`<header>` and :code:`<body>` are msgpack maps:

.. code-block:: none

    Request/Response:

    0        5
    +--------+ +============+ +===================================+
    | BODY + | |            | |                                   |
    | HEADER | |   HEADER   | |               BODY                |
    |  SIZE  | |            | |                                   |
    +--------+ +============+ +===================================+
      MP_INT       MP_MAP                     MP_MAP

.. code-block:: none

    UNIFIED HEADER:

    +================+================+=====================+
    |                |                |                     |
    |   0x00: CODE   |   0x01: SYNC   |    0x05: SCHEMA_ID  |
    | MP_INT: MP_INT | MP_INT: MP_INT |  MP_INT: MP_INT     |
    |                |                |                     |
    +================+================+=====================+
                              MP_MAP

They only differ in the allowed set of keys and values. The key defines the type
of value that follows. In a request, the body map can be absent. Responses will 
contain it anyway even if it is a ``PING``. ``schema_id``
may be absent in the request's header, meaning that there will be no version
checking, but it must be present in the response. If ``schema_id`` is sent in
the header, then it will be checked.

.. _box_protocol-authentication:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Authentication
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

When a client connects to the server instance, the instance responds with a 128-byte
text greeting message. Part of the greeting is base-64 encoded session salt -
a random string which can be used for authentication. The length of decoded
salt (44 bytes) exceeds the amount necessary to sign the authentication
message (first 20 bytes). An excess is reserved for future authentication
schemas.

.. code-block:: none

    PREPARE SCRAMBLE:

        LEN(ENCODED_SALT) = 44;
        LEN(SCRAMBLE)     = 20;

    prepare 'chap-sha1' scramble:

        salt = base64_decode(encoded_salt);
        step_1 = sha1(password);
        step_2 = sha1(step_1);
        step_3 = sha1(salt, step_2);
        scramble = xor(step_1, step_3);
        return scramble;

    AUTHORIZATION BODY: CODE = 0x07

    +==================+====================================+
    |                  |        +-------------+-----------+ |
    |  (KEY)           | (TUPLE)|  len == 9   | len == 20 | |
    |   0x23:USERNAME  |   0x21:| "chap-sha1" |  SCRAMBLE | |
    | MP_INT:MP_STRING | MP_INT:|  MP_STRING  |  MP_BIN   | |
    |                  |        +-------------+-----------+ |
    |                  |                   MP_ARRAY         |
    +==================+====================================+
                            MP_MAP

:code:`<key>` holds the user name. :code:`<tuple>` must be an array of 2 fields:
authentication mechanism ("chap-sha1" is the only supported mechanism right now)
and password, encrypted according to the specified mechanism. Authentication in
Tarantool is optional, if no authentication is performed, session user is 'guest'.
The instance responds to authentication packet with a standard response with 0 tuples.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Requests
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

* SELECT: CODE - 0x01
  Find tuples matching the search pattern

.. code-block:: none

    SELECT BODY:

    +==================+==================+==================+
    |                  |                  |                  |
    |   0x10: SPACE_ID |   0x11: INDEX_ID |   0x12: LIMIT    |
    | MP_INT: MP_INT   | MP_INT: MP_INT   | MP_INT: MP_INT   |
    |                  |                  |                  |
    +==================+==================+==================+
    |                  |                  |                  |
    |   0x13: OFFSET   |   0x14: ITERATOR |   0x20: KEY      |
    | MP_INT: MP_INT   | MP_INT: MP_INT   | MP_INT: MP_ARRAY |
    |                  |                  |                  |
    +==================+==================+==================+
                              MP_MAP

* INSERT:  CODE - 0x02
  Inserts tuple into the space, if no tuple with same unique keys exists. Otherwise throw *duplicate key* error.
* REPLACE: CODE - 0x03
  Insert a tuple into the space or replace an existing one.

.. code-block:: none


    INSERT/REPLACE BODY:

    +==================+==================+
    |                  |                  |
    |   0x10: SPACE_ID |   0x21: TUPLE    |
    | MP_INT: MP_INT   | MP_INT: MP_ARRAY |
    |                  |                  |
    +==================+==================+
                     MP_MAP

* UPDATE: CODE - 0x04
  Update a tuple

.. code-block:: none

    UPDATE BODY:

    +==================+=======================+
    |                  |                       |
    |   0x10: SPACE_ID |   0x11: INDEX_ID      |
    | MP_INT: MP_INT   | MP_INT: MP_INT        |
    |                  |                       |
    +==================+=======================+
    |                  |          +~~~~~~~~~~+ |
    |                  |          |          | |
    |                  | (TUPLE)  |    OP    | |
    |   0x20: KEY      |    0x21: |          | |
    | MP_INT: MP_ARRAY |  MP_INT: +~~~~~~~~~~+ |
    |                  |            MP_ARRAY   |
    +==================+=======================+
                     MP_MAP

.. code-block:: none

    OP:
        Works only for integer fields:
        * Addition    OP = '+' . space[key][field_no] += argument
        * Subtraction OP = '-' . space[key][field_no] -= argument
        * Bitwise AND OP = '&' . space[key][field_no] &= argument
        * Bitwise XOR OP = '^' . space[key][field_no] ^= argument
        * Bitwise OR  OP = '|' . space[key][field_no] |= argument
        Works on any fields:
        * Delete      OP = '#'
          delete <argument> fields starting
          from <field_no> in the space[<key>]

    0           2
    +-----------+==========+==========+
    |           |          |          |
    |    OP     | FIELD_NO | ARGUMENT |
    | MP_FIXSTR |  MP_INT  |  MP_INT  |
    |           |          |          |
    +-----------+==========+==========+
                  MP_ARRAY

.. code-block:: none

        * Insert      OP = '!'
          insert <argument> before <field_no>
        * Assign      OP = '='
          assign <argument> to field <field_no>.
          will extend the tuple if <field_no> == <max_field_no> + 1

    0           2
    +-----------+==========+===========+
    |           |          |           |
    |    OP     | FIELD_NO | ARGUMENT  |
    | MP_FIXSTR |  MP_INT  | MP_OBJECT |
    |           |          |           |
    +-----------+==========+===========+
                  MP_ARRAY

        Works on string fields:
        * Splice      OP = ':'
          take the string from space[key][field_no] and
          substitute <offset> bytes from <position> with <argument>

.. code-block:: none

    0           2
    +-----------+==========+==========+========+==========+
    |           |          |          |        |          |
    |    ':'    | FIELD_NO | POSITION | OFFSET | ARGUMENT |
    | MP_FIXSTR |  MP_INT  |  MP_INT  | MP_INT |  MP_STR  |
    |           |          |          |        |          |
    +-----------+==========+==========+========+==========+
                             MP_ARRAY


It is an error to specify an argument of a type that differs from the expected type.

* DELETE: CODE - 0x05
  Delete a tuple

.. code-block:: none

    DELETE BODY:

    +==================+==================+==================+
    |                  |                  |                  |
    |   0x10: SPACE_ID |   0x11: INDEX_ID |   0x20: KEY      |
    | MP_INT: MP_INT   | MP_INT: MP_INT   | MP_INT: MP_ARRAY |
    |                  |                  |                  |
    +==================+==================+==================+
                              MP_MAP


* CALL_16: CODE - 0x06
  Call a stored function, returning an array of tuples. This is deprecated; CALL (0x0a) is recommended instead.

.. code-block:: none

    CALL_16 BODY:

    +=======================+==================+
    |                       |                  |
    |   0x22: FUNCTION_NAME |   0x21: TUPLE    |
    | MP_INT: MP_STRING     | MP_INT: MP_ARRAY |
    |                       |                  |
    +=======================+==================+
                        MP_MAP

.. _box_protocol-eval:

* EVAL: CODE - 0x08
  Evaulate Lua expression

.. code-block:: none

    EVAL BODY:

    +=======================+==================+
    |                       |                  |
    |   0x27: EXPRESSION    |   0x21: TUPLE    |
    | MP_INT: MP_STRING     | MP_INT: MP_ARRAY |
    |                       |                  |
    +=======================+==================+
                        MP_MAP


* UPSERT: CODE - 0x09
  Update tuple if it would be found elsewhere try to insert tuple. Always use primary index for key.

.. code-block:: none

    UPSERT BODY:

    +==================+==================+==========================+
    |                  |                  |             +~~~~~~~~~~+ |
    |                  |                  |             |          | |
    |   0x10: SPACE_ID |   0x21: TUPLE    |       (OPS) |    OP    | |
    | MP_INT: MP_INT   | MP_INT: MP_ARRAY |       0x28: |          | |
    |                  |                  |     MP_INT: +~~~~~~~~~~+ |
    |                  |                  |               MP_ARRAY   |
    +==================+==================+==========================+
                                    MP_MAP

    Operations structure same as for UPDATE operation.
       0           2
    +-----------+==========+==========+
    |           |          |          |
    |    OP     | FIELD_NO | ARGUMENT |
    | MP_FIXSTR |  MP_INT  |  MP_INT  |
    |           |          |          |
    +-----------+==========+==========+
                  MP_ARRAY

    Supported operations:

    '+' - add a value to a numeric field. If the filed is not numeric, it's
          changed to 0 first. If the field does not exist, the operation is
          skipped. There is no error in case of overflow either, the value
          simply wraps around in C style. The range of the integer is MsgPack:
          from -2^63 to 2^64-1
    '-' - same as the previous, but subtract a value
    '=' - assign a field to a value. The field must exist, if it does not exist,
          the operation is skipped.
    '!' - insert a field. It's only possible to insert a field if this create no
          nil "gaps" between fields. E.g. it's possible to add a field between
          existing fields or as the last field of the tuple.
    '#' - delete a field. If the field does not exist, the operation is skipped.
          It's not possible to change with update operations a part of the primary
          key (this is validated before performing upsert).

* CALL: CODE - 0x0a
  Similar to CALL_16, but -- like EVAL, CALL returns a list of values, unconverted

.. code-block:: none

    CALL BODY:

    +=======================+==================+
    |                       |                  |
    |   0x22: FUNCTION_NAME |   0x21: TUPLE    |
    | MP_INT: MP_STRING     | MP_INT: MP_ARRAY |
    |                       |                  |
    +=======================+==================+
                        MP_MAP


~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Response packet structure
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

We will show whole packets here:

.. code-block:: none


    OK:    LEN + HEADER + BODY

    0      5                                          OPTIONAL
    +------++================+================++===================+
    |      ||                |                ||                   |
    | BODY ||   0x00: 0x00   |   0x01: SYNC   ||   0x30: DATA      |
    |HEADER|| MP_INT: MP_INT | MP_INT: MP_INT || MP_INT: MP_OBJECT |
    | SIZE ||                |                ||                   |
    +------++================+================++===================+
     MP_INT                MP_MAP                      MP_MAP

Set of tuples in the response :code:`<data>` expects a msgpack array of tuples as value
EVAL command returns arbitrary `MP_ARRAY` with arbitrary MsgPack values.

.. code-block:: none

    ERROR: LEN + HEADER + BODY

    0      5
    +------++================+================++===================+
    |      ||                |                ||                   |
    | BODY ||   0x00: 0x8XXX |   0x01: SYNC   ||   0x31: ERROR     |
    |HEADER|| MP_INT: MP_INT | MP_INT: MP_INT || MP_INT: MP_STRING |
    | SIZE ||                |                ||                   |
    +------++================+================++===================+
     MP_INT                MP_MAP                      MP_MAP

    Where 0xXXX is ERRCODE.

An error message is present in the response only if there is an error; :code:`<error>`
expects as value a msgpack string.

Convenience macros which define hexadecimal constants for return codes
can be found in `src/box/errcode.h
<https://github.com/tarantool/tarantool/blob/1.10/src/box/errcode.h>`_

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Replication packet structure
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. code-block:: none

    -- replication keys
    <server_id>     ::= 0x02
    <lsn>           ::= 0x03
    <timestamp>     ::= 0x04
    <server_uuid>   ::= 0x24
    <cluster_uuid>  ::= 0x25
    <vclock>        ::= 0x26

.. code-block:: none

    -- replication codes
    <join>      ::= 0x41
    <subscribe> ::= 0x42


.. code-block:: none

    JOIN:

    In the beginning you must send initial JOIN
                   HEADER                      BODY
    +================+================++===================+
    |                |                ||   SERVER_UUID     |
    |   0x00: 0x41   |   0x01: SYNC   ||   0x24: UUID      |
    | MP_INT: MP_INT | MP_INT: MP_INT || MP_INT: MP_STRING |
    |                |                ||                   |
    +================+================++===================+
                   MP_MAP                     MP_MAP

    Then instance, which we connect to, will send last SNAP file by, simply,
    creating a number of INSERTs (with additional LSN and ServerID)
    (don't reply). Then it'll send a vclock's MP_MAP and close a socket.

    +================+================++============================+
    |                |                ||        +~~~~~~~~~~~~~~~~~+ |
    |                |                ||        |                 | |
    |   0x00: 0x00   |   0x01: SYNC   ||   0x26:| SRV_ID: SRV_LSN | |
    | MP_INT: MP_INT | MP_INT: MP_INT || MP_INT:| MP_INT: MP_INT  | |
    |                |                ||        +~~~~~~~~~~~~~~~~~+ |
    |                |                ||               MP_MAP       |
    +================+================++============================+
                   MP_MAP                      MP_MAP

    SUBSCRIBE:

    Then you must send SUBSCRIBE:

                                  HEADER
    +===================+===================+
    |                   |                   |
    |     0x00: 0x42    |    0x01: SYNC     |
    |   MP_INT: MP_INT  |  MP_INT: MP_INT   |
    |                   |                   |
    +===================+===================+
    |    SERVER_UUID    |    CLUSTER_UUID   |
    |   0x24: UUID      |   0x25: UUID      |
    | MP_INT: MP_STRING | MP_INT: MP_STRING |
    |                   |                   |
    +===================+===================+
                     MP_MAP

          BODY
    +================+
    |                |
    |   0x26: VCLOCK |
    | MP_INT: MP_INT |
    |                |
    +================+
          MP_MAP

    Then you must process every query that'll came through other masters.
    Every request between masters will have Additional LSN and SERVER_ID.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
XLOG / SNAP
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

XLOG and SNAP files have nearly the same format. The header looks like:

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

See the example in the following section.
