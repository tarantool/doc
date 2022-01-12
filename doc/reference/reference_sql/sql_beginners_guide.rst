.. _sql_beginners_guide:

--------------------------------------------------------------------------------
SQL beginners' guide
--------------------------------------------------------------------------------

The Beginners' Guide describes how users can start up with SQL with Tarantool, and necessary concepts.

The SQL Beginners' Guide is about databases in general, and about the relationship between
Tarantool's NoSQL and SQL products.
Most of the matters in the Beginners' Guide will already be familiar to people who have used relational databases before.

**Sample Simple Table**

In football training camp it is traditional for the trainer to begin by showing a football
and saying "this is a football". In that spirit, this is a table:

.. code-block:: none

    TABLE
              [1]              [2]              [3]
           +-----------------+----------------+----------------+
     Row#1 | Row#1,Column#1  | Row#1,Column#2 | Row#1,Column#3 |
           +-----------------+----------------+----------------+
     Row#2 | Row#2,Column#1  | Row#2,Column#2 | Row#2,Column#3 |
           +-----------------+----------------+----------------+
     Row#3 | Row#3,Column#1  | Row#3,Column#2 | Row#3,Column#3 |
           +-----------------+----------------+----------------+

but the labels are misleading -- we usually don't identify rows and columns by their ordinal positions,
we prefer to pick out specific items by their contents. In that spirit, this is a table:

.. code-block:: none

    MODULES

    +-----------------+------+---------------------+
    | NAME            | SIZE | PURPOSE             |
    +-----------------+------+---------------------+
    | box             | 1432 | Database Management |
    | clock           |  188 | Seconds             |
    | crypto          |    4 | Cryptography        |
    +-----------------+------+---------------------+

so we do not use longitude/latitude navigation by talking about "Row#2 Column #2",
we use the contents of the Name column and the name of the Size column
by talking about "the size, where the name is 'clock'".
To be more exact, this is what we say:

``SELECT size FROM modules WHERE name = 'clock';``

If you're familiar with Tarantool's architecture -- and we hope that you read
about that before coming to this chapter -- then you know that there is a NoSQL
way to get the same thing:

``box.space.MODULES:select()[2][2]``

Well, you can do that. One of the advantages of Tarantool is that if you can get
data via an SQL statement, then you can get the same data via a NoSQL request.
But the reverse is not true, because not all NoSQL tuple sets are definable
as SQL tables. These restrictions apply for SQL that do not apply for NoSQL: |br|
1. Every column must have a name. |br|
2. Every column must have a scalar type (Tarantool is relaxed about
which particular scalar type you can have, but there is no way to index and
search arrays, tables within tables, or what MessagePack calls "maps".)

Tarantool/NoSQL's "format" clause causes the same restrictions.

So an SQL "table" is a NoSQL "tuple set with format restrictions",
an SQL "row" is a NoSQL "tuple", an SQL "column" is a NoSQL "list of fields within a tuple set".

**Creating a table**

This is how to create the modules table:

``CREATE TABLE modules (name STRING, size INTEGER, purpose STRING, PRIMARY KEY (name));``

The words that are IN CAPITAL LETTERS are "keywords" (although it is only a convention in
this manual that keywords are in capital letters, in practice many programmers prefer to avoid shouting).
A keyword has meaning for the SQL parser so many keywords are reserved, they cannot be used as names
unless they are enclosed inside quotation marks.

The word "modules" is a "table name", and the words "name" and "size" and "purpose" are "column names".
All tables and all columns must have names.

The words "STRING" and "INTEGER" are "data types".
STRING means "the contents should be characters, the length is indefinite, the equivalent NoSQL type is 'string''".
INTEGER means "the contents should be numbers without decimal points, the equivalent NoSQL type is 'integer'".
Tarantool supports other data types but our example table has data types from the two main groups,
namely, data types for numbers and data types for strings.

The final clause, PRIMARY KEY (name), means that the name column is the main column used to identify the row.

.. _sql_nulls:

**Nulls**

Frequently it is necessary, at least temporarily, that a column value should be NULL.
Typical situations are: the value is unknown, or the value is not applicable.
For example, you might make a module as a placeholder but you don't want to say its size or purpose.
If such things are possible, the column is "nullable".
Our name column cannot contain nulls, and it could be defined explicitly as "name STRING NOT NULL",
but in this case that's unnecessary -- a column defined as PRIMARY KEY is automatically NOT NULL.

