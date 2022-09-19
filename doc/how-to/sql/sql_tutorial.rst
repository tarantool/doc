.. _sql_tutorial:

================================================================================
SQL tutorial
================================================================================

This tutorial is a demonstration of the SQL feature introduced in
Tarantool 2.x series. There are two ways to go through this tutorial:

* read what we say the results are and take our word for it, or
* copy and paste each section and see everything work with Tarantool 2.4.

You will encounter all the functionality that you'd encounter in an "SQL-101"
course.

.. _sql_tutorial-starting_up_with_a_first_table_and_selects:

--------------------------------------------------------------------------------
Starting up with a first table and SELECTs
--------------------------------------------------------------------------------

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Initialize
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Requests will be done using Tarantool as a
:ref:`client <admin-using_tarantool_as_a_client>`.
Start Tarantool and, optionally, enter the Tarantool configuration request,
for example:

.. code-block:: tarantoolsession

    tarantool> box.cfg{}

Before Tarantool 2.0 you needed to say ``box.cfg{...}`` prior to
performing any database operations.
Now you can start working with the database outright.
Tarantool initiates the database module and applies
:ref:`default settings <box_introspection-box_cfg>`.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
\set
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

A feature of the client console program is that you can
switch languages and specify the end-of-statement delimiter.

Here we say: default language is SQL and statements end with semicolons.

..  code-block:: tarantoolsession

    tarantool> \set language sql
    tarantool> \set delimiter ;

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
CREATE, INSERT, UPDATE, SELECT
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Start with simple SQL statements just to be sure they're there.

.. code-block:: sql

    CREATE TABLE table1 (column1 INTEGER PRIMARY KEY, column2 VARCHAR(100));
    INSERT INTO table1 VALUES (1, 'A');
    UPDATE table1 SET column2 = 'B';
    SELECT * FROM table1 WHERE column1 = 1;

The result of the ``SELECT`` statement will look like this:

.. code-block:: tarantoolsession

    tarantool> SELECT * FROM table1 WHERE column1 = 1;
    ---
    - - [1, 'B']
    ...

Reality check: actually the result will include include initial fields
called "metadata", the names and data types of each column. For all
SELECT examples we show only the result rows without showing the metadata.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
CREATE TABLE
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Here is ``CREATE TABLE`` with more details:

* There are multiple columns, with different data types.
* There is a ``PRIMARY KEY`` (unique and not-null) for two of the columns.

.. code-block:: sql

    CREATE TABLE table2 (column1 INTEGER,
                         column2 VARCHAR(100),
                         column3 SCALAR,
                         column4 DOUBLE,
                         PRIMARY KEY (column1, column2));

The result will be: "``row_count: 1``" (no error).

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
INSERT
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Try to put 5 rows in the table:

* The INTEGER and DOUBLE columns get numbers.
* The VARCHAR and SCALAR columns get strings
  (the SCALAR strings are expressed as hexadecimals).

.. code-block:: sql

    INSERT INTO table2 VALUES (1, 'AB', X'4142', 5.5);
    INSERT INTO table2 VALUES (1, 'CD', X'2020', 1E4);
    INSERT INTO table2 VALUES (1, 'AB', X'A5', -5.5);
    INSERT INTO table2 VALUES (2, 'AB', X'2020', 12.34567);
    INSERT INTO table2 VALUES (-1000, '', X'', 0.0);

The result will be:

* The third ``INSERT`` will fail because of a primary-key violation
  (``1, 'AB'`` is a duplication).
* The other four ``INSERT`` statements will succeed.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
SELECT with ORDER BY clause
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Retrieve the 4 rows in the table, in descending order
by ``column2``, then (where the ``column2`` values are the
same) in ascending order by column4.

"*" is short for "all columns".

.. code-block:: sql

    SELECT * FROM table2 ORDER BY column2 DESC, column4 ASC;

The result will be:

.. code-block:: tarantoolsession

    - - [1, 'CD', '  ', 10000]
      - [1, 'AB', 'AB', 5.5]
      - [2, 'AB', '  ', 12.34567]
      - [-1000, '', '', 0]

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
SELECT with WHERE clauses
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Retrieve some of what you inserted:

