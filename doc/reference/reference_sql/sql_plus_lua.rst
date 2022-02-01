.. _sql_plus_lua:

--------------------------------------------------------------------------------
SQL PLUS LUA -- Adding Tarantool/NoSQL to Tarantool/SQL
--------------------------------------------------------------------------------

The Adding Tarantool/NoSQL To Tarantool/SQL Guide contains descriptions of NoSQL
database objects that can be accessed from SQL, of SQL database objects that can
be accessed from NoSQL, of the way to call SQL from Lua, and of the way to call
Lua from SQL.


.. list-table::
   :widths: 50 50
   :header-rows: 1
   :align: left

   * - Heading
     - Summary
   * - :ref:`Lua requests <sql_lua_requests>`
     - Some Lua requests that are especially useful for
       SQL, such as requests to grant privileges
   * - :ref:`System tables <sql_system_tables>`
     - Looking at Lua sysview spaces such as _space
   * - :ref:`Calling Lua routines from SQL <sql_calling_lua>`
     - Tarantool's implementation of SQL stored procedures
   * - :ref:`Executing Lua chunks <sql_executing_lua_chunks>`
     - The LUA(...) function
   * - :ref:`Example sessions <sql_example_sessions>`
     - Million-row insert, etc.
   * - :ref:`Lua functions to make views of metadata <sql_lua_functions>`
     - Making equivalents to standard-SQL information_schema tables

.. COMMENT
   The next section is adapted from
   https://docs.google.com/document/d/1rzJFUePFIVqgCxLax8naYj4qDN2Vp56c6ctj2ae288I/edit#

.. _sql_lua_requests:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Lua Requests
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

A great deal of functionality is not specifically part of Tarantool's SQL feature,
but is part of the Tarantool Lua application server and DBMS.
Here are some examples so it is clear where to look in other sections of the Tarantool manual.

NoSQL :ref:`"spaces" <index-box_space>` can be accessed as SQL ``"tables"``, and vice versa.
For example, suppose a table has been created with |br|
``CREATE TABLE things (id INTEGER PRIMARY KEY, remark SCALAR);``

This is viewable from Tarantool's NoSQL feature as a memtx space named THINGS with a primary-key
:ref:`TREE index <index-box_index>` ...

.. code-block:: tarantoolsession

    tarantool> box.space.THINGS
    ---
    - engine: memtx
      before_replace: 'function: 0x40bb4608'
      on_replace: 'function: 0x40bb45e0'
      ck_constraint: []
      field_count: 2
      temporary: false
      index:
        0: &0
          unique: true
          parts:
         - type: integer
            is_nullable: false
            fieldno: 1
          id: 0
          space_id: 520
          type: TREE
          name: pk_unnamed_THINGS_1
        pk_unnamed_THINGS_1: *0
      is_local: false
      enabled: true
      name: THINGS
      id: 520

The NoSQL :ref:`basic data operation requests <index-box_data-operations>`
select, insert, replace, upsert, update, delete will all work.
Particularly interesting are the requests that come only via NoSQL.

To create an index on things (remark) with a non-default :ref:`option <box_space-create_index-options>` for example a special id, say: |br|
``box.space.THINGS:create_index('idx_100_things_2', {id=100, parts={2, 'scalar'}})``

(If the SQL data type name is SCALAR, then the NoSQL type is 'scalar',
as described earlier. See the chart in section :ref:`Operands <sql_operands>`.)

To :doc:`grant </reference/reference_lua/box_schema/user_grant>`
database-access privileges to user 'guest', say |br|
``box.schema.user.grant('guest', 'execute', 'universe')`` |br|
To grant SELECT privileges on table things to user 'guest', say |br|
``box.schema.user.grant('guest',  'read', 'space', 'THINGS')`` |br|
To grant UPDATE privileges on table things to user 'guest', say: |br|
``box.schema.user.grant('guest', 'read,write', 'space', 'THINGS')`` |br|
To grant DELETE or INSERT privileges on table things if no reading is involved, say: |br|
``box.schema.user.grant('guest', 'write', 'space', 'THINGS')`` |br|
To grant DELETE or INSERT privileges on table things if reading is involved, say: |br|
``box.schema.user.grant('guest',  'read,write',  'space',  'THINGS')`` |br|
To grant CREATE TABLE privilege to user 'guest', say |br|
``box.schema.user.grant('guest', 'read,write', 'space', '_schema')`` |br|
``box.schema.user.grant('guest', 'read,write', 'space', '_space')`` |br|
``box.schema.user.grant('guest', 'read,write', 'space', '_index')`` |br|
``box.schema.user.grant('guest', 'create', 'space')`` |br|
To grant CREATE TRIGGER privilege to user 'guest', say |br|
``box.schema.user.grant('guest', 'read', 'space', '_space')`` |br|
``box.schema.user.grant('guest', 'read,write', 'space', '_trigger')`` |br|
To grant CREATE INDEX privilege to user 'guest', say |br|
``box.schema.user.grant('guest', 'read,write', 'space', '_index')`` |br|
``box.schema.user.grant('guest', 'create', 'space')`` |br|
To grant CREATE TABLE ... INTEGER PRIMARY KEY AUTOINCREMENT to user 'guest', say |br|
``box.schema.user.grant('guest', 'read,write', 'space', '_schema')`` |br|
``box.schema.user.grant('guest', 'read,write', 'space', '_space')`` |br|
``box.schema.user.grant('guest', 'read,write', 'space', '_index')`` |br|
``box.schema.user.grant('guest', 'create', 'space')`` |br|
``box.schema.user.grant('guest', 'read,write', 'space', '_space_sequence')`` |br|
``box.schema.user.grant('guest', 'read,write', 'space', '_sequence')`` |br|
``box.schema.user.grant('guest', 'create', 'sequence')`` |br|

