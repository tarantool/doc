.. _internals-sql_protocol:

--------------------------------------------------------------------------------
SQL protocol
--------------------------------------------------------------------------------

Tarantool's SQL protocol regulates how to build SQL requests and parse responses
using Tarantool's common binary protocol.

Special SQL keys:

.. code-block:: none

    <metadata>      ::= 0x32
    <sql_text>      ::= 0x40
    <sql_bind>      ::= 0x41
    <sql_info>      ::= 0x42


Special SQL commands:

.. code-block:: none

    <execute> ::= 11

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

If the SQL request is SELECT, the response contains:

* metadata for columns (metadata for a single column contains only the column's
  name and type) and
* result rows.

.. code-block:: none

    EXECUTE SELECT RESPONSE BODY:
                                  MAP
    +======================================+===========================+
    |                                      |                           |
    |     0x32: METADATA                   |                           |
    | MP_ARRAY: array of maps:             |                           |
    |           +~~~~~~~~~~~~~~~~~~~~~~~~+ |                           |
    |           | +~~~~~~~~~~~~~~~~~~~~+ | |     0x30: DATA            |
    |           | |   0x00: FIELD_NAME | | | MP_ARRAY: array of tuples |
    |           | | MP_STR: field name | | |                           |
    |           | |   0x01: FIELD_TYPE | | |                           |
    |           | | MP_STR: field type | | |                           |
    |           | +~~~~~~~~~~~~~~~~~~~~+ | |                           |
    |           |        MP_MAP          | |                           |
    |           +~~~~~~~~~~~~~~~~~~~~~~~~+ |                           |
    |                   MP_ARRAY           |                           |
    |                                      |                           |
    +======================================+===========================+

**Example:**

Request: :code:`SELECT x, y FROM test_space;`

Response:

.. code-block:: none

    BODY = {
        METADATA = [
        { FIELD_NAME: 'X', FIELD_TYPE: 'TEXT'}, { FIELD_NAME: 'Y', FIELD_TYPE: 'INTEGER'},
        DATA = [ ['a', 1], ['c', 2], ['e', 5], ... ]
    }

If the SQL request is not SELECT, the response body contains only SQL_INFO.
Usually SQL_INFO is a map with only one key -- SQL_INFO_ROW_COUNT (0) -- which is the number of
changed rows. For example, if the request is
:code:`INSERT INTO test VALUES (1), (2), (3)`, the response body contains
an SQL_INFO map with SQL_INFO_ROW_COUNT = 3.
SQL_INFO_ROW_COUNT can be 0 for statements that do not change rows, such as CREATE TABLE.

The SQL_INFO map may contain a second key -- SQL_INFO_AUTO_INCREMENT_IDS (1) -- which is the
new primary-key value for an INSERT in a table defined with PRIMARY KEY
AUTOINCREMENT.

.. code-block:: none

    EXECUTE NOT-SELECT RESPONSE BODY:

    +=========================================================+
    |                                                         |
    |   0x42: SQL_INFO                                        |
    | MP_MAP: usually 1 key   +~~~~~~~~~~~~~~~~~~~~~~~~~~~~~+ |
    |                         |                             | |
    |                         |    0x00: SQL_INFO_ROW_COUNT | |
    |                         | MP_UINT: changed row count  | |
    |                         |                             | |
    |                         +~~~~~~~~~~~~~~~~~~~~~~~~~~~~~+ |
    |                                                         |
    +=========================================================+
