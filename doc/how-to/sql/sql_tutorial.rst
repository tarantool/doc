.. _sql_tutorial:

SQL tutorial
============

This tutorial is a demonstration of the support for SQL in Tarantool.
It includes the functionality that you'd encounter in an "SQL-101"course.

.. _sql_tutorial-starting_up_with_a_first_table_and_selects:

Starting up with a first table and SELECTs
------------------------------------------

Initialize
~~~~~~~~~~

In this tutorial, the requests are done in the Tarantool interactive console.
Start Tarantool and initialize it with :ref:`default settings <box_introspection-box_cfg>`
by calling ``box.cfg{}``:

.. code-block:: tarantoolsession

    tarantool> box.cfg{}

Now you can start working with the database.

Switch to the SQL language
~~~~~~~~~~~~~~~~~~~~~~~~~~

A feature of the client console program is that you can switch languages and
specify the end-of-statement delimiter.

Run the following commands to set the console input language to SQL and use
semicolon as a delimiter:

..  code-block:: tarantoolsession

    tarantool> \set language sql
    tarantool> \set delimiter ;


CREATE, INSERT, UPDATE, SELECT
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

To get started, enter simple SQL statements:

.. code-block:: sql

    CREATE TABLE table1 (column1 INTEGER PRIMARY KEY, column2 VARCHAR(100));
    INSERT INTO table1 VALUES (1, 'A');
    UPDATE table1 SET column2 = 'B';
    SELECT * FROM table1 WHERE column1 = 1;

The result of the ``SELECT`` statement looks like this:

.. code-block:: tarantoolsession

    tarantool> SELECT * FROM table1 WHERE column1 = 1;
    ---
    - metadata:
      - name: COLUMN1
        type: integer
      - name: COLUMN2
        type: string
      rows:
      - [1, 'B']
    ...

The result includes:

-   Metadata: the names and data types of each column
-   Result rows

For conciseness, metadata is skipped in query results in this tutorial.
Only the result rows are shown.

CREATE TABLE
~~~~~~~~~~~~

Here is ``CREATE TABLE`` with more details:

*   There are multiple columns, with different data types.
*   There is a ``PRIMARY KEY`` (unique and not-null) for two of the columns.

.. code-block:: sql

    CREATE TABLE table2 (column1 INTEGER,
                         column2 VARCHAR(100),
                         column3 SCALAR,
                         column4 DOUBLE,
                         PRIMARY KEY (column1, column2));

The result is: ``row_count: 1``.

INSERT
~~~~~~

Put four rows in the table:

*   The INTEGER and DOUBLE columns get numbers
*   The VARCHAR and SCALAR columns get strings
    (the SCALAR strings are expressed as hexadecimals)

.. code-block:: sql

    INSERT INTO table2 VALUES (1, 'AB', X'4142', 5.5);
    INSERT INTO table2 VALUES (1, 'CD', X'2020', 1E4);
    INSERT INTO table2 VALUES (2, 'AB', X'2020', 12.34567);
    INSERT INTO table2 VALUES (-1000, '', X'', 0.0);

Then try to put another row:

.. code-block:: sql

    INSERT INTO table2 VALUES (1, 'AB', X'A5', -5.5);

This ``INSERT`` fails because of a primary-key violation: the row with the primary
key ``1, 'AB'`` already exists.

SELECT with ORDER BY clause
~~~~~~~~~~~~~~~~~~~~~~~~~~~

Retrieve the 4 rows in the table, in descending order by ``column2``, then
(where the ``column2`` values are the same) in ascending order by ``column4``.

``*`` is short for "all columns".

.. code-block:: sql

    SELECT * FROM table2 ORDER BY column2 DESC, column4 ASC;

The result is:

.. code-block:: tarantoolsession

    - - [1, 'CD', '  ', 10000]
      - [1, 'AB', 'AB', 5.5]
      - [2, 'AB', '  ', 12.34567]
      - [-1000, '', '', 0]

SELECT with WHERE clauses
~~~~~~~~~~~~~~~~~~~~~~~~~

Retrieve some of what you inserted:

*   The first statement uses
    the ``LIKE`` comparison operator which is asking
    for "first character must be 'A', the next characters can be anything."
*   The second statement uses logical operators and parentheses,
    so the ANDed expressions must be true, or the ORed expression
    must be true. Notice the columns don't have to be indexed.