Is a NULL in SQL the same thing as a nil in Lua?
No, but it is close enough that there will be confusion.
When nil means "unknown" or "inapplicable", yes.
But when nil means "nonexistent" or "type is nil", no.
NULL is a value, it has a data type because it is inside a column which is defined with that data type. 

**Creating an index**

This is how to create indexes for the modules table:

``CREATE INDEX size ON modules (size);`` |br|
``CREATE UNIQUE INDEX purpose ON modules (purpose);``

There is no need to create an index on the name column,
because Tarantool creates an index automatically when it sees a PRIMARY KEY clause in the CREATE TABLE statement.
In fact there is no need to create indexes on the size or purpose columns
either -- if indexes don't exist, then it is still possible to use the columns for searches.
Typically people create non-primary indexes, also called secondary indexes,
when it becomes clear that the table will grow large and searches will be frequent,
because searching with an index is generally much faster than searching without an index.

Another use for indexes is to enforce uniqueness.
When an index is created with CREATE UNIQUE INDEX for the purpose column,
it is not possible to have duplicate values in that column.

**Data change**

Putting data into a table is called "inserting".
Changing data is called "updating".
Removing data is called "deleting".
Together, the three SQL statements INSERT plus UPDATE plus DELETE are the three main "data-change" statements.

This is how to insert, update, and delete a row in the modules table:

``INSERT INTO modules VALUES ('json', 14, 'format functions for JSON');`` |br|
``UPDATE modules SET size = 15 WHERE name = 'json';`` |br|
``DELETE FROM modules WHERE name = 'json';``

The corresponding non-SQL Tarantool requests would be:

``box.space.MODULES:insert{'json', 14, 'format functions for JSON'}`` |br|
``box.space.MODULES:update('json', {{'=', 2, 15}})`` |br|
``box.space.MODULES:delete{'json'}`` |br|

This is how we would populate the table with the values that we showed earlier:

``INSERT INTO modules VALUES ('box', 1432, 'Database Management');`` |br|
``INSERT INTO modules VALUES ('clock', 188, 'Seconds');`` |br|
``INSERT INTO modules VALUES ('crypto', 4, 'Cryptography');`` |br|

**Constraints**

Some data-change statements are illegal due to something in the table's definition.
This is called "constraining what can be done". We have already seen some types of constraints ...

NOT NULL -- if a column is defined with a NOT NULL clause, it is illegal to put NULL into it.
A primary-key column is automatically NOT NULL.

UNIQUE -- if a column has a UNIQUE index, it is illegal to put a duplicate into it.
A primary-key column automatically has a UNIQUE index.

data domain -- if a column is defined as having data type INTEGER, it is illegal to put a non-number into it.
More generally, if a value doesn't correspond to the data type of the definition, it is illegal.
Some database management systems (DBMSs) are very forgiving and will try to
make allowances for bad values rather than reject them; Tarantool is a bit more strict than those DBMSs.

Now, here are other types of constraints ...

CHECK -- a table description can have a clause "CHECK (conditional expression)".
For example, if the CREATE TABLE modules statement looked like this:

.. code-block:: sql

    CREATE TABLE modules (name STRING,
                          size INTEGER,
                          purpose STRING,
                          PRIMARY KEY (name),
                          CHECK (size > 0));

then this INSERT statement would be illegal: |br|
``INSERT INTO modules VALUES ('box', 0, 'The Database Kernel');`` |br|
because there is a CHECK constraint saying that the second column, the size column,
cannot contain a value which is less than or equal to zero. Try this instead: |br|
``INSERT INTO modules VALUES ('box', 1, 'The Database Kernel');``

FOREIGN KEY -- a table description can have a clause
"FOREIGN KEY (column-list) REFERENCES table (column-list)".
For example, if there is a new table "submodules" which in a way depends on the modules table,
it can be defined like this:

.. code-block:: sql

    CREATE TABLE submodules (name STRING,
                             module_name STRING,
                             size INTEGER,
                             purpose STRING,
                             PRIMARY KEY (name),
                             FOREIGN KEY (module_name) REFERENCES
                             modules (name));

Now try to insert a new row into this submodules table:

``INSERT INTO submodules VALUES`` |br|
|nbsp| |nbsp| ``('space', 'Box', 10000, 'insert etc.');``

