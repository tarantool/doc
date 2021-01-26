.. _box-sql_box_execute:

===============================================================================
box.execute()
===============================================================================

.. function:: box.execute(sql-statement[, extra-parameters])

    Execute the SQL statement contained in the sql-statement parameter.

    :param string sql-statement: statement, which should conform to
                                 :ref:`the rules for SQL grammar <sql_statements_and_clauses>`
    :param table extra-parameters: optional table for placeholders in the statement

    :return: depends on statement

    .. _box-sql_extra_parameters:

    There are two ways to pass extra parameters for ``box.execute()``:

    * The first way, which is the preferred way, is to put placeholders in the
      string, and pass a second argument, an *extra-parameters* table. A
      placeholder is either a question mark "?", or a colon ":" followed by a
      name. An extra parameter is any Lua expression.
      If placeholders are question marks, then they will be replaced by
      extra-parameter values in corresponding positions, that is, the first ?
      will be replaced by the first extra parameter, the second ? will be
      replaced by the second extra parameter, and so on. If placeholders are
      :names, then they will be replaced by extra-parameter values with
      corresponding names. For example this request which contains literal
      values 1 and 'x': |br|
      ``box.execute([[INSERT INTO tt VALUES (1, 'x');]]);`` |br|
      is the same as this request which contains two question-mark placeholders
      (``?`` and ``?``) and a two-element extra-parameters table: |br|
      ``x = {1,'x'}`` |br|
      ``box.execute([[INSERT INTO tt VALUES (?, ?);]], x);`` |br|
      and is the same as this request which contains two :name placeholders
      (``:a`` and ``:b``) and a two-element extra-parameters table with elements
      named "a" and "b": |br|
      ``box.execute([[INSERT INTO tt VALUES (:a, :b);]], {{[':a']=1},{[':b']='x'}})`` |br|

    * The second way is to concatenate strings.
      For example, this Lua script will insert 10 rows with different primary-key
      values into table t: |br|
      ``for i=1,10,1 do`` |br|
      |nbsp| |nbsp| ``box.execute("insert into t values (" .. i .. ")")`` |br|
      ``end`` |br|
      When creating SQL statements based on user input, application developers
      should beware of `SQL injection <https://en.wikipedia.org/wiki/SQL_injection>`_.

    Since ``box.execute()`` is an invocation of a Lua function,
    it either causes an error message or returns a value.

    For some statements the returned value will contain a field named "rowcount".
    For example;

    .. code-block:: tarantoolsession

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

    For a look at raw format of SELECT results, see
    :ref:`Binary protocol -- responses for SQL <box_protocol-sql_protocol>`.

    The order of components within a map is not guaranteed.

    .. _box-sql_if_full_metadata:

    If ``sql_full_metadata`` in the
    :ref:`_session_settings <box_space-session_settings>` system table is TRUE,
    then result set metadata may include these things in addition to ``name``
    and ``type``:

    * ``collation`` (present only if COLLATE clause is specified for a STRING) =
      :ref:`"Collation" <index-collation>`.
    * ``is_nullable`` (present only if the :ref:`select list <sql_select_list>`
      specified a base table column and nothing else) = false if column was
      defined as :ref:`NOT NULL <sql_nulls>`, otherwise true.
      If this is not present, that implies that nullability is unknown.
    * ``is_autoincrement`` (present only if the select list specified a base
      table column and nothing else) = true if column was defined as
      :ref:`PRIMARY KEY AUTOINCREMENT <sql_table_constraint_def>`,
      otherwise false.
    * ``span`` (always present) = the original expression in a select list,
      which will often be the same as ``name`` if the select list specifies a
      column name and nothing else, but otherwise will differ, for example after
      ``SELECT x+55 AS x FROM t;`` the ``name`` is X and the ``span`` is x+55.
      If ``span`` and ``name`` are the same then the content is MP_NIL.

    Alternative: if you are using the Tarantool server as a client,
    you can switch languages thus:

    .. code-block:: none

        \set language sql
        \set delimiter ;

    Afterwards, you can enter any SQL statement directly without needing
    ``box.execute()``.

    There is also an ``execute()`` function available via
    :ref:`module net.box <net_box-module>`, for example after
    ``conn = net_box.connect(url-string)`` one can say
    ``conn:execute(sql-statement])``.