.. code-block:: sql

    SELECT column1, column2, column1 * column4 FROM table2 WHERE column2
    LIKE 'A%';
    SELECT column1, column2, column3, column4 FROM table2
        WHERE (column1 < 2 AND column4 < 10)
        OR column3 = X'2020';

The results are:

.. code-block:: tarantoolsession

    - - [1, 'AB', 5.5]
      - [2, 'AB', 24.69134]

and

.. code-block:: tarantoolsession

    - - [-1000, '', '', 0]
      - [1, 'AB', 'AB', 5.5]
      - [1, 'CD', '  ', 10000]
      - [2, 'AB', '  ', 12.34567]

SELECT with GROUP BY and aggregate functions
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Retrieve with grouping.

The rows which have the same values for ``column2`` are grouped and are aggregated
-- summed, counted, averaged -- for ``column4``.

.. code-block:: sql

    SELECT column2, SUM(column4), COUNT(column4), AVG(column4)
    FROM table2
    GROUP BY column2;

The result is:

.. code-block:: tarantoolsession

    - - ['', 0, 1, 0]
      - ['AB', 17.84567, 2, 8.922835]
      - ['CD', 10000, 1, 10000]

.. _sql_tutorial-complications_and_complex_selects:

Complications and complex SELECTs
---------------------------------

NULLs
~~~~~

Insert rows that contain ``NULL`` values.

``NULL`` is not the same as Lua ``nil``; it commonly is used in SQL for unknown
or not-applicable.

.. code-block:: sql

    INSERT INTO table2 VALUES (1, NULL, X'4142', 5.5);
    INSERT INTO table2 VALUES (0, '!!@', NULL, NULL);
    INSERT INTO table2 VALUES (0, '!!!', X'00', NULL);

The results are:

* The first ``INSERT`` fails because ``NULL`` is not
  permitted for a column that was defined with a
  ``PRIMARY KEY`` clause.
* The other ``INSERT`` statements succeed.

Indexes
~~~~~~~

Create a new index on ``column4``.

There already is an index for the primary key. Indexes are useful for making queries
faster. In this case, the index also acts as a constraint, because it prevents
two rows from having the same values in ``column4``. However, it is not an error
that ``column4`` has multiple occurrences of NULLs.

.. code-block:: sql

    CREATE UNIQUE INDEX i ON table2 (column4);

The result is: ``rowcount: 1``.

Create a subset table
~~~~~~~~~~~~~~~~~~~~~

Create a table ``table3``, which contains a subset of the ``table2`` columns
and a subset of the ``table2`` rows.

You can do this by combining ``INSERT`` with ``SELECT``. Then select everything
from the result table.

.. code-block:: sql

    CREATE TABLE table3 (column1 INTEGER, column2 VARCHAR(100), PRIMARY KEY
    (column2));
    INSERT INTO table3 SELECT column1, column2 FROM table2 WHERE column1 <> 2;
    SELECT * FROM table3;

The result is:

.. code-block:: tarantoolsession

    - - [-1000, '']
      - [0, '!!!']
      - [0, '!!@']
      - [1, 'AB']
      - [1, 'CD']

SELECT with a subquery
~~~~~~~~~~~~~~~~~~~~~~

A subquery is a query within a query.

Find all the rows in ``table2`` whose ``(column1, column2)`` values are not
present in ``table3``.

.. code-block:: sql

    SELECT * FROM table2 WHERE (column1, column2) NOT IN (SELECT column1,
    column2 FROM table3);

The result is the single row that was excluded when inserting the rows with
the ``INSERT ... SELECT`` statement:

.. code-block:: tarantoolsession

    - - [2, 'AB', '  ', 12.34567]

SELECT with a join
~~~~~~~~~~~~~~~~~~

A join is a combination of two tables. There is more than one way to do them in
Tarantool: "Cartesian joins", "left outer joins", and so on.

This example shows the most typical case, where column values from one table match
column values from another table.

.. code-block:: sql

    SELECT * FROM table2, table3
        WHERE table2.column1 = table3.column1 AND table2.column2 = table3.column2
        ORDER BY table2.column4;

The result is:

.. code-block:: tarantoolsession

    - - [0, '!!!', "\0", null, 0, '!!!']
      - [0, '!!@', null, null, 0, '!!@']
      - [-1000, '', '', 0, -1000, '']
      - [1, 'AB', 'AB', 5.5, 1, 'AB']
      - [1, 'CD', ' ', 10000, 1, 'CD']

