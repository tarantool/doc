..  _internals-iproto-sql:

SQL-specific requests and responses
===================================

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

The :ref:`Understanding binary protocol <box_protocol-illustration>`
tutorial shows actual byte codes of the IPROTO_EXECUTE message.

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


..  _box_protocol-sql_protocol:

Responses for SQL
-----------------

After the :ref:`header <box_protocol-header>`, for a response to an SQL statement,
there will be a body that is slightly different from the body for non-SQL requests/responses.

If the SQL request is not SELECT or VALUES or PRAGMA, then the response body
contains only IPROTO_SQL_INFO (0x42). Usually IPROTO_SQL_INFO is a map with only
one item -- SQL_INFO_ROW_COUNT (0x00) -- which is the number of changed rows.

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
        IPROTO_REQUEST_TYPE: IPROTO_OK,
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

The tutorial :ref:`Understanding the binary protocol <box_protocol-illustration>`
shows actual byte codes of responses to the above SQL messages.
