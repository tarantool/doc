.. _sql_sql_beginners_guide:

--------------------------------------------------------------------------------
SQL beginners' guide
--------------------------------------------------------------------------------

**What Tarantool's SQL product delivers**

Tarantool's SQL is a major new feature that was first introduced with Tarantool version 2.1. |br|
The primary advantages are: |br|
- a high level of SQL compatibility |br|
- an easy way to switch from NoSQL to SQL and back |br|
- the Tarantool brand.

The "high level of SQL compatibility" includes support for joins, subqueries, triggers,
indexes, groupings, transactions in a multi-user environment, and conformance with the
majority of the mandatory requirements of the SQL:2016 standard.

The "easy way to switch" consists of the fact that the same tables can be operated
on with SQL and with the  long-established Tarantool-NoSQL product, meaning that
when you want standard Relational-DBMS jobs you can do them, and when you want NoSQL capability
you can have it (Tarantool-NoSQL outperforms other NoSQL products in public benchmarks).

The "Tarantool brand" comes from the support of a multi-billion-dollar internet / mail / social-network
provider, a dozens-of-professionals staff of programmers and support people, a community who believes
in open-source BSD licensing, and hundreds of corporations / government bodies using Tarantool products in production already.

The status of Tarantool's SQL feature is "release". So, it is working now and you can verify
that by downloading it and trying all the features, which we will explain in the rest of this document.
There is also a :ref:`tutorial <sql_tutorial>`.

This document has four parts.
The SQL BEGINNERS' GUIDE explains the basics of relational database management and SQL in particular.
The USER GUIDE explains "How to get Started" and explains the terms and the syntax elements that
apply for all SQL statements.
The SQL STATEMENTS AND CLAUSES guide explains, for each SQL statement, the format and the rules
and the exceptions and the examples and the limitations.
The SQL PLUS LUA guide has the details about calling Lua from SQL, calling SQL from Lua,
and using the same database objects in both SQL and Lua.

Users are expected to know what databases are, and experience with other SQL DBMSs would be an advantage.

**SQL beginners' guide begins**

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

    modules

    +-----------------+------+---------------------+
    | name            | size | purpose             |
    +-----------------|------|---------------------|
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
However, some database management systems (DBMSs) are very forgiving and will try to
make allowances for bad values rather than reject them; Tarantool is one of those DBMSs.

Now, here are other types of constraints ...

CHECK -- a table description can have a clause "CHECK (conditional expression)".
For example, if the CREATE TABLE modules statement looked like this:

.. code-block:: none

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

.. code-block:: none

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

Now try to delete the new row from the modules table:

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

.. code-block:: none

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

.. code-block:: none

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
      | double_size    | concatenated_literals  |
      +----------------+------------------------+
      |               8| XY                     |
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

.. code-block:: none

    SELECT name FROM submodules
    WHERE module_name =
        (SELECT name FROM modules WHERE purpose LIKE '%Database%');

Subqueries are also useful in the select list, when one wishes to combine
information from more than one table.
For example this statement will display submodules rows but will include values that come from the modules table:

.. code-block:: none

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
      | submodules_name   | modules_purpose        | submodules_purpose |
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
    | name   | size | purpose             | name  | module_name | size  | purpose     |
    +--------+------+---------------------+-------+-------------+-------+-------------+
    | box    | 1432 | Database Management | space | box         | 10000 | insert etc. |
    | clock  | 188  | Seconds             | space | box         | 10000 | insert etc. |
    | crypto |   4  | Cryptography        | space | box         | 10000 | insert etc. |
    +--------+------+---------------------+-------+-------------+-------+-------------+

It is not an error. The meaning of this type of join is "combine every row in table-1 with every row in table-2".
It did not specify what the relationship should be, so the result has everything,
even when the submodule has nothing to do with the module.

It is handy to look at the above result, called a "Cartesian join" result, to see what we really want.
Probably for this case the row that actually makes sense is the one where the modules.name = submodules.module_name,
and we should make that clear in both the select list and the WHERE clause, thus:

.. code-block:: none

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
    | modules_ |  modules_ | modules_   | name   | module_ | size  | purpose     |
    | name     |  size     | purpose    |        | name    |       |             |
    +----------+-----------+--------- --+--------+---------+-------+-------------|
    | box      | 1432      | Database   | space  | box     | 10000 | insert etc. |
    |          |           | Management |        |         |       |             |
    +----------+-----------+------------+--------+---------+-------+-------------|

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

.. code-block:: none

    SELECT *
    FROM modules LEFT JOIN submodules
    ON modules.name = submodules.module_name;

which returns:

.. code-block:: none

    { columns from modules table }         { columns from submodules table }
    +--------+------+---------------------+-------+-------------+-------+-------------+
    | name   | size | purpose             | name  | module_name | size  | purpose     |
    +--------+------+---------------------+-------+-------------+-------+-------------+
    | box    | 1432 | Database Management | space | box         | 10000 | insert etc. |
    | clock  | 188  | Seconds             | NULL  | NULL        | NULL  | NULL        |
    | crypto |   4  | Cryptography        | NULL  | NULL        | NULL  | NULL        |
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

    modules

    +-----------------+------+---------------------+
    | name            | size | purpose             |
    +-----------------|------|---------------------|
    | box             | 1432 | Database Management |
    | clock           |  188 | Seconds             |
    | crypto          |    4 | Cryptography        |
    +-----------------+------+---------------------+


Suppose that we do not want to know all the individual size values,
we just want to know about their aggregation, that is, take the attributes of the collection.
SQL allows five aggregation functions: AVG (average), SUM, MIN (minimum), MAX (maximum), and COUNT.
For example

``SELECT AVG(size), SUM(size), MIN(size), MAX(size), COUNT(size) FROM modules;``

The result will look like this:

.. code-block:: none

     +--------------+-----------+-----------+-----------+-------------+
     | AVG(size)    | SUM(size) | MIN(size) | MAX(size) | COUNT(size) |
     +--------------+-----------+-----------+-----------+-------------|
     | 5.413333E+02 | 1624      |         4 |      1432 |           3 |
     +--------------+-----------+-----------+-----------+-------------+

Suppose that we want aggregations, but aggregations of rows that have some common characteristic.
Supposing further, we want to divide the rows into two groups, the ones whose names
begin with 'b' and the ones whose names begin with 'c'.
This can be done by adding a clause [GROUP BY expression]. For example,

.. code-block:: none

    SELECT SUBSTR(name, 1, 1), AVG(size), SUM(size), MIN(size), MAX(size), COUNT(size)
    FROM modules
    GROUP BY SUBSTR(name, 1, 1);

The result will look like this:

.. code-block:: none

     +--------------------+--------------+-----------+-----------+-----------+-------------+
     | SUBSTR(name, 1, 1) | AVG(size)    | SUM(size) | MIN(size) | MAX(size) | CoUNT(size) |
     +--------------------+--------------+-----------+-----------+-----------|-------------|
     | b                  |         1432 |      1432 |      1432 |      1432 |           1 |
     | c                  |           96 |       192 |         4 |       188 |           2 |
     +--------------------+--------------+-----------+-----------+-----------|-------------+


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

.. code-block:: none

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

.. code-block:: none

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

.. code-block:: none

    CREATE TABLE things (remark STRING, PRIMARY KEY (remark));
    INSERT INTO things VALUES ('X');

is somewhat similar to

.. code-block:: none

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

.. _sql_sql_user_guide:

--------------------------------------------------------------------------------
SQL user guide
--------------------------------------------------------------------------------

The User Guide describes how users can start up with SQL with Tarantool, and necessary concepts.

Getting Started

The explanations for installing and starting the Tarantool server are in earlier chapters of the Tarantool manual..

To get started specifically with the SQL features, using Tarantool as a client, execute these requests:

.. code-block:: none

    box.cfg{}
    box.execute([[VALUES ('hello');]])

The bottom of the screen should now look like this: 

.. code-block:: none

    tarantool> box.execute([[VALUES ('hello');]])
    ---
    - metadata:
      - name: column1
        type: string
      rows:
      - ['hello']
    ...

That's an SQL statement done with Tarantool.

Now you are ready to execute any SQL statements via the connection. For example

.. code-block:: none

    box.execute([[CREATE TABLE things (id INTEGER PRIMARY key,
                                       remark STRING);]])
    box.execute([[INSERT INTO things VALUES (55, 'Hello SQL world!');]])
    box.execute([[SELECT * FROM things WHERE id > 0;]])

And you will see the results of the SQL query.

For the rest of this chapter, the
:ref:`box.execute([[...]]) <box-sql>` enclosure will not be shown.
Examples will simply say what a piece of syntax looks like, such as
``SELECT 'hello';`` |br|
and users should know that must be entered as |br|
``box.execute([[SELECT 'hello';]])`` |br|
It is also legal to enclose SQL statements inside single or double quote marks instead of [[ ... ]].

Supported syntax

Keywords, for example CREATE or INSERT or VALUES, may be entered in either upper case or lower case.

Literal values, for example ``55`` or ``'Hello SQL world!'``, should be entered without single quote marks
if they are numeric, and should be entered with single quote marks if they are strings.

Object names, for example table1 or column1, should usually be entered without double quote marks
and are subject to some restrictions. They may be enclosed in double quote marks and in that case
they are subject to fewer restrictions.

Almost all keywords are :ref:`reserved <sql_reserved_words>`,
which means that they cannot be used as object names
unless they are enclosed in double quote marks.

Comments may be between ``/*`` and ``*/`` (bracketed)
or between ``--`` and the end of a line (simple).

.. code-block:: none

    INSERT /* This is a bracketed comment */ INTO t VALUES (5);
    INSERT INTO t VALUES (5); -- this is a simple comment

Expressions, for example ``a + b`` OR ``a > b AND NOT a <= b``, may have arithmetic operators
``+ - / *``, may have comparison operators ``= > < <= >= LIKE``, and may be combined with
``AND OR NOT``, with optional parentheses.

SQL statements should end with ; (semicolon); this is not mandatory but it is recommended.

In alphabetical order, the following statements are legal.

|nbsp| :ref:`ALTER TABLE table-name [RENAME or ADD CONSTRAINT or DROP CONSTRAINT clauses]; <sql_alter_table>` |br|
|nbsp| ANALYZE [table-name]; -- temporarily disabled in current version |br|
|nbsp| :ref:`COMMIT; <sql_commit>` |br|
|nbsp| :ref:`CREATE [UNIQUE] INDEX [IF NOT EXISTS] index-name <sql_create_index>` |br|
|nbsp| |nbsp| |nbsp| |nbsp| :ref:`ON table-name (column-name [, column-name ...]); <sql_create_index>` |br|
|nbsp| :ref:`CREATE TABLE [IF NOT EXISTS] table-name <sql_create_table>` |br|
|nbsp| |nbsp| |nbsp| |nbsp| :ref:`(column-or-constraint-definition <sql_create_table>` |br|
|nbsp| |nbsp| |nbsp| |nbsp| :ref:`[, column-or-constraint-definition ...]) <sql_create_table>` |br|
|nbsp| |nbsp| |nbsp| |nbsp| :ref:`[WITH ENGINE = engine-name]; <sql_create_table>` |br|
|nbsp| :ref:`CREATE TRIGGER [IF NOT EXISTS] trigger-name <sql_create_trigger>` |br|
|nbsp| |nbsp| |nbsp| |nbsp| :ref:`BEFORE|AFTER INSERT|UPDATE|DELETE ON table-name <sql_create_trigger>` |br|
|nbsp| |nbsp| |nbsp| |nbsp| :ref:`FOR EACH ROW <sql_create_trigger>` |br|
|nbsp| |nbsp| |nbsp| |nbsp| :ref:`BEGIN dml-statement [, dml-statement ...] END; <sql_create_trigger>` |br|
|nbsp| :ref:`CREATE VIEW [IF NOT EXISTS] view-name <sql_create_view>`  |br|
|nbsp| |nbsp| |nbsp| |nbsp| :ref:`[(column-name [, column-name ...])] <sql_create_view>`  |br|
|nbsp| |nbsp| |nbsp| |nbsp| :ref:`AS select-statement | values-statement; <sql_create_view>`  |br|
|nbsp| :ref:`DROP INDEX [IF EXISTS] index-name ON table-name; <sql_drop_index>`  |br|
|nbsp| :ref:`DROP TABLE [IF EXISTS] table-name; <sql_drop_table>`  |br|
|nbsp| :ref:`DROP TRIGGER [IF EXISTS] trigger-name; <sql_drop_trigger>` |br|
|nbsp| :ref:`DROP VIEW [IF EXISTS] view-name; <sql_drop_view>` |br|
|nbsp| :ref:`EXPLAIN explainable-statement; <sql_explain>` |br|
|nbsp| :ref:`INSERT INTO table-name <sql_insert>` |br|
|nbsp| |nbsp| |nbsp| |nbsp| :ref:`[(column-name [, column-name ...])] <sql_insert>` |br|
|nbsp| |nbsp| |nbsp| |nbsp| :ref:`values-statement | select-statement; <sql_insert>` |br|
|nbsp| :ref:`PRAGMA pragma-name[(value)]; <sql_pragma>` |br|
|nbsp| :ref:`RELEASE SAVEPOINT savepoint-name; <sql_release_savepoint>` |br|
|nbsp| :ref:`REPLACE INTO table-name VALUES (expression [, expression ...]); <sql_replace>` |br|
|nbsp| :ref:`ROLLBACK [TO [SAVEPOINT] savepoint-name]; <sql_rollback>` |br|
|nbsp| :ref:`SAVEPOINT savepoint-name; <sql_savepoint>` |br|
|nbsp| :ref:`SELECT [DISTINCT|ALL] expression [, expression ...] <sql_select>` |br|
|nbsp| |nbsp| |nbsp| |nbsp| :ref:`FROM table-name | joined-table-names [AS alias]  <sql_select>` |br|
|nbsp| |nbsp| |nbsp| |nbsp| :ref:`[WHERE expression] <sql_select>` |br|
|nbsp| |nbsp| |nbsp| |nbsp| :ref:`[GROUP BY expression [, expression ...]] <sql_group_by>` |br|
|nbsp| |nbsp| |nbsp| |nbsp| :ref:`[HAVING expression] <sql_having>` |br|
|nbsp| |nbsp| |nbsp| |nbsp| :ref:`[ORDER BY expression] <sql_order_by>` |br|
|nbsp| |nbsp| |nbsp| |nbsp| :ref:`LIMIT expression [OFFSET expression]]; <sql_limit>` |br|
|nbsp| :ref:`START TRANSACTION; <sql_start_transaction>` |br|
|nbsp| :ref:`TRUNCATE TABLE table-name; <sql_truncate>` |br|
|nbsp| :ref:`UPDATE table-name <sql_update>` |br|
|nbsp| |nbsp| |nbsp| |nbsp| :ref:`SET column-name=expression [,column-name=expression...] <sql_update>` |br|
|nbsp| |nbsp| |nbsp| |nbsp| :ref:`[WHERE expression]; <sql_update>` |br|
|nbsp| :ref:`VALUES (expression [, expression ...]; <sql_values>` |br|
|nbsp| :ref:`WITH [RECURSIVE] common-table-expression; <sql_with>`

Differences from other products

Differences from other SQL products:
We believe that Tarantool's SQL conforms to the majority of the listed
mandatory requirements of the core SQL:2016 standard, and we
enumerate the specific conformance statements in the feature list
in a section about :ref:`"compliance with the official SQL standard" <sql>`.
We believe that the deviations which most people will find notable are:
type checking is less strict,
and some data definition options must be done with NoSQL syntax.

Differences from other NoSQL products:
We have examined attempts by others to paste relatively smaller
subsets of SQL onto NoSQL products, and concluded that Tarantool's
SQL has demonstrably more features and capabilities.
The reason is that we started with a complete code base of
a working SQL DBMS and made it work with Tarantool-NoSQL underneath,
rather than starting with a NoSQL DBMS and adding syntax to it.

Concepts

In an earlier section of this documentation, we discussed: |br|
What are: relational databases, tables, views, rows, and columns? |br|
What are: transactions, write-ahead logs, commits and rollbacks? |br|
What are: security considerations? |br|
How do we: add, delete, or update rows in tables? |br|
How do we: work inside transactions with commits and/or rollbacks? |br|
How do we: select, join, filter, group, and sort rows?

Tarantool has a "schema". A schema is a container for all database objects.
A schema may be called a "database" in other DBMS implementations

Tarantool allows four types of "database objects" to be created within
the schema: tables, triggers, indexes, and constraints.
Within tables, there are "columns".

Almost all Tarantool SQL statements begin with a reserved-word "verb"
such as INSERT, and end optionally with a semicolon.
For example: ``INSERT INTO t VALUES (1);``

A Tarantool SQL database and a Tarantool NoSQL database are the same thing.
However, some operations are only possible with SQL, and others are only
possible with NoSQL. Mixing SQL statements with NoSQL requests is allowed.

.. _sql_tokens:

Tokens

The token is the minimum SQL-syntax unit that Tarantool understands.
These are the types of tokens:

Keywords -- official words in the language, for example ``SELECT`` |br|
Literals -- constants for numbers or strings, for example ``15.7`` or ``'Taranto'`` |br|
Identifiers -- for example column55 or table_of_accounts |br|
Operators (strictly speaking "non-alphabetic operators") -- for example ``* / + - ( ) , ; < = >=``

Tokens can be separated from each other by one or more separators: |br|
* White space characters: tab (U+0009), line feed (U+000A), vertical tab (U+000B), form feed (U+000C), carriage return (U+000D), space (U+0020), next line (U+0085), and all the rare characters in Unicode classes Zl and Zp and Zs. For a full list see https://github.com/tarantool/tarantool/issues/2371. |br|
* Bracketed comments (beginning with ``/*`` and ending with ``*/``) |br|
* Simple comments (beginning with ``--`` and ending with line feed) |br|
Separators are not necessary before or after operators. |br|
Separators are necessary after keywords or numbers or ordinary identifiers, unless the following token is an operator. |br|
Thus Tarantool can understand this series of six tokens: |br|
``SELECT'a'FROM/**/t;`` |br|
but for readability one would usually use spaces to separate tokens: |br|
``SELECT 'a' FROM /**/ t;``

.. _sql_literals:

Literals

There are five kinds of literals: BOOLEAN INTEGER DOUBLE STRING VARBINARY.

BOOLEAN literals:  |br|
TRUE | FALSE | UNKNOWN |br|
A literal has :ref:`data type = BOOLEAN <sql_data_type_boolean>` if it is the keyword TRUE or FALSE.
UNKNOWN is a synonym for NULL.
A literal may have type = BOOLEAN if it is the keyword NULL and there is no context to indicate a different data type.

INTEGER literals: |br|
[plus-sign | minus-sign] digit [digit ...] |br|
or, for a hexadecimal integer literal, |br|
[plus-sign | minus-sign] 0X | 0x hexadecimal-digit [hexadecimal-digit ...] |br|
Examples: 5, -5, +5, 55555, 0X55, 0x55 |br|
Hexadecimal 0X55 is equal to decimal 85.
A literal has :ref:`data type = INTEGER <sql_data_type_integer>` if it contains only digits and is in
the range  -9223372036854775808 to +18446744073709551615, integers outside that range are illegal.

DOUBLE literals: |br|
[plus-sign | minus-sign] [digit [digit ...]] period [digit [digit ...]] |br|
[E|e [plus-sign | minus-sign] digit ...] |br|
Examples: .0, 1.0, 1E5, 1.1E5. |br|
A literal has :ref:`data type = DOUBLE <sql_data_type_double>` if it contains a period, or contains "E".
DOUBLE literals are also known as floating-point literals or approximate-numeric literals.
To represent "Inf" (infinity), write a real number outside the double-precision number range, for example 1E309.
To represent "nan" (not a number), write an expression that does not result in a real number,
for example 0/0, using Tarantool/NoSQL. This will appear as NULL in Tarantool/SQL.
In an earlier version literals containing periods were considered to be :ref:`NUMBER <sql_data_type_number>` literals.
In a future version "nan" may not appear as NULL.

STRING literals: |br|
[quote] [character ...] [quote] |br|
Examples: ``'ABC'``, ``'AB''C'`` |br|
A literal has :ref:`data type type = STRING <sql_data_type_string>`
if it is a sequence of zero or more characters enclosed in single quotes.
The sequence ``''``  (two single quotes in a row) is treated as ``'`` (a single quote) when enclosed in quotes,
that is, ``'A''B'`` is interpreted as ``A'B``.

VARBINARY literals: |br|
X|x [quote] [hexadecimal-digit-pair ...] [quote] |br|
Example: ``X'414243'``, which will be displayed as ``'ABC'``. |br|
A literal has :ref:`data type = VARBINARY <sql_data_type_varbinary>`
("variable-length binary") if it is the letter X followed by quotes containing pairs of hexadecimal digits, representing byte values.

Here are four ways to put non-ASCII characters,such as the Greek letter α alpha,  in string literals: |br|
First make sure that your shell program is set to accept characters as UTF-8. A simple way to check is |br|
``SELECT hex('α');``
If the result is CEB1 -- which is the hexadecimal value for the UTF-8 representation of α -- it is good. |br|
(1) Simply enclose the character inside ``'...'``, |br|
``'α'`` |br|
or |br|
(2) Find out what is the hexadecimal code for the UTF-8 representation of α,
and enclose that inside ``X'...'``, then cast to STRING because ``X'...'`` literals are data type VARBINARY not STRING, |br|
``CAST(X'CEB1' AS STRING)`` |br|
or |br|
(3) Find out what is the Unicode code point for α, and pass that to the :ref:`CHAR function <sql_function_char>`. |br|
``CHAR(945)  /* remember that this is α as data type STRING not VARBINARY */`` |br|
(4) Enclose statements inside double quotes and include Lua escapes, for example
``box.execute("SELECT '\206\177';")`` |br|
One can use the concatenation operator ``||`` to combine characters made with any of these methods.

Limitations: (`Issue#2344 <https://github.com/tarantool/tarantool/issues/2344>`_) |br|
* Numeric literals may be quoted, one cannot depend on the presence or
absence of quote marks to determine whether a literal is numeric. |br|
* ``LENGTH('A''B') = 3`` which is correct, but the display from
``SELECT A''B;`` is ``A''B``, which is misleading. |br|
* It is unfortunate that ``X'41'`` is a byte sequence which looks the same as ``'A'``,
but it is not the same. ``box.execute("select 'A' < X'41';")`` is not legal at the moment.
This happens because ``TYPEOF(X'41')`` yields ``'varbinary'``.
Also it is illegal to say ``UPDATE ... SET string_column = X'41'``,
one must say ``UPDATE ... SET string_column = CAST(X'41' AS STRING);``. |br|
* It is non-standard to say that any number which contains a period has data type = DOUBLE.

.. _sql_identifiers:

Identifiers

All database objects -- tables, triggers, indexes, columns, constraints, functions, collations -- have identifiers.
An identifier should begin with a letter or underscore (``'_'``) and should contain
only letters, digits, dollar signs (``'$'``), or underscores.
The maximum number of bytes in an identifier is between 64982 and 65000.
For compatibility reasons, Tarantool recommends that an identifier should not have more than 30 characters.

Letters in identifiers do not have to come from the Latin alphabet,
for example the Japanese syllabic ひ and the Cyrillic letter д are legal.
But be aware that a Latin letter needs only one byte but a Cyrillic letter needs two bytes,
so Cyrillic identifiers consume a tiny amount more space.

.. _sql_reserved_words:

Certain words are reserved and should not be used for identifiers.
The simple rule is: if a word means something in Tarantool SQL syntax,
do not try to use it for an identifier. The current list of reserved words is:

ALL ALTER ANALYZE AND ANY AS ASC ASENSITIVE AUTOINCREMENT
BEGIN BETWEEN BINARY BLOB BOOL BOOLEAN BOTH BY CALL CASE
CAST CHAR CHARACTER CHECK COLLATE COLUMN COMMIT CONDITION
CONNECT CONSTRAINT CREATE CROSS CURRENT CURRENT_DATE
CURRENT_TIME CURRENT_TIMESTAMP CURRENT_USER CURSOR DATE
DATETIME dec DECIMAL DECLARE DEFAULT DEFERRABLE DELETE DENSE_RANK
DESC DESCRIBE DETERMINISTIC DISTINCT DOUBLE DROP EACH ELSE
ELSEIF END ESCAPE EXCEPT EXISTS EXPLAIN FALSE FETCH FLOAT
FOR FOREIGN FROM FULL FUNCTION GET GRANT GROUP HAVING IF
IMMEDIATE IN INDEX INNER INOUT INSENSITIVE INSERT INT
INTEGER INTERSECT INTO IS ITERATE JOIN LEADING LEAVE LEFT
LIKE LIMIT LOCALTIME LOCALTIMESTAMP LOOP MATCH NATURAL NOT
NULL NUM NUMBER NUMERIC OF ON OR ORDER OUT OUTER OVER PARTIAL
PARTITION PRAGMA PRECISION PRIMARY PROCEDURE RANGE RANK
READS REAL RECURSIVE REFERENCES REGEXP RELEASE RENAME
REPEAT REPLACE RESIGNAL RETURN REVOKE RIGHT ROLLBACK ROW
ROWS ROW_NUMBER SAVEPOINT SCALAR SELECT SENSITIVE SET
SIGNAL SIMPLE SMALLINT SPECIFIC SQL START STRING SYSTEM TABLE
TEXT THEN TO TRAILING TRANSACTION TRIGGER TRIM TRUE
TRUNCATE UNION UNIQUE UNKNOWN UNSIGNED UPDATE USER USING VALUES
VARBINARY VARCHAR VIEW WHEN WHENEVER WHERE WHILE WITH

.. COMMENT:
   This is the Lua code that I (Peter Gulutzan) use for making the
   list of SQL reserved words.
   I assume the Tarantool 2.3 source is on /home/pgulutzan/tarantool-2.3
   I check whether I can create tables with names in the
   source file mkkeywordhash.c.
   This is only reliable if the database is new and empty.
   This is only reliable if mkkeywordhash.c keywords,
   and only keywords, are listed exactly this way:
   { "ROW_NUMBER",             "TK_STANDARD", RESERVED,         true  },
   I do not check whether mask = RESERVED or ALWAYS,
   because I would get false positives.
   statement = ''
   keyword = ''
   fh_string = ''
   fio = require('fio')
   fh = fio.open('/home/pgulutzan/tarantool-master/extra/mkkeywordhash.c', {'O_RDONLY'})
   fh_string = fh:read(100000)
   reserved_word_list = {}
   word_start = 1
   function f () local status local err status, err = box.execute(statement) if err == nil then return 0 else print(err) return 1 end end
   while true do
     i, word_start = string.find(fh_string, "\n  { \"", word_start)
     if i == nil then break end
     word_end = string.find(fh_string, "\"", word_start + 1)
     keyword = string.sub(fh_string, word_start+1, word_end-1)
     statement = "CREATE TABLE " .. keyword .. " (" .. keyword .. " INT PRIMARY KEY);"
     if f() == 1 then table.insert(reserved_word_list, keyword) end
     statement = "DROP TABLE IF EXISTS " .. keyword .. ";"
     if keyword ~= "END" and keyword ~= "IF" and keyword ~= "MATCH"
       and keyword ~= "RELEASE" and keyword ~= "RENAME" and keyword ~= "REPLACE"
       and keyword ~= "BINARY" and keyword ~= "CHARACTER" and keyword ~= "SMALLINT"
       then f() end
   end
   table.sort(reserved_word_list)
   fh:close()
   reserved_word_list

Identifiers may be enclosed in double quotes.
These are called quoted identifiers or "delimited identifiers"
(unquoted identifiers may be called "regular identifiers").
The double quotes are not part of the identifier.
A delimited identifier may be a reserved word and may contain
any printable character. Tarantool converts letters in regular
identifiers to upper case before it accesses the database,
so for statements like
``CREATE TABLE a (a INTEGER PRIMARY KEY);``
or
``SELECT a FROM a;``
the table name is A and the column name is A.
However, Tarantool does not convert delimited identifiers
to upper case, so for statements like
``CREATE TABLE "a" ("a" INTEGER PRIMARY KEY);``
or
``SELECT "a" FROM "a";``
the table name is a and the column name is a.
The sequence ``""`` is treated as ``"`` when enclosed in double quotes, 
that is, ``"A""B"`` is interpreted as ``"A"B"``.

Examples: things, t45, journal_entries_for_2017, ддд, ``"into"``

Inside certain statements, identifiers may have "qualifiers" to prevent ambiguity.
A qualifier is an identifier of a higher-level object, followed by a period.
For example column1 within table1 may be referred to as table1.column1.
The "name" of an object is the same as its identifier, or its qualified identifier.
For example, inside ``SELECT t1.column1, t2.column1 FROM t1, t2;`` the qualifiers
make it clear that the first column is column1 from table1 and the second column
is column2 from table2.

The rules are sometimes relaxed for compatibility reasons, for example
some non-letter characters such as $ and « are legal in regular identifiers.
However, it is better to assume that rules are never relaxed.

The following are examples of legal and illegal identifiers.

.. code-block:: none

    _A1   -- legal, begins with underscore and contains underscore | letter | digit
    1_A   -- illegal, begins with digit
    A$« -- legal, but not recommended, try to stick with digits and letters and underscores
    + -- illegal, operator token
    grant -- illegal, GRANT is a reserved word
    "grant" -- legal, delimited identifiers may be reserved words
    "_space" -- legal, but Tarantool already uses this name for a system space
    "A"."X" -- legal, for columns only, inside statements where qualifiers may be necessary
    'a' -- illegal, single quotes are for literals not identifiers
    A123456789012345678901234567890 -- legal, identifiers can be long
    ддд -- legal, and will be converted to upper case in identifiers

The following example shows that conversion to upper case affects regular identifiers but not delimited identifiers.

.. code-block:: none

    CREATE TABLE "q" ("q" INTEGER PRIMARY KEY);
    SELECT * FROM q;
    -- Result = "error: 'no such table: Q'.

.. _sql_operands:

Operands

An operand is something that can be operated on. Literals and column identifiers are operands. So are NULL and DEFAULT.

NULL and DEFAULT are keywords which represent values whose data types are not known until they are assigned or compared,
so they are known by the technical term "contextually typed value specifications".
(Exception: for the non-standard statement "SELECT NULL FROM table-name;"  NULL has data type BOOLEAN.)

Every operand has a data type.

For literals, :ref:`as we saw earlier <sql_literals>`, the data type is usually determined by the format.

For identifiers, the data type is usually determined by the definition.

The usual determination may change because of context or because of
:ref:`explicit casting <sql_function_cast>`.

For some SQL data type names there are *aliases*.
An alias may be used for data definition.
For example VARCHAR(5) and TEXT are aliases of STRING and may appear in
:samp:`CREATE TABLE {table_name} ({column_name} VARCHAR(5) PRIMARY KEY);` but Tarantool,
if asked, will report that the data type of :samp:`{column_name}` is STRING.

For every SQL data type there is a corresponding NoSQL type, for example
an SQL STRING is stored in a NoSQL space as :ref:`type = 'string' <index-box_string>`.

To avoid confusion in this manual, all references to SQL data type names are
in upper case and all similar words which refer to NoSQL types or to other kinds
of object are in lower case, for example:

* STRING is a data type name, but string is a general term;
* NUMBER is a data type name, but number is a general term.

Although it is common to say that a VARBINARY value is a "binary string",
this manual will not use that term and will instead say "byte sequence".

Here are all the SQL data types, their corresponding NoSQL types, their aliases,
and minimum / maximum literal examples.

.. container:: table

    **Data types**

    .. rst-class:: left-align-column-1
    .. rst-class:: left-align-column-2
    .. rst-class:: left-align-column-3
    .. rst-class:: left-align-column-4

    +-----------+------------+------------+----------------------+-------------------------+
    | SQL type  | NoSQL type | Aliases    | Minimum              | Maximum                 |
    +===========+============+============+======================+=========================+
    | BOOLEAN   | boolean    | BOOL       | FALSE                | TRUE                    |
    +-----------+------------+------------+----------------------+-------------------------+
    | INTEGER   | integer    | INT        | -9223372036854775808 | 18446744073709551615    |
    +-----------+------------+------------+----------------------+-------------------------+
    | UNSIGNED  | unsigned   | (none)     | 0                    | 18446744073709551615    |
    +-----------+------------+------------+----------------------+-------------------------+
    | DOUBLE    | double     | (none)     | -1.79769e308         | 1.79769e308             |
    +-----------+------------+------------+----------------------+-------------------------+
    | NUMBER    | number     | (none)     | -1.79769e308         | 1.79769e308             |
    +-----------+------------+------------+----------------------+-------------------------+
    | STRING    | string     | TEXT,      | ``''``               | ``'many-characters'``   |
    |           |            | VARCHAR(n) |                      |                         |
    +-----------+------------+------------+----------------------+-------------------------+
    | VARBINARY | varbinary  | (none)     | ``X''``              | ``X'many-hex-digits'``  |
    +-----------+------------+------------+----------------------+-------------------------+
    | SCALAR    | scalar     | (none)     | FALSE                |  ``X'many-hex-digits'`` |
    +-----------+------------+------------+----------------------+-------------------------+

.. _sql_data_type_boolean:

BOOLEAN values are FALSE, TRUE, and UNKNOWN (which is the same as NULL).
FALSE is less than TRUE.

.. _sql_data_type_integer:

INTEGER values are numbers that do not contain decimal points and are
not expressed with exponential notation. The range of possible values is
between -2^63 and +2^64, or NULL.

.. _sql_data_type_unsigned:

UNSIGNED values are numbers that do not contain decimal points and are not
expressed with exponential notation. The range of possible values is
between 0 and +2^64, or NULL.

.. _sql_data_type_double:

DOUBLE values are numbers that do contain decimal points (for example 0.5) or
are expressed with exponential notation (for example 5E-1).
The range of possible values is the same as for the IEEE 754 floating-point
standard, or NULL. Numbers outside the range of DOUBLE literals may be displayed
as -inf or inf.

.. _sql_data_type_number:

NUMBER values have the same range as DOUBLE values.
But NUMBER values may also also be integers, and, if so,
arithmetic operation results will be exact rather than approximate.
For example, if a NUMBER column ``X`` contains 5, then ``X / 2`` is 2, an integer.
There is no literal format for NUMBER (literals like ``1.5`` or ``1E555``
are considered to be DOUBLEs), so use :ref:`CAST <sql_function_cast>`
to insist that a number has data type NUMBER, but that is rarely necessary.
See the description of NoSQL type :ref:`'number' <index-box_number>`.

.. _sql_data_type_string:

STRING values are any sequence of zero or more characters encoded with UTF-8,
or NULL. The possible character values are the same as for the Unicode standard.
Byte sequences which are not valid UTF-8 characters are allowed but not recommended.
STRING literal values are enclosed within single quotes, for example ``'literal'``.
If the VARCHAR alias is used for column definition, it must include a maximum
length, for example column_1 VARCHAR(40). However, the maximum length is ignored.
The data-type may be followed by :ref:`[COLLATE collation-name] <sql_collate_clause>`.

.. _sql_data_type_varbinary:

VARBINARY values are any sequence of zero or more octets (bytes), or NULL.
VARBINARY literal values are expressed as X followed by pairs of hexadecimal
digits enclosed within single quotes, for example ``X'0044'``.
VARBINARY's NoSQL equivalent is ``'varbinary'`` but not character string -- the
MessagePack storage is MP_BIN (MsgPack binary).

.. _sql_data_type_scalar:

SCALAR can be used for
:ref:`column definitions <sql_column_def_data_type>` but the individual column values have
one of the preceding types -- BOOLEAN, INTEGER, DOUBLE, STRING, or VARBINARY.
See more about SCALAR in the section
:ref:`Column definition -- the rules for the SCALAR data type <sql_column_def_scalar>`.
The data-type may be followed by :ref:`[COLLATE collation-name] <sql_collate_clause>`.

Any value of any data type may be NULL. Ordinarily NULL will be cast to the
data type of any operand it is being compared to or to the data type of the
column it is in. If the data type of NULL cannot be determined from context,
it is BOOLEAN.

All the SQL data types correspond to
:ref:`Tarantool/NoSQL types <details_about_index_field_types>` with the same name.
There are also some Tarantool/NoSQL data types which have no corresponding SQL data types.
If Tarantool/SQL reads a Tarantool/NoSQL value which has a type which has no SQL equivalent,
Tarantool/SQL may treat it as NULL or INTEGER or VARBINARY.
For example, ``SELECT "flags" FROM "_space";`` will return a column whose data type is ``'map'``.
Such columns can only be manipulated in SQL by
:ref:`invoking Lua functions <sql_calling_lua>`.

Operators

An operator signifies what operation can be performed on operands.

Almost all operators are easy to recognize because they consist of one-character
or two-character non-alphabetic tokens, except for six keyword operators (AND IN IS LIKE NOT OR).

Almost all operators are "dyadic", that is, they are performed on a pair of operands
-- the only operators that are performed on a single operand are NOT and ~ and (sometimes) -.

The result of an operation is a new operand. If the operator is a comparison operator
then the result has data type BOOLEAN (TRUE or FALSE or UNKNOWN).
Otherwise the result has the same data type as the original operands, except that:
promotion to a broader type may occur to avoid overflow.
Arithmetic with NULL operands will result in a NULL operand. 

In the following list of operators, the tag "(arithmetic)" indicates
that all operands are expected to be numbers and should result in a number;
the tag "(comparison)" indicates that operands are expected to have similar
data types and should result in a BOOLEAN; the tag "(logic)"
indicates that operands are expected to be BOOLEAN and should result in a BOOLEAN.
Exceptions may occur where operations are not possible, but see the "special situations"
which are described after this list.
Although all examples show literals, they could just as easily show column identifiers.

.. _sql_operator_arithmetic:

.. _sql_operator_addition:

``+`` addition (arithmetic)
Add two numbers according to standard arithmetic rules.
Example: ``1 + 5``, result = 6.

.. _sql_operator_subtraction:

``-`` subtraction (arithmetic)
Subtract second number from first number according to standard arithmetic rules.
Example: ``1 - 5``, result = -4.

``*`` multiplication (arithmetic)
Multiply two numbers according to standard arithmetic rules.
Example: ``2 * 5``, result = 10.

``/`` division (arithmetic)
Divide second number into first number according to standard arithmetic rules.
Division by zero is not legal.
Division of integers always results in rounding down, use :ref:`CAST <sql_function_cast>` to DOUBLE to get
non-integer results.
Example: ``5 / 2``, result = 2.

``%`` modulus (arithmetic)
Divide second number into first number according to standard arithmetic rules.
The result is the remainder.
Example: ``17 % 5``, result = 2.

``<<`` shift left (arithmetic)
Shift the first number to the left N times, where N = the second number.
For positive numbers, each 1-bit shift to the left is equivalent to multiplying times 2.
Example: ``5 << 1``, result = 10.

``>>`` shift right (arithmetic)
Shift the first number to the right N times, where N = the second number.
For positive numbers, each 1-bit shift to the right is equivalent to dividing by 2.
Example: ``5 >> 1``, result = 2.

``&`` and (arithmetic)
Combine the two numbers, with 1 bits in the result if and only if both original numbers have 1 bits.
Example: ``5 & 4``, result = 4.

``|`` or (arithmetic)
Combine the two numbers, with 1 bits in the result if either original number has a 1 bit.
Example: ``5 | 2``, result = 7.

``~`` negate (arithmetic), sometimes called bit inversion 
Change 0 bits to 1 bits, change 1 bits to 0 bits.
Example: ``~5``, result = -6.

.. _sql_operator_comparison:

``<`` less than (comparison)
Return TRUE if the first operand is less than the second by arithmetic or collation rules.
Example for numbers: ``5 < 2``, result = FALSE. Example for strings: ``'C' < ' '``, result = FALSE.

``<=`` less than or equal (comparison)
Return TRUE if the first operand is less than or equal to the second by arithmetic or collation rules.
Example for numbers: ``5 <= 5``, result = TRUE. Example for strings: ``'C' <= 'B'``, result = FALSE.

``>`` greater than (comparison)
Return TRUE if the first operand is greater than the second by arithmetic or collation rules.
Example for numbers: ``5 > -5``, result = TRUE. Example for strings: ``'C' > '!'``, result = TRUE.

``>=`` greater than or equal (comparison)
Return TRUE if the first operand is greater than or equal to the second by arithmetic or collation rules.
Example for numbers: ``0 >= 0``, result = TRUE. Example for strings: ``'Z' >= 'Γ'``, result = FALSE.

.. _sql_equal:

``=`` equal (assignment or comparison)
After the word SET, "=" means the first operand gets the value from the second operand.
In other contexts, "=" returns TRUE if operands are equal.
Example for assignment: ``... SET column1 = 'a';``
Example for numbers: ``0 = 0``, result = TRUE. Example for strings:  ``'1' = '2 '``, result = FALSE.

``==`` equal (assignment), or equal (comparison)
This is a non-standard equivalent of
:ref:`"= equal (assignment or comparison)" <sql_equal>`.

.. _sql_not_equal:

``<>`` not equal (comparison)
Return TRUE if the first operand is not equal to the second by arithmetic or collation rules.
Example for strings: ``'A' <> 'A     '`` is TRUE.

``!=`` not equal (comparison)
This is a non-standard equivalent of
:ref:`"\<\> not equal (comparison)" <sql_not_equal>`.

.. _sql_is_null:

``IS NULL`` and ``IS NOT NULL`` (comparison)
For IS NULL: Return TRUE if the first operand is NULL, otherwise return FALSE.
Example: column1 IS NULL, result = TRUE if column1 contains NULL.
For IS NOT NULL: Return FALSE if the first operand is NULL, otherwise return TRUE.
Example: ``column1 IS NOT NULL``, result = FALSE if column1 contains NULL.

.. _sql_operator_like:

``LIKE`` (comparison)
Perform a comparison of two string operands.
If the second operand contains ``'_'``, the ``'_'`` matches any single character in the first operand.
If the second operand contains ``'%'``, the ``'%'`` matches 0 or more characters in the first operand.
If it is necessary to search for either ``'_'`` or ``'%'`` within a string without treating it specially,
an optional clause can be added, ESCAPE single-character-operand, for example
``'abc_' LIKE 'abcX_' ESCAPE 'X'`` is TRUE because ``X'`` means "following character is not
special". Matching is also affected by the string's collation.

.. _sql_operator_between:

``BETWEEN`` (comparison)
:samp:`{x} BETWEEN {y} AND {z}` is shorthand for :samp:`{x} >= {y} AND {x} <= {z}`.

``NOT`` negation (logic)
Return TRUE if operand is FALSE return FALSE if operand is TRUE, else return UNKNOWN.
Example: ``NOT (1 > 1)``, result = TRUE.

``IN`` is equal to one of a list of operands (comparison)
Return TRUE if first operand equals any of the operands in a parenthesized list.
Example: ``1 IN (2,3,4,1,7)``, result = TRUE.

``AND`` and (logic)
Return TRUE if both operands are TRUE.
Return UNKNOWN if both operands are UNKNOWN.
Return UNKNOWN if one operand is TRUE and the other operand is UNKNOWN.
Return FALSE if one operand is FALSE and the other operand is (UNKNOWN or TRUE or FALSE).

``OR`` or (logic)
Return TRUE if either operand is TRUE.
Return FALSE if both operands are FALSE.
Return UNKNOWN if one operand is UNKNOWN and the other operand is (UNKNOWN or FALSE).

.. _sql_operator_concatenate:

``||`` concatenate (string manipulation)
Return the value of the first operand concatenated with the value of the second operand.
Example: ``'A' || 'B'``, result = ``'AB'``.

The precedence of dyadic operators is:

.. code-block:: none

    ||
    * / %
    + -
    << >> & |
    <  <= > >=
    =  == != <> IS IS NOT IN LIKE
    AND   
    OR

To ensure a desired precedence, use () parentheses.

Special Situations

If one of the operands has data type DOUBLE, Tarantool uses floating-point arithmetic.
This means that exact results are not guaranteed and rounding may occur without warning.
For example, 4.7777777777777778 = 4.7777777777777777 is TRUE.

The floating-point values inf and -inf are possible.
For example, ``SELECT 1e318, -1e318;`` will return "inf, -inf".
Arithmetic on infinite values may cause NULL results,
for example ``SELECT 1e318 - 1e318;`` is NULL and ``SELECT 1e318 * 0;`` is NULL.

SQL operations never return the floating-point value -nan,
although it may exist in data created by Tarantool's NoSQL. In SQL, -nan is treated as NULL.

A string will be converted to a number if it is used with an arithmetic operator and conversion is possible,
for example ``'7' + '7'`` = 14.
And for comparison or assignment, ``'7'`` = 7.
This is called implicit casting. It is applicable for STRINGs and all numeric data types.

Limitations: (`Issue#2346 <https://github.com/tarantool/tarantool/issues/2346>`_) |br|
* Some words, for example MATCH and REGEXP, are reserved but are not necessary for current or planned Tarantool versions |br|
* 999999999999999 << 210 yields 0. (1 << 63) >> 63 yields -1.

Expressions

An expression is a chunk of syntax that causes return of a value.
Expressions may contain literals, column-names, operators, and parentheses.

Therefore these are examples of expressions:
``1``, ``1 + 1 << 1``, ``(1 = 2) OR 4 > 3``, ``'x' || 'y' || 'z'``.

Also there are two expressions that involve keywords:

value IS [NOT] NULL |br|
  ... for determining whether value is (not) NULL

CASE ... WHEN ... THEN ... ELSE ... END |br|
  ... for setting a series of conditions.

See also: :ref:`subquery <sql_subquery>`.

Limitations: IS TRUE and IS FALSE return an error.

Comparing and Ordering

There are rules for determining whether value-1 is "less than", "equal to", or "greater than" value-2.
These rules are applied for searches, for sorting results in order by column values,
and for determining whether a column is unique.
The result of a comparison of two values can be TRUE, FALSE, or UNKNOWN (the three BOOLEAN values).
Sometimes for retrieval TRUE is converted to 1, FALSE is converted to 0, UNKNOWN is converted to NULL.
For any comparisons where neither operand is NULL, the operands are "distinct" if the comparison
result is FALSE.
For any set of operands where all operands are distinct from each other, the set is considered to be "unique".

When comparing a number to a number: |br|
* infinity = infinity is true |br|
* regular numbers are compared according to usual arithmetic rules

When comparing any value to NULL: |br|
(for examples in this paragraph assume that column1 in table T contains {NULL, NULL, 1, 2}) |br|
* value comparison-operator NULL is UNKNOWN (not TRUE and not FALSE), which affects "WHERE condition" because the condition must be TRUE, and does not affect  "CHECK (condition)" because the condition must be either TRUE or UNKNOWN. Therefore SELECT * FROM T WHERE column1 > 0 OR column1 < 0 OR column1 = 0; returns only  {1,2}, and the table can have been created with CREATE TABLE T (... column1 INTEGER, CHECK (column1 >= 0)); |br|
* for any operations that contain the keyword DISTINCT, NULLs are not distinct. Therefore SELECT DISTINCT column1 FROM T; will return {NULL,1,2}. |br|
* for grouping, NULL values sort together. Therefore SELECT column1, COUNT(*) FROM T GROUP BY column1; will include a row {NULL, 2}. |br|
* for ordering, NULL values sort together and are less than non-NULL values. Therefore SELECT column1 FROM T ORDER BY column1; returns {NULL, NULL, 1,2}. |br|
* for evaluating a UNIQUE constraint or UNIQUE index, any number of NULLs is okay. Therefore CREATE UNIQUE INDEX i ON T (column1); will succeed.