The insert will fail because the second column (module_name)
refers to the name column in the modules table, and the name
column in the modules table does not contain 'Box'.
However, it does contain 'box'.
By default searches in Tarantool's SQL use a binary collation. This will work:

``INSERT INTO submodules`` |br|
|nbsp| |nbsp| ``VALUES ('space', 'box', 10000, 'insert etc.');``

Now try to delete the corresponding row from the modules table:

``DELETE FROM modules WHERE name = 'box';``

The delete will fail because the second column (module_name) in the submodules
table refers to the name column in the modules table, and the name column
in the modules table would not contain 'box' if the delete succeeded.
So the FOREIGN KEY constraint affects both the table which contains
the FOREIGN KEY clause and the table that the FOREIGN KEY clause refers to.

The constraints in a table's definition -- NOT NULL, UNIQUE, data domain, CHECK,
and FOREIGN KEY -- are guarantors of the database's integrity.
It is important that they are fixed and well-defined parts of the definition,
and hard to bypass with SQL.
This is often seen as a difference between SQL and NoSQL -- SQL emphasizes law and order,
NoSQL emphasizes freedom and making your own rules.

**Table Relationships**

Think about the two tables that we have discussed so far:

.. code-block:: sql

    CREATE TABLE modules (name STRING,
                          size INTEGER,
                           purpose STRING,
                           PRIMARY KEY (name),
                           CHECK (size > 0));

    CREATE TABLE submodules (name STRING,
                             module_name STRING,
                             size INTEGER,
                             purpose STRING,
                             PRIMARY KEY (name),
                             FOREIGN KEY (module_name) REFERENCES
                             modules (name));

.. COMMENT
   [Addition suggested by Konstantin Osipov in another document, moved to here]
   By defining a relationship using a REFERENCES clause, you tell the DBMS that
   it should keep an eye on the data in the module_name column of submodules table: 
   it may store only the names of existing modules, as recorded in the ‘name’ column of the modules table.

Because of the FOREIGN KEYS clause in the submodules table, there is clearly a many-to-one relationship: |br|
submodules -->> modules |br|
that is, every submodules row must refer to one (and only one) modules row,
while every modules row can be referred to in zero or more submodules rows.

Table relationships are important, but beware:
do not trust anyone who tells you that databases made with SQL are relational
"because there are relationships between tables".
That is wrong. We will see why when we talk about what makes a database relational, later.

**Selecting with WHERE**

We gave a simple example of a SELECT statement earlier:

``SELECT size FROM modules WHERE name = 'clock';``

The clause "WHERE name = 'clock'" is legal in other statements -- we
have seen it in UPDATE and DELETE -- but here we will only give examples with SELECT.

The first variation is that the WHERE clause does not have to be specified at all,
it is optional. So this statement would return all rows:

``SELECT size FROM modules;``

The second variation is that the comparison operator does not have to be '=',
it can be anything that makes sense: '>' or '>=' or '<' or '<=',
or 'LIKE' which is an operator that works with strings that may
contain wildcard characters '_' meaning 'match any one character'
or '%' meaning 'match any zero or one or many characters'.
These are legal statements which return all rows:

``SELECT size FROM modules WHERE name >= '';`` |br|
``SELECT size FROM modules WHERE name LIKE '%';``

The third variation is that IS [NOT] NULL is a special condition.
Remembering that the NULL value can mean "it is unknown what the value should be",
and supposing that in some row the size is NULL,
then the condition "size > 10" is not certainly true and it is not certainly false,
so it is evaluated as "unknown".
Ordinarily the application of a WHERE clause filters out both false and unknown results.
So when searching for NULL, say IS NULL;
when searching anything that is not NULL, say IS NOT NULL.
This statement will return all rows because (due to the definition) there are no NULLs in the name column:

``SELECT size FROM modules WHERE name IS NOT NULL;``

The fourth variation is that conditions can be combined with AND / OR, and negated with NOT.

So this statement would return all rows (the first condition is false
but the second condition is true, and OR means "return true if either condition is true"):

.. code-block:: sql

    SELECT size
    FROM modules
    WHERE name = 'wombat' OR size IS NOT NULL;

**Selecting with a select list**

Yet again, here is a simple example of a SELECT statement:

``SELECT size FROM modules WHERE name = 'clock';``

The words between SELECT and FROM are the select list.
In this case, the select list is just one word: size.
Formally it means that the desire is to return the size values,
and technically the name for picking a particular column is called "projection".

