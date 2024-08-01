..  _how-to-iproto:
..  _box_protocol-illustration:

Understanding the binary protocol
=================================

Overview
--------

To communicate with each other, Tarantool instances use a binary protocol called iproto.

In this set of examples, the user will be looking at binary code transferred via iproto.
The code is intercepted with ``tcpdump``, a monitoring utility.

Examples
--------

To follow the examples in this section,
get a single Linux computer and start three command-line shells ("terminals").

-- On terminal #1, Start monitoring port 3302 with `tcpdump <https://www.tcpdump.org/manpages/tcpdump.1.html>`_: |br|

..  code-block:: bash

    sudo tcpdump -i lo 'port 3302' -X

On terminal #2, start a server with:

..  code-block:: lua

    box.cfg{listen=3302}
    box.schema.space.create('tspace')
    box.space.tspace:create_index('I')
    box.space.tspace:insert{280}
    box.schema.user.grant('guest','read,write,execute,create,drop','universe')

On terminal #3, start another server, which will act as a client, with:

..  code-block:: lua

    box.cfg{}
    net_box = require('net.box')
    conn = net_box.connect('localhost:3302')

IPROTO_SELECT
~~~~~~~~~~~~~

On terminal #3, run the following:

..  code-block:: lua

    conn.space.tspace:select(280)

Now look at what tcpdump shows for the job connecting to 3302 -- the "request".
After the words "length 32" is a packet that ends with these 32 bytes
(we have added indented comments):