When comparing a number to a STRING: |br|
* If implicit casting is possible, the STRING operand is converted to a number before comparison.
If implicit casting is not possible, and one of the operands is the name of a column which was
defined as SCALAR, and the column is being compared with a number, then number is less than STRING. Otherwise, the comparison is not legal.

When comparing a BOOLEAN to a BOOLEAN: |br|
TRUE is greater than FALSE.

When comparing a VARBINARY to a VARBINARY: |br|
* The numeric value of each pair of bytes is compared until the end of the byte sequences or until inequality. If two byte sequences are otherwise equal but one is longer, then the longer one is greater.

When comparing for the sake of eliminating duplicates: |br|
* This is usually signalled by the word DISTINCT, so it applies to SELECT DISTINCT, to set operators such as UNION (where DISTINCT is implied), and to aggregate functions such as  AVG(DISTINCT). |br|
* Two operators are "not distinct" if they are equal to each other, or are both NULL |br|
* If two values are equal but not identical, for example 1.0 and 1.00, they are non-distinct and there is no way to specify which one will be eliminated |br|
* Values in primary-key or unique columns are distinct due to definition.

When comparing a STRING to a STRING: |br|
* Ordinarily collation is "binary", that is, comparison is done according to the numeric values of the bytes. This can be cancelled by adding a :ref:`COLLATE clause <sql_collate_clause>` at the end of either expression. So ``'A' < 'a'`` and ``'a' < 'Ä'``, but ``'A' COLLATE "unicode_ci" = 'a'`` and ``'a' COLLATE "unicode_ci" = 'Ä'``. |br|
* When comparing a column with a string literal, the column's defined collation is used. |br|
* Ordinarily trailing spaces matter. So ``'a' = 'a  '`` is not TRUE. This can be cancelled by using the :ref:`TRIM(TRAILING ...) <sql_function_trim>` function. |br|

Limitations: |br|
* LIKE comparisons return integer results according to meta-information. |br|
* LIKE is not expected to work with VARBINARY.

.. _sql_data_type_conversion:

Data Type Conversion

Data type conversion, also called casting, is necessary for any operation involving two operands X and Y,
when X and Y have different data types. |br|
Or, casting is necessary for assignment operations
(when INSERT or UPDATE is putting a value of type X into a column defined as type Y). |br|
Casting can be "explicit" when a user uses the :ref:`CAST <sql_function_cast>` function, or "implicit" when Tarantool does a conversion automatically.

The general rules are fairly simple: |br|
Assignments and operations involving NULL cause NULL or UNKNOWN results. |br|
For arithmetic, convert to the data type which can contain both operands and the result. |br|
For explicit casts, if a meaningful result is possible, the operation is allowed. |br|
For implicit casts, if a meaningful result is possible and the data types on both sides
are either STRINGs or numbers (that is, are STRING or INTEGER or UNSIGNED or DOUBLE or NUMBER),
the operation is sometimes allowed.

The specific situations in this chart follow the general rules:

.. code-block:: none

    ~                To BOOLEAN | To number  | To STRING | To VARBINARY
    ---------------  ----------   ----------   ---------   ------------
    From BOOLEAN   | AAA        | S--        | A--       | ---
    From number    | A--        | SSA        | AAA       | ---
    From STRING    | S--        | SSS        | AAA       | A--
    From VARBINARY | ---        | ---        | A--       | AAA

Where each entry in the chart has 3 characters: |br|
Where A = Always allowed, S = Sometimes allowed, - = Never allowed. |br|
The first character of an entry is for explicit casts, |br|
the second character is for implicit casts for assignment, |br|
the third character is for implicit cast for comparison. |br|
So AAA = Always for explicit, Always for Implicit (assignment), Always for Implicit (comparison).

The S "Sometimes allowed" character applies for these special situations: |br|
From STRING To BOOLEAN is allowed if UPPER(string-value) = ``'TRUE'`` or ``'FALSE'``. |br|
From number to INTEGER or UNSIGNED is allowed for cast and assignment only if the result is not out of range,
and the number has no post-decimal digits. |br|
From STRING to INTEGER or UNSIGNED is allowed only if the string has a representation of a number,
and the result is not out of range,
and the number has no post-decimal digits. |br|
From STRING to DOUBLE or NUMBER is allowed only if the string has a representation of a number. |br|
From BOOLEAN to number is allowed only if the number is not DOUBLE.
The chart does not show To|From SCALAR because the conversions depend on the type of the value,
not the type of the column definition.
Explicit cast to SCALAR is allowed but has no effect, the result data type is always the same as the original data type.
But comparisons of values of different types are allowed if the definition is SCALAR.

Examples of casts, illustrating the situations in the chart:

``CAST(TRUE AS INTEGER)`` is legal because the intersection of the  "From BOOLEAN" row with the "To number"
column is ``A--`` and the first letter of ``A--`` is for explicit cast and A means Always Allowed.
The result is 1.

``UPDATE ... SET varbinary_column = 'A'`` is illegal because the intersection of the "From STRING" row with the "To VARBINARY"
column is ``A--`` and the second letter of ``A--`` is for implicit cast (assignment) and - means not allowed.
The result is an error message. 

``1.7E-1 > 0`` is legal because the intersection of the "From number" row with the "To number"
column is SSA, and the third letter of SSA is for implicit cast (comparison) and A means Always Allowed.
The result is TRUE.

``11 > '2'`` is legal because the intersection of the "From number" row with the "To STRING"
column is AAA and the third letter of AAA is for implicit cast (comparison) and A means Always Allowed.
The result is TRUE.  For detailed explanation see the following section.

Implicit string/numeric cast

Special considerations may apply for casting STRINGs
to/from INTEGERs/DOUBLEs/NUMBERs/UNSIGNEDs (numbers) for comparison or assignment.

``1 = '1' /* compare a STRING with a number */`` |br|
``UPDATE ... SET string_column = 1 /* assign a number to a STRING */``

For comparisons, the cast is always from STRING to number. |br|
Therefore ``1e2 = '100'`` is TRUE, and ``11 > '2'`` is TRUE. |br|
If the cast fails, then the number is less than the STRING. |br|
Therefore ``1e400 < ''`` is TRUE. |br|
Exception: for BETWEEN the cast is to the data type of the first and last operands. |br|
Therefore ``'66' BETWEEN 5 AND '7'`` is TRUE.

For assignments, the cast is always from source to target.
Therefore ``INSERT INTO t (integer_column) VALUES ('5');`` inserts 5. |br|
If the cast fails, then the result is an error.
Due to a change in behavior starting with Tarantool 2.4.1,
if the string contains post-decimal digits and the target is INTEGER or UNSIGNED,
the assignment will fail.
Therefore ``INSERT INTO t (integer_column) VALUES ('5.5');`` causes an error. |br|

Implicit cast also happens if STRINGS are used in arithmetic. |br|
Therefore ``'5' / '5' = 1``. If the cast fails, then the result is an error. |br|
Therefore ``'5' / ''`` is an error.

Implicit cast does NOT happen if numbers are used in concatenation, or in LIKE. |br|
Therefore ``5 || '5'`` is illegal.

In the following examples, implicit cast does not happen for values in SCALAR columns: |br|
``DROP TABLE scalars;`` |br|
``CREATE TABLE scalars (scalar_column SCALAR PRIMARY KEY);`` |br|
``INSERT INTO scalars VALUES (11), ('2');`` |br|
``SELECT * FROM scalars WHERE scalar_column > 11;   /* 0 rows. So 11 > '2'. */`` |br|
``SELECT * FROM scalars WHERE scalar_column < '2';  /* 1 row. So 11 < '2'. */`` |br|
``SELECT max(scalar_column) FROM scalars; /* 1 row: '2'. So 11 < '2'. */`` |br|
``SELECT sum(scalar_column) FROM scalars; /* 1 row: 13. So cast happened. */`` |br|
These results are not affected by indexing, or by reversing the operands.

Implicit cast does NOT happen for :ref:`GREATEST() <sql_function_greatest>`
or :ref:`LEAST() <sql_function_least>`.
Therefore ``LEAST('5',6)`` is 6.

For function arguments: |br|
If the function description says that a parameter has a specific data type,
and implicit assignment casts are allowed, then arguments which are not passed with that
data type will be converted before the function is applied. |br|
For example, the :ref:`LENGTH() <sql_function_length>` function expects a
STRING or VARBINARY,
and INTEGER  can be converted to STRING, therefore LENGTH(15) will return
the length of ``'15'``, that is, 2. |br|
But implicit cast sometimes does NOT happen for parameters.
Therefore ``ABS('5')`` will cause an error message after
`Issue#4159 <https://github.com/tarantool/tarantool/issues/4159>`_ is fixed.
However, :ref:`TRIM(5) <sql_function_trim>` will still be legal.

Although it is not a requirement of the SQL standard, implicit cast is supposed to help compatibility
with other DBMSs. However, other DBMSs have different rules about what can be converted
(for example they may allow assignment of ``'inf'`` but disallow comparison with ``'1e5'``).
And, of course, it is not possible to be compatible with other DBMSs and at the same
time support SCALAR, which other DBMSs do not have.

Limitations (`Issue#3809 <https://github.com/tarantool/tarantool/issues/3809>`_): |br|
Result of concatenation, or out-of-bound result, may have wrong type. |br|
Parameter conversion behavior will change (`Issue#4159 <https://github.com/tarantool/tarantool/issues/4159>`_). After issue#4159 is done, LENGTH(15) will be illegal.

Statements

A statement consists of SQL-language keywords and expressions that direct Tarantool to do something with a database.
Statements begin with one of the words
ALTER ANALYZE COMMIT CREATE DELETE DROP EXPLAIN INSERT PRAGMA RELEASE REPLACE ROLLBACK SAVEPOINT
SELECT START TRUNCATE UPDATE VALUES WITH.
Statements should end with ";" semicolon although this is not mandatory.

A client sends a statement to the Tarantool server.
The Tarantool server parses the statement and executes it.
If there is an error, Tarantool returns an error message.

.. _sql_sql_statements_and_clauses:

--------------------------------------------------------------------------------
SQL statements and clauses
--------------------------------------------------------------------------------

.. _sql_alter_table:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
ALTER TABLE
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Syntax:

* :samp:`ALTER TABLE {table-name} RENAME TO {new-table-name};`
* :samp:`ALTER TABLE {table-name} ADD CONSTRAINT {constraint-name} {constraint-definition};`
* :samp:`ALTER TABLE {table-name} DROP CONSTRAINT {constraint-name};`
* :samp:`ALTER TABLE {table-name} ENABLE|DISABLE CHECK CONSTRAINT {constraint-name};`


|br|

.. image:: alter_table.svg
    :align: left

|br|

ALTER is used to change a table's name or a table's constraints.

Examples:

.. code-block:: sql

For renaming a table with ``ALTER ... RENAME``, the *old-table* must exist, the *new-table* must not
exist. Example: |br|
``-- renaming a table:``
``ALTER TABLE t1 RENAME TO t2;``

For adding a :ref:`table constraint <sql_table_constraint_def>` with ``ADD CONSTRAINT``,
the table must exist, the table must be empty,
the constraint name must be unique within the table.
Example with a :ref:`foreign-key constraint definition <sql_foreign_key>`: |br|
``ALTER TABLE t1 ADD CONSTRAINT fk_s1_t1_1 FOREIGN KEY (s1) REFERENCES t1;`` |br|

It is not possible to say ``CREATE TABLE table_a ... REFERENCES table_b ...``
if table ``b`` does not exist yet. This is a situation where ``ALTER TABLE`` is
handy -- users can ``CREATE TABLE table_a`` without the foreign key, then
``CREATE TABLE table_b``, then ``ALTER TABLE table_a ... REFERENCES table_b ...``.

.. code-block:: sql

   -- adding a primary-key constraint definition:
   -- This is unusual because primary keys are created automatically
   -- and it is illegal to have two primary keys for the same table.
   -- However, it is possible to drop a primary-key index, and this
   -- is a way to restore the primary key if that happens.
   ALTER TABLE t1 ADD CONSTRAINT "pk_unnamed_T1_1" PRIMARY KEY (s1);

   -- adding a unique-constraint definition:
   -- Alternatively, you can say CREATE UNIQUE INDEX unique_key ON t1 (s1);
   ALTER TABLE t1 ADD CONSTRAINT "unique_unnamed_T1_2" UNIQUE (s1);

   -- Adding a check-constraint definition:
   ALTER TABLE t1 ADD CONSTRAINT "ck_unnamed_T1_1" CHECK (s1 > 0);

.. _sql_alter_table_drop_constraint:

For ``ALTER ... DROP CONSTRAINT``, it is only legal to drop a named constraint.
(Tarantool generates the
constraint names automatically if the user does not provide them.)
To remove a unique constraint, use use either ``ALTER ... DROP CONSTRAINT`` or
:ref:`DROP INDEX <sql_drop_index>`, which will drop the constraint
as well.

To remove a unique constraint, use :ref:`DROP INDEX <sql_drop_index>`, which will drop the constraint
as well.

.. code-block:: sql

   -- dropping a constraint:
   ALTER TABLE t1 DROP CONSTRAINT "fk_unnamed_JJ2_1";

For ``ALTER ... ENABLE|DISABLE CHECK CONSTRAINT``, it is only legal to enable or disable a named constraint,
and Tarantool only looks for names of check constraints.
By default a constraint is enabled.
If a constraint is disabled, then the check will not be performed.

.. code-block:: sql

   -- disabling and re-enabling a constraint:
   ALTER TABLE t1 DISABLE CHECK CONSTRAINT c;
   ALTER TABLE t1 ENABLE CHECK CONSTRAINT c;

Limitations:

* It is not possible to add or drop a column.
* It is not possible to modify NOT NULL constraints or column properties DEFAULT
  and :ref:`data type <sql_column_def_data_type>`.
  However, it is possible to modify them with Tarantool/NOSQL, for example by
  calling :ref:`space_object:format() <box_space-format>` with a different
  ``is_nullable`` value.

.. _sql_create_table:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
CREATE TABLE
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Syntax:

:samp:`CREATE TABLE [IF NOT EXISTS] {table-name} (column-definition or table-constraint list)`
:samp:`[WITH ENGINE = {string}];`

|br|

.. image:: create_table.svg
    :align: left

|br|

Create a new base table, usually called a "table".

.. NOTE::

   A table is a *base table* if it is created with CREATE TABLE and contains
   data in persistent storage.

   A table is a *viewed table*, or just "view", if it is created with
   :ref:`CREATE VIEW <sql_create_view>` and gets its data from other views or from base tables.

The *table-name* must be an identifier which is valid according to the rules for
identifiers, and must not be the name of an already existing base table or view.

The *column-definition* or *table-constraint* list is a comma-separated list
of :ref:`column definitions <sql_column_def>`
or :ref:`table constraint definitions <sql_table_constraint_def>`.
Column definitions and table constraint definitions are sometimes called *table elements*.

Rules:

* A primary key is necessary; it can be specified with a table constraint
  PRIMARY KEY.
* There must be at least one column.
* When IF NOT EXISTS is specified, and there is already a table with the same
  name, the statement is ignored.
* When :samp:`WITH ENGINE = {string}` is specified,
  where :samp:`{string}` must be either 'memtx' or 'vinyl',
  the table is created with that :ref:`storage engine <engines-chapter>`.
  When this clause is not specified,
  the table is created with the default engine,
  which is ordinarily 'memtx' but may be changed
  by updating the :ref:`box.space._session_settings <box_space-session_settings>` system table..

Actions:

#. Tarantool evaluates each column definition and table-constraint,
   and returns an error if any of the rules is violated.
#. Tarantool makes a new definition in the schema.
#. Tarantool makes new indexes for PRIMARY KEY or UNIQUE constraints.
   A unique index name is created automatically.
#. Usually Tarantool effectively executes a :ref:`COMMIT <sql_commit>` statement.

Examples:

.. code-block:: sql

   -- the simplest form, with one column and one constraint:
   CREATE TABLE t1 (s1 INTEGER, PRIMARY KEY (s1));

   -- you can see the effect of the statement by querying
   -- Tarantool system spaces:
   SELECT * FROM "_space" WHERE "name" = 'T1';
   SELECT * FROM "_index" JOIN "_space" ON "_index"."id" = "_space"."id"
            WHERE "_space"."name" = 'T1';

   -- variation of the simplest form, with delimited identifiers
   -- and a bracketed comment:
   CREATE TABLE "T1" ("S1" INT /* synonym of INTEGER */, PRIMARY KEY ("S1"));

   -- two columns, one named constraint
   CREATE TABLE t1 (s1 INTEGER, s2 STRING, CONSTRAINT pk_s1s2_t1_1 PRIMARY KEY (s1, s2));

Limitations:

* The maximum number of columns is 2000.
* The maximum length of a row depends on the
  :ref:`memtx_max_tuple_size <cfg_storage-memtx_max_tuple_size>` or
  :ref:`vinyl_max_tuple_size  <cfg_storage-memtx_max_tuple_size>`
  configuration option.

.. _sql_column_def:

***********************************************
Column definition
***********************************************

Syntax:

:samp:`column-name data-type [, column-constraint]`

Define a column, which is a table-element used in a :ref:`CREATE TABLE <sql_create_table>` statement.

The ``column-name`` must be an identifier which is valid according to the rules
for identifiers.

Each ``column-name`` must be unique within a table.

.. _sql_column_def_data_type:

***********************************************
Column definition -- data type
***********************************************

.. image:: data_type.svg
    :align: left

|br|

Every column has a data type:
BOOLEAN or DOUBLE or INTEGER or NUMBER or SCALAR or STRING or UNSIGNED or VARBINARY.
The detailed description of data types is in the section
:ref:`Operands <sql_operands>`.

.. _sql_column_def_scalar:

********************************************************
Column definition -- the rules for the SCALAR data type
********************************************************

SCALAR is a "complex" data type, unlike all the other data types which are "primitive".
Two column values in a SCALAR column can have two different primitive data types.

#. Any item defined as SCALAR has an underlying primitive type. For example, here:

   .. code-block:: sql

      CREATE TABLE t (s1 SCALAR PRIMARY KEY);
      INSERT INTO t VALUES (55), ('41');

   the underlying primitive type of the item in the first row is INTEGER
   because literal 55 has data type INTEGER, and the underlying primitive type
   in the second row is STRING (the data type of a literal is always clear from
   its format).

   An item's primitive type is far more important than its defined type.
   Incidentally Tarantool might find the primitive type by looking at the way
   MsgPack stores it, but that is an implementation detail.

#. A SCALAR definition may not include a maximum length, as there is no suggested
   restriction.
#. A SCALAR definition may include a :ref:`COLLATE clause <sql_collate_clause>`, which affects any items
   whose primitive data type is STRING. The default collation is "binary".
#. Some assignments are illegal when data types differ, but legal when the
   target is a SCALAR item. For example ``UPDATE ... SET column1 = 'a'``
   is illegal if ``column1`` is defined as INTEGER, but is legal if ``column1``
   is defined as SCALAR -- values which happen to be INTEGER will be changed
   so their data type is STRING.
#. There is no literal syntax which implies data type SCALAR.
#. TYPEOF(x) is never SCALAR, it is always the underlying data type.
   This is true even if ``x`` is NULL (in that case the data type is BOOLEAN).
   In fact there is no function that is guaranteed to return the defined data type.
   For example, ``TYPEOF(CAST(1 AS SCALAR));`` returns INTEGER, not SCALAR.
#. For any operation that requires implicit casting from an item defined as SCALAR,
   the syntax is legal but the operation may fail at runtime.
   At runtime, Tarantool detects the underlying primitive data type and applies
   the rules for that. For example, if a definition is:

   .. code-block:: sql

      CREATE TABLE t (s1 SCALAR PRIMARY KEY, s2 INTEGER);

   and within any row ``s1 = 'a'``, that is, its underlying primitive type is
   STRING to indicate character strings, then ``UPDATE t SET s2 = s1;`` is illegal.
   Tarantool usually does not know that in advance.
#. For any dyadic operation that requires implicit casting for comparison, the
   syntax is legal and the operation will not fail at runtime.
   Take this situation: comparison with a primitive type VARBINARY and
   a primitive type STRING.

   .. code-block:: sql

      CREATE TABLE t (s1 SCALAR PRIMARY KEY);
      INSERT INTO t VALUES (X'41');
      SELECT * FROM t WHERE s1 > 'a';

   The comparison is valid, because Tarantool knows the ordering of X'41' and 'a'
   in Tarantool/NoSQL 'scalar'.
#. The result data type of :ref:`min/max <sql_aggregate>` operation on a column defined as SCALAR
   is the data type of the minimum/maximum operand, unless the result value
   is NULL. For example:

   .. code-block:: sql

      CREATE TABLE t (s1 INTEGER, s2 SCALAR PRIMARY KEY);
      INSERT INTO t VALUES (1, X'44'), (2, 11), (3, 1E4), (4, 'a');
      SELECT min(s2), hex(max(s2)) FROM t;

   The result is: ``- - [11, '44',]``

   That is only possible with Tarantool/NoSQL scalar rules, but ``SELECT SUM(s2)``
   would not be legal because addition would in this case require implicit casting
   from VARBINARY to a number, which is not sensible.
#. The result data type of a primitive combination is never SCALAR because we
   in effect use TYPEOF(item) not the defined data type.
   (Here we use the word "combination" in the way that the standard document
   uses it for section "Result of data type combinations".) Therefore for
   ``greatest(1E308, 'a', 0, X'00')`` the result is X'00'.

********************************************
Column definition -- relation to NoSQL
********************************************

All the SQL data types correspond to
:ref:`Tarantool/NoSQL types with the same name <box_space-index_field_types>`.
For example an SQL STRING is stored in a NoSQL space as type = 'string'.

Therefore specifying an SQL data type X determines that the storage will be
in a space with a format column saying that the NoSQL type is 'x'.

The rules for that NoSQL type are applicable to the SQL data type.

If two items have SQL data types that have the same underlying type, then they
are compatible for all assignment or comparison purposes.

If two items have SQL data types that have different underlying types, then the
rules for explicit casts, or implicit (assignment) casts, or implicit (comparison)
casts, apply.

There is one floating-point value which is not handled by SQL: -nan is seen as NULL.

There are also some Tarantool/NoSQL data types which have no corresponding
SQL data types. For example, ``SELECT "flags" FROM "_space";`` will return
a column whose data type is 'map'. Such columns can only be manipulated in SQL
by :ref:`invoking Lua functions <sql_calling_lua>`.

.. _sql_column_def_constraint:

**********************************************************
Column definition -- column-constraint or default clause
**********************************************************

.. image:: column_constraint.svg
    :align: left

The column-constraint or default clause may be as follows:

.. container:: table

    .. rst-class:: left-align-column-1
    .. rst-class:: left-align-column-2

    +--------------------+-----------------------------------------------------------------+
    | Type               | Comment                                                         |
    +====================+=================================================================+
    | NOT NULL           | means                                                           |
    |                    | "it is illegal to assign a NULL to this column"                 |
    +--------------------+-----------------------------------------------------------------+
    | PRIMARY KEY        | explained in the later section                                  |
    |                    | :ref:`"Table Constraint Definition" <sql_table_constraint_def>` |
    +--------------------+-----------------------------------------------------------------+
    | UNIQUE             | explained in the later section                                  |
    |                    | "Table Constraint Definition"                                   |
    +--------------------+-----------------------------------------------------------------+
    | CHECK (expression) | explained in the later section                                  |
    |                    | "Table Constraint Definition"                                   |
    +--------------------+-----------------------------------------------------------------+
    | foreign-key-clause | explained in the later section                                  |
    |                    | :ref:`"Table Constraint Definition for foreign keys"            |
    |                    | <sql_foreign_key>`                                              |
    +--------------------+-----------------------------------------------------------------+
    | DEFAULT expression | means                                                           |
    |                    | "if INSERT does not assign to this column                       |
    |                    | then assign expression result to this column" --                |
    |                    | if there is no DEFAULT clause then DEFAULT NULL                 |
    |                    | is assumed.                                                     |
    +--------------------+-----------------------------------------------------------------+

If column-constraint is PRIMARY KEY, this is a shorthand for a separate
:ref:`table-constraint definition <sql_table_constraint_def>`: "PRIMARY KEY (column-name)".

If column-constraint is UNIQUE, this is a shorthand for a separate
:ref:`table-constraint definition <sql_table_constraint_def>`: "UNIQUE (column-name)".

If column-constraint is CHECK, this is a shorthand for a separate
:ref:`table-constraint definition <sql_table_constraint_def>`: "CHECK (expression)".

Columns defined with PRIMARY KEY are automatically NOT NULL.

To enforce some restrictions that Tarantool does not enforce automatically,
add CHECK clauses, like these:

.. code-block:: sql

   CREATE TABLE t ("smallint" INTEGER PRIMARY KEY CHECK ("smallint" <= 32767 AND "smallint" >= -32768));
   CREATE TABLE t ("shorttext" STRING PRIMARY KEY CHECK (length("shorttext") <= 10));

but this may cause inserts or updates to be slow.

*******************************
Column definition -- examples
*******************************

These are shown within :ref:`CREATE TABLE <sql_create_table>` statements.
Data types may also appear in :ref:`CAST <sql_function_cast>` functions.

.. code-block:: sql

   -- the simple form with column-name and data-type
   CREATE TABLE t (column1 INTEGER ...);
   -- with column-name and data-type and column-constraint
   CREATE TABLE t (column1 STRING PRIMARY KEY ...);
   -- with column-name and data-type and collate-clause
   CREATE TABLE t (column1 SCALAR COLLATE "unicode" ...);

.. code-block:: sql

   -- with all possible data types and aliases
   CREATE TABLE t
   (column1 BOOLEAN, column2 BOOL,
    column3 INT PRIMARY KEY, column4 INTEGER,
    column5 DOUBLE,
    column6 NUMBER,
    column7 STRING, column8 STRING COLLATE "unicode",
    column9 TEXT, columna TEXT COLLATE "unicode_sv_s1",
    columnb VARCHAR(0), columnc VARCHAR(100000) COLLATE "binary",
    columnd VARBINARY,
    columne SCALAR, columnf SCALAR COLLATE "unicode_uk_s2");

.. code-block:: sql

   -- with all possible column constraints and a default clause
   CREATE TABLE t
   (column1 INTEGER NOT NULL,
    column2 INTEGER PRIMARY KEY,
    column3 INTEGER UNIQUE,
    column4 INTEGER CHECK (column3 > column2),
    column5 INTEGER REFERENCES t,
    column6 INTEGER DEFAULT NULL);

.. _sql_table_constraint_def:

*******************************
Table Constraint Definition
*******************************

Syntax:

:samp:`[CONSTRAINT {constraint-name}] primary-key-constraint | unique-constraint | check-constraint | foreign-key-constraint`

|br|

.. image:: constraint.svg
    :align: left

|br|

Define a constraint, which is a table-element used in a CREATE TABLE statement.

The constraint-name must be an identifier which is valid according to the rules for identifiers.
The constraint-name must be unique within the table.

PRIMARY KEY constraints look like this: |br|
:samp:`PRIMARY KEY ({column-name} [, {column-name}...])`

There is a shorthand: specifying PRIMARY KEY in a :ref:`column definition <sql_column_def_constraint>`.

Every table must have one and only one primary key. |br|
Primary-key columns are automatically NOT NULL. |br|
Primary-key columns are automatically indexed. |br|
Primary-key columns are unique, that is, it is illegal to have two rows which
have the same values for the columns specified in the constraint.

Examples:

.. code-block:: none

    -- this is a table with a one-column primary-key constraint
    CREATE TABLE t1 (s1 INTEGER, PRIMARY KEY (s1));
    -- this is the column-definition shorthand for the same thing:
    CREATE TABLE t1 (s1 INTEGER PRIMARY KEY);
    -- this is a table with a two-column primary-key constraint
    CREATE TABLE t2 (s1 INTEGER, s2 INTEGER, PRIMARY KEY (s1, s2));
    -- this is an example of an attempted primary-key violation
    -- (the third INSERT will fail because 55, 'a' is a duplicate)
    CREATE TABLE t3 (s1 INTEGER, s2 STRING, PRIMARY KEY (s1, s2));
    INSERT INTO t3 VALUES (55, 'a');
    INSERT INTO t3 VALUES (55, 'b');
    INSERT INTO t3 VALUES (55, 'a');

PRIMARY KEY plus AUTOINCREMENT modifier may be specified in one of two ways: |br|
- In a column definition after the words PRIMARY KEY, as in ``CREATE TABLE t (c INTEGER PRIMARY KEY AUTOINCREMENT);`` |br|
- In a PRIMARY KEY (column-list) after a column name, as in ``CREATE TABLE t (c INTEGER, PRIMARY KEY (c AUTOINCREMENT));`` |br|
When AUTOINCREMENT is specified, the column must be a primary-key column and it must be INTEGER or UNSIGNED. |br|
Only one column in the table may be autoincrement.
However, it is legal to say ``PRIMARY KEY (a, b, c AUTOINCREMENT)`` -- in that case, there
are three columns in the primary key but only the first column (``a``) is AUTOINCREMENT.

As the name suggests, values in an autoincrement column are automatically incremented.
That is: if a user inserts NULL in the column, then the stored value will be the smallest
non-negative integer that has not already been used.
This occurs because autoincrement columns are associated with :ref:`sequences <box_schema-sequence_create_index>`.

UNIQUE constraints look like this: |br|
:samp:`UNIQUE ({column-name} [, {column-name}...])`

There is a shorthand: specifying UNIQUE in a :ref:`column definition <sql_column_def_constraint>`.

Unique constraints are similar to primary-key constraints, except that:
a table may have any number of unique keys, and unique keys are not automatically NOT NULL. |br|
Unique columns are automatically indexed. |br|
Unique columns are unique, that is, it is illegal to have two rows with the same values in the unique-key columns.

Examples:

.. code-block:: none

    -- this is a table with a one-column primary-key constraint
    -- and a one-column unique constraint
    CREATE TABLE t1 (s1 INTEGER, s2 INTEGER, PRIMARY KEY (s1), UNIQUE (s2));
    -- this is the column-definition shorthand for the same thing:
    CREATE TABLE t1 (s1 INTEGER PRIMARY KEY, s2 INTEGER UNIQUE);
    -- this is a table with a two-column unique constraint
    CREATE TABLE t2 (s1 INTEGER PRIMARY KEY, s2 INTEGER, UNIQUE (s2, s1));
    -- this is an example of an attempted unique-key violation
    -- (the third INSERT will not fail because NULL is not a duplicate)
    -- (the fourth INSERT will fail because 'a' is a duplicate)
    CREATE TABLE t3 (s1 INTEGER PRIMARY KEY, s2 STRING, UNIQUE (s2));
    INSERT INTO t3 VALUES (1, 'a');
    INSERT INTO t3 VALUES (2, NULL);
    INSERT INTO t3 VALUES (3, NULL);
    INSERT INTO t3 VALUES (4, 'a');

CHECK constraints look like this: |br|
:samp:`CHECK ({expression})`

There is a shorthand: specifying CHECK in a :ref:`column definition <sql_column_def_constraint>`.

The expression may be anything that returns a BOOLEAN result = TRUE or FALSE or UNKNOWN. |br|
The expression may not contain a :ref:`subquery <sql_subquery>`. |br|
If the expression contains a column name, the column must exist in the table. |br|
If a CHECK constraint is specified, the table must not contain rows where the expression is FALSE.
(The table may contain rows where the expression is either TRUE or UNKNOWN.) |br|
Constraint checking may be stopped with :ref:`ALTER TABLE ... DISABLE CHECK CONSTRAINT <sql_alter_table>`
and restarted with ALTER TABLE ... ENABLE CHECK CONSTRAINT.

Examples:

.. code-block:: none

    -- this is a table with a one-column primary-key constraint
    -- and a check constraint
    CREATE TABLE t1 (s1 INTEGER PRIMARY KEY, s2 INTEGER, CHECK (s2 <> s1));
    -- this is an attempt to violate the constraint, it will fail
    INSERT INTO t1 VALUES (1, 1);
    -- this is okay because comparison with NULL will not return FALSE
    INSERT INTO t1 VALUES (1, NULL);
    -- a constraint that makes it difficult to insert lower case
    CHECK (s1 = UPPER(s1))

Limitations: (`Issue#3503 <https://github.com/tarantool/tarantool/issues/3503>`_): |br|
* ``CREATE TABLE t99 (s1 INTEGER, UNIQUE(s1, s1),PRIMARY KEY(s1));``
causes no error message, although (s1, s1) is probably a user error.

.. _sql_foreign_key:

*********************************************
Table Constraint Definition for foreign keys
*********************************************

FOREIGN KEY constraints look like this: |br|
:samp:`FOREIGN KEY ({referencing-column-name} [, {referencing-column-name}...]) REFERENCES {referenced-table-name} [({referenced-column-name} [, {referenced-column-name}...]]) [MATCH FULL] [update-or-delete-rules]`

There is a shorthand: specifying REFERENCES in a :ref:`column definition <sql_column_def_constraint>`.

The referencing column names must be defined in the table that is being created.
The referenced table name must refer to a table that already exists,
or to the table that is being created.
The referenced column names must be defined in the referenced table,
and have similar data types.
There must be a PRIMARY KEY or UNIQUE constraint or UNIQUE index on the referenced column names.

The words MATCH FULL are optional and have no effect.

If a foreign-key constraint exists, then the values in the referencing columns
must equal values in the referenced columns of the referenced table,
or at least one of the referencing columns must contain NULL.

Examples:

.. code-block:: none

    -- A foreign key referencing a primary key in the same table
    CREATE TABLE t1 (s1 INTEGER PRIMARY KEY, s2 INTEGER, FOREIGN KEY (s2) REFERENCES t1 (s1));
    -- The same thing with column shorthand
    CREATE TABLE t1 (s1 INTEGER PRIMARY KEY, s2 INTEGER REFERENCES t1(s1));
    -- An attempt to violate the constraint -- this will fail
    INSERT INTO t1 VALUES (1, 2);
    -- A NULL in the referencing column -- this will succeed
    INSERT INTO t1 VALUES (1, NULL);
    -- A reference to a primary key that now exists -- this will succeed
    INSERT INTO t1 VALUES (2, 1);

The optional update-or-delete rules look like this: |br|
``ON {UPDATE|DELETE} { CASCADE | SET DEFAULT | SET NULL | RESTRICT | NO ACTION}`` |br|
and the idea is: if something changes the referenced key, then one of these possible "referential actions" takes place: |br|
``CASCADE``: the change that is applied for the referenced key is applied for the referencing key. |br|
``SET DEFAULT``: the referencing key is set to its default value. |br|
``SET NULL``: the referencing key is set to NULL. |br|
``RESTRICT``: the UPDATE or DELETE fails if a referencing key exists; checked immediately. |br|
``NO ACTION``: the UPDATE or DELETE fails if a referencing key exists; checked at statement end. |br|
The default is ``NO ACTION``.

For example:

.. code-block:: none

    CREATE TABLE f1 (ordinal INTEGER PRIMARY KEY,
                 referenced_planet STRING UNIQUE NOT NULL);
    CREATE TABLE f2 (
        ordinal INTEGER PRIMARY KEY,
        referring_planet STRING DEFAULT 'Earth',
        FOREIGN KEY (referring_planet) REFERENCES f1 (referenced_planet)
            ON UPDATE SET DEFAULT
            ON DELETE CASCADE);
    INSERT INTO f1 VALUES (1, 'Mercury'), (2,' Venus'), (3, 'Earth');
    INSERT INTO f2 VALUES (1, 'Mercury'), (2, 'Mercury');
    UPDATE f1 SET referenced_planet = 'Mars'
        WHERE referenced_planet = 'Mercury';
    SELECT * FROM f2;
    DELETE FROM f1 WHERE referenced_planet = 'Earth';
    SELECT * FROM f2;
    ... In this example, the UPDATE statement changes the referenced key,
        and the clause is ON UPDATE SET DEFAULT, therefore both of the
        rows in f2 have referring_planet set to their default value,
        which is 'Earth'. The DELETE statement deletes the row that
        has 'Earth', and the clause is ON DELETE CASCADE,
        therefore both of the rows in f2 are deleted.

Limitations: |br|
* Foreign keys can have a MATCH clause (`Issue#3455 <https://github.com/tarantool/tarantool/issues/3455>`_).

.. COMMENT
   Constraint Conflict Clauses are temporarily disabled.
   However, the description is here, as a big comment.

   Constraint Conflict Clauses

   In a CREATE TABLE statement:
   CREATE TABLE ... constraint-definition ON CONFLICT {ABORT | FAIL | IGNORE | REPLACE | ROLLBACK} ...;

   In an INSERT or UPDATE statement:
   {INSERT|UPDATE} OR {ABORT | FAIL | IGNORE | REPLACE | ROLLBACK} ...;

   The standard way to handle a constraint violation is "statement rollback" -- all rows affected by the statement are restored to their original values -- and an error is returned. However, Tarantool allows the user to specify non-standard ways to handle PRIMARY KEY, UNIQUE, CHECK, and NOT NULL constraint violations.

   ABORT -- do statement rollback and return an error. This is the default and is recommended, so a user's best strategy is to never use constraint conflict clauses.

   FAIL -- return an error but do not do statement rollback.

   IGNORE -- do not insert or update the row whose update would cause an error, but do not do statement rollback and do not return an error. Due to optimizations related to NoSQL, handling with IGNORE may be slightly faster than handling with ABORT.

   REPLACE -- (for a UNIQUE or PRIMARY KEY constraint) --  instead of inserting a new row, delete the old row before putting in the new one;  (for a NOT NULL constraint for a column that has a non-NULL default value) replace the NULL value with the column's default value; (for a NOT NULL constraint for a column that has a NULL default value) do statement rollback and return an error; (for a CHECK constraint) -- do statement rollback and return an error. If REPLACE action causes a row to be deleted, and if PRAGMA recursive_triggers was specified earlier, then delete triggers (if any) are activated.

   ROLLBACK -- do transaction rollback and return an error.

   The order of constraint evaluation is described in section Order of Execution in Data-Change Statements.

   For example, suppose a new table  t has one column and the column has a unique constraint.
   A transaction starts with START TRANSACTION.
   The first statement in the transaction is INSERT INTO t VALUES (1), (2);
   i.e. "insert 1, then insert 2" -- Tarantool processes the new rows in order.
   This statement always succeeds, there are no constraint violations.
   The second SQL statement is INSERT INTO t VALUES (3), (2), (5);
   i.e. "insert 3, then insert 2".
   Inserting 3 is not a problem, but inserting 2 is a problem -- it would violate the UNIQUE constraint.

   If behavior is ABORT: the second statement is rolled back, there is an error message. The table now contains (1), (2).

   If behavior is FAIL: the second statement is not rolled back, there is an error message. The table now contains (1), (2), (3).

   If behavior is IGNORE: the second statement is not rolled back, the (2) is not inserted, there is no error message. The table now contains (1), (2), (3), (5).

   If behavior is REPLACE: the second statement is not rolled back, the first (2) is replaced by the second (2), there is no error message. The table now contains (1), (2), (3), (5).

   If behavior is ROLLBACK: the statement is rolled back, and the first statement is rolled back,
   and there is an error message. The table now contains nothing.

   There are two ways to specify the behavior: at the end of the CREATE TABLE statement constraint clause, or as an extra clause in an INSERT or UPDATE statement. Specification in the INSERT or UPDATE statement takes precedence.

   Another example:
   DROP TABLE t1;
   CREATE TABLE t1 (s1 INTEGER PRIMARY KEY ON CONFLICT REPLACE, s2 INTEGER);
   INSERT INTO t1 VALUES (1, NULL);      -- now t1 contains (1,NULL)
   INSERT INTO t1 VALUES (1, 1);         -- now t1 contains (1, 1)
   INSERT OR ABORT INTO t1 VALUES (1, 2); -- now t1 contains (1, 1)
   INSERT OR IGNORE INTO t1 VALUES (1, 2), (3, 4); -- now t1 contains (1, 1), (3, 4)
   PRAGMA recursive_triggers(true);
   CREATE TRIGGER t1d
     AFTER DELETE ON t1 FOR EACH ROW
     BEGIN
     INSERT INTO t1 VALUES (18, 25);
     END;
   INSERT INTO t1 VALUES (1, 4); -- now t1 contains (1, 4), (3, 4), (18, 35)

.. _sql_drop_table:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
DROP TABLE
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Syntax:

:samp:`DROP TABLE [IF EXISTS] {table-name};`

|br|

.. image:: drop_table.svg
    :align: left

|br|

Drop a table.

The *table-name* must identify a table that was created earlier with the
:ref:`CREATE TABLE statement <sql_create_table>`.

Rules:

* If there is a view that references the table, the drop will fail.
  Please drop the referencing view with :ref:`DROP VIEW <sql_drop_view>` first.
* If there is a foreign key that references the table, the drop will fail.
  Please drop the referencing constraint with
  :ref:`ALTER TABLE ... DROP <sql_alter_table_drop_constraint>` first.

Actions:

#. Tarantool returns an error if the table does not exist and there is no ``IF EXISTS`` clause.
#. The table and all its data are dropped.
#. All indexes for the table are dropped.
#. All triggers for the table are dropped.
#. Usually Tarantool effectively executes a :ref:`COMMIT <sql_commit>` statement.

Examples:

.. code-block:: sql

   -- the simple case:
   DROP TABLE t31;
   -- with an IF EXISTS clause:
   DROP TABLE IF EXISTS t31;

See also: :ref:`DROP VIEW <sql_drop_view>`.

.. _sql_create_view:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
CREATE VIEW
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Syntax:

:samp:`CREATE VIEW [IF NOT EXISTS] {view-name} [(column-list)] AS subquery;`

|br|

.. image:: create_view.svg
    :align: left

|br|

Create a new viewed table, usually called a "view".

The *view-name* must be valid according to the rules for identifiers.

The optional *column-list* must be a comma-separated list of names of columns
in the view.

The syntax of the subquery must be the same as the syntax of a
:ref:`SELECT statement <sql_select>`,
or of a VALUES clause.

Rules:

* There must not already be a base table or view with the same name as
  *view-name*.
* If *column-list* is specified, the number of columns in *column-list* must be
  the same as the number of columns in the :ref:`select list <sql_select_list>` of the subquery.

Actions:

#. Tarantool will throw an error if a rule is violated.
#. Tarantool will create a new persistent object with *column-names* equal to
   the names in the *column-list* or the names in the subquery's *select list*.
#. Usually Tarantool effectively executes a :ref:`COMMIT <sql_commit>` statement.

Examples:

.. code-block:: sql

   -- the simple case:
   CREATE VIEW v AS SELECT column1, column2 FROM t;
   -- with a column-list:
   CREATE VIEW v (a,b) AS SELECT column1, column2 FROM t;

Limitations:

* It is not possible to insert or update or delete from a view, although
  sometimes a possible substitution is to
  :ref:`create an INSTEAD OF trigger <sql_create_trigger>`.

.. _sql_drop_view:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
DROP VIEW
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Syntax:

:samp:`DROP VIEW [IF EXISTS] {view-name};`

|br|

.. image:: drop_view.svg
    :align: left

|br|

Drop a view.

The *view-name* must identify a view that was created earlier with the
:ref:`CREATE VIEW statement <sql_create_view>`.

Rules: none

Actions:

#. Tarantool returns an error if the view does not exist and there is no ``IF EXISTS`` clause.
#. The view is dropped.
#. All triggers for the view are dropped.
#. Usually Tarantool effectively executes a :ref:`COMMIT <sql_commit>` statement.

Examples:

.. code-block:: sql

   -- the simple case:
   DROP VIEW v31;
   -- with an IF EXISTS clause:
   DROP VIEW IF EXISTS v31;

See also: :ref:`DROP TABLE <sql_drop_table>`.

.. _sql_create_index:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
CREATE INDEX
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Syntax:

:samp:`CREATE [UNIQUE] INDEX [IF NOT EXISTS] {index-name} ON {table-name} (column-list);`

|br|

.. image:: create_index.svg
    :align: left

|br|

Create an index.

The *index-name* must be valid according to the rules for identifiers.

The *table-name* must refer to an existing table.

The *column-list* must be a comma-separated list of names of columns in the
table.

Rules:

* There must not already be, for the same table, an index with the same name as
  *index-name*.
  But there may already be, for a different table, an index with the same name as
  *index-name*.
* The maximum number of indexes per table is 128.

Actions:

#. Tarantool will throw an error if a rule is violated.
#. If the new index is UNIQUE, Tarantool will throw an error if any row exists
   with columns that have duplicate values.
#. Tarantool will create a new index.
#. Usually Tarantool effectively executes a :ref:`COMMIT <sql_commit>` statement.

Automatic indexes:

Indexes may be created automatically for columns mentioned in the PRIMARY KEY
or UNIQUE clauses of a CREATE TABLE statement.
If an index was created automatically, then the *index-name* has four parts:

#. ``pk`` if this is for a PRIMARY KEY clause, ``unique`` if this is for
   a UNIQUE clause;
#. ``_unnamed_``;
#. the name of the table;
#. ``_`` and an ordinal number; the first index is 1, the second index is 2,
   and so on.

For example, after ``CREATE TABLE t (s1 INTEGER PRIMARY KEY, s2 INTEGER, UNIQUE (s2));``
there are two indexes named ``pk_unnamed_T_1`` and ``unique_unnamed_T_2``.
You can confirm this by saying ``SELECT * FROM "_index";`` which will list all
indexes on all tables.
There is no need to say ``CREATE INDEX`` for columns that already have
automatic indexes.

Examples:

.. code-block:: sql

   -- the simple case
   CREATE INDEX idx_column1_t_1 ON t (column1);
   -- with IF NOT EXISTS clause
   CREATE INDEX IF NOT EXISTS idx_column1_t_1 ON t (column1);
   -- with UNIQUE specifier and more than one column
   CREATE UNIQUE INDEX idx_unnamed_t_1 ON t (column1, column2);

Dropping an automatic index created for a unique constraint will drop
the unique constraint as well.

.. _sql_drop_index:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
DROP INDEX
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Syntax:

:samp:`DROP INDEX [IF EXISTS] index-name ON {table-name};`

|br|

.. image:: drop_index.svg
    :align: left

|br|

The *index-name* must be the name of an existing index, which was created with
:ref:`CREATE INDEX <sql_create_index>`.
Or, the *index-name* must be the name of an index that was created automatically
due to a PRIMARY KEY or UNIQUE clause in the :ref:`CREATE TABLE <sql_create_table>` statement.
To see what a table's indexes are, use :ref:`PRAGMA index_list(table-name); <sql_pragma>`.

Rules: none

Actions:

#. Tarantool throws an error if the index does not exist, or is an automatically
   created index.
#. Tarantool will drop the index.
#. Usually Tarantool effectively executes a :ref:`COMMIT <sql_commit>` statement.