The first variation is that one can specify any column in any order:

``SELECT name, purpose, size FROM modules;``

The second variation is that one can specify an expression,
it does not have to be a column name, it does not even have to include a column name.
The common expression operators for numbers are the arithmetic operators ``+ - / *``;
the common expression operator for strings is the concatenation operator ||.
For example this statement will return 8, 'XY':

``SELECT size * 2, 'X' || 'Y' FROM modules WHERE size = 4;``

The third variation is that one can add a clause [AS name] after every expression,
so that in the return the column titles will make sense.
This is especially important when a title might otherwise be ambiguous or meaningless.
For example this statement will return 8, 'XY' as before

``SELECT size * 2 AS double_size, 'X' || 'Y' AS concatenated_literals  FROM modules`` |br|
|nbsp| |nbsp| ``WHERE size = 4;``

but displayed as a table the result will look like

.. code-block:: none

      +----------------+------------------------+
      | DOUBLE_SIZE    | CONCATENATED_LITERALS  |
      +----------------+------------------------+
      |              8 | XY                     |
      +----------------+------------------------+

**Selecting with a select list with asterisk**

Instead of listing columns in a select list, one can just say ``'*'``. For example

``SELECT * FROM modules;``

This is the same thing as

``SELECT name, size, purpose FROM modules;``

Selecting with ``"*"``  saves time for the writer,
but it is unclear to a reader who has not memorized what the column names are.
Also it is unstable, because there is a way to change a table's
definition (the ALTER statement, which is an advanced topic).
Nevertheless, although it might be bad to use it for production,
it is handy to use it for introduction, so we will use ``"*"`` in several examples.

**Select with subqueries**

Remember that we have a modules table and we have a submodules table.
Suppose that we want to list the submodules that refer to modules for which the purpose is X.
That is, this involves a search of one table using a value in another table.
This can be done by enclosing "(SELECT ...)" within the WHERE clause. For example:

.. code-block:: sql

    SELECT name FROM submodules
    WHERE module_name =
        (SELECT name FROM modules WHERE purpose LIKE '%Database%');

Subqueries are also useful in the select list, when one wishes to combine
information from more than one table.
For example this statement will display submodules rows but will include values that come from the modules table:

.. code-block:: sql

    SELECT name AS submodules_name,
        (SELECT purpose FROM modules
         WHERE modules.name = submodules.module_name)
         AS modules_purpose,
        purpose AS submodules_purpose
    FROM submodules;

Whoa. What are "modules.name" and "submodules.name"?
Whenever you see "x . y" you are looking at a "qualified column name",
and the first part is a table identifier, the second part is a column identifier.
It is always legal to use qualified column names, but until now it has not been necessary.
Now it is necessary, or at least it is a good idea, because both tables have a column named "name".

The result will look like this:

.. code-block:: none

      +-------------------+------------------------+--------------------+
      | SUBMODULES_NAME   | MODULES_PURPOSE        | SUBMODULES_PURPOSE |
      +-------------------+------------------------+--------------------+
      | space             | Database Management    | insert etc.        |
      +-------------------+------------------------+--------------------+

Perhaps you have read somewhere that SQL stands for "Structured Query Language".
That is not true any more.
But it is true that the query syntax allows for a structural component,
namely the subquery, and that was the original idea.
However, there is a different way to combine tables -- with joins instead of subqueries.

**Select with Cartesian join**

Until now we have only used "FROM modules" or "FROM submodules" in our SELECT statements.
What if we used more than one table in the FROM clause? For example

``SELECT * FROM modules, submodules;`` |br|
or
``SELECT * FROM modules JOIN submodules;``

That is legal. Usually it is not what you want, but it is a learning aid. The result will be:

.. code-block:: none

    { columns from modules table }         { columns from submodules table }
    +--------+------+---------------------+-------+-------------+-------+-------------+
    | NAME   | SIZE | PURPOSE             | NAME  | MODULE_NAME | SIZE  | PURPOSE     |
    +--------+------+---------------------+-------+-------------+-------+-------------+
    | box    | 1432 | Database Management | space | box         | 10000 | insert etc. |
    | clock  |  188 | Seconds             | space | box         | 10000 | insert etc. |
    | crypto |    4 | Cryptography        | space | box         | 10000 | insert etc. |
    +--------+------+---------------------+-------+-------------+-------+-------------+

