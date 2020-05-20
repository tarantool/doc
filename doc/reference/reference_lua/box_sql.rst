.. _box-sql:

--------------------------------------------------------------------------------
Functions for SQL
--------------------------------------------------------------------------------

The ``box`` module contains some functions related to SQL:

* ``box.schema.func.create`` -- for making Lua functions callable from
  SQL statements. See :ref:`Calling Lua routines from SQL <sql_calling_lua>`
  in the :ref:`SQL Plus Lua <sql_sql_plus_lua>` section.

* ``box.execute`` -- for making SQL statements callable from Lua functions.
  See the :ref:`SQL user guide <sql_sql_user_guide>`.

* ``box.prepare`` and ``box.unprepare``.

Some SQL statements are illustrated in the :ref:`SQL tutorial <sql_tutorial>`.

.. _box-sql_box_execute:

.. function:: box.execute(sql-statement[, extra-parameters])

    Execute the SQL statement contained in the sql-statement parameter.

    :param string sql-statement: statement, which should conform to :ref:`the rules for SQL grammar <sql_sql_statements_and_clauses>`
    :param table extra-parameters: optional table for placeholders in the statement

    :return: depends on statement

    .. _box-sql_extra_parameters:

    There are two ways to pass extra parameters for ``box.execute()``:

    * The first way is to concatenate strings.
      For example, this Lua script will insert 10 rows with different primary-key
      values into table t: |br|
      ``for i=1,10,1 do`` |br|
      |nbsp| |nbsp| ``box.execute("insert into t values (" .. i .. ")")`` |br|
      ``end``

    * The second way is to put placeholder ``?`` question-mark tokens inside the string,
      and pass a second argument *extra-parameters*, which must be a table containing values for each placeholder.
      For example these two requests are equivalent: |br|
      ``box.execute([[INSERT INTO tt VALUES (1, 'x');]]);`` |br|
      ``x = {1,'x'}; box.execute([[INSERT INTO tt VALUES (?, ?);]], x);`` |br|
      Or, put parameter names inside the string. A parameter name must start with ``:`` colon
      and must match a named component of the *extra-parameters* table. For example,
      this request is also equivalent: |br|
      ``box.execute([[INSERT INTO tt VALUES (:a, :b);]], {{[':a']=1},{[':b']='x'}})``

    Since ``box.execute()`` is an invocation of a Lua function,
    it either causes an error message or returns a value.

    For some statements the returned value will contain a field named rowcount.
    For example;

    .. code-block:: tarantoolsession

        tarantool> box.execute([[INSERT INTO tt VALUES (8,8),(9,9);]])
        tarantool> box.execute([[CREATE TABLE table1 (column1 INT PRIMARY key, column2 VARCHAR(10));]])
        ---
        - rowcount: 1
        ...
        tarantool> box.execute([[INSERT INTO table1 VALUES (55,'Hello SQL world!');]])
        ---
        - rowcount: 1
        ...

    For statements that cause generation of values for PRIMARY KEY AUTOINCREMENT columns,
    there will also be a field named "autoincrement_ids".

    .. _box-sql_result_sets:

    For SELECT or PRAGMA statements, the returned value will be a *result set*,
    containing a field named "metadata" (a table with column names and
    Tarantool/NoSQL type names)
    and a field named "rows" (a table with the contents of each row).

    For example, for a statement ``SELECT "x" FROM t WHERE "x"=5;``
    where ``"x"`` is an INTEGER column and there is one row,
    a display on the Tarantool client will look like this:

    .. code-block:: tarantoolsession

        tarantool> box.execute([[SELECT "x" FROM t WHERE "x"=5;]])
        ---
        - metadata:
          - name: x
            type: integer
          rows:
          - [5]
        ...

    The data for the result set, in MsgPack format, will look like this:

    .. code-block:: none

        dd 00 00 00 01                  1-element array
        82                              2-element map (for metadata + rows)
        a8 6d 65 74 61 64 61 74 61      string = "metadata"
        91                              1-element array (for column count)
        82                              2-element map (for name + type)
        a4 6e 61 6d 65                  string = "name"
        a1 78                           string = "x"
        a4 74 79 70 6                   string = "type"
        a7 69 6e 74 65 67 65 72         string = "integer"
        a4 72 6f 77 73                  string = "rows"
        91                              1-element array (for row count)
        91                              1-element array (for field count)
        05                              contents

    For a look at the raw format see :ref:`Binary protocol -- illustration <box_protocol-illustration>`.

    The order of components within a map is not guaranteed.
 
    .. _box-sql_if_full_metadata:

    If ``sql_full_metadata`` in the :ref:`_session_settings <box_space-session_settings>` system table
    is TRUE, then result set metadata may include these things in addition to ``name`` and ``type``:

    * ``collation`` (present only if COLLATE clause is specified for a STRING) = :ref:`"Collation" <index-collation>`.
    * ``is_nullable`` (present only if the :ref:`select list <sql_select_list>` specified a
      base table column and nothing else) = false if column was defined as :ref:`NOT NULL <sql_nulls>`, otherwise true.
      If this is not present, that implies that nullability is unknown.
    * ``is_autoincrement`` (present only if the select list specified a base
      table column and nothing else) = true if column was defined as :ref:`PRIMARY KEY AUTOINCREMENT <sql_table_constraint_def>`,
      otherwise false.
    * ``span`` (always present) = the original expression in a select list,
      which will often be the same as ``name`` if the select list specifies a column name
      and nothing else, but otherwise will differ, for example after
      ``SELECT x+55 AS x FROM t;`` the ``name`` is X and the ``span`` is x+55.
      If ``span`` and ``name`` are the same then the content is MP_NIL.

    Alternative: if you are using the Tarantool server as a client,
    you can switch languages thus:

    .. code-block:: none

        \set language sql
        \set delimiter ;

    Afterwards, you can enter any SQL statement directly without needing ``box.execute()``.

    There is also an ``execute()`` function available via :ref:`module net.box <net_box-module>`,
    for example after ``conn = net_box.connect(url-string)`` one can say
    ``conn:execute(sql-statement])``.