To write a stored procedure that inserts 5 rows in things, say |br|
``function f() for i = 3, 7 do box.space.THINGS:insert{i, i} end end`` |br|
For client-side API functions, see section :ref:`"Connectors" <index-box_connectors>`.

To make spaces with field names that SQL can understand, use
:ref:`space_object:format() <box_space-format>`.
(Exception: in Tarantool/NoSQL it is legal for tuples to have more fields than are described by a format clause,
but in Tarantool/SQL such fields will be ignored.)

To handle replication and sharding of SQL data, see section
:ref:`Sharding <vshard-summary>`.

To enhance performance of SQL statements by preparing them in advance, see section
:ref:`box.prepare() <box-sql_box_prepare>`.

To call SQL from Lua, see section
:ref:`box.execute([[...]]) <box-sql>`.

Limitations: (`Issue#2368 <https://github.com/tarantool/tarantool/issues/2368>`_) |br|
* after ``box.schema.user.grant('guest','read,write,execute','universe')``, user ``'guest'`` can create tables. But this is a powerful set of privileges.

Limitations: (`Issue#4659 <https://github.com/tarantool/tarantool/issues/4659>`_,
`Issue#4757 <https://github.com/tarantool/tarantool/issues/4757>`_, 
`Issue#4758 <https://github.com/tarantool/tarantool/issues/4758>`_) |br|
SELECT with * or ORDER BY or GROUP BY from spaces that have map fields
or array fields may cause errors. Any access to spaces that have hash
indexes may cause severe errors in Tarantool version 2.3 or earlier.

.. _sql_system_tables:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
System Tables
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

There is a way to get some information about the database objects,
for example the names of all the tables and their indexes, using
:ref:`SELECT statements <sql_select>`.
This is done by looking at special read-only tables which Tarantool updates
automatically whenever objects are created or dropped.
See the :ref:`submodule box.space <box_space>` overview section.
Names of system tables are in lower case so always enclose them in ``"quotes"``.

For example, the :ref:`_space <box_space-space>` system table has these fields which are seen in SQL as columns: |br|
|nbsp|  id = numeric identifier |br|
|nbsp|  owner = for example, 1 if the object was made by the ``'admin'`` user |br|
|nbsp|  name = the name that was used with :ref:`CREATE TABLE <sql_create_table>` |br|
|nbsp|  engine = usually ``'memtx'`` (the ``'vinyl'`` engine can be used but is not default) |br|
|nbsp|  field_count = sometimes 0, but usually a count of the table's columns |br|
|nbsp|  flags = usually empty |br|
|nbsp|  format = what a Lua format() function or an SQL CREATE statement produced |br|
Example selection: |br|
|nbsp|  ``SELECT "id", "name" FROM "_space";``

See also: :ref:`Lua functions to make views of metadata <sql_lua_functions>`.

.. COMMENT:
   BOX.INTERNAL.COLLATION.CREATE MAY BE BUGGY AND MAY BE UNNECESSARY.
   FORMAL APPROVAL IS NEEDED BEFORE PUBLISHING THIS SECTION.

   .. _sql_box_internal_collation_create:

   ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   box.internal.collation.create
   ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

   The box.internal.collation.create Lua function can be used to identify a
   :ref:`collation <index-collation>`.
   It does not actually "create" a collation (collations already exist and are supported in the library),
   it specifies the name that will be used in Tarantool SQL statements and the characteristics associated with that name.

   The many pre-defined collations including 'unicode' and 'unicode_ci' are part of the default Unicode specification,
   and the default Unicode specification is almost always good for common languages such as English and Russian.
   Additionally the default predefined collation 'binary'  is good for speed and compatible with the
   standard-SQL requirement for a collation that is in order by code point.
   Therefore box.internal.collation.create is usually not necessary.
   It is designated "internal" which means end users should not be encouraged to use it without careful consultation.

   Format: :samp:`box.internal.collation.create ({name}, {type}, {locale} [,` :code:`{` :samp:`{opts}` :code:`}])`

   Name is the string that can be subsequently used in COLLATE clauses.
   Typically the name will show what the language is or what the strength is.
   Example: swedish_s1 for a Swedish primary-strength collation.

   Type is always 'ICU' (International Components for Unicode).

   Locale should be a two-letter language code, then a hyphen '-' or underscore '_',
   then a two-letter country code. The language code and country code should be according
   to the BCP 47 standard. https://tools.ietf.org/html/bcp47
   There is no validity check so it is the user's responsibility to ensure the input is valid.
   Examples: 'zh-CN' (Chinese as used in China), 'de_DE' (German as used in Germany).

   Opts should be one of the not-deprecated options according to
   ICU http://icu-project.org/apiref/icu4c/ucol_8h.html#a583fbe7fc4a850e2fcc692e766d2826c without the ``UCOL_`` prefix, so: |br|
   french_collation = on | off |br|
   alternate_handling = non_ignorable | shifted |br|
   case_first = off  | upper_first | lower_first (default is off which usually means upper_first) |br|
   case_level = off  | on (default is off) |br|
   normalization_mode = off | on |br|
   strength = primary | secondary | tertiary | quaternary | identical (default is identical) |br|
   numeric_collation = off | on (default is off) |br|
   The important option is 'strength'.
   Commonly a 'primary' strength is good for searching (so that WHERE x = 'a' will find 'A' and 'ą́')
   and a 'tertiary' strength is good for sorting (so that 'a' will come before 'A' which will come before 'ą́').

   If box.internal.collation.create is successful, there will be a new entry in the "_collation" space
   and the clause COLLATE "name" will work.
   Never drop or change a collation which is being used for indexes or deterministic functions.

   Example:
   Suppose there is a desire to use a non-default collation which has Ukrainian rules.
   There are many deviations from DUCET, all formally described by the Common Language Data Repository,
   in this case https://unicode.org/cldr/charts/32/collation/uk.html.
   Two notable deviations are: Ґ is a separate letter after Г and Ь is before Ю.
   In addition there is a desire that upper case letters should come before lower case letters.
   The Lua request for this collation could be: |br|
   ``box.internal.collation.create('UKRAINIAN_S3', 'ICU', 'uk_UK', {strength='tertiary', case_first = 'upper_first'});``

   Then say |br|
   ``CREATE TABLE things (remark STRING PRIMARY KEY);
   ``INSERT INTO things VALUES ('Гю'), ('Ґу'), ('гуя'), ('ГУЯ');``
   ``SELECT remark FROM things ORDER BY remark COLLATE "unicode";``
   ``SELECT remark FROM things ORDER BY remark COLLATE ukrainian_s3;``

   The result with COLLATE "unicode" will be: Ґу гуя ГУЯ Гю.
   The result with COLLATE ukrainian_s3 will be: ГУЯ гуя Гю Ґу.

   Since there are 736 CLDR specifications
   http://unicode.org/repos/cldr/trunk/common/main/,
   and each specification usually has about 2 variants, and there are 5 possible strengths,
   and 2**6 possibilities for the other opts options, Tarantool supports
   about 736 * 2 * 5 * 64 = 471,040 different collations out of the box.
   In fact three of the pre-defined collations (unicode_uk_s1 unicode_uk_s2 unicode_uk_s3)
   are the standard CLDR variants for Ukrainian, so the above example was
   made only to show how one makes a new one, not because there is any need to do so for this situation.

   Limitations:
   Collations cannot be maintained by deleting them (with box.space._collation:delete) and creating them again.
   For example this is not recommended: |br|
   ``box.internal.collation.create('UNICODE_3', 'ICU', 'uk_UK', {});``
   ``box.execute([[CREATE TABLE things (id INTEGER PRIMARY KEY, remark STRING COLLATE UNICODE_3);]])``
   ``box.execute([[INSERT INTO things VALUES (2, 'a');]])``
   ``-- change 277 to id of the new collation``
   ``box.space._collation:delete(277)``
   ``box.internal.collation.create('UNICODE_3', 'ICU', 'uk_UK', {});``
   ``box.execute([[SELECT * FROM things WHERE remark = 'a';]])``
   It will not cause an immediate error, but read the warning at the start of this section.
   Use only documented technique.