* The first statement uses
  the ``LIKE`` comparison operator which is asking
  for "first character must be 'A', the next characters can be anything."
* The second statement uses logical operators and parentheses,
  so the ANDed expressions must be true, or the ORed expression
  must be true. Notice the columns don't have to be indexed.

.. code-block:: sql

    SELECT column1, column2, column1 * column4 FROM table2 WHERE column2
    LIKE 'A%';
    SELECT column1, column2, column3, column4 FROM table2
        WHERE (column1 < 2 AND column4 < 10)
        OR column3 = X'2020';

The results will be:

.. code-block:: tarantoolsession

    - - [1, 'AB', 5.5]
      - [2, 'AB', 24.69134]

and

.. code-block:: tarantoolsession

    - - [-1000, '', '', 0]
      - [1, 'AB', 'AB', 5.5]
      - [1, 'CD', '  ', 10000]
      - [2, 'AB', '  ', 12.34567]

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
SELECT with GROUP BY and aggregating
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Retrieve with grouping.

The rows which have the same values for ``column2`` are grouped
and are aggregated -- summed, counted, averaged --
for ``column4``.

.. code-block:: sql

    SELECT column2, SUM(column4), COUNT(column4), AVG(column4)
    FROM table2
    GROUP BY column2;

The result will be:

.. code-block:: tarantoolsession

    - - ['', 0, 1, 0]
      - ['AB', 17.84567, 2, 8.922835]
      - ['CD', 10000, 1, 10000]

.. _sql_tutorial-complications_and_complex_selects:

--------------------------------------------------------------------------------
Complications and complex SELECTs
--------------------------------------------------------------------------------

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
NULLs
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Insert more rows, containing NULL values.

NULL is not the same as Lua nil; it commonly is
used in SQL for unknown or not-applicable.

.. code-block:: sql

    INSERT INTO table2 VALUES (1, NULL, X'4142', 5.5);
    INSERT INTO table2 VALUES (0, '!!@', NULL, NULL);
    INSERT INTO table2 VALUES (0, '!!!', X'00', NULL);

The result will be:

* The first ``INSERT`` will fail because NULL is not
  permitted for a column that was defined with a
  ``PRIMARY KEY`` clause.
* The other ``INSERT`` statements will succeed.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Indexes
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Make a new index on column4.

There already is an index for the primary key.
Indexes are useful for making queries faster.
In this case, the index also acts as a constraint,
because it prevents two rows from having the same
values in ``column4``. However, it is not an error that
``column4`` has multiple occurrences of NULLs.

.. code-block:: sql

    CREATE UNIQUE INDEX i ON table2 (column4);

The result will be: "``rowcount: 1``" (no error).

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Create a subset table
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Make a table which will have some of the columns
of ``table2``, and some of the rows of ``table2``.

You can do this by combining ``INSERT`` with ``SELECT``.
Then select everything in the resultant subset table.

.. code-block:: sql

    CREATE TABLE table3 (column1 INTEGER, column2 VARCHAR(100), PRIMARY KEY
    (column2));
    INSERT INTO table3 SELECT column1, column2 FROM table2 WHERE column1 <> 2;
    SELECT * FROM table3;

The result will be:

.. code-block:: tarantoolsession

    - - [-1000, '']
      - [0, '!!!']
      - [0, '!!@']
      - [1, 'AB']
      - [1, 'CD']

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
SELECT with a subquery
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

A subquery is a query within a query.

Here we find all the rows in ``table2`` whose
``(column1, column2)`` values are not in ``table3``.

.. code-block:: sql

    SELECT * FROM table2 WHERE (column1, column2) NOT IN (SELECT column1,
    column2 FROM table3);

The result is, unsurprisingly, the single row
which we deliberately excluded when we inserted
the rows in the ``INSERT ... SELECT`` statement:

.. code-block:: tarantoolsession

    - - [2, 'AB', '  ', 12.34567]

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
SELECT with a join
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