.. _sql_tutorial-constraints_and_foreign_keys:

Constraints and foreign keys
-----------------------------

CREATE TABLE with a CHECK clause
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Create a table which includes a constraint that there must not be any rows
containing ``13`` in ``column2``. Then try to insert such a row.

.. code-block:: sql

    CREATE TABLE table4 (column1 INTEGER PRIMARY KEY, column2 INTEGER, CHECK
    (column2 <> 13));
    INSERT INTO table4 VALUES (12, 13);

Result: the insert fails, as it should, with the message
``Check constraint failed ''ck_unnamed_TABLE4_1'': column2 <> 13``.

CREATE TABLE with a FOREIGN KEY clause
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Create a table which includes a constraint that there must not be any rows containing
values that do not appear in ``table2``.

.. code-block:: sql

    CREATE TABLE table5 (column1 INTEGER, column2 VARCHAR(100),
        PRIMARY KEY (column1),
        FOREIGN KEY (column1, column2) REFERENCES table2 (column1, column2));
    INSERT INTO table5 VALUES (2,'AB');
    INSERT INTO table5 VALUES (3,'AB');

Result:

*   The first ``INSERT`` statement succeeds because
    ``table3`` contains a row with ``[2, 'AB', ' ', 12.34567]``.
*   The second ``INSERT`` statement, correctly, fails with the message
    ``Failed to execute SQL statement: FOREIGN KEY constraint failed``.

UPDATE
~~~~~~

Due to earlier ``INSERT`` statements, these values are in ``column4`` of ``table2``:
``{0, NULL, NULL, 5.5, 10000, 12.34567}``. Add ``5`` to each of these values except ``0``.
Adding ``5`` to ``NULL`` results in NULL, as SQL arithmetic requires.
Use ``SELECT`` to see what happened to ``column4``.

.. code-block:: sql

    UPDATE table2 SET column4 = column4 + 5 WHERE column4 <> 0;
    SELECT column4 FROM table2 ORDER BY column4;

The result is: ``{NULL, NULL, 0, 10.5, 17.34567, 10005}``.

DELETE
~~~~~~

Due to earlier ``INSERT`` statements, there are 6 rows in ``table2``:

.. code-block:: tarantoolsession

    - - [-1000, '', '', 0]
      - [0, '!!!', "\0", null]
      - [0, '!!@', null, null]
      - [1, 'AB', 'AB', 10.5]
      - [1, 'CD', '  ', 10005]
      - [2, 'AB', '  ', 17.34567]

Try to delete the last and first of these rows:

.. code-block:: sql

    DELETE FROM table2 WHERE column1 = 2;
    DELETE FROM table2 WHERE column1 = -1000;
    SELECT COUNT(column1) FROM table2;

The result is:

*   The first ``DELETE`` statement causes an error message because
    there's a foreign-key constraint.
*   The second ``DELETE`` statement succeeds.
*   The ``SELECT`` statement shows that there are 5 rows remaining.

ALTER TABLE with a FOREIGN KEY clause
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Create another constraint that there must not be any rows in ``table1``
containing values that do not appear in ``table5``. This was impossible
during the ``table1`` creation because at that time ``table5`` did not exist.
You can add constraints to existing tables withthe ``ALTER TABLE`` statement.

.. code-block:: sql

    ALTER TABLE table1 ADD CONSTRAINT c
        FOREIGN KEY (column1) REFERENCES table5 (column1);
    DELETE FROM table1;
    ALTER TABLE table1 ADD CONSTRAINT c
        FOREIGN KEY (column1) REFERENCES table5 (column1);

Result: the ``ALTER TABLE`` statement fails the first time because there is a row
in ``table1``, and ``ADD CONSTRAINT`` requires that the table be empty.
After the row is deleted, the ``ALTER TABLE`` statement completes successfully.
Now there is a chain of references, from ``table1`` to ``table5`` and from ``table5``
to ``table2``.

Triggers
~~~~~~~~~

The idea of a trigger is: if a change (``INSERT`` or ``UPDATE`` or ``DELETE``) happens,
then a further action -- perhaps another ``INSERT`` or ``UPDATE`` or ``DELETE``
-- will happen.

Set up the following trigger: when a update to ``table3`` is done, do an update
to ``table2``. Specify this as ``FOR EACH ROW``, so that the trigger activates 5
times (since there are 5 rows in ``table3``).