It is not an error. The meaning of this type of join is "combine every row in table-1 with every row in table-2".
It did not specify what the relationship should be, so the result has everything,
even when the submodule has nothing to do with the module.

It is handy to look at the above result, called a "Cartesian join" result, to see what we really want.
Probably for this case the row that actually makes sense is the one where the modules.name = submodules.module_name,
and we should make that clear in both the select list and the WHERE clause, thus:

.. code-block:: sql

    SELECT modules.name AS modules_name,
           modules.size AS modules_size,
           modules.purpose AS modules_purpose,
           submodules.name,
           module_name,
           submodules.size,
           submodules.purpose
    FROM modules, submodules
    WHERE modules.name = submodules.module_name;

The result will be:

.. code-block:: none

    +----------+-----------+------------+--------+---------+-------+-------------+
    | MODULES_ |  MODULES_ | MODULES_   | NAME   | MODULE_ | SIZE  | PURPOSE     |
    | NAME     |  SIZE     | PURPOSE    |        | NAME    |       |             |
    +----------+-----------+--------- --+--------+---------+-------+-------------+
    | box      |      1432 | Database   | space  | box     | 10000 | insert etc. |
    |          |           | Management |        |         |       |             |
    +----------+-----------+------------+--------+---------+-------+-------------+

In other words, you can specify a Cartesian join in the FROM clause,
then you can filter out the irrelevant rows in the WHERE clause,
and then you can rename columns in the select list.
This is fine, and every SQL DBMS supports this.
But it is worrisome that the number of rows in a Cartesian join is always
(number of rows in first table multiplied by number of rows in second table),
which means that conceptually you are often filtering in a large set of rows.

It is good to start by looking at Cartesian joins because they show the concept.
Many people, though, prefer to use different syntaxes for joins because they
look better or clearer. We will look at those alternatives now.

**Select with join with ON clause**

The ON clause would have the same comparisons as the WHERE clause that we illustrated
for the previous section, but by using different syntax we would be making it clear
"this is for the sake of the join".
Readers can see at a glance that it is, in concept at least, an initial step before
the result rows are filtered. For example this

``SELECT * FROM modules JOIN submodules`` |br|
|nbsp| |nbsp| ``ON (modules.name = submodules.module_name);``

is the same as

``SELECT * FROM modules, submodules`` |br|
|nbsp| |nbsp| ``WHERE modules.name = submodules.module_name;``

**Select with join with USING clause**

The USING clause would take advantage of names that are held in common between the two tables,
with the assumption that the intent is to match those columns with '=' comparisons. For example,

``SELECT * FROM modules JOIN submodules USING (name);``

has the same effect as

``SELECT * FROM modules JOIN submodules WHERE modules.name = submodules.name;``

If we had created our table with a plan in advance to use USING clauses,
that would save time. But we did not.
So, although the above example "works", the results will not be sensible.

**Select with natural join**

A natural join would take advantage of names that are held in common between the two tables,
and would do the filtering automatically based on that knowledge, and throw away duplicate columns.

If we had created our table with a plan in advance to use natural joins, that would be very handy.
But we did not. So, although the following example "works", the results won't be sensible.

``SELECT * FROM modules NATURAL JOIN submodules;``

Result: nothing, because modules.name does not match submodules.name,
and so on And even if there had been a result, it would only have included
four columns: name, module_name, size, purpose.

**Select with left join**

Now what if we want to join modules to submodules,
but we want to be sure that we get all the modules?
In other words, we want to get modules even if the condition submodules.module_name = modules.name
is not true, because the module has no submodules.

When that is what we want, the type of join is an "outer join"
(as opposed to the type we have used so far which is an "inner join").
Specifically we will use LEFT [OUTER] JOIN because our main table, modules, is on the left. For example:

.. code-block:: sql

    SELECT *
    FROM modules LEFT JOIN submodules
    ON modules.name = submodules.module_name;

which returns:

.. code-block:: none

    { columns from modules table }         { columns from submodules table }
    +--------+------+---------------------+-------+-------------+-------+-------------+
    | NAME   | SIZE | PURPOSE             | NAME  | MODULE_NAME | SIZE  | PURPOSE     |
    +--------+------+---------------------+-------+-------------+-------+-------------+
    | box    | 1432 | Database Management | space | box         | 10000 | insert etc. |
    | clock  |  188 | Seconds             | NULL  | NULL        | NULL  | NULL        |
    | crypto |    4 | Cryptography        | NULL  | NULL        | NULL  | NULL        |
    +--------+------+---------------------+-------+-------------+-------+-------------+