A join is a combination of two tables.
There is more than one way to do them in Tarantool:
"Cartesian joins", "left outer joins", etc.

Here we're just showing the most typical case,
where column values from one table match column
values from another table.

.. code-block:: sql

    SELECT * FROM table2, table3
        WHERE table2.column1 = table3.column1 AND table2.column2 = table3.column2
        ORDER BY table2.column4;

The result will be:

.. code-block:: tarantoolsession

    - - [0, '!!!', "\0", null, 0, '!!!']
      - [0, '!!@', null, null, 0, '!!@']
      - [-1000, '', '', 0, -1000, '']
      - [1, 'AB', 'AB', 5.5, 1, 'AB']
      - [1, 'CD', ' ', 10000, 1, 'CD']

.. _sql_tutorial-constraints_affecting_updates:

--------------------------------------------------------------------------------
Constraints affecting updates
--------------------------------------------------------------------------------

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
CREATE TABLE, with a CHECK clause
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

First we make a table which includes a "constraint"
that there must not be any rows containing 13 in
``column2``. Then we try to insert such a row.

.. code-block:: sql

    CREATE TABLE table4 (column1 INTEGER PRIMARY KEY, column2 INTEGER, CHECK
    (column2 <> 13));
    INSERT INTO table4 VALUES (12, 13);

Result: the insert fails, as it should, with the message
"``'Check constraint failed ''ck_unnamed_TABLE4_1'': column2 <> 13'``".

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
CREATE TABLE, with a FOREIGN KEY clause
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

First we make a table which includes a "constraint"
that there must not be any rows containing values
that do not appear in ``table2``.

When we made ``table2``, we specified that its "primary key"
columns were ``(column1, column2)``.

.. code-block:: sql

    CREATE TABLE table5 (column1 INTEGER, column2 VARCHAR(100),
        PRIMARY KEY (column1),
        FOREIGN KEY (column1, column2) REFERENCES table2 (column1, column2));
    INSERT INTO table5 VALUES (2,'AB');
    INSERT INTO table5 VALUES (3,'AB');

Result:

* The first ``INSERT`` statement succeeds because
  ``table3`` contains a row with ``[2, 'AB', ' ', 12.34567]``.
* The second INSERT statement, correctly, fails with the message
  "``Failed to execute SQL statement: FOREIGN KEY constraint failed``".

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
UPDATE
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Due to earlier INSERT statements, these values
are in ``table2 column4``: ``{0, NULL, NULL, 5.5, 10000, 12.34567}``.
We will add 5 to every one of them except the one with 0.
(Adding 5 to NULL will result in NULL, as SQL arithmetic requires.)
Then we'll use ``SELECT`` to see what happened to ``column4``.

.. code-block:: sql

    UPDATE table2 SET column4 = column4 + 5 WHERE column4 <> 0;
    SELECT column4 FROM table2 ORDER BY column4;

The result is: ``{NULL, NULL, 0, 10.5, 17.34567, 10005}``.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
DELETE
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Due to earlier ``INSERT`` statements, there are now 6 rows in ``table2``:

.. code-block:: tarantoolsession

    - - [-1000, '', '', 0]
      - [0, '!!!', "\0", null]
      - [0, '!!@', null, null]
      - [1, 'AB', 'AB', 10.5]
      - [1, 'CD', '  ', 10005]
      - [2, 'AB', '  ', 17.34567]

We will try to delete the last and first of these rows.

.. code-block:: sql

    DELETE FROM table2 WHERE column1 = 2;
    DELETE FROM table2 WHERE column1 = -1000;
    SELECT COUNT(column1) FROM table2;

The result will be:

* The first ``DELETE`` statement causes an error message because (remember?)
  there's a foreign-key constraint.
* The second ``DELETE`` statement succeeds.
* The ``SELECT`` statement shows that there are now only 5 rows remaining.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
ALTER TABLE, with a FOREIGN KEY clause
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Now we want to make another "constraint",
that there must not be any rows in ``table1``
containing values that do not appear in ``table5``.
We couldn't do this when we created ``table1``
because at that time ``table5`` did not exist.
But we can add constraints to existing tables with
the ALTER TABLE statement.