.. code-block:: sql

    SELECT column4 FROM table2 WHERE column1 = 2;
    CREATE TRIGGER tr AFTER UPDATE ON table3 FOR EACH ROW
    BEGIN UPDATE table2 SET column4 = column4 + 1 WHERE column1 = 2; END;
    UPDATE table3 SET column2 = column2;
    SELECT column4 FROM table2 WHERE column1 = 2;

Result:

*   The first ``SELECT`` shows that the original value of
    ``column4`` in ``table2`` where ``column1 = 2`` was: 17.34567.
*   The second ``SELECT`` returns:

  .. code-block:: tarantoolsession

      - - [22.34567]

.. _sql_tutorial-operators_and_functions:

Operators and functions
-----------------------

String operations
~~~~~~~~~~~~~~~~~

You can manipulate string data (usually defined with ``CHAR`` or ``VARCHAR`` data types)
in many ways. For example:

* concatenate strings with the ``||`` operator
* extract substrings with the ``SUBSTR`` function

.. code-block:: sql

    SELECT column2, column2 || column2, SUBSTR(column2, 2, 1) FROM table2;

The result is:

.. code-block:: tarantoolsession

    - - ['!!!', '!!!!!!', '!']
      - ['!!@', '!!@!!@', '!']
      - ['AB', 'ABAB', 'B']
      - ['CD', 'CDCD', 'D']
      - ['AB', 'ABAB', 'B']

Number operations
~~~~~~~~~~~~~~~~~

You can also manipulate number data (usually defined with ``INTEGER``
or ``DOUBLE`` data types) in many ways. For example:

* shift lleft with the ``<<`` operator
* get modulo with the ``%`` operator

.. code-block:: sql

    SELECT column1, column1 << 1, column1 << 2, column1 % 2 FROM table2;

The result is:

.. code-block:: tarantoolsession

    - - [0, 0, 0, 0]
      - [0, 0, 0, 0]
      - [1, 2, 4, 1]
      - [1, 2, 4, 1]
      - [2, 4, 8, 0]

Ranges and limits
~~~~~~~~~~~~~~~~~

Tarantool can handle:

*   integers anywhere in the 4-byte integer range
*   approximate-numerics anywhere in the 8-byte IEEE floating point range
*   any Unicode characters, with UTF-8 encoding and a choice of collations

Insert such values in a new table and see what happens when you select them
with arithmetic on a number column and ordering by a string column.

.. code-block:: sql

    CREATE TABLE t6 (column1 INTEGER, column2 VARCHAR(10), column4 DOUBLE,
    PRIMARY KEY (column1));
    INSERT INTO t6 VALUES (-1234567890, 'АБВГД', 123456.123456);
    INSERT INTO t6 VALUES (+1234567890, 'GD', 1e30);
    INSERT INTO t6 VALUES (10, 'FADEW?', 0.000001);
    INSERT INTO t6 VALUES (5, 'ABCDEFG', NULL);
    SELECT column1 + 1, column2, column4 * 2 FROM t6 ORDER BY column2;

The result is:

.. code-block:: tarantoolsession

    - - [6, 'ABCDEFG', null]
      - [11, 'FADEW?', 2e-06]
      - [1234567891, 'GD', 2e+30]
      - [-1234567889, 'АБВГД', 246912.246912]

Views
~~~~~

A view (or *viewed table*), is virtual, meaning that its rows aren't physically
in the database, their values are calculated from other tables.

Create a view ``v3`` based on ``table3`` and select from it:

.. code-block:: sql

    CREATE VIEW v3 AS SELECT SUBSTR(column2,1,2), column4 FROM t6 WHERE
    column4 >= 0;
    SELECT * FROM v3;

The result is:

.. code-block:: tarantoolsession

    - - ['АБ', 123456.123456]
      - ['FA', 1e-06]
      - ['GD', 1e+30]

Common table expressions
~~~~~~~~~~~~~~~~~~~~~~~~

By putting ``WITH`` + ``SELECT`` in front of a ``SELECT``, you can make a
temporary view that lasts for the duration of the statement.

Create such a view and select from it:

.. code-block:: sql

    WITH cte AS (
                 SELECT SUBSTR(column2,1,2), column4 FROM t6 WHERE column4
                 >= 0)
    SELECT * FROM cte;