Example:

.. code-block:: sql

   -- the simplest form:
   DROP INDEX idx_unnamed_t_1 ON t;

.. _sql_insert:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
INSERT
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Syntax:

* :samp:`INSERT INTO {table-name} [(column-list)] VALUES (expression-list) [, (expression-list)];`
* :samp:`INSERT INTO {table-name} [(column-list)]  select-statement;`
* :samp:`INSERT INTO {table-name} DEFAULT VALUES;`

|br|

.. image:: insert.svg
    :align: left

|br|

Insert one or more new rows into a table.

The *table-name* must be a name of a table defined earlier with :ref:`CREATE TABLE <sql_create_table>`.

The optional *column-list* must be a comma-separated list of names of columns
in the table.

The *expression-list* must be a comma-separated list of expressions; each
expression may contain literals and operators and subqueries and function invocations.

Rules:

* The values in the *expression-list* are evaluated from left to right.
* The order of the values in the *expression-list* must correspond to the order
  of the columns in the table, or (if a *column-list* is specified) to the order
  of the columns in the *column-list*.
* The data type of the value should correspond to the
  :ref:`data type of the column <sql_column_def_data_type>`,
  that is, the data type that was specified with CREATE TABLE.
* If a *column-list* is not specified, then the number of expressions must be
  the same as the number of columns in the table.
* If a *column-list* is specified, then some columns may be omitted; omitted
  columns will get default values.
* The parenthesized *expression-list* may be repeated --
  ``(expression-list),(expression-list),...`` -- for multiple rows.

Actions:

#. Tarantool evaluates each expression in *expression-list*, and returns an
   error if any of the rules is violated.
#. Tarantool creates zero or more new rows containing values based on the values
   in the VALUES list or based on the results of the *select-expression* or
   based on the default values.
#. Tarantool executes constraint checks and trigger actions and the actual insertion.

.. //  append to 3: in the order described by section "Order of Execution in Data-Change Statements"

Examples:

.. code-block:: sql

   -- the simplest form:
   INSERT INTO table1 VALUES (1, 'A');
   -- with a column list:
   INSERT INTO table1 (column1, column2) VALUES (2, 'B');
   -- with an arithmetic operator in the first expression:
   INSERT INTO table1 VALUES (2 + 1, 'C');
   -- put two rows in the table:
   INSERT INTO table1 VALUES (4, 'D'), (5, 'E');


See also: :ref:`REPLACE statement <sql_replace>`.

.. _sql_update:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
UPDATE
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Syntax:

:samp:`UPDATE {table-name}
SET column-name = expression [, column-name = expression ...]
[WHERE search-condition];`

|br|

.. image:: update.svg
    :align: left

|br|

Update zero or more existing rows in a table.

The *table-name* must be a name of a table defined earlier with
:ref:`CREATE TABLE <sql_create_table>` or :ref:`CREATE VIEW <sql_create_view>`.

The *column-name* must be an updatable column in the table.

The *expression* may contain literals and operators and subqueries and function
invocations and column names.

Rules:

* The values in the SET clause are evaluated from left to right.
* The data type of the value should correspond to the
  :ref:`data type of the column <sql_column_def_data_type>`,
  that is, the data type that was specified with CREATE TABLE.
* If a *search-condition* is not specified, then all rows in the table will be
  updated; otherwise only those rows which match the *search-condition* will be
  updated.

Actions:

#. Tarantool evaluates each expression in the SET clause, and returns an error
   if any of the rules is violated.
   For each row that is found by the WHERE clause, a temporary new row is formed
   based on the original contents and the modifications caused by the SET clause.
#. Tarantool executes constraint checks and trigger actions and the actual update.

.. // append to 2: in the order described by section Order of Execution in Data-Change Statements.

Examples:

.. code-block:: sql

   -- the simplest form:
   UPDATE t SET column1 = 1;
   -- with more than one assignment in the SET clause:
   UPDATE t SET column1 = 1, column2 = 2;
   -- with a WHERE clause:
   UPDATE t SET column1 = 5 WHERE column2 = 6;

Special cases:

It is legal to say SET (list of columns) = (list of values). For example:

.. code-block:: sql

   UPDATE t SET (column1, column2, column3) = (1, 2, 3);

It is not legal to assign to a column more than once. For example:

.. code-block:: sql

   INSERT INTO t (column1) VALUES (0);
   UPDATE t SET column1 = column1 + 1, column1 = column1 + 1;

The result is an error: "duplicate column name".

It is not legal to assign to a primary-key column.

.. _sql_delete:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
DELETE
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Syntax:

:samp:`DELETE FROM {table-name} [WHERE search-condition];`

|br|

.. image:: delete.svg
    :align: left

|br|

Delete zero or more existing rows in a table.

The *table-name* must be a name of a table defined earlier with
:ref:`CREATE TABLE <sql_create_table>` or :ref:`CREATE VIEW <sql_create_view>`.

The *search-condition* may contain literals and operators and subqueries and
function invocations and column names.

Rules:

* If a search-condition is not specified, then all rows in the table will be
  deleted; otherwise only those rows which match the *search-condition* will be
  deleted.

Actions:

#. Tarantool evaluates each expression in the *search-condition*, and returns
   an error if any of the rules is violated.
#. Tarantool finds the set of rows that are to be deleted.
#. Tarantool executes constraint checks and trigger actions and the actual deletion.

.. // append to 3: in the order described by section Order of Execution in Data-Change Statements.

Examples:

.. code-block:: sql

   -- the simplest form:
   DELETE FROM t;
   -- with a WHERE clause:
   DELETE FROM t WHERE column2 = 6;

.. _sql_replace:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
REPLACE
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Syntax:

* :samp:`REPLACE INTO {table-name} [(column-list)] VALUES (expression-list) [, (expression-list)];`
* :samp:`REPLACE INTO {table-name} [(column-list)] select-statement;`
* :samp:`REPLACE INTO {table-name} DEFAULT VALUES;`

|br|

.. image:: replace.svg
    :align: left

|br|

Insert one or more new rows into a table, or update existing rows.

If a row already exists (as determined by the primary key or any unique key),
then the action is delete + insert, and the rules are the same as for a
:ref:`DELETE statement <sql_delete>` followed by an :ref:`INSERT statement <sql_insert>`.
Otherwise the action is insert, and the rules are the same as for the
INSERT statement.

Examples:

.. code-block:: sql

   -- the simplest form:
   REPLACE INTO table1 VALUES (1, 'A');
   -- with a column list:
   REPLACE INTO table1 (column1, column2) VALUES (2, 'B');
   -- with an arithmetic operator in the first expression:
   REPLACE INTO table1 VALUES (2 + 1, 'C');
   -- put two rows in the table:
   REPLACE INTO table1 VALUES (4, 'D'), (5, 'E');

See also: :ref:`INSERT Statement <sql_insert>`, :ref:`UPDATE Statement <sql_update>`.

.. // and Order of Execution in Data-Change Statements.

.. _sql_create_trigger:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
CREATE TRIGGER
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Syntax:

:samp:`CREATE TRIGGER [IF NOT EXISTS] {trigger-name}` |br|
:samp:`BEFORE|AFTER|INSTEAD OF` |br|
:samp:`DELETE|INSERT|UPDATE ON {table-name}` |br|
:samp:`FOR EACH ROW` |br|
:samp:`[WHEN search-condition]` |br|
:samp:`BEGIN` |br|
:samp:`delete-statement | insert-statement | replace-statement | select-statement | update-statement;` |br|
:samp:`[delete-statement | insert-statement | replace-statement | select-statement | update-statement; ...]` |br|
:samp:`END;`

|br|

.. image:: create_trigger.svg
    :align: left

|br|

The *trigger-name* must be valid according to the rules for identifiers.

If the trigger action time is BEFORE or AFTER, then the *table-name* must refer
to an existing base table.

If the trigger action time is INSTEAD OF, then the *table-name* must refer to an
existing view.

Rules:

* There must not already be a trigger with the same name as *trigger-name*.
* Triggers on different tables or views share the same namespace.
* The statements between BEGIN and END should not refer to the *table-name*
  mentioned in the ON clause.
* The statements between BEGIN and END should not contain an
  :ref:`INDEXED BY <sql_indexed_by>` clause.

SQL triggers are not activated by Tarantool/NoSQL requests.
This will change in a future version.

On a :ref:`replica <Replication>`, effects of trigger execution are applied, and the SQL triggers
themselves are not activated upon replication events.

NoSQL triggers are activated both on replica and master, thus if you have a
:ref:`NoSQL trigger <triggers>` on a replica, it is activated when applying effects of an SQL trigger.

Actions:

#. Tarantool will throw an error if a rule is violated.
#. Tarantool will create a new trigger.
#. Usually Tarantool effectively executes a :ref:`COMMIT <sql_commit>` statement.

Examples:

.. code-block:: sql

   -- the simple case:
   CREATE TRIGGER stores_before_insert BEFORE INSERT ON stores FOR EACH ROW
     BEGIN DELETE FROM warehouses; END;
   -- with IF NOT EXISTS clause:
   CREATE TRIGGER IF NOT EXISTS stores_before_insert BEFORE INSERT ON stores FOR EACH ROW
     BEGIN DELETE FROM warehouses; END;
   -- with FOR EACH ROW and WHEN clauses:
   CREATE TRIGGER stores_before_insert BEFORE INSERT ON stores FOR EACH ROW WHEN a=5
     BEGIN DELETE FROM warehouses; END;
   -- with multiple statements between BEGIN and END:
   CREATE TRIGGER stores_before_insert BEFORE INSERT ON stores FOR EACH ROW
     BEGIN DELETE FROM warehouses; INSERT INTO inventories VALUES (1); END;

.. _sql_trigger_extra:

***********************************************
Trigger extra clauses
***********************************************

* :samp:`UPDATE OF column-list`

  After BEFORE|AFTER UPDATE it is optional to add ``OF column-list``.
  If any of the columns in *column-list* is affected at the time the row is
  processed, then the trigger will be activated for that row. For example:

  .. code-block:: sql

     CREATE TRIGGER table1_before_update
      BEFORE UPDATE  OF column1, column2 ON table1
      FOR EACH ROW
      BEGIN UPDATE table2 SET column1 = column1 + 1; END;
     UPDATE table1 SET column3 = column3 + 1; -- Trigger will not be activated
     UPDATE table1 SET column2 = column2 + 0; -- Trigger will be activated

* :samp:`WHEN`

  After *table-name* FOR EACH ROW it is optional to add [``WHEN expression``].
  If the expression is true at the time the row is processed, only then will the
  trigger will be activated for that row. For example:

  .. code-block:: sql

     CREATE TRIGGER table1_before_update BEFORE UPDATE ON table1 FOR EACH ROW
      WHEN (SELECT COUNT(*) FROM table1) > 1
      BEGIN UPDATE table2 SET column1 = column1 + 1; END;

  This trigger will not be activated unless there is more than one row in
  ``table1``.

* :samp:`OLD and NEW`

  The keywords OLD and NEW have special meaning in the context of trigger action:

  * OLD.column-name refers to the value of *column-name* before the change.
  * NEW.column-name refers to the value of *column-name* after the change.

  For example:

  .. code-block:: sql

     CREATE TABLE table1 (column1 STRING, column2 INTEGER PRIMARY KEY);
     CREATE TABLE table2 (column1 STRING, column2 STRING, column3 INTEGER PRIMARY KEY);
     INSERT INTO table1 VALUES ('old value', 1);
     INSERT INTO table2 VALUES ('', '', 1);
     CREATE TRIGGER table1_before_update BEFORE UPDATE ON table1 FOR EACH ROW
      BEGIN UPDATE table2 SET column1 = old.column1, column2 = new.column1; END;
     UPDATE table1 SET column1 = 'new value';
     SELECT * FROM table2;

  At the beginning of the UPDATE for the single row of ``table1``, the value in
  ``column1`` is 'old value' -- so that is what is seen as ``old.column1``.

  At the end of the UPDATE for the single row of ``table1``, the value in
  ``column1`` is 'new value' -- so that is what is seen as ``new.column1``.
  (OLD and NEW are qualifiers for ``table1``, not ``table2.``)

  Therefore, ``SELECT * FROM table2;`` returns ``['old value', 'new value']``.

  ``OLD.column-name`` does not exist for an INSERT trigger.

  ``NEW.column-name`` does not exist for a DELETE trigger.

  OLD and NEW are read-only; you cannot change their values.

* Deprecated or illegal statements:

  It is illegal for the trigger action to include a qualified column reference
  other than ``OLD.column-name`` or ``NEW.column-name``. For example,
  ``CREATE TRIGGER ... BEGIN UPDATE table1 SET table1.column1 = 5; END;``
  is illegal.

  It is illegal for the trigger action to include statements that include a
  :ref:`WITH clause <sql_with>`,
  a DEFAULT VALUES clause, or an :ref:`INDEXED BY <sql_indexed_by>` clause.

  It is usually not a good idea to have a trigger on ``table1`` which causes
  a change on ``table2``, and at the same time have a trigger on ``table2``
  which causes a change on ``table1``. For example:

  .. code-block:: none

     CREATE TRIGGER table1_before_update
      BEFORE UPDATE ON table1
      FOR EACH ROW
      BEGIN UPDATE table2 SET column1 = column1 + 1; END;
     CREATE TRIGGER table2_before_update
      BEFORE UPDATE ON table2
      FOR EACH ROW
      BEGIN UPDATE table1 SET column1 = column1 + 1; END;

  Luckily ``UPDATE table1 ...`` will not cause an infinite loop, because
  Tarantool recognizes when it has already updated so it will stop.
  However, not every DBMS acts this way.

.. _sql_trigger_activation:

***********************************************
Trigger activation
***********************************************

These are remarks concerning trigger activation.

Standard terminology:

* "trigger action time" = BEFORE or AFTER or INSTEAD OF
* "trigger event" = INSERT or DELETE or UPDATE
* "triggered statement" = BEGIN ... DELETE|INSERT|REPLACE|SELECT|UPDATE ... END
* "triggered when clause" = WHEN search-condition
* "activate" = execute a triggered statement
* some vendors use the word "fire" instead of "activate"

If there is more than one trigger for the same trigger event, Tarantool may
execute the triggers in any order.

It is possible for a triggered statement to cause activation of another
triggered statement. For example, this is legal:

.. code-block:: sql

   CREATE TRIGGER t1_before_delete BEFORE DELETE ON t1 FOR EACH ROW BEGIN DELETE FROM t2; END;
   CREATE TRIGGER t2_before_delete BEFORE DELETE ON t2 FOR EACH ROW BEGIN DELETE FROM t3; END;

Activation occurs FOR EACH ROW, not FOR EACH STATEMENT. Therefore, if no rows
are candidates for insert or update or delete, then no triggers are activated.

The BEFORE trigger is activated even if the trigger event fails.

If an UPDATE trigger event does not make a change, the trigger is activated
anyway. For example, if row 1 ``column1`` contains ``'a'``, and the trigger event
is ``UPDATE ... SET column1 = 'a';``, the trigger is activated.

The triggered statement may refer to a function:
``RAISE(FAIL, error-message)``.
If a triggered statement invokes a ``RAISE(FAIL, error-message)`` function, or
if a triggered statement causes an error, then statement execution stops
immediately.

The triggered statement may refer to column values within the rows being changed.
in this case:

* The row "as of before" the change is called the "old" row (which makes sense
  only for UPDATE and DELETE statements).
* The row "as of after" the change is called the "new" row (which makes sense
  only for UPDATE and INSERT statements).

This example shows how an INSERT can be done to a view by referring to the
"new" row:

.. code-block:: sql

   CREATE TABLE t (s1 INTEGER PRIMARY KEY, s2 INTEGER);
   CREATE VIEW v AS SELECT s1, s2 FROM t;
   CREATE TRIGGER v_instead_of INSTEAD OF INSERT ON v
     FOR EACH ROW
     BEGIN INSERT INTO t VALUES (new.s1, new.s2); END;
   INSERT INTO v VALUES (1, 2);

Ordinarily saying ``INSERT INTO view_name ...`` is illegal in Tarantool,
so this is a workaround.

It is possible to generalize this so that all data-change statements
on views will change the base tables, provided that the view contains
all the columns of the base table, and provided that the triggers
refer to those columns when necessary, as in this example:

.. code-block:: sql

   CREATE TABLE base_table (primary_key_column INTEGER PRIMARY KEY, value_column INTEGER);
   CREATE VIEW viewed_table AS SELECT primary_key_column, value_column FROM base_table;
   CREATE TRIGGER viewed_table_instead_of_insert INSTEAD OF INSERT ON viewed_table FOR EACH ROW
     BEGIN
       INSERT INTO base_table VALUES (new.primary_key_column, new.value_column); END;
   CREATE TRIGGER viewed_table_instead_of_update INSTEAD OF UPDATE ON viewed_table FOR EACH ROW
     BEGIN
       UPDATE base_table
       SET primary_key_column = new.primary_key_column, value_column = new.value_column
       WHERE primary_key_column = old.primary_key_column; END;
   CREATE TRIGGER viewed_table_instead_of_delete INSTEAD OF DELETE ON viewed_table FOR EACH ROW
     BEGIN
       DELETE FROM base_table WHERE primary_key_column = old.primary_key_column; END;

When INSERT or UPDATE or DELETE occurs for table ``X``, Tarantool usually
operates in this order (a basic scheme):

.. code-block:: none

   For each row
     Perform constraint checks
     For each BEFORE trigger that refers to table X
       Check that the trigger's WHEN condition is true.
       Execute what is in the triggered statement.
     Insert or update or delete the row in table X.
     Perform more constraint checks
     For each AFTER trigger that refers to table X
       Check that the trigger's WHEN condition is true.
       Execute what is in the triggered statement.

.. // For details, see "Order of Execution in Data-change statements".

However, Tarantool does not guarantee execution order when there are multiple
constraints, or multiple triggers for the same event (including NoSQL
:ref:`on_replace triggers <box_space-on_replace>`
or SQL
:ref:`INSTEAD OF triggers <sql_instead_of_triggers>` that affect a view of table
``X``).

The maximum number of trigger activations per statement is 32.

.. _sql_instead_of_triggers:

***********************************************
INSTEAD OF triggers
***********************************************

A trigger which is created with the clause |br|
:samp:`INSTEAD OF {INSERT|UPDATE|DELETE} ON {view-name}` |br|
is an INSTEAD OF trigger. For each affected row, the trigger action is performed
"instead of" the INSERT or UPDATE or DELETE statement that causes trigger
activation.

For example, ordinarily it is illegal to INSERT rows in a view, but it is legal
to create a trigger which intercepts attempts to INSERT, and puts rows in the
underlying base table:

.. code-block:: sql

   CREATE TABLE t1 (column1 INTEGER PRIMARY KEY, column2 INTEGER);
   CREATE VIEW v1 AS SELECT column1, column2 FROM t1;
   CREATE TRIGGER v1_instead_of INSTEAD OF INSERT ON v1 FOR EACH ROW BEGIN
    INSERT INTO t1 VALUES (NEW.column1, NEW.column2); END;
   INSERT INTO v1 VALUES (1, 1);
   -- ... The result will be: table t1 will contain a new row.

INSTEAD OF triggers are only legal for views, while
BEFORE or AFTER triggers are only legal for base tables.

It is legal to create INSTEAD OF triggers with triggered WHEN clauses.

Limitations:

* It is legal to create INSTEAD OF triggers with UPDATE OF *column-list* clauses,
  but they are not standard SQL.

Example:

.. code-block:: sql

   CREATE TRIGGER ev1_instead_of_update
     INSTEAD OF UPDATE OF column2,column1 ON ev1
     FOR EACH ROW BEGIN
     INSERT INTO et2 VALUES (NEW.column1, NEW.column2); END;

.. _sql_drop_trigger:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
DROP TRIGGER
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Syntax:

:samp:`DROP TRIGGER [IF EXISTS] {trigger-name};`

|br|

.. image:: drop_trigger.svg
    :align: left

|br|

Drop a trigger.

The *trigger-name* must identify a trigger that was created earlier with the
:ref:`CREATE TRIGGER <sql_create_trigger>` statement.

Rules: none

Actions:

#. Tarantool returns an error if the trigger does not exist and there is no ``IF EXISTS`` clause.
#. The trigger is dropped.
#. Usually Tarantool effectively executes a :ref:`COMMIT <sql_commit>` statement.

Examples:

.. code-block:: sql

   -- the simple case:
   DROP TRIGGER table1_before_insert;
   -- with an IF EXISTS clause:
   DROP TRIGGER IF EXISTS table1_before_insert;

.. _sql_truncate:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
TRUNCATE
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Syntax:

:samp:`TRUNCATE TABLE {table-name};`

|br|

.. image:: truncate.svg
    :align: left

|br|

Remove all rows in the table.

TRUNCATE is considered to be a schema-change rather than a data-change statement,
so it does not work within transactions (it cannot be
:ref:`rolled back <sql_rollback>`).

Rules:

* It is illegal to truncate a table which is referenced by a foreign key.
* It is illegal to truncate a table which is also a system space, such as
  ``_space``.
* The table must be a base table rather than a view.

Actions:

#. All rows in the table are removed. Usually this is faster than
   :samp:`DELETE FROM {table-name};`.
#. If the table has an autoincrement primary key, its
   :ref:`sequence <box_schema-sequence_create_index>` is not reset to zero,
   but that may occur in a future Tarantool version.
#. There is no effect for any triggers associated with the table.
#. There is no effect on the counts for the ``ROW_COUNT()`` function.
#. Only one action is written to the
   :ref:`write-ahead log <internals-wal>`
   (with :samp:`DELETE FROM {table-name};` there would be one action for each deleted
   row).

Example:

.. code-block:: sql

   TRUNCATE TABLE t;

.. _sql_select:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
SELECT
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Syntax:

:samp:`SELECT [ALL|DISTINCT]
select list
[from clause]
[where clause]
[group-by clause] [having clause]
[order-by clause];`

|br|

.. image:: select.svg
    :align: left

|br|

Select zero or more rows.

The clauses of the SELECT statement are discussed in the following five sections.

.. _sql_select_list:

***********************************************
Select list
***********************************************

Syntax:

:samp:`select-list-column [, select-list-column ...]`

select-list-column:

.. image:: select_list.svg
    :align: left

|br|

Define what will be in a result set; this is a clause in a :ref:`SELECT statement <sql_select>`.

The *select list* is a comma-delimited list of expressions, or ``*`` (asterisk).
An expression can have an alias provided with an ``[[AS] column-name]`` clause.

The ``*`` "asterisk" shorthand is valid if and only if the SELECT statement also
contains a :ref:`FROM clause <sql_from>` which specifies the table or tables
(details about the FROM clause are in the next section). The simple form is
``*``
which means "all columns" -- for example, if the select is done for a table
which contains three columns ``s1`` ``s2`` ``s3``, then ``SELECT * ...``
is equivalent to ``SELECT s1, s2, s3 ...``.
The qualified form is ``table-name.*`` which means "all columns in the specified
table", which again must be a result of the FROM clause -- for example, if the
table is named ``table1``, then ``table1.*`` is equivalent to a list of the
columns of ``table1``.

The ``[[AS] column-name]`` clause determines the column name.
The column name is useful for two reasons:

* in a tabular display, the column names are the headings
* if the results of the SELECT are used when creating a new table (such as a view),
  then
  the column names in the new table will be the column names in the *select list*.

If ``[[AS] column-name]`` is missing, Tarantool makes a name equal to the
expression, for example ``SELECT 5 * 88`` will cause the column name to be
``5 * 88``, but such names may be ambiguous or illegal in other contexts,
so it is better to say, for example, ``SELECT 5 * 88 AS column1``.