Thus, for the submodules of the clock module and the submodules of the crypto
module -- which do not exist -- there are NULLs in every column.

**Select with functions**

A function can take any expression, including an expression that contains another function,
and return a scalar value. There are many such functions. We will just describe one, SUBSTR,
which returns a substring of a string.

Format: :samp:`SUBSTR({input-string}, {start-with} [, {length}])`

Description: SUBSTR takes input-string, eliminates any characters before start-with,
eliminates any characters after (start-with plus length), and returns the result.

Example: ``SUBSTR('abcdef', 2, 3)`` returns 'bcd'.

Select with aggregation, GROUP BY, and HAVING

Remember that our modules table looks like this:

.. code-block:: none

    MODULES

    +-----------------+------+---------------------+
    | NAME            | SIZE | PURPOSE             |
    +-----------------+------+---------------------+
    | box             | 1432 | Database Management |
    | clock           |  188 | Seconds             |
    | crypto          |    4 | Cryptography        |
    +-----------------+------+---------------------+


Suppose that we do not want to know all the individual size values,
we just want to know about their aggregation, that is, take the attributes of the collection.
SQL allows aggregation functions including: AVG (average), SUM, MIN (minimum), MAX (maximum), and COUNT.
For example

``SELECT AVG(size), SUM(size), MIN(size), MAX(size), COUNT(size) FROM modules;``

The result will look like this:

.. code-block:: none

     +-----------+-----------+-----------+-----------+-----------+
     | COLUMN_1  | COLUMN_2  | COLUMN_3  | COLUMN_4  | COLUMN_5  |
     +-----------+-----------+-----------+-----------+-----------|
     |       541 |      1624 |         4 |      1432 |         3 |
     +-----------+-----------+-----------+-----------+-----------+

Suppose that we want aggregations, but aggregations of rows that have some common characteristic.
Supposing further, we want to divide the rows into two groups, the ones whose names
begin with 'b' and the ones whose names begin with 'c'.
This can be done by adding a clause [GROUP BY expression]. For example,

.. code-block:: sql

    SELECT SUBSTR(name, 1, 1), AVG(size), SUM(size), MIN(size), MAX(size), COUNT(size)
    FROM modules
    GROUP BY SUBSTR(name, 1, 1);

The result will look like this:

.. code-block:: none

     +------------+--------------+-----------+-----------+-----------+-------------+
     | COLUMN_1   | COLUMN_2     | COLUMN_3  | COLUMN_4  | COLUMN_5  | COLUMN_6    |
     +------------+--------------+-----------+-----------+-----------+-------------+
     | b          |         1432 |      1432 |      1432 |      1432 |           1 |
     | c          |           96 |       192 |         4 |       188 |           2 |
     +------------+--------------+-----------+-----------+-----------+-------------+


**Select with common table expression**

It is possible to define a temporary (viewed) table within a statement,
usually within a SELECT statement, using a WITH clause. For example:

``WITH tmp_table AS (SELECT x1 FROM t1) SELECT * FROM tmp_table;``

**Select with order, limit, and offset clauses**

Every time we have searched in the modules table, the rows have come out in alphabetical order by name:
'box', then 'clock', then 'crypto'.
However, if we want to be sure about the order, or if we want a different order,
we will have to be explicit and add a clause:
``ORDER BY column-name [ASC|DESC]``.
(ASC stands for ASCending, DESC stands for DESCending.)
For example:

``SELECT * FROM modules ORDER BY name DESC;``

The result will be the usual rows, in descending alphabetical order: 'crypto' then 'clock' then 'box'.

After the ORDER BY clause we can add a clause LIMIT n, where n is the maximum number of rows that we want. For example:

``SELECT * FROM modules ORDER BY name DESC LIMIT 2;``

The result will be the first two rows, 'crypto' and 'clock'.

After the ORDER BY clause and the LIMIT clause we can add a clause OFFSET n,
where n is the row to start with. The first offset is 0. For example:

``SELECT * FROM modules ORDER BY name DESC LIMIT 2 OFFSET 2;``

The result will be the third row, 'box'.

**Views**

A view is a canned SELECT. If you have a complex SELECT that you want to run frequently, create a view and then do a simple SELECT on the view. For example:

.. code-block:: sql

    CREATE VIEW v AS SELECT size, (size *5) AS size_times_5
    FROM modules
    GROUP BY size, name
    ORDER BY size_times_5;
    SELECT * FROM v;

**Transactions**

Tarantool has a "Write Ahead Log" (WAL).
Effects of data-change statements are logged before they are permanently stored on disk.
This is a reason that, although entire databases can be stored in temporary memory,
they are not vulnerable in case of power failure.

Tarantool supports commits and rollbacks. In effect, asking for a commit means
asking for all the recent data-change statements,
since a transaction began, to become permanent.
In effect, asking for a rollback means asking for all the recent data-change statements,
since a transaction began, to be cancelled.

For example, consider these statements:

.. code-block:: sql

    CREATE TABLE things (remark STRING, PRIMARY KEY (remark));
    START TRANSACTION;
    INSERT INTO things VALUES ('A');
    COMMIT;
    START TRANSACTION;
    INSERT INTO things VALUES ('B');
    ROLLBACK;
    SELECT * FROM things;

The result will be: one row, containing 'A'. The ROLLBACK cancelled the second INSERT statement,
but did not cancel the first one, because it had already been committed.

Ordinarily every statement is automatically committed.

After START TRANSACTION, statements are not automatically committed -- Tarantool considers
that a transaction is now "active", until the transaction ends with a COMMIT statement or a ROLLBACK statement.
While a transaction is active, all statements are legal except another START TRANSACTION.

**Implementing Tarantool's SQL On Top of NoSQL**

Tarantool's SQL data is the same as Tarantool's NoSQL data. When you create a table or an index with SQL,
you are creating a space or an index in NoSQL. For example:

.. code-block:: sql

    CREATE TABLE things (remark STRING, PRIMARY KEY (remark));
    INSERT INTO things VALUES ('X');

is somewhat similar to

.. code-block:: lua

    box.schema.space.create('THINGS',
    {
        format = {
                  [1] = {["name"] = "REMARK", ["type"] = "string"}
                  }
    })
    box.space.THINGS:create_index('pk_unnamed_THINGS_1',{unique=true,parts={1,'string'}})
    box.space.THINGS:insert{'X'}

Therefore you can take advantage of Tarantool's NoSQL features even though your primary language is SQL.
Here are some possibilities.

(1) NoSQL applications written in one of the connector languages may be slightly faster than SQL applications
because SQL statements may require more parsing and may be translated to NoSQL requests.

(2) You can write stored procedures in Lua, combining Lua loop-control and Lua library-access statements with SQL statements.
These routines are executed on the server, which is the principal advantage of pure-SQL stored procedures.

(3) There are some options that are implemented in NoSQL that are not (yet) implemented in SQL.
For example you can use NoSQL to change an index option, and to deny access to users named 'guest'.

(4) System spaces such as _space and _index can be accessed with SQL SELECT statements.
This is not quite the same as an information_schema, but it does mean that you can
use SQL to access the database's metadata catalog.

Fields in NoSQL spaces can be accessed with SQL if and only if they are scalar and are defined
in format clauses. Indexes of NoSQL spaces will be used with SQL if and only if they are TREE indexes.

**Relational Databases**

Edgar F. Codd, the person most responsible for researching and explaining relational database concepts,
listed the main criteria as
(`Codd's 12 rules <https://en.wikipedia.org/wiki/Codd's_12_rules>`_).

Although we do not advertise Tarantool as "relational", we claim that Tarantool complies with these rules,
with the following caveats and exceptions ...

The rules state that all data must be viewable as relations.
A Tarantool SQL table is a relation.
However, it is possible to have duplicate values in SQL tables and it is possible
to have an implicit ordering. Those characteristics are not allowed for true relations.

The rules state that there must be a dynamic online catalog. Tarantool has one but some metadata is missing from it.

The rules state that the data language must support authorization.
Tarantool's SQL does not. Authorization occurs via NoSQL requests.

The rules require that data must be physically independent (from underlying storage changes)
and logically independent (from application program changes).
So far we do not have enough experience to make this guarantee.

The rules require certain types of updatable views. Tarantool's views are not updatable.

The rules state that it should be impossible to use a low-level language to bypass
integrity as defined in the relational-level language.
In our case, this is not true, for example one can execute a request
with Tarantool's NoSQL to violate a foreign-key constraint that was defined with Tarantool's SQL.