.. _sql_calling_lua:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Calling Lua routines from SQL
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

SQL statements can invoke functions that are written in Lua.
This is Tarantool's equivalent for the "stored procedure" feature found in other SQL DBMSs.
Tarantool server-side stored procedures are written in Lua rather than SQL/PSM dialect.

Functions can be invoked anywhere that the SQL syntax allows a literal or a column name for reading.
Function parameters can include any number of SQL values.
If a SELECT statement's result set has a million rows, and the
:ref:`select list <sql_select_list>` invokes a non-deterministic function,
then the function is called a million times.

To create a Lua function that you can call from SQL, use
:ref:`box.schema.func.create(func-name, {options-with-body}) <box_schema-func_create_with-body>`
with these additional options:

``exports = {'LUA', 'SQL'}`` -- This indicates what languages can call the function.
The default is ``'LUA'``. Specify both: ``'LUA', 'SQL'``.

``param_list = {list}`` -- This is the list of parameters.
Specify the Lua type names for each parameter of the function.
Remember that a Lua type name is
:ref:`the same as <sql_operands>` an SQL data type name, in lower case.
The Lua type should not be an array.

Also it is good to specify ``{deterministic = true}`` if possible,
because that may allow Tarantool to generate more efficient SQL byte code.

For a useful example, here is a general function for decoding a single Lua ``'map'`` field:

.. code-block:: lua

    box.schema.func.create('_DECODE',
       {language = 'LUA',
        returns = 'string',
        body = [[function (field, key)
                 -- If Tarantool version < 2.10.1, replace next line with
                 -- return require('msgpack').decode(field)[key]
                 return field[key]
                 end]],
        is_sandboxed = false,
        -- If Tarantool version < 2.10.1, replace next line with
        -- param_list = {'string', 'string'},
        param_list = {'map', 'string'},
        exports = {'LUA', 'SQL'},
        is_deterministic = true})

See it work with, say, the _trigger space.
That space has a ``'map'`` field named opts which has a key named sql.
By selecting from the space and passing the field and the key name to _DECODE,
you can get a list of all the trigger bodies.

.. code-block:: lua

    box.execute([[SELECT _decode("opts", 'sql') FROM "_trigger";]])

Remember that SQL converts :ref:`regular identifiers <sql_identifiers>` to upper case,
so this example works with a function named _DECODE.
If the function had been named _decode, then the SELECT statement would have to be: |br|
``box.execute([[SELECT "_decode"("opts", 'sql') FROM "_trigger";]])``

Here is another example, which illustrates the way that Tarantool creates
a view which includes the table_name and table_type columns in the same
way that the standard-SQL information_schema.tables view contains them.
The difficulty is that, in order to discover whether table_type should
be ``'BASE TABLE'`` or should be ``'VIEW'``, it is necessary to know the value of the
``"flags"`` field in the Tarantool/NoSQL :ref:`"_space" <box_space-space>` or ``"_vspace"`` space.
The ``"flags"`` field type is ``"map"``, which SQL does not understand well.
If there were no Lua functions, it would be necessary to treat the field as a VARBINARY
and look for ``POSITION(X'A476696577C3',"flags")  > 0`` (A4 is a MsgPack signal
that a 4-byte string follows, 76696577 is UTF8 encoding for 'view',
C3 is a MsgPack code meaning true).
In any case, starting with Tarantool version 2.10, POSITION() does not work on VARBINARY operands.
But there is a more sophisticated way, namely, creating a function that
returns true if ``"flags".view`` is true.
So for this case the way to make the function looks like this:

.. code-block:: lua

    box.schema.func.create('TABLES_IS_VIEW',
         {language = 'LUA',
          returns = 'boolean',
          body = [[function (flags)
              local view
              -- If Tarantool version < 2.10.1, replace next line with
              -- view = require('msgpack').decode(flags).view
              view = flags.view
              if view == nil then return false end
              return view
              end]],
         is_sandboxed = false,
         -- If Tarantool version < 2.10.1, replace next line with
         -- param_list = {'string'},
         param_list = {'map'},
         exports = {'LUA', 'SQL'},
         is_deterministic = true})

And this creates the view:

.. code-block:: lua

    box.execute([[
    CREATE VIEW vtables AS SELECT
    "name" AS table_name,
    CASE WHEN tables_is_view("flags") == TRUE THEN 'VIEW'
         ELSE 'BASE TABLE' END AS table_type,
    "id" AS id,
    "engine" AS engine,
    (SELECT "name" FROM "_vuser" x
     WHERE x."id" = y."owner") AS owner,
    "field_count" AS field_count
    FROM "_vspace" y;
    ]])

Remember that these Lua functions are persistent, so if the server has to be restarted then they do not have to be re-declared.

.. _sql_executing_lua_chunks:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Executing Lua chunks
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

To execute Lua code without creating a function, use: |br|
:samp:`LUA({Lua-code-string})` |br|
where Lua-code-string is any amount of Lua code.
The string should begin with ``'return '``.

For example this will show the number of seconds since the epoch: |br|
``box.execute([[SELECT lua('return os.time()');]])`` |br|
For example this will show a database configuration member: |br|
``box.execute([[SELECT lua('return box.cfg.memtx_memory');]])`` |br|
For example this will return FALSE because Lua nil and box.NULL are the same as SQL NULL: |br|
``box.execute([[SELECT lua('return box.NULL') IS NOT NULL;]])``

Warning: the SQL statement must not invoke a Lua function, or execute a Lua chunk,
that accesses a space that underlies any SQL table that the SQL statement accesses.
For example, if function ``f()`` contains a request ``"box.space.TEST:insert{0}"``,
then the SQL statement ``"SELECT f() FROM test;"`` will try to access the same space in two ways.
The results of such conflict may include a hang or an infinite loop.

.. _sql_example_sessions:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Example Sessions
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

********************************************************************************
Example Session -- Create, Insert, Select
********************************************************************************

Assume that the task is to create two tables, put some rows in each table,
create a :ref:`view <sql_create_view>` that is based on a join of the tables,
then select from the view all rows where the second column values
are not null, ordered by the first column.

That is, the way to populate the table is |br|
``CREATE TABLE t1 (c1 INTEGER PRIMARY KEY, c2 STRING);`` |br|
``CREATE TABLE t2 (c1 INTEGER PRIMARY KEY, x2 STRING);`` |br|
``INSERT INTO t1 VALUES (1, 'A'), (2, 'B'), (3, 'C');`` |br|
``INSERT INTO t1 VALUES (4, 'D'), (5, 'E'), (6, 'F');`` |br|
``INSERT INTO t2 VALUES (1, 'C'), (4, 'A'), (6, NULL);`` |br|
``CREATE VIEW v AS SELECT * FROM t1 NATURAL JOIN t2;`` |br|
``SELECT * FROM v WHERE c2 IS NOT NULL ORDER BY c1;``

So the session looks like this: |br|
``box.cfg{}`` |br|
``box.execute([[CREATE TABLE t1 (c1 INTEGER PRIMARY KEY, c2 STRING);]])`` |br|
``box.execute([[CREATE TABLE t2 (c1 INTEGER PRIMARY KEY, x2 STRING);]])`` |br|
``box.execute([[INSERT INTO t1 VALUES (1, 'A'), (2, 'B'), (3, 'C');]])`` |br|
``box.execute([[INSERT INTO t1 VALUES (4, 'D'), (5, 'E'), (6, 'F');]])`` |br|
``box.execute([[INSERT INTO t2 VALUES (1, 'C'), (4, 'A'), (6, NULL);]])`` |br|
``box.execute([[CREATE VIEW v AS SELECT * FROM t1 NATURAL JOIN t2;]])`` |br|
``box.execute([[SELECT * FROM v WHERE c2 IS NOT NULL ORDER BY c1;]])``

If one executes the above requests with Tarantool as a client, provided the database
objects do not already exist, the execution will be successful and the final display will be

.. code-block:: tarantoolsession

   tarantool> box.execute([[SELECT * FROM v WHERE c2 IS NOT NULL ORDER BY c1;]])
   ---
   - - [1, 'A', 'C']
   - [4, 'D', 'A']
   - [6, 'F', null]

********************************************************************************
Example Session -- Get a List of Columns
********************************************************************************

Here  is a function which will create a table that contains
a list of all the columns and their Lua types, for all tables.
It is not a necessary function because one can create a
:ref:`_COLUMNS view <sql__columns_view>` instead.
It merely shows, with simpler Lua code, how to make a base table instead of a view.

.. code-block:: lua

    function create_information_schema_columns()
      box.execute([[DROP TABLE IF EXISTS information_schema_columns;]])
      box.execute([[CREATE TABLE information_schema_columns (
                        table_name STRING,
                        column_name STRING,
                        ordinal_position INTEGER,
                        data_type STRING,
                        PRIMARY KEY (table_name, column_name));]]);
      local space = box.space._vspace:select()
      local sqlstring = ''
      for i = 1, #space do
          for j = 1, #space[i][7] do
              sqlstring = "INSERT INTO information_schema_columns VALUES ("
                      .. "'" .. space[i][3] .. "'"
                      .. ","
                      .. "'" .. space[i][7][j].name .. "'"
                      .. ","
                      .. j
                      .. ","
                      .. "'" .. space[i][7][j].type .. "'"
                      .. ");"
              box.execute(sqlstring)
          end
      end
      return
    end

