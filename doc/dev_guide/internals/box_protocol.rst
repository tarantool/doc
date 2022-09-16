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
            -   :ref:`extension <internals-msgpack_ext>`
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
    iproto/authentication
    iproto/events
    iproto/streams
    iproto/replication
    Examples <../../how-to/other/iproto>





Responses if no error and no SQL
--------------------------------


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


..  _box_protocol-sql_protocol:

Responses for SQL
-----------------

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

Later in :ref:`Binary protocol -- illustration <box_protocol-illustration>`
we will show actual byte codes of responses to the above SQL messages.
