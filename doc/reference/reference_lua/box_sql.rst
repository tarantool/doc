.. _box-sql:

--------------------------------------------------------------------------------
Functions for SQL
--------------------------------------------------------------------------------

The ``box`` module contains two functions related to SQL:

* ``box.internal.sql_create_function`` -- for making Lua functions callable from
  SQL statements. This, or an SQL statement with the same effect, will be part of
  the documentation regarding SQL Plus Lua.

* ``box.execute`` -- for making SQL statements callable from Lua functions.

Some SQL statements are illustrated in the :ref:`SQL tutorial <sql_tutorial>`.

.. _box-sql_box_execute:

.. function:: box.execute(sql-statement[, extra-parameters])

    Execute the SQL statement contained in the sql-statement parameter.

    :param string sql-statement: statement, which should conform to :ref:`the rules for SQL grammar <sql_sql_statements_and_clauses>`
    :param table extra-parameters: optional table for placeholders in the statement

    :return: depends on statement

    .. _box-sql_extra_parameters:

    There are two ways to pass extra parameters for ``box.execute()``:

    * The first way, which is the preferred way, is to put placeholders in the string,
      and pass a second argument, an *extra-parameters* table.
      A placeholder is either a question mark "?", or a colon ":" followed by a name.
      An extra parameter is any Lua expression.
      If placeholders are question marks, then they will be replaced by extra-parameter
      values in corresponding positions, that is, the first ? will be replaced by the first
      extra parameter, the second ? will be replaced by the second extra parameter, and so on.
      If placeholders are :names, then they will be replaced by extra-parameter
      values with corrresponding names.
      For example this request which contains literal values 1 and 'x': |br|
      ``box.execute([[INSERT INTO tt VALUES (1, 'x');]]);`` |br|
      is the same as this request which contains two question-mark placeholders (``?`` and ``?``)
      and a two-element extra-parameters table: |br|
      ``x = {1,'x'}`` |br|
      ``box.execute([[INSERT INTO tt VALUES (?, ?);]], x);`` |br|
      and is the same as this request which contains two :name placeholders (``:a`` and ``:b``)
      and a two-element extra-parameters table with elements named "a" and "b": |br|
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

    For SELECT statements the returned value will contain a field named "metadata"
    (a table with column names and data types)
    and a field named "rows" (a table with the result set). For example:

    .. code-block:: tarantoolsession

        tarantool> box.execute([[SELECT * FROM table1 WHERE column1 > 0;]])
        ---
        - metadata:
          - name: COLUMN1
            type: integer
          - name: COLUMN2
            type: string
          rows:
          - [55, 'Hello SQL world!']
        ...

    The result structure contains Tarantool/NoSQL data type names in MsgPack format.
    For example, for a statement SELECT "x" FROM t WHERE "x"=5;
    where "x" is an integer column and there is one row,
    the raw data for the result set will look like this:

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

    The order of components within a map is not guaranteed.

    Alternative: if you are using the Tarantool server as a client,
    you can switch languages thus:

    .. code-block:: none

        \set language sql
        \set delimiter ;

    Afterwards, you can enter any SQL statement directly without needing ``box.execute()``.

    There is also an ``execute()`` function available via :ref:`module net.box <net_box-module>`,
    for example after ``conn = net_box.connect(url-string)`` one can say
    ``conn:execute(sql-statement])``.