If you now execute the function by saying |br|
``create_information_schema_columns()`` |br|
you will see that there is a table named information_schema_columns
containing table_name and column_name and ordinal_position and data_type for everything that was accessible. 

********************************************************************************
Example Session -- Million-Row Insert
********************************************************************************

Here is a variation of the Lua tutorial
:ref:`"Insert one million tuples with a Lua stored procedure" <c_lua_tutorial-insert_one_million_tuples>`.
The differences are: the creation is done with an SQL
:ref:`CREATE TABLE statement <sql_create_table>`,
and the inserting is done with an SQL :ref:`INSERT statement <sql_insert>`. 
Otherwise, it is the same. It is the same because Lua and SQL are compatible,
just as Lua and NoSQL are compatible.

.. code-block:: lua

    box.execute([[CREATE TABLE tester (s1 INTEGER PRIMARY KEY, s2 STRING);]])

    function string_function()
      local random_number
      local random_string
      random_string = ""
      for x = 1,10,1 do
        random_number = math.random(65, 90)
        random_string = random_string .. string.char(random_number)
      end
      return random_string
    end

    function main_function()
        local string_value, t, sql_statement
        for i = 1,1000000, 1 do
        string_value = string_function()
        sql_statement = "INSERT INTO tester VALUES (" .. i .. ",'" .. string_value .. "');"
        box.execute(sql_statement)
        end
    end
    start_time = os.clock()
    main_function()
    end_time = os.clock()
    'insert done in ' .. end_time - start_time .. ' seconds'

Limitations:
The function takes more time than the original (Tarantool/NoSQL).

.. _sql_lua_functions:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Lua functions to make views of metadata
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Tarantool does not include all the standard-SQL
`information_schema <https://en.wikipedia.org/wiki/information_schema>`_
views, which are for looking at metadata, that is, "data about the data".
But here is the Lua code and SQL code for creating equivalents: |br|
:ref:`_TABLES <sql__tables_view>` nearly equivalent to INFORMATION_SCHEMA.TABLES |br|
:ref:`_COLUMNS <sql__columns_view>` nearly equivalent to INFORMATION_SCHEMA.COLUMNS |br|
:ref:`_VIEWS <sql__views_view>` nearly equivalent to INFORMATION_SCHEMA.VIEWS |br|
:ref:`_TRIGGERS <sql__triggers_view>` nearly equivalent to INFORMATION_SCHEMA.TRIGGERS |br|
:ref:`_REFERENTIAL_CONSTRAINTS <sql__referential_constraints_view>` nearly equivalent to INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS |br|
:ref:`_CHECK_CONSTRAINTS <sql__check_constraints_view>` nearly equivalent to INFORMATION_SCHEMA.CHECK_CONSTRAINTS |br|
:ref:`_TABLE_CONSTRAINTS <sql__table_constraints_view>` nearly equivalent to INFORMATION_SCHEMA.TABLE_CONSTRAINTS. |br|
For each view there will be an example of a SELECT from the view, and the code.
Users who want metadata can simply copy the code.
Use this code only with Tarantool version 2.3.0 or later.
With an earlier Tarantool version, a :ref:`PRAGMA statement <sql_pragma>` may be useful.

.. _sql__tables_view:

********************************************************************************
_TABLES view
********************************************************************************

Example:

.. code-block:: none

    tarantool>SELECT * FROM _tables WHERE id > 340 LIMIT 5;
    OK 5 rows selected (0.0 seconds)
    +---------------+--------------+----------------+------------+-----+--------+-------+-------------+
    | TABLE_CATALOG | TABLE_SCHEMA | TABLE_NAME     | TABLE_TYPE | ID  | ENGINE | OWNER | FIELD_COUNT |
    +---------------+--------------+----------------+------------+-----+--------+-------+-------------+
    | NULL          | NULL         | _fk_constraint | BASE TABLE | 356 | memtx  | admin |        0    |
    | NULL          | NULL         | _ck_constraint | BASE TABLE | 364 | memtx  | admin |        0    |
    | NULL          | NULL         | _func_index    | BASE TABLE | 372 | memtx  | admin |        0    |
    | NULL          | NULL         | _COLUMNS       | VIEW       | 513 | memtx  | admin |        8    |
    | NULL          | NULL         | _VIEWS         | VIEW       | 514 | memtx  | admin |        7    |
    +---------------+--------------+----------------+------------+-----+--------+-------+-------------+

Definition of the function and the CREATE VIEW statement:

.. code-block:: lua

    box.schema.func.drop('_TABLES_IS_VIEW',{if_exists = true})
    box.schema.func.create('_TABLES_IS_VIEW',
         {language = 'LUA',
          returns = 'boolean',
          body = [[function (flags)
              local view
              -- If Tarantool version < 2.10.1, replace next line with
              -- view = require('msgpack').decode(flags).view
              view = flags.view
              if view == nil then return false end
              return view
              end]],
         is_sandboxed = false,
         -- If Tarantool version < 2.10.1, replace next line with
         -- param_list = {'string'},
         param_list = {'map'},
         exports = {'LUA', 'SQL'},
         is_deterministic = true})
    box.schema.role.grant('public', 'execute', 'function', '_TABLES_IS_VIEW')
    pcall(function ()
        box.schema.role.revoke('public', 'read', 'space', '_TABLES', {if_exists = true})
        end)
    box.execute([[DROP VIEW IF EXISTS _tables;]])
    box.execute([[
    CREATE VIEW _tables AS SELECT
        CAST(NULL AS STRING) AS table_catalog,
        CAST(NULL AS STRING) AS table_schema,
        "name" AS table_name,
        CASE
            WHEN _tables_is_view("flags") = TRUE THEN 'VIEW'
            ELSE 'BASE TABLE' END
            AS table_type,
        "id" AS id,
        "engine" AS engine,
        (SELECT "name" FROM "_vuser" x WHERE x."id" = y."owner") AS owner,
        "field_count" AS field_count
    FROM "_vspace" y;
    ]])
    box.schema.role.grant('public', 'read', 'space', '_TABLES')