Examples:

.. code-block:: sql

   -- the simple form:
   SELECT 5;
   -- with multiple expressions including operators:
   SELECT 1, 2 * 2, 'Three' || 'Four';
   -- with [[AS] column-name] clause:
   SELECT 5 AS column1;
   -- * which must be eventually followed by a FROM clause:
   SELECT * FROM table1;
   -- as a list:
   SELECT 1 AS a, 2 AS b, table1.* FROM table1;

Limitations: (`Issue#3962 <https://github.com/tarantool/tarantool/issues/3962>`_) |br|
* Names for expressions will change in a future version.


.. _sql_from:

***********************************************
FROM clause
***********************************************

Syntax:

:samp:`FROM table-reference [, table-reference ...]`

|br|

.. image:: from.svg
    :align: left

|br|

Specify the table or tables for the source of a :ref:`SELECT statement <sql_select>`.

The *table-reference* must be a name of an existing table, or a subquery, or
a joined table.

A joined table looks like this:

:samp:`table-reference-or-joined-table join-operator table-reference-or-joined-table [join-specification]`

A *join-operator* must be any of
`the standard types <https://en.wikipedia.org/wiki/Join_(SQL)>`_:

* [NATURAL] LEFT [OUTER] JOIN,
* [NATURAL] INNER JOIN, or
* CROSS JOIN

A *join-specification* must be any of:

* ON expression, or
* USING (column-name [, column-name ...])

Parentheses are allowed, and ``[[AS] correlation-name]`` is allowed.

The maximum number of joins in a FROM clause is 64.

Examples:

.. code-block:: sql

   -- the simplest form:
   SELECT * FROM t;
   -- with two tables, making a Cartesian join:
   SELECT * FROM t1, t2;
   -- with one table joined to itself, requiring correlation names:
   SELECT a.*, b.* FROM t1 AS a, t1 AS b;
   -- with a left outer join:
   SELECT * FROM t1 LEFT JOIN t2;

.. _sql_where:

***********************************************
WHERE clause
***********************************************

Syntax:

:samp:`WHERE condition;`

|br|

.. image:: where.svg
    :align: left

|br|

Specify the condition for filtering rows from a table; this is a clause in
a :ref:`SELECT <sql_select>` or :ref:`UPDATE <sql_update>` or :ref:`DELETE <sql_delete>` statement.

The condition may contain any expression that returns a BOOLEAN
(TRUE or FALSE or UNKNOWN) value.

For each row in the table:

* if the condition is true, then the row is kept;
* if the condition is false or unknown, then the row is ignored.

In effect, WHERE condition takes a table with n rows and returns a table with
n or fewer rows.

Examples:

.. code-block:: sql

   -- with a simple condition:
   SELECT 1 FROM t WHERE column1 = 5;
   -- with a condition that contains AND and OR and parentheses:
   SELECT 1 FROM t WHERE column1 = 5 AND (x > 1 OR y < 1);

.. _sql_group_by:

***********************************************
GROUP BY clause
***********************************************

Syntax:

:samp:`GROUP BY expression [, expression ...]`

|br|

.. image:: group_by.svg
    :align: left

|br|

Make a grouped table; this is a clause in a :ref:`SELECT statement <sql_select>`.

The expressions should be column names in the table, and each column should be
specified only once.

In effect, the GROUP BY clause takes a table with rows that may have matching values,
combines rows that have matching values into single rows,
and returns a table which, because it is the result of GROUP BY,
is called a grouped table.

Thus, if the input is a table:

.. code-block:: none

   a    b      c
   -    -      -
   1    'a'   'b
   1    'b'   'b'
   2    'a'   'b'
   3    'a'   'b'
   1    'b'   'b'

then ``GROUP BY a, b`` will produce a grouped table:

.. code-block:: none

   a    b      c
   -    -      -
   1    'a'   'b'
   1    'b'   'b'
   2    'a'   'b'
   3    'a'   'b'

The rows where column ``a`` and column ``b`` have the same value have been
merged; column ``c`` has been preserved but its value should not be depended
on -- if the rows were not all 'b', Tarantool could pick any value.

It is useful to envisage a grouped table as having hidden extra columns for
the aggregation of the values, for example:

.. code-block:: none

   a    b      c    COUNT(a) SUM(a) MIN(c)
   -    -      -    -------- ------ ------
   1    'a'    'b'         2      2    'b'
   1    'b'    'b'         1      1    'b'
   2    'a'    'b'         1      2    'b'
        'a'    'b'         1      3    'b'

These extra columns are what :ref:`aggregate functions <sql_aggregate>` are for.

Examples:

.. code-block:: sql

   -- with a single column:
   SELECT 1 FROM t GROUP BY column1;
   -- with two columns:
   SELECT 1 FROM t GROUP BY column1, column2;

Limitations:

* ``SELECT s1, s2 FROM t GROUP BY s1;`` is legal.
* ``SELECT s1 AS q FROM t GROUP BY q;`` is legal.
* ``SELECT s1 FROM t GROUP by 1;`` is legal.

.. // (Issue#2364)

.. _sql_aggregate:

***********************************************
Aggregate functions
***********************************************

Syntax:

:samp:`function-name (one or more expressions)`

Apply a built-in aggregate function to one or more expressions and return
a scalar value.

Aggregate functions are only legal in certain clauses
of a :ref:`SELECT statement <sql_select>` for grouped tables. (A table is a grouped
table if a GROUP BY clause is present.) Also, if
an aggregate function is used in a :ref:`select list <sql_select_list>` and the
GROUP BY clause is omitted, then Tarantool assumes
``SELECT ... GROUP BY [all columns];``.

NULLs are ignored for all aggregate functions except COUNT(*).

.. _sql_aggregate_avg:

``AVG([DISTINCT] expression)``
             Return the average value of expression.

             Example: :samp:`AVG({column1})`

.. _sql_aggregate_count_row:

``COUNT([DISTINCT] expression)``
             Return the number of occurrences of expression.

             Example: :samp:`COUNT({column1})`

``COUNT(*)``
             Return the number of occurrences of a row.

             Example: :samp:`COUNT(*)`

``GROUP_CONCAT(expression-1 [, expression-2])`` or ``GROUP_CONCAT(DISTINCT expression-1)``
             Return a list of *expression-1* values, separated
             by commas if *expression-2* is omitted, or separated
             by the *expression-2* value if *expression-2* is not omitted.

             Example: :samp:`GROUP_CONCAT({column1})`

.. _sql_aggregate_max:

``MAX([DISTINCT] expression)``
             Return the maximum value of expression.

             Example: :samp:`MAX({column1})`

.. _sql_aggregate_min:

``MIN([DISTINCT] expression)``
             Return the minimum value of expression.

             Example: :samp:`MIN({column1})`

.. _sql_aggregate_sum:

``SUM([DISTINCT] expression)``
             Return the sum of values of expression.

             Example: :samp:`SUM({column1})`

``TOTAL([DISTINCT] expression)``
             Return the sum of values of expression.

             Example: :samp:`TOTAL({column1})`

.. // See also: :ref:`Functions <sql_functions>`.

.. _sql_having:

***********************************************
HAVING clause
***********************************************

Syntax:

:samp:`HAVING condition;`

|br|

.. image:: having.svg
    :align: left

|br|

Specify the condition for filtering rows from a grouped table;
this is a clause in a :ref:`SELECT statement <sql_select>`.

The clause preceding the HAVING clause may be a GROUP BY clause.
HAVING operates on the table that the GROUP BY produces,
which may contain grouped columns and aggregates.

If the preceding clause is not a GROUP BY clause,
then there is only one group and the HAVING clause may only contain
aggregate functions or literals.

For each row in the table:

* if the condition is true, then the row is kept;
* if the condition is false or unknown, then the row is ignored.

In effect, HAVING condition takes a table with n rows and returns a table
with n or fewer rows.

Examples:

.. code-block:: sql

   -- with a simple condition:
   SELECT 1 FROM t GROUP BY column1 HAVING column2 > 5;
   -- with a more complicated condition:
   SELECT 1 FROM t GROUP BY column1 HAVING column2 > 5 OR column2 < 5;
   -- with an aggregate:
   SELECT x, SUM(y) FROM t GROUP BY x HAVING SUM(y) > 0;
   -- with no GROUP BY and an aggregate:
   SELECT SUM(y) FROM t GROUP BY x HAVING MIN(y) < MAX(y);

Limitations:

* HAVING without GROUP BY is not supported for multiple tables.

.. _sql_order_by:

***********************************************
ORDER BY clause
***********************************************

Syntax:

:samp:`ORDER BY expression [ASC|DESC] [, expression [ASC|DESC] ...]`

|br|

.. image:: order_by.svg
    :align: left

|br|

Put rows in order; this is a clause in a :ref:`SELECT statement <sql_select>`.

An ORDER BY expression has one of three types which are checked in order:

#. Expression is a positive integer, representing the ordinal position of the
   column in the :ref:`select list <sql_select_list>`. For example, in the statement |br|
   ``SELECT x, y, z FROM t ORDER BY 2;`` |br|
   ``ORDER BY 2`` means "order by the second column in the select list",
   which is ``y``.
#. Expression is a name of a column in the select list, which is determined
   by an AS clause. For example, in the statement |br|
   ``SELECT x, y AS x, z FROM t ORDER BY x;`` |br|
   ``ORDER BY x`` means "order by the column explicitly named ``x`` in the
   select list", which is the second column.
#. Expression contains a name of a column in a table of the FROM clause.
   For example, in the statement |br|
   ``SELECT x, y FROM t1 JOIN t2 ORDER BY z;`` |br|
   ``ORDER BY z`` means "order by a column named ``z`` which is expected to be
   in table ``t1`` or table ``t2``".

If both tables contain a column named ``z``, then Tarantool will choose
the first column that it finds.

The expression may also contain operators and function names and literals.
For example, in the statement |br|
``SELECT x, y FROM t ORDER BY UPPER(z);`` |br|
``ORDER BY UPPER(z)`` means "order by the uppercase form of column ``t.z``",
which may be similar to doing ordering in a case-insensitive manner.

Type 3 is illegal if the SELECT statement contains
:ref:`UNION or EXCEPT or INTERSECT <sql_union>`.

If an ORDER BY clause contains multiple expressions, then expressions on the
left are processed first and expressions on the right are processed only if
necessary for tie-breaking.
For example, in the statement |br|
``SELECT x, y FROM t ORDER BY x, y;``
if there are two rows which both have the same values for column ``x``,
then an additional check is made to see which row has a greater value
for column ``y``.

In effect, ORDER BY clause takes a table with rows that may be out of order,
and returns a table with rows in order.

Sorting order:

* The default order is ASC (ascending), the optional order is DESC (descending).
* NULLs come first, then BOOLEANs, then numbers, then STRINGs, then VARBINARYs.
* Within STRINGs, ordering is according to collation.
* Collation may be specified with a :ref:`COLLATE clause <sql_collate_clause>` within the ORDER BY column-list, or may be default.

Examples:

.. code-block:: sql

   -- with a single column:
   SELECT 1 FROM t ORDER BY column1;
   -- with two columns:
   SELECT 1 FROM t ORDER BY column1, column2;
   -- with a variety of data:
   CREATE TABLE h (s1 NUMBER PRIMARY KEY, s2 SCALAR);
   INSERT INTO h VALUES (7, 'A'), (4, 'a'), (-4, 'AZ'), (17, 17), (23, NULL);
   INSERT INTO h VALUES (17.5, 'Д'), (1e+300, 'A'), (0, ''), (-1, '');
   SELECT * FROM h ORDER BY s2 COLLATE "unicode_ci", s1;
   -- The result of the above SELECT will be:
   - - [23, null]
     - [17, 17]
     - [-1, '']
     - [0, '']
     - [4, 'a']
     - [7, 'A']
     - [1e+300, 'A']
     - [-4, 'AZ']
     - [17.5, 'Д']
   ...

Limitations:

* ORDER BY 1 is legal. This is common but is not standard SQL nowadays.

.. // (Issue#2365)

.. _sql_limit:

***********************************************
LIMIT clause
***********************************************

Syntax:

* :samp:`LIMIT limit-expression [OFFSET offset-expression]`
* :samp:`LIMIT offset-expression, limit-expression`

.. NOTE::

   The above is not a typo: *offset-expression* and *limit-expression* are
   in reverse order if a comma is used.

|br|

.. image:: limit.svg
    :align: left

|br|

Specify a maximum number of rows and a start row; this is a clause in
a :ref:`SELECT statement <sql_select>`.

Expressions may contain integers and arithmetic operators or functions,
for example ``ABS(-3 / 1)``.
However, the result must be an integer value greater than or equal to zero.

Usually the LIMIT clause follows an :ref:`ORDER BY clause <sql_order_by>`, because otherwise
Tarantool does not guarantee that rows are in order.

Examples:

.. code-block:: sql

   -- simple case:
   SELECT * FROM t LIMIT 3;
   -- both limit and order:
   SELECT * FROM t LIMIT 3 OFFSET 1;
   -- applied to a UNIONed result (LIMIT clause must be the final clause):
   SELECT column1 FROM table1 UNION SELECT column1 FROM table2 ORDER BY 1 LIMIT 1;

Limitations:

* If ORDER BY ... LIMIT is used, then all order-by columns must be
  ASC or all must be DESC.

.. // (Issue#4038)

.. _sql_values:

***********************************************
VALUES
***********************************************

Syntax:

:samp:`VALUES (expression [, expression ...]) [, (expression [, expression ...])`

|br|

.. image:: values.svg
    :align: left

|br|

Select one or more rows.

VALUES has the same effect as :ref:`SELECT <sql_select>`, that is, it returns a result set,
but VALUES statements may not have FROM or GROUP or ORDER BY or LIMIT clauses.

VALUES may be used wherever SELECT may be used, for example in :ref:`subqueries <sql_subquery>`.

Examples:

.. code-block:: sql

   -- simple case:
   VALUES (1);
   -- equivalent to SELECT 1, 2, 3:
   VALUES (1, 2, 3);
   -- two rows:
   VALUES (1, 2, 3), (4, 5, 6);

.. _sql_subquery:

***********************************************
Subquery
***********************************************

Syntax:

* :ref:`SELECT-statement <sql_select>` syntax
* :ref:`VALUES-statement <sql_values>` syntax

A subquery has the same syntax as a :ref:`SELECT statement <sql_select>`
or :ref:`VALUES statement <sql_values>`
embedded inside a main statement.

.. NOTE::

   The SELECT and VALUES statements are called "queries" because they
   return answers, in the form of result sets.

Subqueries may be the second part of :ref:`INSERT statements <sql_insert>`. For example:

.. code-block:: sql

   INSERT INTO t2 SELECT a, b, c FROM t1;

Subqueries may be in the :ref:`FROM clause <sql_from>` of SELECT statements.

Subqueries may be expressions, or be inside expressions.
In this case they must be parenthesized, and usually the number of rows
must be 1. For example:

.. code-block:: sql

   SELECT 1, (SELECT 5), 3 FROM t WHERE c1 * (SELECT COUNT(*) FROM t2) > 5;

Subqueries may be expressions on the right side of certain comparison operators,
and in this unusual case the number of rows may be greater than 1.
The comparison operators are: [NOT] EXISTS and [NOT] IN. For example:

.. code-block:: sql

   DELETE FROM t WHERE s1 NOT IN (SELECT s2 FROM t);

Subqueries may refer to values in the outer query.
In this case, the subquery is called a "correlated subquery".

Subqueries may refer to rows which are being updated or deleted by the main query.
In that case, the subquery finds the matching rows first, before starting to
update or delete. For example, after:

.. code-block:: sql

   CREATE TABLE t (s1 INTEGER PRIMARY KEY, s2 INTEGER);
   INSERT INTO t VALUES (1, 3), (2, 1);
   DELETE FROM t WHERE s2 NOT IN (SELECT s1 FROM t);

only one of the rows is deleted, not both rows.

.. _sql_with:

***********************************************
WITH clause
***********************************************

**WITH clause (common table expression)**

Syntax:

:samp:`WITH {temporary-table-name} AS (subquery)` |br|
:samp:`[, {temporary-table-name} AS (subquery)]` |br|
:samp:`SELECT statement | INSERT statement | DELETE statement | UPDATE statement | REPLACE statement;`

|br|

.. image:: with.svg
    :align: left

|br|

.. code-block:: sql

   WITH v AS (SELECT * FROM t) SELECT * FROM v;

is equivalent to :ref:`creating a view <sql_create_view>` and selecting from it:

.. code-block:: sql

   CREATE VIEW v AS SELECT * FROM t;
   SELECT * FROM v;

The difference is that a WITH-clause "view" is temporary and only
useful within the same statement. No CREATE privilege is required.

The WITH-clause can also be thought of as a :ref:`subquery <sql_subquery>` that has a name.
This is useful when the same subquery is being repeated. For example:

.. code-block:: sql

   SELECT * FROM t WHERE a < (SELECT s1 FROM x) AND b < (SELECT s1 FROM x);

can be replaced with:

.. code-block:: sql

   WITH s AS (SELECT s1 FROM x) SELECT * FROM t,s WHERE a < s.s1 AND b < s.s1;

This "factoring out" of a repeated expression is regarded as good practice.

Examples:

.. code-block:: sql

   WITH cte AS (VALUES (7, '') INSERT INTO j SELECT * FROM cte;
   WITH cte AS (SELECT s1 AS x FROM k) SELECT * FROM cte;
   WITH cte AS (SELECT COUNT(*) FROM k WHERE s2 < 'x' GROUP BY s3)
     UPDATE j SET s2 = 5
     WHERE s1 = (SELECT s1 FROM cte) OR s3 = (SELECT s1 FROM cte);

WITH can only be used at the beginning of a statement, therefore it cannot
be used at the beginning of a subquery or after a :ref:`set operator <sql_union>` or inside
a CREATE statement.

A WITH-clause "view" is read-only because Tarantool does not support
updatable views.

.. _sql_with_recursive:

*********************************************************
WITH RECURSIVE
*********************************************************

**WITH RECURSIVE clause (iterative common table expression)**

The real power of WITH lies in the WITH RECURSIVE clause, which is useful when
it is combined with :ref:`UNION or UNION ALL <sql_union>`:

:samp:`WITH RECURSIVE recursive-table-name AS` |br|
:samp:`(SELECT ... FROM non-recursive-table-name ...` |br|
:samp:`UNION [ALL]` |br|
:samp:`SELECT ... FROM recursive-table-name ...)` |br|
:samp:`statement-that-uses-recursive-table-name;` |br|

|br|

.. image:: with_recursive.svg
    :align: left

|br|

In non-SQL this can be read as: starting with a seed value from
a non-recursive table, produce a recursive viewed table, UNION that with itself,
UNION that with itself, UNION that with itself ... forever, or until a condition
in the WHERE clause says "stop".

For example:

.. code-block:: sql

   CREATE TABLE ts (s1 INTEGER PRIMARY KEY);
   INSERT INTO ts VALUES (1);
   WITH RECURSIVE w AS (
     SELECT s1 FROM ts
     UNION ALL
     SELECT s1 + 1 FROM w WHERE s1 < 4)
   SELECT * FROM w;

First, table ``w`` is seeded from ``t1``, so it has one row: [1].

Then, ``UNION ALL (SELECT s1 + 1 FROM w)`` takes the row from ``w`` -- which
contains [1] -- adds 1 because the select list says "s1+1", and so it has
one row: [2].

Then, ``UNION ALL (SELECT s1 + 1 FROM w)`` takes the row from ``w`` -- which
contains [2] -- adds 1 because the select list says "s1+1", and so it has
one row: [3].

Then, ``UNION ALL (SELECT s1 + 1 FROM w)`` takes the row from ``w`` -- which
contains [3] -- adds 1 because the select list says "s1+1", and so it has
one row: [4].

Then, ``UNION ALL (SELECT s1 + 1 FROM w)`` takes the row from ``w`` -- which
contains [4] -- and now the importance of the WHERE clause becomes evident,
because "s1 < 4" is false for this row, and therefore we have reached the
"stop" condition.

So, before the "stop", table ``w`` got 4 rows -- [1], [2], [3], [4] -- and
the result of the statement looks like:

.. code-block:: tarantoolsession

   tarantool> WITH RECURSIVE w AS (
            >   SELECT s1 FROM ts
            >   UNION ALL
            >   SELECT s1 + 1 FROM w WHERE s1 < 4)
            > SELECT * FROM w;
   ---
   - - [1]
     - [2]
     - [3]
     - [4]
   ...

In other words, this ``WITH RECURSIVE ... SELECT`` produces a table of
auto-incrementing values.

.. _sql_union:

*********************************************************
UNION, EXCEPT, and INTERSECT clauses
*********************************************************

Syntax:

* :samp:`select-statement UNION [ALL] select-statement [ORDER BY clause] [LIMIT clause];`
* :samp:`select-statement EXCEPT select-statement [ORDER BY clause] [LIMIT clause];`
* :samp:`select-statement INTERSECT select-statement [ORDER BY clause] [LIMIT clause];`

|br|

.. image:: union.svg
    :align: left

|br|

.. image:: except.svg
    :align: left

|br|

.. image:: intersect.svg
    :align: left

|br|

UNION, EXCEPT, and INTERSECT are collectively called "set operators" or "table operators".
In particular:

* ``a UNION b`` means "take rows which occur in a OR b".
* ``a EXCEPT b`` means "take rows which occur in a AND NOT b".
* ``a INTERSECT b`` means "take rows which occur in a AND b".

Duplicate rows are eliminated unless ALL is specified.

The *select-statements* may be chained: ``SELECT ... SELECT ... SELECT ...;``

Each *select-statement* must result in the same number of columns.

The *select-statements* may be replaced with :ref:`VALUES statements <sql_values>`.

The maximum number of set operations is 50.

Example:

.. code-block:: sql

   CREATE TABLE t1 (s1 INTEGER PRIMARY KEY, s2 STRING);
   CREATE TABLE t2 (s1 INTEGER PRIMARY KEY, s2 STRING);
   INSERT INTO t1 VALUES (1, 'A'), (2, 'B'), (3, NULL);
   INSERT INTO t2 VALUES (1, 'A'), (2, 'C'), (3,NULL);
   SELECT s2 FROM t1 UNION SELECT s2 FROM t2;
   SELECT s2 FROM t1 UNION ALL SELECT s2 FROM t2 ORDER BY s2;
   SELECT s2 FROM t1 EXCEPT SELECT s2 FROM t2;
   SELECT s2 FROM t1 INTERSECT SELECT s2 FROM t2;

In this example:

* The UNION query returns 4 rows: NULL, 'A', 'B', 'C'.
* The UNION ALL query returns 6 rows: NULL, NULL, 'A', 'A', 'B', 'C'.
* The EXCEPT query returns 1 row: 'B'.
* The INTERSECT query returns 2 rows: NULL, 'A'.

Limitations:

* Parentheses are not allowed.
* Evaluation is left to right, INTERSECT does not have precedence.

Example:

.. code-block:: sql

   CREATE TABLE t01 (s1 INTEGER PRIMARY KEY, s2 STRING);
   CREATE TABLE t02 (s1 INTEGER PRIMARY KEY, s2 STRING);
   CREATE TABLE t03 (s1 INTEGER PRIMARY KEY, s2 STRING);
   INSERT INTO t01 VALUES (1, 'A');
   INSERT INTO t02 VALUES (1, 'B');
   INSERT INTO t03 VALUES (1, 'A');
   SELECT s2 FROM t01 INTERSECT SELECT s2 FROM t03 UNION SELECT s2 FROM t02;
   SELECT s2 FROM t03 UNION SELECT s2 FROM t02 INTERSECT SELECT s2 FROM t03;
   -- ... results are different.

.. _sql_indexed_by:

***********************************************
INDEXED BY clause
***********************************************

Syntax:

:samp:`INDEXED BY {index-name}`

|br|

.. image:: indexed_by.svg
    :align: left

|br|

The INDEXED BY clause may be used in a
:ref:`SELECT <sql_select>`, :ref:`DELETE <sql_delete>`, or :ref:`UPDATE <sql_update>` statement,
immediately after the *table-name*. For example:

.. code-block:: sql

   DELETE FROM table7 INDEXED BY index7 WHERE column1 = 'a';

In this case the search for 'a' will take place within ``index7``. For example:

.. code-block:: sql

   SELECT * FROM table7 NOT INDEXED WHERE column1 = 'a';

In this case the search for 'a' will be done via a search of the whole table,
what is sometimes called a "full table scan", even if there is an index for
``column1``.

Ordinarily Tarantool chooses the appropriate index or lookup method depending
on a complex set of "optimizer" rules; the INDEXED BY clause overrides the
optimizer choice.

Example:

Suppose a table has two columns:

* The first column is the primary key and
  therefore it has an automatic index named ``pk_unnamed_T_1``.
* The second column has an index created by the user.

The user selects with ``INDEXED BY the-index-on-column1``,
then selects with ``INDEXED BY the-index-on-column-2``.

.. code-block:: sql

   CREATE TABLE t (column1 INTEGER PRIMARY KEY, column2 INTEGER);
   CREATE INDEX idx_column2_t_1 ON t (column2);
   INSERT INTO t VALUES (1, 2), (2, 1);
   SELECT * FROM t INDEXED BY "pk_unnamed_T_1";
   SELECT * FROM t INDEXED BY idx_column2_t_1;
   -- Result for the first select: (1, 2), (2, 1)
   -- Result for the second select: (2, 1), (1, 2).

Limitations: |br|
Often INDEXED BY has no effect. |br|
Often INDEXED BY affects a choice of covering index, but not a WHERE clause.

.. _sql_transactions:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Transactions
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. _sql_start_transaction:

***********************************************
START TRANSACTION
***********************************************

Syntax:

:samp:`START TRANSACTION;`

|br|

.. image:: start.svg
    :align: left

|br|

Start a transaction. After ``START TRANSACTION;``, a transaction is "active".
If a transaction is already active, then ``START TRANSACTION;`` is illegal.

Transactions should be active for fairly short periods of time, to avoid
concurrency issues. To end a transaction, say :ref:`COMMIT; <sql_commit>` or :ref:`ROLLBACK; <sql_rollback>`.

Just as in NoSQL, transaction control statements are subject to limitations
set by the :ref:`storage engine <engines-chapter>` involved: |br|
* For the memtx storage engine, if a yield happens within an active transaction, the transaction is rolled back. |br|
* For the vinyl engine, yields are allowed. |br|
Also, although CREATE AND DROP and ALTER statements are legal in transactions,
there are a few exceptions. For example, :samp:`CREATE INDEX ON {table_name} ...` will fail within a
multi-statement transaction if the table is not empty.

However,transaction control statements still may not work as you expect when
run over a network connection:
a transaction is associated with a fiber, not a network connection, and
different transaction control statements sent via the same network connection
may be executed by different fibers from the fiber pool.

In order to ensure that all statements are part of the intended transaction,
put all of them between ``START TRANSACTION;`` and ``COMMIT;`` or ``ROLLBACK;``
then send as a single batch. For example:

* Enclose each separate SQL statement in a
  :ref:`box.execute() <box-sql_box_execute>` function.
* Pass all the ``box.execute()`` functions to the server in a single message.

  If you are using a console, you can do this by writing everything on a single
  line.

  If you are using :ref:`net.box <net_box-module>`, you can do this by putting
  all the function calls in a single string and calling
  :ref:`eval(string) <net_box-eval>`.

Example:

.. code-block:: sql

   START TRANSACTION;

Example of a whole transaction sent to a server on ``localhost:3301`` with
``eval(string)``:

.. code-block:: lua

   net_box = require('net.box')
   conn = net_box.new('localhost', 3301)
   s = 'box.execute([[START TRANSACTION;]]) '
   s = s .. 'box.execute([[INSERT INTO t VALUES (1);]]) '
   s = s .. 'box.execute([[ROLLBACK;]]) '
   conn:eval(s)

.. _sql_commit:

***********************************************
COMMIT
***********************************************

Syntax:

:samp:`COMMIT;`

|br|

.. image:: commit.svg
    :align: left

|br|

Commit an active transaction, so all changes are made permanent
and the transaction ends.

COMMIT is illegal unless a transaction is active.
If a transaction is not active then SQL statements are committed automatically.

Example:

.. code-block:: sql

   COMMIT;

.. _sql_savepoint:

***********************************************
SAVEPOINT
***********************************************

Syntax:

:samp:`SAVEPOINT {savepoint-name};`

|br|

.. image:: savepoint.svg
    :align: left

|br|

Set a savepoint, so that :ref:`ROLLBACK TO savepoint-name <sql_rollback>` is possible.

SAVEPOINT is illegal unless a transaction is active.

If a savepoint with the same name already exists, it is released
before the new savepoint is set.

Example:

.. code-block:: sql

   SAVEPOINT x;

.. _sql_release_savepoint:

***********************************************
RELEASE SAVEPOINT
***********************************************

Syntax:

:samp:`RELEASE SAVEPOINT {savepoint-name};`

|br|

.. image:: release.svg
    :align: left

|br|

Release (destroy) a savepoint created by a :ref:`SAVEPOINT statement <sql_savepoint>`.

RELEASE is illegal unless a transaction is active.

Savepoints are released automatically when a transaction ends.

Example:

.. code-block:: sql

   RELEASE SAVEPOINT x;

.. _sql_rollback:

***********************************************
ROLLBACK
***********************************************

Syntax:

:samp:`ROLLBACK [TO [SAVEPOINT] {savepoint-name}];`

|br|

.. image:: rollback.svg
    :align: left

|br|

If ROLLBACK does not specify a *savepoint-name*,
rollback an active transaction, so all changes
since :ref:`START TRANSACTION <sql_start_transaction>` are cancelled,
and the transaction ends.

If ROLLBACK does specify a *savepoint-name*,
rollback an active transaction, so all changes
since :ref:`SAVEPOINT savepoint-name <sql_savepoint>` are cancelled,
and the transaction does not end.

ROLLBACK is illegal unless a transaction is active.

Examples:

.. code-block:: sql

   -- the simple form:
   ROLLBACK;
   -- the form so changes before a savepoint are not cancelled:
   ROLLBACK TO SAVEPOINT x;

.. code-block:: lua

   -- An example of a Lua function that will do a transaction
   -- containing savepoint and rollback to savepoint.
   function f()
   box.execute([[DROP TABLE IF EXISTS t;]]) -- commits automatically
   box.execute([[CREATE TABLE t (s1 STRING PRIMARY KEY);]]) -- commits automatically
   box.execute([[START TRANSACTION;]]) -- after this succeeds, a transaction is active
   box.execute([[INSERT INTO t VALUES ('Data change #1');]])
   box.execute([[SAVEPOINT "1";]])
   box.execute([[INSERT INTO t VALUES ('Data change #2');]])
   box.execute([[ROLLBACK TO SAVEPOINT "1";]]) -- rollback Data change #2
   box.execute([[ROLLBACK TO SAVEPOINt "1";]]) -- this is legal but does nothing
   box.execute([[COMMIT;]]) -- make Data change #1 permanent, end the transaction
   end

.. _sql_pragma:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
PRAGMA
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Syntax:

* :samp:`PRAGMA {pragma-name} (pragma-value);`
* or :samp:`PRAGMA {pragma-name};`

.. image:: pragma.svg
    :align: left

PRAGMA statements will give rudimentary information about database 'metadata' or
server performance,
although it is better to get metadata via :ref:`system tables <sql_system_tables>`.

For PRAGMA statements that include (``pragma-value``),
pragma values are strings and can be specified inside ``""`` double quotes,
or without quotes.
When a string is used for searching, results must match according to a
binary collation. If the object being searched has a lower-case name,
use double quotes.

In an earlier version, there were some PRAGMA statements that determined behavior.
Now that does not happen. Behavior change is done by updating the
:ref:`box.space._session_settings <box_space-session_settings>` system table.

.. container:: table

    .. rst-class:: left-align-column-1
    .. rst-class:: left-align-column-2
    .. rst-class:: left-align-column-3

    +---------------------+-----------------+-------------------------------------------------+
    | Pragma              | Parameter       | Effect                                          |
    +=====================+=================+=================================================+
    | foreign_key_list    | string |br|     | Return a                                        |
    |                     | table-name      | :ref:`result set <box-sql_result_sets>`         |
    |                     |                 | with one row for each foreign key of            |
    |                     |                 | "table-name". Each row contains: |br|           |
    |                     |                 | (INTEGER) id -- identification number |br|      |
    |                     |                 | (INTEGER) seq -- sequential number |br|         |
    |                     |                 | (STRING) table -- name of table |br|            |
    |                     |                 | (STRING) from  -- referencing key |br|          |
    |                     |                 | (STRING) to -- referenced key |br|              |
    |                     |                 | (STRING) on_update -- ON UPDATE clause |br|     |
    |                     |                 | (STRING) on_delete -- ON DELETE clause |br|     |
    |                     |                 | (STRING) match -- MATCH clause |br|             |
    |                     |                 | The system table is ``"_fk_constraint"``.       |
    +---------------------+-----------------+-------------------------------------------------+
    | collation_list      |                 | Return a result set with one row for each       |
    |                     |                 | supported collation. The first four collations  |
    |                     |                 | are ``'none'`` and ``'unicode'`` and            |
    |                     |                 | ``'unicode_ci'`` and ``'binary'``, then come    |
    |                     |                 | about 270 predefined collations, the exact      |
    |                     |                 | count may vary because users can add their      |
    |                     |                 | own collations. |br|                            |
    |                     |                 | The system table is ``"_collation"``.           |
    +---------------------+-----------------+-------------------------------------------------+
    | index_info          | string |br|     | Return a result set with one row for each       |
    |                     | table-name .    | column in "table-name.index-name".              |
    |                     | index-name      | Each row contains: |br|                         |
    |                     |                 | (INTEGER) seqno -- the column's ordinal         |
    |                     |                 | position in the index (first column is 0) |br|  |
    |                     |                 | (INTEGER) cid -- the column's ordinal           |
    |                     |                 | position in the table (first column is 0) |br|  |
    |                     |                 | (STRING) name -- name of the column |br|        |
    |                     |                 | (INTEGER) desc -- 0 if ASC, 1 if DESC |br|      |
    |                     |                 | (STRING) collation name |br|                    |
    |                     |                 | (STRING) type -- data type |br|                 |
    +---------------------+-----------------+-------------------------------------------------+
    | index_list          | string |br|     | Return a result set                             |
    |                     | table-name      | with one row for each index of "table-name".    |
    |                     |                 | Each row contains: |br|                         |
    |                     |                 | (INTEGER) seq -- sequential number |br|         |
    |                     |                 | (STRING) name -- index name |br|                |
    |                     |                 | (INTEGER) unique -- whether the index is        |
    |                     |                 | unique, 0 = false, 1 = true |br|                |
    |                     |                 | The system table is ``"_index"``.               |
    +---------------------+-----------------+-------------------------------------------------+
    | stats               |                 | Return a result set with                        |
    |                     |                 | one row for each index of each table.           |
    |                     |                 | Each row contains: |br|                         |
    |                     |                 | (STRING) table -- name of the table |br|        |
    |                     |                 | (STRING) index -- name of the index |br|        |
    |                     |                 | (INTEGER) width -- arbitrary information |br|   |
    |                     |                 | (INTEGER) height -- arbitrary information       |
    +---------------------+-----------------+-------------------------------------------------+
    | table_info          | string |br|     | Return a result set                             |
    |                     | table-name      | with one row for each column                    |
    |                     |                 | in "table-name". Each row contains: |br|        |
    |                     |                 | (INTEGER) cid -- ordinal position in the table  |
    |                     |                 | |br|                                            |
    |                     |                 | (first column number is 0) |br|                 |
    |                     |                 | (STRING) name -- column name |br|               |
    |                     |                 | (INTEGER) notnull -- whether the column is      |
    |                     |                 | NOT NULL. 0 is                                  |
    |                     |                 | false, 1 is true. |br|                          |
    |                     |                 | (STRING) dflt_value -- default value |br|       |
    |                     |                 | (INTEGER) pk -- whether the column is           |
    |                     |                 | a PRIMARY KEY column. 0 is false, 1 is true.    |
    +---------------------+-----------------+-------------------------------------------------+

Example: (not showing result set metadata)

.. code-block:: none

   PRAGMA table_info('T');
   ---
   - - [0, 's1', 'integer', 1, null, 1]
     - [1, 's2', 'integer', 0, null, 0]
   ...


.. _sql_explain:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
EXPLAIN
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Syntax:

* :samp:`EXPLAIN explainable-statement;`

.. image:: explain.svg
    :align: left

EXPLAIN will show what steps Tarantool would take if it executed explainable-statement.
This is primarily a debugging and optimization aid for the Tarantool team.

Example: ``EXPLAIN DELETE FROM m;`` returns:

.. code-block:: none

    - - [0, 'Init', 0, 3, 0, '', '00', 'Start at 3']
      - [1, 'Clear', 16416, 0, 0, '', '00', '']
      - [2, 'Halt', 0, 0, 0, '', '00', '']
      - [3, 'Transaction', 0, 1, 1, '0', '01', 'usesStmtJournal=0']
      - [4, 'Goto', 0, 1, 0, '', '00', '']

Variation: ``EXPLAIN QUERY PLAN statement;`` shows the steps of a search.

.. COMMENT
   ANALYZE is currently disabled.

   ANALYZE [table_name]

   ANALYZE will collect statistics about a table and put the results in system tables named _sql_stat1 and _sql_stat4.

   Example:

   ANALYZE t;
   SELECT * FROM "_sql_stat1", "_sql_stat4";
   +-----+-----+------+-----+-----+-----+-----+------+
   | tbl | idx | stat | tbl | idx | neq | nlt | ndlt |
   +-----+-----+------+-----+-----+-----+-----+------+
   | T   | T   | 2 1  | T   | T   | 1   | 0   | 0    |
   | T   | T   | 2 1  | T   | T   | 1   | 1   | 1    |
   +-----+-----+------+-----+-----+-----+-----+------+

   Limitations:
   Issue#4069 ANALYZE is temporarily disabled in the current version

.. COMMENT
   This section should exist but changes have happened, it is probably obsolete.
   So it is all commented out.

   Order of Execution In Data-Change Statements

   This is the general order in which Tarantool performs checks and triggered actions for data-change (INSERT or UPDATE or DELETE) statements, Notice that one action can cause another action, as is the case for triggers (see "CREATE TRIGGER Statement"), or as is the case for REPLACE (which can cause either INSERT or DELETE plus INSERT).

   In this description, the words "constraint ... would be violated" mean "table would contain a value that would not be allowed (due to the constraint) if the operation was permitted to continue"..The word "behavior" refers to one of the possible behaviors described in section "Constraint Conflict Clauses".  If two or more constraints are relevant at the same time, for example UNIQUE (s2), CHECK (s2 <> 5), Tarantool may elect to check them in any order. If Tarantool determines that a step is not necessary, it does not perform it.

   Limitation(documentation only): The description here is not currently correct.

   For each row ...

   If statement is INSERT|UPDATE: If a value was not specified or is NULL for a column defined with AUTOINCREMENT,  set the value to the next available integer.
   If statement is INSERT|UPDATE: for each NOT NULL constraint that would be violated:... If behavior is "REPLACE  (for a NOT NULL constraint for a column that has a non-NULL default value)", then replace NULL with the default value.
   If statement is INSERT|UPDATE: for each  UNIQUE or PRIMARY KEY constraint that would be violated ...  If behavior is "REPLACE", then delete the old row and insert the new row.
   For each FOREIGN KEY constraint that would be violated ... do statement rollback and return an error.
   If statement is INSERT, then activate the table's BEFORE INSERT triggers.If statement is UPDATE, then activate the table's BEFORE UPDATE triggers. If statement is DELETE, then activate the table's BEFORE DELETE triggers.
   If statement is INSERT|UPDATE: for each NOT NULL constraint that would be violated ... If behavior is "ABORT" or "REPLACE (for a NOT NULL constraint that has a NULL default value)", do statement rollback and return an error.  If behavior is "IGNORE", then skip this and all following steps (i.e. skip this row). If behavior is "FAIL", then return an error. If behavior is "ROLLBACK", then do transaction rollback and return an error.
   If statement is INSERT|UPDATE: for each CHECK or UNIQUE or PRIMARY KEY constraint that would be violated ... If behavior is "IGNORE", then skip this row.  If behavior is "FAIL", return an error. If behavior is "ROLLBACK", then do transaction rollback and return an error. If behavior is "ABORT" or "REPLACE": do statement rollback and return an error. This means that UNIQUE or PRIMARY KEY constraints are checked twice, in step 2 and in this step. This is necessary because execution of an earlier step might cause a new conflict. 
   If statement is INSERT, then activate the table's AFTER INSERT triggers.If statement is UPDATE, then activate the table's AFTER UPDATE triggers. If statement is DELETE, then activate the table's AFTER DELETE triggers.

   If all rows were processed without an error that caused statement rollback or transaction rollback, the data-change can be committed. Ordinarily, unless processing is within a transaction that began with START TRANSACTION, there will be an automatic COMMIT.

   Finish the data-change by calling the low-level Tarantool routines. Thus new rows (new "tuples" in Tarantool's NoSQL terminology) are added to the table (the "space" in Tarantool's NoSQL terminology), or row sare removed from the table,  and indexes are updated.


.. _sql_functions:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Functions
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Syntax:

:samp:`function-name (one or more expressions)`

Apply a built-in function to one or more expressions and return a scalar value.

Tarantool supports 32 built-in functions.

The maximum number of operands for any function is 127.

The required privileges for built-in functions will likely change in a future version.

.. _sql_function_abs:

***********************************************
ABS
***********************************************

Syntax:

:samp:`ABS({numeric-expression})`

Return the absolute value of numeric-expression, which can be any numeric type.

Example: ``ABS(-1)`` is 1.

.. _sql_function_cast:

***********************************************
CAST
***********************************************

Syntax:

:samp:`CAST({expression} AS {data-type})`

Return the expression value after casting to the specified
:ref:`data type <sql_column_def_data_type>`.

Examples: ``CAST('AB' AS VARBINARY)``, ``CAST(X'4142' AS STRING)``

.. _sql_function_char:

***********************************************
CHAR
***********************************************

Syntax:

:samp:`CHAR([numeric-expression [,numeric-expression...])`

Return the characters whose Unicode code point values are equal
to the numeric expressions.

Short example:

The first 128 Unicode characters are the "ASCII" characters,
so CHAR(65, 66, 67) is 'ABC'.

Long example:

For the current list of Unicode characters,
in order by code point, see
`www.unicode.org/Public/UCD/latest/ucd/UnicodeData.txt
<http://www.unicode.org/Public/UCD/latest/ucd/UnicodeData.txt>`_.
In that list, there is a line for a Linear B ideogram

``100CC;LINEAR B IDEOGRAM B240 WHEELED CHARIOT ...``

Therefore, for a string with a chariot in the middle,
use the concatenation operator ``||`` and the CHAR function

``'start of string ' || CHAR(0X100CC) || ' end of string'``.

.. _sql_function_coalesce:

***********************************************
COALESCE
***********************************************

Syntax:

:samp:`COALESCE(expression, expression [, expression ...])`

Return the value of the first non-NULL expression, or, if all
expression values are NULL, return NULL.

Example:
  ``COALESCE(NULL, 17, 32)`` is 17.

.. _sql_function_greatest:

***********************************************
GREATEST
***********************************************

Syntax:

:samp:`GREATEST({expression-1}, {expression-2}, [{expression-3} ...])`

Return the greatest value of the supplied expressions, or, if any expression
is NULL, return NULL.
The reverse of ``GREATEST`` is :ref:`LEAST <sql_function_least>`.

Examples: ``GREATEST(7, 44, -1)`` is 44;
``GREATEST(1E308, 'a', 0, X'00')`` is '\0' = the nul character;
``GREATEST(3, NULL, 2)`` is NULL

.. _sql_function_hex:

***********************************************
HEX
***********************************************

Syntax:

:samp:`HEX(expression)`

Return the hexadecimal code for each byte in **expression**,
which may be either a string or a byte sequence.
For ASCII characters, this
is straightforward because the encoding is
the same as the code point value. For
non-ASCII characters, since character strings
are usually encoded in UTF-8, each character
will require two or more bytes.

Examples:

  * ``HEX('A')`` will return ``41``.
  * ``HEX('Д')`` will return ``D094``.

.. _sql_function_ifnull:

***********************************************
IFNULL
***********************************************

Syntax:

:samp:`IFNULL(expression, expression)`

Return the value of the first non-NULL expression, or, if both
expression values are NULL, return NULL. Thus
``IFNULL(expression, expression)`` is the same as
:ref:`COALESCE(expression, expression) <sql_function_coalesce>`.

Example:
  ``IFNULL(NULL, 17)`` is 17

.. _sql_function_least:

***********************************************
LEAST
***********************************************

Syntax:

:samp:`LEAST({expression-1}, {expression-2}, [{expression-3} ...])`

Return the least value of the supplied expressions, or, if any expression
is NULL, return NULL.
The reverse of ``LEAST`` is :ref:`GREATEST <sql_function_greatest>`.

Examples: ``LEAST(7, 44, -1)`` is -1;
``LEAST(1E308, 'a', 0, X'00')`` is 0;
``LEAST(3, NULL, 2)`` is NULL.

.. _sql_function_length:

***********************************************
LENGTH
***********************************************

Syntax:

:samp:`LENGTH(expression)`

Return the number of characters in the **expression**,
or the number of bytes in the **expression**.
It depends on the data type:
strings with data type STRING are counted in characters,
byte sequences with data type VARBINARY
are counted in bytes and are not ended by the nul character.
There are two aliases for ``LENGTH(expression)`` -- ``CHAR_LENGTH(expression)``
and ``CHARACTER_LENGTH(expression)`` do the same thing.

Examples:

  * ``LENGTH('ДД')`` is 2, the string has 2 characters.
  * ``LENGTH(CAST('ДД' AS VARBINARY))`` is 4, the string has 4 bytes.
  * ``LENGTH(CHAR(0, 65))`` is 2, '\0' does not mean 'end of string'.
  * ``LENGTH(X'410041')`` is 3, X'...' byte sequences have type VARBINARY.

.. _sql_function_likelihood:

***********************************************
LIKELIHOOD
***********************************************

Syntax:

:samp:`LIKELIHOOD({expression}, {number literal})`

Return the result of the expression, provided that the number literal is between 0.0 and 1.0.

Example: ``LIKELIHOOD('a' = 'b', .0)`` is FALSE

.. _sql_function_likely:

***********************************************
LIKELY
***********************************************

Syntax:

:samp:`LIKELY({expression})`

Return TRUE if the expression is probably true.

Example: ``LIKELY('a' <= 'b')`` is TRUE

.. _sql_function_lower:

***********************************************
LOWER
***********************************************

Syntax:

:samp:`LOWER({string-expression})`

Return the expression, with upper-case characters converted to lower case.
The reverse of ``LOWER`` is :ref:`UPPER <sql_function_upper>`.

Example: ``LOWER('ДA')`` is 'дa'

.. _sql_function_nullif:

***********************************************
NULLIF
***********************************************

Syntax:

:samp:`NULLIF(expression-1, expression-2)`

Return *expression-1* if *expression-1* <> *expression-2*,
otherwise return NULL.

Examples:

  * ``NULLIF('a', 'A')`` is 'a'.
  * ``NULLIF(1.00, 1)`` is NULL.

.. _sql_function_position:

***********************************************
POSITION
***********************************************

Syntax:

:samp:`POSITION({expression-1}, {expression-2})`

Return the position of expression-1 within expression-2,
or return 0 if expression-1 does not appear
within expression-2. 
The data types of the expressions must be either STRING or VARBINARY.
If the expressions have data type STRING, then the result is the character position.
If the expressions have data type VARBINARY, then the result is the
byte position.

Short example:
``POSITION('C', 'ABC')`` is 3

Long example: The UTF-8 encoding for the Latin letter A
is hexadecimal 41; the UTF-8 encoding for the
Cyrillic letter Д is hexadecimal D094 -- you can confirm this
by saying SELECT HEX('ДA'); and seeing that the
result is 'D09441'. If you now execute
``SELECT POSITION('A', 'ДA');``
the result will be 2,
because 'A' is the second character in the string.
However, if you now execute
``SELECT POSITION(X'41', X'D09441');``
the result will be 3,
because X'41' is the third byte in the byte sequence.

.. _sql_function_printf:

***********************************************
PRINTF
***********************************************

Syntax:

:samp:`PRINTF(string-expression [, expression ...])`

Return a string formatted according to the rules of the C
``sprintf()`` function, where ``%d%s`` means the next two arguments
are a number and a string, and so on.

If an argument is missing or is NULL, it becomes:

  * '0' if the format requires an integer,
  * '0.0' if the format requires a number with a decimal point,
  * '' if the format requires a string.

Example: ``PRINTF('%da', 5)`` is '5a'.

.. _sql_function_quote:

***********************************************
QUOTE
***********************************************

Syntax:

:samp:`QUOTE(string-literal)`

Return a string with enclosing quotes if necessary,
and with quotes inside the enclosing quotes if necessary.
This function is useful for creating strings
which are part of SQL statements, because of SQL's rules that
string literals are enclosed by single quotes, and single quotes
inside such strings are shown as two single quotes in a row.

Example: ``QUOTE('a')`` is ``'a'``.

.. _sql_function_raise:

***********************************************
RAISE
***********************************************

Syntax:

:samp:`RAISE(FAIL, {error-message})`

This may only be used within a triggered statement. See also :ref:`Trigger Activation <sql_trigger_activation>`.

.. _sql_function_random:

***********************************************
RANDOM
***********************************************

Syntax: :samp:`RANDOM()`

Return a 19-digit integer which is generated by a pseudo-random number generator,

Example: ``RANDOM()`` is 6832175749978026034, or it is any other integer

.. _sql_function_randomblob:

***********************************************
RANDOMBLOB
***********************************************

Syntax:

:samp:`RANDOMBLOB({n})`

Return a byte sequence, n bytes long, data type = VARBINARY, containing bytes generated by a
pseudo-random byte generator. The result can be translated to hexadecimal.
If n is less than 1 or is NULL or is infinity, then NULL is returned.

Example: ``HEX(RANDOMBLOB(3))`` is '9EAAA8', or it is the hex value for any other
three-byte string

.. _sql_function_replace:

***********************************************
REPLACE
***********************************************

Syntax:

:samp:`REPLACE({expression-1}, {expression-2}, {expression-3})`

Return expression-1, except that wherever expression-1
contains expression-2, replace expression-2 with
expression-3.
The expressions should all have data type STRING or VARBINARY.

Example: ``REPLACE('AAABCCCBD', 'B', '!')`` is 'AAA!CCC!D'

.. _sql_function_round:

***********************************************
ROUND
***********************************************

Syntax:

:samp:`ROUND({numeric-expression-1} [, {numeric-expression-2}])`

Return the rounded value of numeric-expression-1, always rounding
.5 upward for floating-point positive numbers or downward for negative numbers.
If numeric-expression-2 is supplied then rounding is to the nearest
numeric-expression-2 digits after the decimal point;
if numeric-expression-2 is not supplied then rounding is to the nearest integer.

Example: ``ROUND(-1.5)`` is -2, ``ROUND(1.7766E1,2)`` is 17.77.

.. _sql_function_row_count:

***********************************************
ROW_COUNT
***********************************************

:samp:`ROW_COUNT()`

Return the number of rows that were inserted / updated / deleted
by the last :ref:`INSERT <sql_insert>` or
:ref:`UPDATE <sql_update>` or
:ref:`DELETE <sql_delete>` or
:ref:`REPLACE <sql_replace>` statement.
Rows which were updated by an UPDATE statement are counted even if there was no change.
Rows which were inserted / updated / deleted due to foreign-key action are not counted.
Rows which were inserted / updated / deleted due to a view's
:ref:`INSTEAD OF triggers <sql_instead_of_triggers>` are  not counted. 
After a CREATE or DROP statement, ROW_COUNT() is 1.
After other statements,  ROW_COUNT() is 0.

Example: ``ROW_COUNT()`` is 1 after a successful INSERT of a single row.

Special rule if there are BEFORE or AFTER triggers: In effect the ROW_COUNT() 
counter is pushed at the beginning of a series of triggered statements,
and popped at the end. Therefore, after the following statements:

.. code-block:: sql

             CREATE TABLE t1 (s1 INTEGER PRIMARY KEY);
             CREATE TABLE t2 (s1 INTEGER, s2 STRING, s3 INTEGER, PRIMARY KEY (s1, s2, s3)); 
             CREATE TRIGGER tt1 BEFORE DELETE ON t1 FOR EACH ROW BEGIN
               INSERT INTO t2 VALUES (old.s1, '#2 Triggered', ROW_COUNT());
               INSERT INTO t2 VALUES (old.s1, '#3 Triggered', ROW_COUNT());
               END;
             INSERT INTO t1 VALUES (1),(2),(3);
             DELETE FROM t1;
             INSERT INTO t2 VALUES (4, '#4 Untriggered', ROW_COUNT());
             SELECT * FROM t2;

The result is:

.. code-block:: none

             ---
             - - [1, '#2 Triggered', 3]
               - [1, '#3 Triggered', 1]
               - [2, '#2 Triggered', 3]
               - [2, '#3 Triggered', 1]
               - [3, '#2 Triggered', 3]
               - [3, '#3 Triggered', 1]
               - [4, '#4 Untriggered', 3]
             ...

.. _sql_function_soundex:

***********************************************
SOUNDEX
***********************************************

Syntax:

:samp:`SOUNDEX(string-expression)`

Return a four-character string which represents the sound
of ``string-expression``. Often words and names which have
different spellings will have the same Soundex representation
if they are pronounced similarly,
so it is possible to search by what they sound like.
The algorithm works with characters in the Latin alphabet
and works best with English words.

Example: ``SOUNDEX('Crater')`` and ``SOUNDEX('Creature')`` both return ``C636``.

.. _sql_function_substr:

***********************************************
SUBSTR
***********************************************

Syntax:

:samp:`SUBSTR({expression-1}, {numeric-expression-1} [, {numeric-expression-2}])`

If expression-1 has data type STRING, then return the substring
which begins
at character position numeric-expression-1 and continues for
numeric-expression-2 characters (if numeric-expression-2 is
supplied), or continues till the end of string-expression-1
(if numeric-expression-2 is not supplied).

If expression-1 has data type VARBINARY rather than data
type STRING, then positioning and counting is by bytes
rather than by characters.

Example: ``SUBSTR('ABCDEFG', 3, 2)`` is 'CD'

.. _sql_function_trim:

***********************************************
TRIM
***********************************************

Syntax:

:samp:`TRIM([[LEADING|TRAILING|BOTH] [{expression-1}] FROM] {expression-2})`

Return expression-2 after removing all leading and/or trailing characters or bytes.
The expressions should have data type STRING or VARBINARY.
If LEADING|TRAILING|BOTH is omitted, the default is BOTH.
If expression-1 is omitted, the default is ' ' (space) for data type STRING
or X'00' (nul) for data type VARBINARY.

Examples:
``TRIM('a' FROM 'abaaaaa')`` is 'b' -- all repetitions of 'a' are removed on both sides;
``TRIM(TRAILING 'ב' FROM 'אב')`` is 'א' -- if all characters are Hebrew, TRAILING means "left";
``TRIM(X'004400')`` is X'44' -- the default byte sequence to trim is X'00' when data type is VARBINARY;
``TRIM(LEADING 'abc' FROM 'abcd')`` is 'd' -- expression-1 can have more than 1 character.

.. _sql_function_typeof:

***********************************************
TYPEOF
***********************************************

Syntax:

:samp:`TYPEOF({expression})`

Return the :ref:`data type <sql_column_def_data_type>` of the expression.

Examples:
``TYPEOF('A')`` returns 'string';
``TYPEOF(RANDOMBLOB(1))`` returns 'varbinary';
``TYPEOF(1e44)`` returns 'double' or 'number';
``TYPEOF(-44)`` returns 'integer';
``TYPEOF(NULL)`` returns 'boolean'

.. _sql_function_unicode:

***********************************************
UNICODE
***********************************************

Syntax:

:samp:`UNICODE(string-expression)`

Return the Unicode code point value of the first character of **string-expression**.
If *string-expression* is empty, the return is NULL.
This is the reverse of :ref:`CHAR(integer) <sql_function_char>`.

Example: ``UNICODE('Щ')`` is 1065 (hexadecimal 0429).

.. _sql_function_unlikely:

***********************************************
UNLIKELY
***********************************************

Syntax:

:samp:`UNLIKELY({expression})`

Return TRUE if the expression is probably false.
Limitation: in fact ``UNLIKELY`` may return the same thing as :ref:`LIKELY <sql_function_likely>`.

Example: ``UNLIKELY('a' <= 'b')`` is TRUE.

.. _sql_function_upper:

***********************************************
UPPER
***********************************************

Syntax:

:samp:`UPPER(string-expression)`

Return the expression, with lower-case characters converted to upper case.
The reverse of ``UPPER`` is :ref:`LOWER <sql_function_lower>`.

Example: ``UPPER('-4щl')`` is '-4ЩL'.

.. _sql_function_version:

***********************************************
VERSION
***********************************************

Syntax:

:samp:`VERSION()`

Return the Tarantool version.

Example: for a February 2020 build VERSION() is ``'2.4.0-35-g57f6fc932'``.

.. _sql_function_zeroblob:

***********************************************
ZEROBLOB
***********************************************

Syntax:

:samp:`ZEROBLOB({n})`

Return a byte sequence, data type = VARBINARY, n bytes long.

.. _sql_collate_clause:

***************
COLLATE clause
***************

:samp:`COLLATE collation-name`

The collation-name must identify an existing collation.

The COLLATE clause is allowed for STRING or SCALAR items: |br|
() in :ref:`CREATE INDEX <sql_create_index>` |br|
() in :ref:`CREATE TABLE <sql_create_table>` as part of :ref:`column definition <sql_column_def>` |br|
() in CREATE TABLE as part of :ref:`UNIQUE definition <sql_table_constraint_def>` |br|
() in string expressions |br|

Examples:

.. code-block:: none

    -- In CREATE INDEX
    CREATE INDEX idx_unicode_mb_1 ON mb (s1 COLLATE "unicode");
    -- In CREATE TABLE
    CREATE TABLE t1 (s1 INTEGER PRIMARY KEY, s2 STRING COLLATE "unicode_ci");
    -- In CREATE TABLE ... UNIQUE
    CREATE TABLE mb (a STRING, b STRING, PRIMARY KEY(a), UNIQUE(b COLLATE "unicode_ci" DESC));
    -- In string expressions
    SELECT 'a' = 'b' COLLATE "unicode"
        FROM t
        WHERE s1 = 'b' COLLATE "unicode"
        ORDER BY s1 COLLATE "unicode";

The list of collations can be seen with: :ref:`PRAGMA collation_list; <sql_pragma>`

The collation rules comply completely with the Unicode Technical Standard #10
(`"Unicode Collation Algorithm" <http://unicode.org/reports/tr10/>`_)
and the default character order is as in the
`Default Unicode Collation Element Table (DUCET) <https://www.unicode.org/Public/UCA/8.0.0/allkeys.txt>`_.
There are many permanent collations; the commonly used ones include: |br|
|nbsp| |nbsp| ``"none"`` (not applicable) |br|
|nbsp| |nbsp| ``"unicode"`` (characters are in DUCET order with strength = 'tertiary') |br|
|nbsp| |nbsp| ``"unicode_ci"`` (characters are in DUCET order with strength = 'primary') |br|
|nbsp| |nbsp| ``"binary"`` (characters are in code point order) |br|
These identifiers must be quoted and in lower case because they are in lower case in
:ref:`Tarantool/NoSQL collations <index-collation>`.

If one says ``COLLATE "binary"``, this is equivalent to asking for what is sometimes called
"code point order" because, if the contents are in the UTF-8 character set,
characters with larger code points will appear after characters with lower code points.

In an expression, ``COLLATE`` is an operator with higher precedence than anything except
``~``. This is fine because there are no other useful operators except ``||`` and comparison.
After ``||``, collation is preserved.

In an expression with more than one ``COLLATE`` clause, if the collation names differ,
there is an error: "Illegal mix of collations".
In an expression with no ``COLLATE`` clauses, literals have collation ``"binary"``,
columns have the collation specified by ``CREATE TABLE``.

In other words, to pick a collation, we use: |br|
the first ``COLLATE`` clause in an expression if it was specified, |br|
else the the column's ``COLLATE`` clause if it was specified, |br|
else ``"binary"``.

However, for searches and sometimes for sorting, the collation may be an index's collation,
so all non-index ``COLLATE`` clauses are ignored.

:ref:`EXPLAIN <sql_explain>` will not show the name of what collation was used, but will show the collation's characteristics. 

Example with Swedish collation: |br|
Knowing that "sv" is the two-letter code for Swedish, |br|
and knowing that "s1" means strength = 1, |br|
and seeing with ``PRAGMA collation_list;`` that there is a collation named unicode_sv_s1, |br|
check whether two strings are equal according to Swedish rules (yes they are): |br|
``SELECT 'ÄÄ' = 'ĘĘ' COLLATE "unicode_sv_s1";``

Example with Russian and Ukrainian and Kyrgyz collations: |br|
Knowing that Russian collation is practically the same as Unicode default, |br|
and knowing that the two-letter codes for Ukrainian and Kyrgyz are 'uk' and 'ky', |br|
and knowing that in Russian (but not Ukrainian) 'Г' = 'Ґ' with strength=primary, |br|
and knowing that in Russian (but not Kyrgyz) 'Е' = 'Ё' with strength=primary, |br|
the three SELECT statements here will return results in three different orders: |br|
``CREATE TABLE things (remark STRING PRIMARY KEY);`` |br|
``INSERT INTO things VALUES ('Е2'), ('Ё1');`` |br|
``INSERT INTO things VALUES ('Г2'), ('Ґ1');`` |br|
``SELECT remark FROM things ORDER BY remark COLLATE "unicode";`` |br|
``SELECT remark FROM things ORDER BY remark COLLATE "unicode_uk_s1";`` |br|
``SELECT remark FROM things ORDER BY remark COLLATE "unicode_ky_s1";``


.. COMMENT
   The next section is adapted from
   https://docs.google.com/document/d/1rzJFUePFIVqgCxLax8naYj4qDN2Vp56c6ctj2ae288I/edit#

.. _sql_sql_plus_lua:

--------------------------------------------------------
SQL PLUS LUA -- Adding Tarantool/NoSQL to Tarantool/SQL
--------------------------------------------------------

The Adding Tarantool/NoSQL To Tarantool/SQL Guide contains descriptions of NoSQL database objects that can be accessed from SQL,
of SQL database objects that can be accessed from NoSQL, of the way to call SQL from Lua, and of the way to call Lua from SQL.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Lua Requests
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

A great deal of functionality is not specifically part of Tarantool's SQL feature,
but is part of the Tarantool Lua application server and DBMS.
Here we will give examples so it is clear where to look in other sections of the Tarantool manual.

NoSQL :ref:`"spaces" <index-box_space>` can be accessed as SQL ``"tables"``, and vice versa.
For example, suppose a table has been created with |br|
``CREATE TABLE things (id INTEGER PRIMARY KEY, remark SCALAR);``

This is viewable from Tarantool's NoSQL feature as a memtx space named THINGS with a primary-key
:ref:`TREE index <index-box_index>` ...

.. code-block:: none

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

To :ref:`grant <box_schema-user_grant>`
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
:ref:`Sharding <shard-module>`.

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
indexes may cause severe errors.

.. _sql_system_tables:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
System Tables
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

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
   Suppose we want to use a non-default collation which has Ukrainian rules.
   There are many deviations from DUCET, all formally described by the Common Language Data Repository,
   in this case https://unicode.org/cldr/charts/32/collation/uk.html.
   Two notable deviations are: Ґ is a separate letter after Г and Ь is before Ю.
   In addition we want upper case letters to come before lower case letters.
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
   re the standard CLDR variants for Ukrainian, so the above example was
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

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Calling Lua routines from SQL
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

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

.. code-block:: none

    box.schema.func.create('_DECODE',
       {language = 'LUA',
        returns = 'string',
        body = [[function (field, part)
                 __GLOBAL= field
                 return dostring("return require('msgpack').decode(__GLOBAL,1)." .. part)
                 end]],
        is_sandboxed = false,
        param_list = {'string', "string"},
        exports = {'LUA', 'SQL'},
        is_deterministic = true})

See it work with, say, the _trigger space.
That space has a ``'map'`` field named opts which has a part named sql.
By selecting from the space and passing the field and the part name to _DECODE,
you can get a list of all the trigger bodies.

.. code-block:: none

    __GLOBAL = ""
    box.execute([[SELECT _decode("opts", 'sql') FROM "_trigger";]])

Remember that SQL converts :ref:`regular identifiers <sql_identifiers>` to upper case,
so this example works with a function named _DECODE.
If the function had been named _decode, then the SELECT statement would have to be: |br|
``box.execute([[SELECT "_decode"("opts", 'sql') FROM "_trigger";]])``

Here is another example, which illustrates the way that Tarantool creates
a view which includes the table_name and table_type columns in the same
way that the standard-SQL information_schema.tables view contains them.
The difficulty is that, in order to discover whether table_type should
be ``'BASE TABLE'`` or should be ``'VIEW'``, we need to know the value of the
``"flags"`` field in the Tarantool/NoSQL :ref:`"_space" <box_space-space>` or ``"_vspace"`` space.
The ``"flags"`` field type is ``"map"``, which SQL does not understand well.
If there were no Lua functions, we would have to treat it as a VARBINARY
and look for ``POSITION(X'A476696577C3',"flags")  > 0`` (A4 is a MsgPack signal
that a 4-byte string follows, 76696577 is UTF8 encoding for 'view',
C3 is a MsgPack code meaning true).
But we have a more sophisticated way, we can create a function that
returns true if ``"flags".view`` is true.
So our way of making the function looks like this:

.. code-block:: none

    box.schema.func.create('TABLES_IS_VIEW',
         {language = 'LUA',
          returns = 'boolean',
          body = [[function (flags)
              local view
              view = require('msgpack').decode(flags).view
              if view == nil then return false end
              return view
              end]],
         is_sandboxed = false,
         param_list = {'string'},
         exports = {'LUA', 'SQL'},
         is_deterministic = true})

And this creates the view:

.. code-block:: none

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

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Executing Lua chunks
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

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

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Example Session -- Create, Insert, Select
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Assume that the task is to create two tables, put some rows in each table,
create a :ref:`view <sql_create_view>` that is based on a join of the tables,
then select from the view all rows where the second column values
are not null, ordered by the first column.

That is, what we want is |br|
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
objects do not already exist, the execution will be successful and the final display will be |br|
tarantool> box.execute([[SELECT * FROM v WHERE c2 IS NOT NULL ORDER BY c1;]])
``---`` |br|
``- - [1, 'A', 'C']`` |br|
``  - [4, 'D', 'A']`` |br|
``  - [6, 'F', null]`` |br|

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Example Session -- Get a List of Columns
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Here  is a function which will create a table that contains
a list of all the columns and their Lua types, for all tables.
It is not a necessary function because one can create a
:ref:`_COLUMNS view <sql__columns_view>` instead.
It merely shows, with simpler Lua code, how to make a base table instead of a view.

.. code-block:: none

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

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Example Session -- Million-Row Insert
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Here is a variation of the Lua tutorial
:ref:`"Insert one million tuples with a Lua stored procedure" <c_lua_tutorial-insert_one_million_tuples>`.
The differences are: the creation is done with an SQL
:ref:`CREATE TABLE statement <sql_create_table>`,
and the inserting is done with an SQL :ref:`INSERT statement <sql_insert>`. 
Otherwise, it is the same. It is the same because Lua and SQL are compatible,
just as Lua and NoSQL are compatible.

.. code-block:: none

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
        sql_statement = "INSERT INTO tester VALUES (" .. i .. ",'" .. string_value .. "')"
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

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Lua functions to make views of metadata
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

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
For each view we show an example of a SELECT from the view, and the code.
Users who want metadata can simply copy the code.
Use this code only with Tarantool version 2.3.0 or later.
With an earlier Tarantool version, a :ref:`PRAGMA statement <sql_pragma>` may be useful.

.. _sql__tables_view:

***********************************************************************************
_TABLES view
***********************************************************************************

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

.. code-block:: none

    box.schema.func.drop('_TABLES_IS_VIEW',{if_exists = true})
    box.schema.func.create('_TABLES_IS_VIEW',
         {language = 'LUA',
          returns = 'boolean',
          body = [[function (flags)
              local view
              view = require('msgpack').decode(flags).view
              if view == nil then return false end
              return view
              end]],
         is_sandboxed = false,
         param_list = {'string'},
         exports = {'LUA', 'SQL'},
         setuid = false,
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

***********************************************************************************
_COLUMNS view
***********************************************************************************

This is also an example of how one can use :ref:`recursive views <sql_with>` to make temporary tables
with multiple rows for each tuple in the original ``"_vtable"`` space.
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

.. code-block:: none

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

***********************************************************************************
_VIEWS view
***********************************************************************************

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

.. code-block:: none

    box.schema.func.drop('_VIEWS_DEFINITION',{if_exists = true})
    box.schema.func.create('_VIEWS_DEFINITION',
        {language = 'LUA',
         returns = 'string',
         body = [[function (flags)
                      return require('msgpack').decode(flags).sql end]],
         param_list = {'string'},
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

***********************************************************************************
_TRIGGERS view
***********************************************************************************

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

.. code-block:: none

    box.schema.func.drop('_TRIGGERS_OPTS_SQL',{if_exists = true})
    box.schema.func.create('_TRIGGERS_OPTS_SQL',
        {language = 'LUA',
         returns = 'string',
         body = [[function (opts)
                      return require('msgpack').decode(opts).sql end]],
         param_list = {'string'},
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

***********************************************************************************
_REFERENTIAL_CONSTRAINTS view
***********************************************************************************

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

.. code-block:: none

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

We are not taking child_cols or parent_cols
from the _fk_constraint space because in standard SQL those
are in a separate table.

Users who select from this view will need 'read' privilege on the _fk_constraint space.

.. _sql__check_constraints_view:

***********************************************************************************
_CHECK_CONSTRAINTS view
***********************************************************************************

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

.. code-block:: none

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

***********************************************************************************
_TABLE_CONSTRAINTS view
***********************************************************************************

This has only the constraints (primary-key and unique-key) that can be found by looking at the
:ref:`_index <box_space-index>` space.
It is not a list of indexes, that is, it is not equivalent to INFORMATION_SCHEMA.STATISTICS.
We do not take the columns of the index because in standard SQL they would be in a different table.

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

.. code-block:: none

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
