..  _internals-requests_responses:

Client requests and responses
=============================

Секцию со всеми возможными пользовательскими запросами с описанием, что делает,
какие аргументы принимает, что возвращает.


..  container:: table

    ..  list-table::
        :header-rows: 1
        :widths: 17 16 17 50

        *   -   Name
            -   Binary code
            -   Type
            -   Description
        *   -   :ref:`IPROTO_SELECT <box_protocol-select>`
            -   0x01
            -   Map
            -   :ref:`Select <box_space-select>` request
        *   -   :ref:`IPROTO_INSERT <box_protocol-insert>`
            -   0x02
            -   Map
            -   :ref:`Insert <box_space-insert>` request
        *   -   :ref:`IPROTO_REPLACE <box_protocol-replace>`
            -   0x03
            -   Map
            -   :ref:`Replace <box_space-insert>` request
        *   -   :ref:`IPROTO_UPDATE <box_protocol-update>`
            -   0x04
            -   Map
            -   :ref:`Update <box_space-update>` request
        *   -   :ref:`IPROTO_UPSERT <box_protocol-upsert>`
            -   0x09
            -   Map
            -   :ref:`Upsert <box_space-upsert>` request
        *   -   :ref:`IPROTO_DELETE <box_protocol-delete>`
            -   0x05
            -   Map
            -   :ref:`Delete <box_space-delete>` request
    
    Function remote call (conn:call())
    IPROTO_CALL=0x0a
    IPROTO_CALL_16=0x06

    Authentification
    IPROTO_AUTH=0x07

    Evaluates a Lua expresstion (conn:eval())
    IPROTO_EVAL=0x08
    
    Execute an SQL statement (box.execute())
    IPROTO_EXECUTE=0x0b
    Prepare an SQL statement (box.prepare())
    IPROTO_PREPARE=0x0d

    Increment the LSN and do nothing else
    IPROTO_NOP=0x0c

    Transactions over streams
    IPROTO_BEGIN=0x0e
    IPROTO_COMMIT=0x0f
    IPROTO_ROLLBACK=0x10

    Ping (conn:ping())
    IPROTO_PING=0x40

    Fetch snapshot
    IPROTO_FETCH_SNAPSHOT=0x45

    Share iproto version and supported features
    IPROTO_ID=0x49

    
    
Everything OK? -> IPROTO_OK

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

Out-of-band? -> IPROTO_CHUNK
If the response is out-of-band, due to use of
:ref:`box.session.push() <box_session-push>`,
then the header Response-Code-Indicator will be IPROTO_CHUNK instead of IPROTO_OK.

Error? -> 0x8xxx where xxx is a value from errcode.h
Instead of IPROTO_DATA... IPROTO_ERROR: :samp:`{{MP_STRING string}}`


..  _box_protocol-select:

IPROTO_SELECT = 0x01
--------------------

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

Response:

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

For most data-access requests (:ref:`IPROTO_SELECT <box_protocol-select>`,
:ref:`IPROTO_INSERT <box_protocol-insert>`, :ref:`IPROTO_DELETE <box_protocol-delete>`, etc.)
the body is an IPROTO_DATA map with an array of tuples that contain an array of fields.

Response for SQL:

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

Example
~~~~~~~

If the id of 'tspace' is 512 and this is the fifth message, |br|
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

In the :ref:`examples <box_protocol-illustration>`,
you can find actual byte codes of an IPROTO_SELECT message.

Response:

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

For most data-access requests (:ref:`IPROTO_SELECT <box_protocol-select>`,
:ref:`IPROTO_INSERT <box_protocol-insert>`, :ref:`IPROTO_DELETE <box_protocol-delete>`, etc.)
the body is an IPROTO_DATA map with an array of tuples that contain an array of fields.


..  _box_protocol-insert:

IPROTO_INSERT = 0x02
--------------------

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

Response:

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

Response for SQL:

..  cssclass:: highlight
..  parsed-literal::

    ...
    # <body>
    msgpack({
        IPROTO_SQL_INFO: {
            SQL_INFO_ROW_COUNT: :samp:`{{MP_UINT}}`

For example, if the request is
:samp:`INSERT INTO {table-name} VALUES (1), (2), (3)`, then the response body
contains an :samp:`IPROTO_SQL_INFO map with SQL_INFO_ROW_COUNT = 3`.
:samp:`SQL_INFO_ROW_COUNT` can be 0 for statements that do not change rows,
but can be 1 for statements that create new objects.


Example
~~~~~~~

If the id of 'tspace' is 512 and this is the fifth message, |br|
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

(TODO: below is a response to another message, unite these examples into one)
If this is the fifth message and the request is
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


For most data-access requests (:ref:`IPROTO_SELECT <box_protocol-select>`,
:ref:`IPROTO_INSERT <box_protocol-insert>`, :ref:`IPROTO_DELETE <box_protocol-delete>`, etc.)
the body is an IPROTO_DATA map with an array of tuples that contain an array of fields.


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

Response:

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

For most data-access requests (:ref:`IPROTO_SELECT <box_protocol-select>`,
:ref:`IPROTO_INSERT <box_protocol-insert>`, :ref:`IPROTO_DELETE <box_protocol-delete>`, etc.)
the body is an IPROTO_DATA map with an array of tuples that contain an array of fields.

Response for SQL -- ??? (VALUES or no VALUES? Come up with a REPLACE request and see how it's encoded/decoded)

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

Response:

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

For most data-access requests (:ref:`IPROTO_SELECT <box_protocol-select>`,
:ref:`IPROTO_INSERT <box_protocol-insert>`, :ref:`IPROTO_DELETE <box_protocol-delete>`, etc.)
the body is an IPROTO_DATA map with an array of tuples that contain an array of fields.

Response for SQL -- ??? (VALUES or no VALUES? Come up with an UPDATE request and see how it's encoded/decoded)

Example
~~~~~~~

If the id of 'tspace' is 512 and this is the fifth message, |br|
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


Response:

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

For most data-access requests (:ref:`IPROTO_SELECT <box_protocol-select>`,
:ref:`IPROTO_INSERT <box_protocol-insert>`, :ref:`IPROTO_DELETE <box_protocol-delete>`, etc.)
the body is an IPROTO_DATA map with an array of tuples that contain an array of fields.

Response for SQL -- ??? (VALUES or no VALUES? Come up with an UPSERT request and see how it's encoded/decoded)

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

Response:

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

For most data-access requests (:ref:`IPROTO_SELECT <box_protocol-select>`,
:ref:`IPROTO_INSERT <box_protocol-insert>`, :ref:`IPROTO_DELETE <box_protocol-delete>`, etc.)
the body is an IPROTO_DATA map with an array of tuples that contain an array of fields.

Response for SQL:

Response for SQL:

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


..  _box_protocol-eval:

IPROTO_EVAL = 0x08
------------------

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

Response:

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

- For :ref:`IPROTO_EVAL <box_protocol-eval>` and :ref:`IPROTO_CALL <box_protocol-call>`
  the response body will usually be an array but, since Lua requests can result in a wide variety
  of structures, bodies can have a wide variety of structures.

Response for SQL: ??? (fiure out why CALL and EVAL are the best place for SQL responses, according to locker)

Example
~~~~~~~

If this is the fifth message, :samp:`conn:eval('return 5;')` will cause:

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



..  _box_protocol-call:

IPROTO_CALL = 0x0a
------------------

See :ref:`conn:call() <net_box-call>`.
This is a remote stored-procedure call. 

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

The return from conn:call is whatever the function returns.

The response will be a list of values, similar to the
:ref:`IPROTO_EVAL <box_protocol-eval>` response.

Response for SQL: ??? (fiure out why CALL and EVAL are the best place for SQL responses, according to locker)


..  _box_protocol-execute:

IPROTO_EXECUTE = 0x0b
---------------------

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

Another example: 

If we ask for full metadata by saying |br|
:code:`conn.space._session_settings:update('sql_full_metadata', {{'=', 'value', true}})`
we select the two rows from a table named t1 that has columns named DD and Д saying
:code:`conn:prepare([[SELECT dd, дд AS д FROM t1;]])` |br|
there would be no IPROTO_DATA and there would be two additional items: |br|
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



..  _box_protocol-nop:

IPROTO_NOP = 0x0c
-----------------

There is no Lua request exactly equivalent to IPROTO_NOP.
It causes the LSN to be incremented.
It could be sometimes used for updates where the old and new values
are the same, but the LSN must be increased because a data-change
must be recorded.
The body is: nothing.


..  _box_protocol-prepare:

IPROTO_PREPARE = 0x0d
---------------------

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


..  _box_protocol-auth:

IPROTO_AUTH = 0x07
------------------

See :ref:`authentication <authentication-users>`.
See the later section :ref:`Binary protocol -- authentication <box_protocol-authentication>`.

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


Streams
-------

..  _box_protocol-begin:

IPROTO_BEGIN = 0x0e
-------------------

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
--------------------

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
----------------------

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
------------------

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

Response:

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
        IPROTO_DATA: :samp:`{{}}`
    })

- For :ref:`IPROTO_PING <box_protocol-ping>` the body will be an empty map.


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

Response:

- For :ref:`IPROTO_ID <box_protocol-id>`, the response body has the same structure as
  the request body. It informs the client about the protocol version and features
  that the server supports.