.. _sql__columns_view:

********************************************************************************
_COLUMNS view
********************************************************************************

This is also an example of how one can use :ref:`recursive views <sql_with>` to make temporary tables
with multiple rows for each tuple in the original ``"_vspace"`` space.
It requires a global variable, _G.box.FORMATS, as a temporary static variable.

Warning: Use this code only with Tarantool version 2.3.2 or later.
Use with earlier versions will cause an assertion.
See `Issue#4504 <https://github.com/tarantool/tarantool/issues/4504>`_.

Example:

.. code-block:: none

    tarantool>SELECT * FROM _columns WHERE ordinal_position = 9;
    OK 6 rows selected (0.0 seconds)
    +--------------+-------------+--------------------------+--------------+------------------+-------------+-----------+-----+
    | CATALOG_NAME | SCHEMA_NAME | TABLE_NAME               | COLUMN_NAME  | ORDINAL_POSITION | IS_NULLABLE | DATA_TYPE | ID  |
    +--------------+-------------+--------------------------+--------------+------------------+-------------+-----------+-----+
    | NULL         | NULL        | _sequence                | cycle        |                9 | YES         | boolean   | 284 |
    | NULL         | NULL        | _vsequence               | cycle        |                9 | YES         | boolean   | 286 |
    | NULL         | NULL        | _func                    | returns      |                9   YES           string    | 296 |
    | NULL         | NULL        | _fk_constraint           | parent_cols  |                9 | YES         | array     | 356 |
    | NULL         | NULL        | _REFERENTIAL_CONSTRAINTS | MATCH_OPTION |                9 | YES         | string    | 518 |
    +--------------+-------------+--------------------------+--------------+------------------+-------------+-----------+-----+

Definition of the function and the CREATE VIEW statement:

.. code-block:: lua

    box.schema.func.drop('_COLUMNS_FORMATS', {if_exists = true})
    box.schema.func.create('_COLUMNS_FORMATS',
        {language = 'LUA',
         returns = 'scalar',
         body = [[
         function (row_number_, ordinal_position)
             if row_number_ == 0 then
                 _G.box.FORMATS = {}
                 local vspace = box.space._vspace:select()
                 for i = 1, #vspace do
                     local format = vspace[i]["format"]
                     for j = 1, #format do
                         local is_nullable = 'YES'
                         if format[j].is_nullable == false then
                             is_nullable = 'NO'
                         end
                         table.insert(_G.box.FORMATS,
                                      {vspace[i].name, format[j].name, j,
                                       is_nullable, format[j].type, vspace[i].id})
                     end
                 end
                 return ''
             end
             if row_number_ > #_G.box.FORMATS then
                 _G.box.FORMATS = {}
                 return ''
             end
             return _G.box.FORMATS[row_number_][ordinal_position]
         end
         ]],
        param_list = {'integer', 'integer'},
        exports = {'LUA', 'SQL'},
        is_sandboxed = false,
        setuid = false,
        is_deterministic = false})
    box.schema.role.grant('public', 'execute', 'function', '_COLUMNS_FORMATS')

    pcall(function ()
        box.schema.role.revoke('public', 'read', 'space', '_COLUMNS', {if_exists = true})
        end)
    box.execute([[DROP VIEW IF EXISTS _columns;]])
    box.execute([[
    CREATE VIEW _columns AS
    WITH RECURSIVE r_columns AS
    (
    SELECT 0 AS row_number_,
          '' AS table_name,
          '' AS column_name,
          0 AS ordinal_position,
          '' AS is_nullable,
          '' AS data_type,
          0 AS id
    UNION ALL
    SELECT row_number_ + 1 AS row_number_,
           _columns_formats(row_number_, 1) AS table_name,
           _columns_formats(row_number_, 2) AS column_name,
           _columns_formats(row_number_, 3) AS ordinal_position,
           _columns_formats(row_number_, 4) AS is_nullable,
           _columns_formats(row_number_, 5) AS data_type,
           _columns_formats(row_number_, 6) AS id
        FROM r_columns
        WHERE row_number_ == 0 OR row_number_ <= lua('return #_G.box.FORMATS + 1')
    )
    SELECT CAST(NULL AS STRING) AS catalog_name,
           CAST(NULL AS STRING) AS schema_name,
           table_name,
           column_name,
           ordinal_position,
           is_nullable,
           data_type,
           id
        FROM r_columns
        WHERE data_type <> '';
    ]])
    box.schema.role.grant('public', 'read', 'space', '_COLUMNS')

.. _sql__views_view:

********************************************************************************
_VIEWS view
********************************************************************************

Example:

.. code-block:: none

    tarantool>SELECT table_name, substr(view_definition,1,20), id, owner, field_count FROM _views LIMIT 5;
    OK 5 rows selected (0.0 seconds)
    +--------------------------+------------------------------+-----+-------+-------------+
    | TABLE_NAME               | SUBSTR(VIEW_DEFINITION,1,20) | ID  | OWNER | FIELD_COUNT |
    +--------------------------+------------------------------+-----+-------+-------------+
    | _COLUMNS                 | CREATE VIEW _columns         | 513 | admin |           8 |
    | _TRIGGERS                | CREATE VIEW _trigger         | 515 | admin |           4 |
    | _CHECK_CONSTRAINTS       | CREATE VIEW _check_c         | 517 | admin |           8 |
    | _REFERENTIAL_CONSTRAINTS | CREATE VIEW _referen         | 518 | admin |          12 |
    | _TABLE_CONSTRAINTS       | CREATE VIEW _table_c         | 519 | admin |          11 |
    +--------------------------+------------------------------+-----+-------+-------------+

Definition of the function and the CREATE VIEW statement:

.. code-block:: lua

    box.schema.func.drop('_VIEWS_DEFINITION',{if_exists = true})
    box.schema.func.create('_VIEWS_DEFINITION',
        {language = 'LUA',
         returns = 'string',
         body = [[function (flags)
                  -- If Tarantool version < 2.10.1, replace next line with
                  -- return require('msgpack').decode(flags).sql
                  return flags.sql
                  end]],
         -- If Tarantool version < 2.10.1, replace next line with
         -- param_list = {'string'},
         param_list = {'map'},
         exports = {'LUA', 'SQL'},
         is_sandboxed = false,
         setuid = false,
         is_deterministic = false})
    box.schema.role.grant('public', 'execute', 'function', '_VIEWS_DEFINITION')
    pcall(function ()
        box.schema.role.revoke('public', 'read', 'space', '_VIEWS', {if_exists = true})
        end)
    box.execute([[DROP VIEW IF EXISTS _views;]])
    box.execute([[
    CREATE VIEW _views AS SELECT
        CAST(NULL AS STRING) AS table_catalog,
        CAST(NULL AS STRING) AS table_schema,
        "name" AS table_name,
        CAST(_views_definition("flags") AS STRING) AS VIEW_DEFINITION,
        "id" AS id,
        (SELECT "name" FROM "_vuser" x WHERE x."id" = y."owner") AS owner,
        "field_count" AS field_count
        FROM "_vspace" y
        WHERE _tables_is_view("flags") = TRUE;
    ]])
    box.schema.role.grant('public', 'read', 'space', '_VIEWS')

_TABLES_IS_VIEW() was described earlier, see :ref:`_TABLES view <sql__tables_view>`.

.. _sql__triggers_view:

********************************************************************************
_TRIGGERS view
********************************************************************************

Example:

.. code-block:: none

    tarantool>SELECT trigger_name, opts_sql FROM _triggers;
    OK 2 rows selected (0.0 seconds)
    +--------------+-------------------------------------------------------------------------------------------------+
    | TRIGGER_NAME | OPTS_SQL                                                                                        |
    +--------------+-------------------------------------------------------------------------------------------------+
    | THINGS1_AD   | CREATE TRIGGER things1_ad AFTER DELETE ON things1 FOR EACH ROW BEGIN DELETE FROM things2; END;  |
    | THINGS1_BI   | CREATE TRIGGER things1_bi BEFORE INSERT ON things1 FOR EACH ROW BEGIN DELETE FROM things2; END; |
    +--------------+-------------------------------------------------------------------------------------------------+

Definition of the function and the CREATE VIEW statement:

.. code-block:: lua

    box.schema.func.drop('_TRIGGERS_OPTS_SQL',{if_exists = true})
    box.schema.func.create('_TRIGGERS_OPTS_SQL',
        {language = 'LUA',
         returns = 'string',
         body = [[function (opts)
                  -- If Tarantool version < 2.10.1, replace next line with
                  -- return require('msgpack').decode(opts).sql
                  return opts.sql
                  end]],
         -- If Tarantool version < 2.10.1, replace next line with
         -- param_list = {'string'},
         param_list = {'map'},
         exports = {'LUA', 'SQL'},
         is_sandboxed = false,
         setuid = false,
         is_deterministic = false})
    box.schema.role.grant('public', 'execute', 'function', '_TRIGGERS_OPTS_SQL')
    pcall(function ()
        box.schema.role.revoke('public', 'read', 'space', '_TRIGGERS', {if_exists = true})
        end)
    box.execute([[DROP VIEW IF EXISTS _triggers;]])
    box.execute([[
    CREATE VIEW _triggers AS SELECT
        CAST(NULL AS STRING) AS trigger_catalog,
        CAST(NULL AS STRING) AS trigger_schema,
        "name" AS trigger_name,
        CAST(_triggers_opts_sql("opts") AS STRING) AS opts_sql,
        "space_id" AS space_id
        FROM "_trigger";
    ]])
    box.schema.role.grant('public', 'read', 'space', '_TRIGGERS')

Users who select from this view will need 'read' privilege on the _trigger space.

.. _sql__referential_constraints_view:

********************************************************************************
_REFERENTIAL_CONSTRAINTS view
********************************************************************************

Example:

.. code-block:: none

    tarantool>SELECT constraint_name, update_rule, delete_rule, match_option,
    > referencing, referenced
    > FROM _referential_constraints;
    OK 2 rows selected (0.0 seconds)
    +----------------------+-------------+-------------+--------------+-------------+------------+
    | CONSTRAINT_NAME      | UPDATE_RULE | DELETE_RULE | MATCH_OPTION | REFERENCING | REFERENCED |
    +----------------------+-------------+-------------+--------------+-------------+------------+
    | fk_unnamed_THINGS2_1 | no_action   | no_action   | simple       | THINGS2     | THINGS1    |
    | fk_unnamed_THINGS3_1 | no_action   | no_action   | simple       | THINGS3     | THINGS1    |
    +----------------------+-------------+-------------+--------------+-------------+------------+

Definition of the CREATE VIEW statement:

.. code-block:: lua

    pcall(function ()
        box.schema.role.revoke('public', 'read', 'space', '_REFERENTIAL_CONSTRAINTS', {if_exists = true})
        end)
    box.execute([[DROP VIEW IF EXISTS _referential_constraints;]])
    box.execute([[
    CREATE VIEW _referential_constraints AS SELECT
        CAST(NULL AS STRING) AS constraint_catalog,
        CAST(NULL AS STRING) AS constraint_schema,
        "name" AS constraint_name,
        CAST(NULL AS STRING) AS unique_constraint_catalog,
        CAST(NULL AS STRING) AS unique_constraint_schema,
        '' AS unique_constraint_name,
        "on_update" AS update_rule,
        "on_delete" AS delete_rule,
        "match" AS match_option,
        (SELECT "name" FROM "_vspace" x WHERE x."id" = y."child_id") AS referencing,
        (SELECT "name" FROM "_vspace" x WHERE x."id" = y."parent_id") AS referenced,
        "is_deferred" AS is_deferred,
        "child_id" AS child_id,
        "parent_id" AS parent_id
        FROM "_fk_constraint" y;
    ]])
    box.schema.role.grant('public', 'read', 'space', '_REFERENTIAL_CONSTRAINTS')