..  code-block:: none

    ce 00 00 00 1b   MP_UINT = decimal 27 = number of bytes after this
    82               MP_MAP, size 2 (we'll call this "Main-Map")
    01                 IPROTO_SYNC (Main-Map Item#1)
    04                 MP_INT = 4 = number that gets incremented with each request
    00                 IPROTO_REQUEST_TYPE (Main-Map Item#2)
    01                 IPROTO_SELECT
    86                 MP_MAP, size 6 (we'll call this "Select-Map")
    10                   IPROTO_SPACE_ID (Select-Map Item#1)
    cd 02 00             MP_UINT = decimal 512 = id of tspace (could be larger)
    11                   IPROTO_INDEX_ID (Select-Map Item#2)
    00                   MP_INT = 0 = id of index within tspace
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
From the comments and from simple function calls like
``mpstream_encode_uint(&stream, IPROTO_SPACE_ID);``
you will be able to see how net_box put together the packet contents that you
have just observed with tcpdump.

There are libraries for reading and writing MessagePack objects.
C programmers sometimes include `msgpuck.h <https://github.com/rtsisyk/msgpuck>`_.

Now you know how Tarantool itself makes requests with the binary protocol.
When in doubt about a detail, consult ``net_box.c`` -- it has routines for each
request. Some :ref:`connectors <index-box_connectors>` have similar code.

IPROTO_UPDATE
~~~~~~~~~~~~~

For an IPROTO_UPDATE example, suppose a user changes field #2 in tuple #2
in space #256 to ``'BBBB'``. The body will look like this:
(notice that in this case there is an extra map item
IPROTO_INDEX_BASE, to emphasize that field numbers
start with 1, which is optional and can be omitted):

..  code-block:: none

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

IPROTO_EXECUTE
~~~~~~~~~~~~~~

Byte codes for the :ref:`IPROTO_EXECUTE <box_protocol-execute>` example:

..  code-block:: none

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

IPROTO_INSERT
~~~~~~~~~~~~~

Byte codes for the response to the :codenormal:`box.space.`:codeitalic:`space-name`:codenormal:`:insert{6}`
example:

..  code-block:: none

    ce 00 00 00 20                MP_UINT = HEADER AND BODY SIZE
    83                            MP_MAP, size 3
    00                              IPROTO_REQUEST_TYPE
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

IPROTO_EVAL
~~~~~~~~~~~

Byte codes for the response to the ``conn:eval([[box.schema.space.create('_space');]])``
example:

..  code-block:: none

    ce 00 00 00 3b                  MP_UINT = HEADER AND BODY SIZE
    83                              MP_MAP, size 3 (i.e. 3 items in header)
       00                              IPROTO_REQUEST_TYPE
       ce 00 00 80 0a                  MP_UINT = hexadecimal 800a
       01                              IPROTO_SYNC
       cf 00 00 00 00 00 00 00 26      MP_UINT = sync value
       05                              IPROTO_SCHEMA_VERSION
       ce 00 00 00 78                  MP_UINT = schema version value
       81                              MP_MAP, size 1
         31                              IPROTO_ERROR_24
         db 00 00 00 1d 53 70 61 63 etc. MP_STR = "Space '_space' already exists"

Creating a table with IPROTO_EXECUTE
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Byte codes, if we use the same net.box connection that
we used in the beginning
and we say |br|
``conn:execute([[CREATE TABLE t1 (dd INT PRIMARY KEY AUTOINCREMENT, дд STRING COLLATE "unicode");]])`` |br|
``conn:execute([[INSERT INTO t1 VALUES (NULL, 'a'), (NULL, 'b');]])`` |br|
and we watch what tcpdump displays, we will see two noticeable things:
(1) the CREATE statement caused a schema change so the response has
a new IPROTO_SCHEMA_VERSION value and the body includes
the new contents of some system tables (caused by requests from net.box which users will not see);
(2) the final bytes of the response to the INSERT will be:

..  code-block:: none

    81   MP_MAP, size 1
    42     IPROTO_SQL_INFO
    82     MP_MAP, size 2
    00       Tarantool constant (not in iproto_constants.h) = SQL_INFO_ROW_COUNT
    02       1 = row count
    01       Tarantool constant (not in iproto_constants.h) = SQL_INFO_AUTOINCREMENT_ID
    92       MP_ARRAY, size 2
    01         first autoincrement number
    02         second autoincrement number

SELECT with SQL
~~~~~~~~~~~~~~~

Byte codes for the SQL SELECT example,
if we ask for full metadata by saying |br|
:code:`conn.space._session_settings:update('sql_full_metadata', {{'=', 'value', true}})` |br|
and we select the two rows from the table that we just created |br|
:code:`conn:execute([[SELECT dd, дд AS д FROM t1;]])` |br|
then tcpdump will show this response, after the header:

..  code-block:: none

    82                       MP_MAP, size 2 (i.e. metadata and rows)
    32                         IPROTO_METADATA
    92                         MP_ARRAY, size 2 (i.e. 2 columns)
    85                           MP_MAP, size 5 (i.e. 5 items for column#1)
    00 a2 44 44                    IPROTO_FIELD_NAME and 'DD'
    01 a7 69 6e 74 65 67 65 72     IPROTO_FIELD_TYPE and 'integer'
    03 c2                          IPROTO_FIELD_IS_NULLABLE and false
    04 c3                          IPROTO_FIELD_IS_AUTOINCREMENT and true
    05 c0                          PROTO_FIELD_SPAN and nil
    85                           MP_MAP, size 5 (i.e. 5 items for column#2)
    00 a2 d0 94                    IPROTO_FIELD_NAME and 'Д' upper case
    01 a6 73 74 72 69 6e 67        IPROTO_FIELD_TYPE and 'string'
    02 a7 75 6e 69 63 6f 64 65     IPROTO_FIELD_COLL and 'unicode'
    03 c3                          IPROTO_FIELD_IS_NULLABLE and true
    05 a4 d0 b4 d0 b4              IPROTO_FIELD_SPAN and 'дд' lower case
    30                         IPROTO_DATA
    92                         MP_ARRAY, size 2
    92                           MP_ARRAY, size 2
    01                             MP_INT = 1 i.e. contents of row#1 column#1
    a1 61                          MP_STR = 'a' i.e. contents of row#1 column#2
    92                           MP_ARRAY, size 2
    02                             MP_INT = 2 i.e. contents of row#2 column#1
    a1 62                          MP_STR = 'b' i.e. contents of row#2 column#2

IPROTO_PREPARE
~~~~~~~~~~~~~~

Byte code for the SQL PREPARE example. If we said |br|
:code:`conn:prepare([[SELECT dd, дд AS д FROM t1;]])` |br|
then tcpdump would show almost the same response, but there would
be no IPROTO_DATA. Instead, additional items will appear:

..  code-block:: none

    34                       IPROTO_BIND_COUNT
    00                       MP_UINT = 0

    33                       IPROTO_BIND_METADATA
    90                       MP_ARRAY, size 0

``MP_UINT = 0`` and ``MP_ARRAY`` has size 0 because there are no parameters to bind.
Full output:

..  code-block:: none

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
    00 a2 44 44                    IPROTO_FIELD_NAME and 'DD'
    01 a7 69 6e 74 65 67 65 72     IPROTO_FIELD_TYPE and 'integer'
    03 c2                          IPROTO_FIELD_IS_NULLABLE and false
    04 c3                          IPROTO_FIELD_IS_AUTOINCREMENT and true
    05 c0                          PROTO_FIELD_SPAN and nil
    85                           MP_MAP, size 5 (i.e. 5 items for column#2)
    00 a2 d0 94                    IPROTO_FIELD_NAME and 'Д' upper case
    01 a6 73 74 72 69 6e 67        IPROTO_FIELD_TYPE and 'string'
    02 a7 75 6e 69 63 6f 64 65     IPROTO_FIELD_COLL and 'unicode'
    03 c3                          IPROTO_FIELD_IS_NULLABLE and true
    05 a4 d0 b4 d0 b4              IPROTO_FIELD_SPAN and 'дд' lower case

Heartbeat
~~~~~~~~~

Byte code for the :ref:`heartbeat <box_protocol-heartbeat>` example. The master might send this body:

..  code-block:: none

    83                      MP_MAP, size 3
    00                        Main-Map Item #1 IPROTO_REQUEST_TYPE
    00                          MP_UINT = 0
    02                        Main-Map Item #2 IPROTO_REPLICA_ID
    02                          MP_UINT = 2 = id
    04                        Main-Map Item #3 IPROTO_TIMESTAMP
    cb                          MP_DOUBLE (MessagePack "Float 64")
    41 d7 ba 06 7b 3a 03 21     8-byte timestamp
    81                      MP_MAP (body), size 1
    5a                      Body Map Item #1 IPROTO_VCLOCK_SYNC
    14                        MP_UINT = 20 (vclock sync value)

Byte code for the :ref:`heartbeat <box_protocol-heartbeat>` example. The replica might send back this body:

..  code-block:: none

    81                       MP_MAP, size 1
    00                         Main-Map Item #1 IPROTO_REQUEST_TYPE
    00                         MP_UINT = 0 = IPROTO_OK
    83                         MP_MAP (body), size 3
    26                           Body Map Item #1 IPROTO_VCLOCK
    81                             MP_MAP, size 1 (vclock of 1 component)
    01                               MP_UINT = 1 = id (part 1 of vclock)
    06                               MP_UINT = 6 = lsn (part 2 of vclock)
    5a                           Body Map Item #2 IPROTO_VCLOCK_SYNC
    14                             MP_UINT = 20 (vclock sync value)
    53                           Body Map Item #3 IPROTO_TERM
    31                             MP_UINT = 49 (term value)