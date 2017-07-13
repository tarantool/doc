.. _internals-sql_protocol:

--------------------------------------------------------------------------------
SQL protocol
--------------------------------------------------------------------------------

Tarantool's SQL protocol regulates how to build SQL requests and parse responses
using the common Tarantool's binary protocol.

Special SQL keys:

.. code-block:: none

    <field_name>    ::= 0x29
    <metadata>      ::= 0x32
    <sql_text>      ::= 0x40
    <sql_bind>      ::= 0x41
    <sql_options>   ::= 0x42 /* yet unused */
    <sql_info>      ::= 0x43
    <sql_row_count> ::= 0x44

Special SQL commands:

.. code-block:: none

    <execute> ::= 0x11

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Request packet body
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

An SQL request has the type ``EXECUTE=11``.

.. code-block:: none

    EXECUTE REQUEST BODY:
                             MAP
    +=====================+===============================+
    |                     |                               |
    |   0x40: SQL_TEXT    |     0x41: SQL_BIND            |
    | MP_STR: SQL request | MP_ARRAY: array of parameters |
    |                     |                               |
    +=====================+===============================+

* **SQL_TEXT** is a single non-empty SQL statement.
  For SQL syntax, see https://sqlite.org/lang.html
* **SQL_BIND** is an optional array of bindings (parameters). Each parameter
  value is a scalar: number, string, binary, null.

  A parameter can be *ordinal* or *named*.
  An ordinal parameter is encoded as a message pack scalar value (MP_UINT, INT,
  DOUBLE, FLOAT, STR, BIN, EXT, NIL).
  A named parameter is encoded as a map with one string key -- its name.
  For bindings syntax, see https://sqlite.org/lang_expr.html#varparam

**Examples:**

* :code:`[100, 'abc', NULL, -345.6] = MP_ARRAY[ MP_UINT, MP_STR, MP_NIL, MP_DOUBLE ]`
* :code:`[1, 2, {'name': 300}] = MP_ARRAY[ MP_UINT, MP_UINT, MP_MAP{ MP_STR : MP_UINT } ]`

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Response packet body
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Body structure depends on the type of the SQL request.

If the SQL request is SELECT, the response contains result rows and
metadata for columns. Metadata for a single column contains only the column's
name.

.. code-block:: none

    EXECUTE SELECT RESPONSE BODY:
                                  MAP
    +===========================+======================================+
    |                           |                                      |
    |                           |     0x32: METADATA                   |
    |                           | MP_ARRAY: array of maps:             |
    |                           |           +~~~~~~~~~~~~~~~~~~~~~~~~+ |
    |     0x30: DATA            |           | +~~~~~~~~~~~~~~~~~~~~+ | |
    | MP_ARRAY: array of tuples |           | |   0x29: FIELD_NAME | | |
    |                           |           | | MP_STR: field name | | |
    |                           |           | +~~~~~~~~~~~~~~~~~~~~+ | |
    |                           |           |        MP_MAP          | |
    |                           |           +~~~~~~~~~~~~~~~~~~~~~~~~+ |
    |                           |                   MP_ARRAY           |
    |                           |                                      |
    +===========================+======================================+

**Example:**

Request: :code:`SELECT col1, col2, col3 FROM test_space`

Response:

.. code-block:: none

    BODY = {
        DATA = [ [1, 1, 1], [2, 2, 2], [3, 3, 3], ... ],
        METADATA = [ { FIELD_NAME: 'col1' }, { FIELD_NAME: 'col2' }, { FIELD_NAME: 'col3' } ]
    }

If the SQL request is not SELECT, the response body contains only SQL_INFO.
The SQL_INFO is a map with one key -- SQL_ROW_COUNT -- which is the number of
changed rows. For example, if the request is
:code:`INSERT INTO test VALUES (1), (2), (3)`, the response body contains
SQL_INFO map with SQL_ROW_COUNT = 3.
Notice that SQL_ROW_COUNT can be 0, for example if the request is CREATE TABLE.

.. code-block:: none

    EXECUTE NOT-SELECT RESPONSE BODY:

    +========================================================+
    |                                                        |
    |   0x43: SQL_INFO                                       |
    | MP_MAP: single-key map  +~~~~~~~~~~~~~~~~~~~~~~~~~~~~+ |
    |                         |                            | |
    |                         |    0x44: ROW_COUNT         | |
    |                         | MP_UINT: changed row count | |
    |                         |                            | |
    |                         +~~~~~~~~~~~~~~~~~~~~~~~~~~~~+ |
    |                                                        |
    +========================================================+