In this example child_cols or parent_cols are not taken
from the _fk_constraint space because in standard SQL those
are in a separate table.

Users who select from this view will need 'read' privilege on the _fk_constraint space.

.. _sql__check_constraints_view:

********************************************************************************
_CHECK_CONSTRAINTS view
********************************************************************************

Example:

.. code-block:: none

    tarantool>SELECT constraint_name, check_clause, space_name, language
    > FROM _check_constraints;
    OK 3 rows selected (0.0 seconds)
    +------------------------+-------------------------+------------+----------+
    | CONSTRAINT_NAME        | CHECK_CLAUSE            | SPACE_NAME | LANGUAGE |
    +------------------------+-------------------------+------------+----------+
    | ck_unnamed_Employees_1 | first_name LIKE 'Влад%' | Employees  | SQL      |
    | ck_unnamed_Critics_1   | first_name LIKE 'Vlad%' | Critics    | SQL      |
    | ck_unnamed_ACTORS_1    | salary > 0              | ACTORS     | SQL      |
    +------------------------+-------------------------+------------+----------+

Definition of the CREATE VIEW statement:

.. code-block:: lua

    pcall(function ()
        box.schema.role.revoke('public', 'read', 'space', '_CHECK_CONSTRAINTS', {if_exists = true})
        end)
    box.execute([[DROP VIEW IF EXISTS _check_constraints;]])
    box.execute([[
    CREATE VIEW _check_constraints AS SELECT
        CAST(NULL AS STRING) AS constraint_catalog,
        CAST(NULL AS STRING) AS constraint_schema,
        "name" AS constraint_name,
        "code" AS check_clause,
        (SELECT "name" FROM "_vspace" x WHERE x."id" = y."space_id") AS space_name,
        "language" AS language,
        "is_deferred" AS is_deferred,
        "space_id" AS space_id
        FROM "_ck_constraint" y;
    ]])
    box.schema.role.grant('public', 'read', 'space', '_CHECK_CONSTRAINTS')

Users who select from this view will need 'read' privilege on the _ck_constraint space.

.. _sql__table_constraints_view:

********************************************************************************
_TABLE_CONSTRAINTS view
********************************************************************************

This has only the constraints (primary-key and unique-key) that can be found by looking at the
:ref:`_index <box_space-index>` space.
It is not a list of indexes, that is, it is not equivalent to INFORMATION_SCHEMA.STATISTICS.
The columns of the index are not taken because in standard SQL they would be in a different table.

Example:

.. code-block:: none

    tarantool>SELECT constraint_name, constraint_type, table_name, id, iid, index_type
    > FROM _table_constraints
    > LIMIT 5;
    OK 5 rows selected (0.0 seconds)
    +-----------------+-----------------+-------------+-----+-----+------------+
    | CONSTRAINT_NAME | CONSTRAINT_TYPE | TABLE_NAME  | ID  | IID | INDEX_TYPE |
    +-----------------+-----------------+-------------+-----+-----+------------+
    | primary         | PRIMARY         | _schema     | 272 |   0 | tree       |
    | primary         | PRIMARY         | _collation  | 276 |   0 | tree       |
    | name            | UNIQUE          | _collation  | 276 |   1 | tree       |
    | primary         | PRIMARY         | _vcollation | 277 |   0 | tree       |
    | name            | UNIQUE          | _vcollation | 277 |   1 | tree       |
    +-----------------+-----------------+-------------+-----+-----+------------+

Definition of the function and the CREATE VIEW statement:

.. code-block:: lua

    box.schema.func.drop('_TABLE_CONSTRAINTS_OPTS_UNIQUE',{if_exists = true})
    function _TABLE_CONSTRAINTS_OPTS_UNIQUE (opts) return require('msgpack').decode(opts).unique end
    box.schema.func.create('_TABLE_CONSTRAINTS_OPTS_UNIQUE',
        {language = 'LUA',
         returns = 'boolean',
         body = [[function (opts) return require('msgpack').decode(opts).unique end]],
         param_list = {'string'},
         exports = {'LUA', 'SQL'},
         is_sandboxed = false,
         setuid = false,
         is_deterministic = false})
    box.schema.role.grant('public', 'execute', 'function', '_TABLE_CONSTRAINTS_OPTS_UNIQUE')
    pcall(function ()
    box.schema.role.revoke('public', 'read', 'space', '_TABLE_CONSTRAINTS', {if_exists = true})
    end)
    box.execute([[DROP VIEW IF EXISTS _table_constraints;]])
    box.execute([[
    CREATE VIEW _table_constraints AS SELECT
    CAST(NULL AS STRING) AS constraint_catalog,
    CAST(NULL AS STRING) AS constraint_schema,
    "name" AS constraint_name,
    (SELECT "name" FROM "_vspace" x WHERE x."id" = y."id") AS table_name,
    CASE WHEN "iid" = 0 THEN 'PRIMARY' ELSE 'UNIQUE' END AS constraint_type,
    CAST(NULL AS STRING) AS initially_deferrable,
    CAST(NULL AS STRING) AS deferred,
    CAST(NULL AS STRING) AS enforced,
    "id" AS id,
    "iid" AS iid,
    "type" AS index_type
    FROM "_vindex" y
    WHERE _table_constraints_opts_unique("opts") = TRUE;
    ]])
    box.schema.role.grant('public', 'read', 'space', '_TABLE_CONSTRAINTS')