The result is the same as the ``CREATE VIEW`` result:

.. code-block:: tarantoolsession

    - - ['АБ', 123456.123456]
      - ['FA', 1e-06]
      - ['GD', 1e+30]

VALUES
~~~~~~

Tarantool can handle statements like ``SELECT 55;`` (select without ``FROM``)
like some other popular DBMSs. But it also handles the more standard statement
``VALUES (expression [, expression ...]);``.

.. code-block:: sql

    SELECT 55 * 55, 'The rain in Spain';
    VALUES (55 * 55, 'The rain in Spain');

The result of both these statements is:

.. code-block:: tarantoolsession

    - - [3025, 'The rain in Spain']

Metadata
~~~~~~~~


To find out the internal structure of the Tarantool database with SQL,
select from the Tarantool system tables:

* tables: ``SELECT * FROM "_space";``
* indexes: ``SELECT * FROM "_index";``
* triggers: ``SELECT * FROM "_trigger";``

Actually, these statements select from NoSQL "system spaces".

Select from ``_space``:

.. code-block:: sql

    SELECT "id", "name", "owner", "engine" FROM "_space" WHERE "name"='TABLE3';

The result is:

.. code-block:: tarantoolsession

    - - [517, 'TABLE3', 1, 'memtx']

.. _sql_tutorial-using_sql_from_lua:

Using SQL from Lua
------------------

You can execute SQL statements directly from the Lua code without switching to
the SQL input.

Change the settings so that the console accepts statements written in Lua instead
of statements written in SQL:

.. code-block:: tarantoolsession

    tarantool> \set language lua

box.execute()
~~~~~~~~~~~~~
You can invoke SQL statements using the Lua function ``box.execute(string)``.

.. code-block:: tarantoolsession

    tarantool> box.execute([[SELECT * FROM table3;]]);

The result is:

.. code-block:: tarantoolsession

    - - [-1000, '']
      - [0, '!!!']
      - [0, '!!@']
      - [1, 'AB']
      - [1, 'CD']
    ...

Create a million-row table
~~~~~~~~~~~~~~~~~~~~~~~~~~

To see how the SQL in Tarantool scales, create a bigger table.

The following Lua code generates one million rows with random data and
inserts them into a table. Copy this code into the Tarantool console and wait
a bit:

.. code-block:: lua

    box.execute("CREATE TABLE tester (s1 INT PRIMARY KEY, s2 VARCHAR(10))");

    function string_function()
       local random_number
       local random_string
       random_string = ""
       for x = 1,10,1 do
         random_number = math.random(65, 90)
         random_string = random_string .. string.char(random_number)
       end
       return random_string
    end;

    function main_function()
       local string_value, t, sql_statement
       for i = 1,1000000,1 do
         string_value = string_function()
         sql_statement = "INSERT INTO tester VALUES (" .. i .. ",'" .. string_value .. "')"
         box.execute(sql_statement)
       end
    end;
    start_time = os.clock();
    main_function();
    end_time = os.clock();
    'insert done in ' .. end_time - start_time .. ' seconds';

The result is: you now have a table with a million rows, with a message saying
"``insert done in 88.570578 seconds``".


Select from a million-row table
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Check how ``SELECT`` works on the million-row table:

*   the first query goes by an index because ``s1`` is the primary key
*   the second query does not go by an index

.. code-block:: lua

    box.execute([[SELECT * FROM tester WHERE s1 = 73446;]]);
    box.execute([[SELECT * FROM tester WHERE s2 LIKE 'QFML%';]]);

The result is:

*   the first statement completes instantaneously
*   the second statement completed noticeably slower

Cleanup and exit
~~~~~~~~~~~~~~~~

To cleanup all the objects created in this tutorial, switch to the SQL input
language again. Then run the ``DROP`` statements for all created tables, views,
and triggers.

These statements must be entered separately.

.. code-block:: tarantoolsession

    tarantool> \set language sql
    tarantool> DROP TABLE tester;
    tarantool> DROP TABLE table1;
    tarantool> DROP VIEW v3;
    tarantool> DROP TRIGGER tr;
    tarantool> DROP TABLE table5;
    tarantool> DROP TABLE table4;
    tarantool> DROP TABLE table3;
    tarantool> DROP TABLE table2;
    tarantool> DROP TABLE t6;
    tarantool> \set language lua
    tarantool> os.exit();