.. code-block:: sql

    ALTER TABLE table1 ADD CONSTRAINT c
        FOREIGN KEY (column1) REFERENCES table5 (column1);
    DELETE FROM table1;
    ALTER TABLE table1 ADD CONSTRAINT c
        FOREIGN KEY (column1) REFERENCES table5 (column1);

Result: the ``ALTER TABLE`` statement fails the first time because
there is a row in ``table1``, and ADD CONSTRAINT requires
that the table be empty. But after we delete that row,
the ``ALTER TABLE`` statement succeeds the second time.
Thus we have set up a chain of references, from ``table1``
to ``table5`` and from ``table5`` to ``table2``.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Triggers
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The idea of a trigger is: if a change (``INSERT`` or ``UPDATE``
or ``DELETE``) happens, then a further action -- perhaps
another ``INSERT`` or ``UPDATE`` or ``DELETE`` -- will happen.

There are many variants, the one we'll illustrate here
is: just after doing an update in ``table3``, do an update
in ``table2``. We will specify this as ``FOR EACH ROW``, so
(since there are 5 rows in ``table3``) the trigger will be
activated 5 times.

.. code-block:: sql

    SELECT column4 FROM table2 WHERE column1 = 2;
    CREATE TRIGGER tr AFTER UPDATE ON table3 FOR EACH ROW
    BEGIN UPDATE table2 SET column4 = column4 + 1 WHERE column1 = 2; END;
    UPDATE table3 SET column2 = column2;
    SELECT column4 FROM table2 WHERE column1 = 2;

Result:

* The first ``SELECT`` shows that the original value of
  ``column4`` in ``table2`` where ``column1 = 2`` was: 17.34567.
* The second ``SELECT`` returns:

  .. code-block:: tarantoolsession

      - - [22.34567]

.. _sql_tutorial-operators_and_functions:

--------------------------------------------------------------------------------
Operators and functions
--------------------------------------------------------------------------------

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
String operations
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

You can manipulate string data (usually defined with CHAR
or VARCHAR data types) in many ways.

We'll illustrate here:

* the ``||`` operator for concatenation and
* the ``SUBSTR`` function for extraction.

.. code-block:: sql

    SELECT column2, column2 || column2, SUBSTR(column2, 2, 1) FROM table2;

The result will be:

.. code-block:: tarantoolsession

    - - ['!!!', '!!!!!!', '!']
      - ['!!@', '!!@!!@', '!']
      - ['AB', 'ABAB', 'B']
      - ['CD', 'CDCD', 'D']
      - ['AB', 'ABAB', 'B']


~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Number operations
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

You can also manipulate number data (usually defined with INTEGER
or DOUBLE data types) in many ways.

We'll illustrate here:

* the ``<<`` operator for shift left and
* the ``%`` operator for modulo.

.. code-block:: sql

    SELECT column1, column1 << 1, column1 << 2, column1 % 2 FROM table2;

The result will be:

.. code-block:: tarantoolsession

    - - [0, 0, 0, 0]
      - [0, 0, 0, 0]
      - [1, 2, 4, 1]
      - [1, 2, 4, 1]
      - [2, 4, 8, 0]

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ranges and limits
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Tarantool can handle:

* integers anywhere in the 4-byte integer range,
* approximate-numerics anywhere in the 8-byte IEEE floating point range,
* any Unicode characters, with UTF-8 encoding and a choice of collations.

Here we will insert some such values in a new table, and see what happens
when we select them, with arithmetic on a number column and
ordering by a string column.

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

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Views
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

A view, or "viewed table", is virtual, that is,
its rows aren't physically in the database,
their values are calculated from other tables.

Here we'll create a view ``v3`` based on ``table3``,
then we select from it.

.. code-block:: sql

    CREATE VIEW v3 AS SELECT SUBSTR(column2,1,2), column4 FROM t6 WHERE
    column4 >= 0;
    SELECT * FROM v3;

The result is:

.. code-block:: tarantoolsession

    - - ['АБ', 123456.123456]
      - ['FA', 1e-06]
      - ['GD', 1e+30]

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Common table expressions
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

By putting ``WITH`` + ``SELECT`` in front of a ``SELECT``,
we can make a sort of temporary view that lasts
for the duration of the statement.

Here we'll select from the sort of temporary view.

.. code-block:: sql

    WITH cte AS (
                 SELECT SUBSTR(column2,1,2), column4 FROM t6 WHERE column4
                 >= 0)
    SELECT * FROM cte;

Result: the same as the result we got with ``CREATE VIEW`` earlier:

.. code-block:: tarantoolsession

    - - ['АБ', 123456.123456]
      - ['FA', 1e-06]
      - ['GD', 1e+30]

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
VALUES
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Tarantool can handle statements like ``SELECT 55;``
(select without ``FROM``) like some other popular DBMSs.
But it also handles the more standard statement
``VALUES (expression [, expression ...]);``.

Here we'll use both styles.

.. code-block:: sql

    SELECT 55 * 55, 'The rain in Spain';
    VALUES (55 * 55, 'The rain in Spain');

The result of either statement will be:

.. code-block:: tarantoolsession

    - - [3025, 'The rain in Spain']

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Metadata
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

What database objects have we created? We can find out about:

* tables with ``SELECT * FROM "_space";``
* indexes with ``SELECT * FROM "_index";``
* triggers with ``SELECT * FROM "_trigger";``
  (These names will be familiar to old Tarantool users
  because we're actually selecting from NoSQL "system spaces".)

Here we will select from ``_space``.

.. code-block:: sql

    SELECT "id", "name", "owner", "engine" FROM "_space" WHERE "name"='TABLE3';

The result is (we know we will get a row because we created ``table3`` earlier):

.. code-block:: tarantoolsession

    - - [517, 'TABLE3', 1, 'memtx']

.. _sql_tutorial-calling_from_a_host_language:

--------------------------------------------------------------------------------
Calling from a host language to make a big table
--------------------------------------------------------------------------------

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
box.execute()
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Now we will change the settings so that the
console accepts statements written in Lua instead
of statements written in SQL. (More ways to switch languages
will exist in Tarantool clients in our next version.)

This doesn't mean we have left the SQL world though, because we
can invoke SQL statements using a Lua function:
``box.execute(string)``.

Here we'll switch languages,
and ask to select again what's in ``table3``.
These statements must be entered separately.

.. code-block:: tarantoolsession

    tarantool> \set language lua
    tarantool> box.execute([[SELECT * FROM table3;]]);

Showing both the statements and the results:

.. code-block:: tarantoolsession

    tarantool> \set language lua
    ---
    ...
    tarantool> box.execute([[SELECT * FROM table3;]]);
    ---
    - - [-1000, '']
      - [0, '!!!']
      - [0, '!!@']
      - [1, 'AB']
      - [1, 'CD']
    ...

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Create a million-row table
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

We've illustrated a lot of SQL, but does it scale?
To answer that, let's make a bigger table.

For this we are going to use Lua. We will not
explain the Lua, because that's in the Lua section
of the Tarantool manual. Just copy-and-paste these
instructions and wait for about a minute.

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

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Select from a million-row table
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Now that we have something a bit larger to play with,
let's see how long it takes to SELECT.

The first query we'll do will automatically go via
an index, because ``s1`` is the primary key.

The second query we'll do will not go via
an index, because for ``s2`` we didn't say
``CREATE INDEX xxxx ON tester (s2);``.

.. code-block:: lua

    box.execute([[SELECT * FROM tester WHERE s1 = 73446;]]);
    box.execute([[SELECT * FROM tester WHERE s2 LIKE 'QFML%';]]);

The result is:

* the first statement will finish instantaneously,
* the second statement will be noticeably slower but still
  a fraction of a second.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Cleanup and exit
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

We're done. We've shown that Tarantool 2.x has a
very reasonable subset of SQL, and it works.

The rest of these commands will simply destroy all
the database objects that were created so that you
can do the demonstration again.
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