.. _box-sql_box_prepare:

.. function:: box.prepare(sql-statement)

    Prepare the SQL statement contained in the sql-statement parameter.
    The syntax and requirements for ``box.prepare`` are the same as for :ref:`box.execute <box-sql_box_execute>`.

    :param string sql-statement: statement, which should conform to :ref:`the rules for SQL grammar <sql_sql_statements_and_clauses>`

    :return: prepared_table, with id and methods and metadata
    :rtype:  table

    ``box.prepare`` compiles an SQL statement into byte code and saves the byte code in a cache.
    Since compiling takes a significant amount of time, preparing a
    statement will enhance performance if the statement is executed many times.

    If ``box.prepare`` succeeds, prepared_table contains:

    * ``stmt_id``: integer -- an identifier generated by a hash of the statement string
    * ``execute``: function
    * ``params``: map [name : string, type : string] -- parameter descriptions
    * ``unprepare``: function
    * ``metadata``: map [name : string, type : string] (This is present only for SELECT or PRAGMA statements
      and has the same contents as the :ref:`result set metadata <box-sql_result_sets>` for ``box.execute``)
    * ``param_count``: integer -- number of parameters

    This can be used by :ref:`prepared_table:execute() <box-sql_box_execute_prepared_statement>`
    and by :ref:`prepared_table:unprepare() <box-sql_box_unprepare_prepared_statement>`.

    The prepared statement cache (which is also called the prepared statement holder)
    is "shared", that is, there is one cache for
    all sessions. However, session X cannot execute a statement prepared by session Y. |br|
    For monitoring the cache, see :ref:`box.info().sql <box_introspection-box_info>`. |br|
    For changing the cache, see :ref:`(Configuration reference) sql_cache_size <cfg_basic-sql_cache_size>`.

    Prepared statements will "expire" (become invalid) if
    any database object is dropped or created or altered --
    even if the object is not mentioned in the SQL statement,
    even if the create or drop or alter is rolled back,
    even if the create or drop or alter is done in a different session.

.. class:: prepared_table

    .. _box-sql_box_execute_prepared_statement:

    .. method:: execute([extra-parameters])

    Execute a statement that has been prepared with :ref:`box.prepare() <box-sql_box_prepare>`.

    Parameter ``prepared_table`` should be the result from ``box.prepare()``. |br|
    Parameter ``extra-parameters`` should be an optional table to match :ref:`placeholders or named parameters <box-sql_extra_parameters>` in the statement.

    There are two ways to execute: with the method or with the statement id.
    That is, :samp:`{prepared_table}:execute()` and :samp:`box.execute({prepared_table}.stmt_id)` do the same thing.

    Example: here is a test. This function inserts a million rows in a table using a prepared INSERT statement.

    .. code-block:: Lua

        function f()
          local p, start_time
          box.execute([[DROP TABLE IF EXISTS t;]])
          box.execute([[CREATE TABLE t (s1 INTEGER PRIMARY KEY);]])
          start_time = os.time()
          p = box.prepare([[INSERT INTO t VALUES (?);]])
          for i=1,1000000 do p:execute({i}) end
          p:unprepare()
          end_time = os.time()
          box.execute([[COMMIT;]])
          print(end_time - start_time) -- elapsed time
        end
        f()

    Take note of the elapsed time. Now change the line with the loop to: |br|
    ``for i=1,1000000 do box.execute([[INSERT INTO t VALUES (?);]], {i}) end`` |br|
    Run the function again, and take note of the elapsed time again.
    The function which executes the prepared statement will be about 15% faster,
    though of course this will vary depending on Tarantool version and
    environment.

    .. _box-sql_box_unprepare_prepared_statement:

    .. method:: unprepare()

    Undo the result of an earlier :ref:`box.prepare() <box-sql_box_prepare>` request.
    This is equivalent to standard-SQL DEALLOCATE PREPARE.

    Parameter ``prepared_table`` should be the result from ``box.prepare()``.

    There are two ways to unprepare: with the method or with the statement id.
    That is, :samp:`{prepared_table}:unprepare()` and :samp:`box.unprepare({prepared_table}.stmt_id)` do the same thing.

    Tarantool strongly recommends using ``unprepare`` as soon as the immediate
    objective (executing a prepared statement multiple times) is done, or
    whenever a prepared statement expires.
    There is no automatic eviction policy, although automatic ``unprepare``
    will happen when the session disconnects (the session's prepared statements will be removed from the prepared-statement cache).
