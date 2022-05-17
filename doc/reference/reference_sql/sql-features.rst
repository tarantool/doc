.. _sql:

SQL features
============

This section compares Tarantool's features with SQL:2016's "Feature taxonomy and definition
for mandatory features".

For each feature in that list, there will be a simple example SQL
statement.
If Tarantool appears to handle the example, it will be marked "Okay",
else it will be marked "Fail".
Since this is rough and arbitrary, the hope is that tests which are unfairly
marked "Okay" will probably be balanced by tests which are unfairly marked "Fail".


E011, Numeric data types
------------------------

..  container:: table

    ..  list-table::
        :widths: 15 30 30 25
        :header-rows: 1

        *   -   Feature ID
            -   Feature
            -   Example
            -   Tests
        *   -   E011-01
            -   INTEGER and SMALLINT
            -   ``CREATE TABLE t (s1 INT PRIMARY KEY);``
            -   :ref:`Okay <sql_create_table>`.
        *   -   E011-02
            -   REAL, DOUBLE PRECISION, and FLOAT data types
            -   ``CREATE TABLE tr (s1 FLOAT PRIMARY KEY);``
            -   Fail. Tarantool's floating point data type is
                :ref:`DOUBLE <sql_data_type_double>`.
                **Note:** Floating point SQL types are not planned to
                be compatible between 2.1 and 2.2 releases. The reason
                is that in 2.1 we set 'number' format for columns of
                these types, but will restrict it to 'float32' and
                'float64' in 2.2. The format change requires data
                migration and cannot be done automatically, because in
                2.1 we have no information to distinguish 'number'
                columns (created from Lua) from FLOAT/DOUBLE/REAL ones
                (created from SQL).
        *   -   E011-03
            -   DECIMAL and NUMERIC data types
            -   ``CREATE TABLE td (s1 NUMERIC PRIMARY KEY);``
            -   Fail, NUMERIC data types are not supported,
                and a number containing post-decimal digits will be
                treated as approximate numeric.
        *   -   E011-04
            -   Arithmetic operators
            -   ``SELECT 10+1, 9-2, 8*3, 7/2 FROM t;``
            -   :ref:`Okay <sql_operator_arithmetic>`.                  
        *   -   E011-05
            -   Numeric comparisons
            -   ``SELECT * FROM t WHERE 1 < 2;``
            -   :ref:`Okay <sql_operator_comparison>`.
        *   -   E011-06
            -   Implicit casting among the numeric data types
            -   ``SELECT * FROM t WHERE s1 = 1.00;``
            -   Okay, because Tarantool allows comparison of 1.00 with an INTEGER column.


E021, Character string types
----------------------------

..  container:: table

    ..  list-table::
        :widths: 15 30 30 25
        :header-rows: 1

        *   -   Feature ID
            -   Feature
            -   Example
            -   Tests 
        *   -   E021-01
            -   Character data type (including all its spellings)
            -   ``CREATE TABLE t44 (s1 CHAR PRIMARY KEY);``
            -   Fail, CHAR is not supported. This type of Fail will only be counted once.
        *   -   E021-02
            -   CHARACTER VARYING data type (including all its spellings)
            -   ``CREATE TABLE t45 (s1 VARCHAR PRIMARY KEY);``
            -   Fail, Tarantool only allows VARCHAR(n), which is a
                synonym for :ref:`STRING <sql_data_type_string>`.     
        *   -   E021-03
            -   Character literals
            -   ``INSERT INTO t45 VALUES ('');``
            -   Okay, and the bad practice of accepting ``""`` for
                character literals is avoided.                        
        *   -   E021-04
            -   CHARACTER_LENGTH function
            -   ``SELECT character_length(s1) FROM t;``
            -   Okay. Tarantool treats this as a synonym of
                :ref:`LENGTH() <sql_function_length>`.                
        *   -   E021-05
            -   OCTET_LENGTH
            -   ``SELECT octet_length(s1) FROM t;``
            -   Fail. There is no such function.
        *   -   E021-06
            -   SUBSTRING function
            -   ``SELECT substring(s1 FROM 1 FOR 1) FROM t;``
            -   Fail. There is no such function. There is a function
                :ref:`SUBSTR(x,n,n) <sql_function_substr>`, which is okay.
        *   -   E021-07
            -   Character concatenation
            -   ``SELECT 'a' || 'b' FROM t;``
            -   :ref:`Okay <sql_operator_concatenate>`.               
        *   -   E021-08
            -   UPPER and LOWER functions
            -   ``SELECT upper('a'),lower('B') FROM t;``
            -   Okay. Tarantool supports both
                :ref:`UPPER() <sql_function_upper>` and
                :ref:`LOWER() <sql_function_lower>`.
        *   -   E021-09
            -   TRIM function
            -   ``SELECT trim('a ') FROM t;``
            -   :ref:`Okay <sql_function_trim>`.
        *   -   E021-10
            -   Implicit casting among the fixed-length and
                variable-length character string types
            -   ``SELECT * FROM tm WHERE char_column > varchar_column;``
            -   Fail, there is no fixed-length character string type.
        *   -   E021-11
            -   POSITION function
            -   ``SELECT position(x IN y) FROM z;``
            -   Fail. Tarantool's :ref:`POSITION <sql_function_position>` function
                requires '``,``' rather than '``IN``'.
        *   -   E021-12
            -   Character comparison
            -   ``SELECT * FROM t WHERE s1 > 'a';``
            -   Okay. We should note here that comparisons use a binary
                collation by default, but it is easy to use a
                :ref:`COLLATE clause <sql_collate_clause>`. 


E031, Identifiers
-----------------

..  container:: table

    ..  list-table::
        :widths: 15 30 30 25
        :header-rows: 1

        *   -   Feature ID
            -   Feature
            -   Example
            -   Tests
        *   -   E031
            -   Identifiers
            -   ``CREATE TABLE rank (ceil INT PRIMARY KEY);``
            -   Fail. Tarantool's list of
                :ref:`reserved words <sql_reserved_words>`   
                differs from the standard's list of reserved words.   
        *   -   E031-01
            -   Delimited identifiers
            -   ``CREATE TABLE "t47" (s1 INT PRIMARY KEY);``
            -   :ref:`Okay <sql_identifiers>`.
                Also, enclosing identifiers inside double quotes
                means they won't be converted to upper case or lower
                case, this is the behavior that some other DBMSs lack.
        *   -   E031-02
            -   Lower case identifiers
            -   ``CREATE TABLE t48 (s1 INT PRIMARY KEY);``
            -   Okay.   
        *   -   E031-03
            -   Trailing underscore
            -   ``CREATE TABLE t49_ (s1 INT PRIMARY KEY);``
            -   Okay. 


E051, Basic query specification
-------------------------------

..  container:: table

    ..  list-table::
        :widths: 15 30 30 25
        :header-rows: 1

        *   -   Feature ID
            -   Feature
            -   Example
            -   Tests
        *   -   E051-01   
            -   SELECT DISTINCT
            -   ``SELECT DISTINCT s1 FROM t;``
            -   Okay.
        *   -   E051-02
            -   GROUP BY clause
            -   ``SELECT DISTINCT s1 FROM t GROUP BY s1;``
            -   :ref:`Okay <sql_group_by>`.
        *   -   E051-04
            -   GROUP BY can contain columns not in select list
            -   ``SELECT s1 FROM t GROUP BY lower(s1);``
            -   Okay.
        *   -   E051-05
            -   Select list items can be renamed
            -   ``SELECT s1 AS K FROM t ORDER BY K;``
            -   Okay.
        *   -   E051-06
            -   HAVING clause
            -   ``SELECT count(*) FROM t HAVING count(*) > 0;``
            -   Okay. Tarantool supports :ref:`HAVING <sql_having>`, and GROUP BY is not
                mandatory before HAVING.
        *   -   E051-07
            -   Qualified * in SELECT list
            -   ``SELECT t.* FROM t;``
            -   Okay.
        *   -   E051-08
            -   Correlation names in the FROM clause
            -   ``SELECT * FROM t AS K;``
            -   Okay.
        *   -   E051-09
            -   Rename columns in the FROM clause
            -   ``SELECT * FROM t AS x(q,c);``
            -   Fail.


E061, Basic predicates and search conditions
--------------------------------------------

..  container:: table

    ..  list-table::
        :widths: 15 30 30 25
        :header-rows: 1

        *   -   Feature ID
            -   Feature
            -   Example
            -   Tests
        *   -   E061-01
            -   Comparison predicate
            -   ``SELECT * FROM t WHERE 0 = 0;``
            -   Okay.   
        *   -   E061-02
            -   BETWEEN predicate
            -   ``SELECT * FROM t WHERE ' ' BETWEEN '' AND ' ';``
            -   :ref:`Okay <sql_operator_between>`.
        *   -   E061-03
            -   IN predicate with list of values
            -   ``SELECT * FROM t WHERE s1 IN ('a', upper('a'));``
            -   Okay.
        *   -   E061-04
            -   LIKE predicate
            -   ``SELECT * FROM t WHERE s1 LIKE '_';``
            -   :ref:`Okay <sql_operator_like>`.
        *   -   E061-05
            -   LIKE predicate: ESCAPE clause
            -   ``VALUES ('abc_' LIKE 'abcX_' ESCAPE 'X');``
            -   Okay.
        *   -   E061-06
            -   NULL predicate
            -   ``SELECT * FROM t WHERE s1 IS NOT NULL;``
            -   :ref:`Okay <sql_is_null>`.
        *   -   E061-07
            -   Quantified comparison predicate
            -   ``SELECT * FROM t WHERE s1 = ANY (SELECT s1 FROM t);``
            -   Fail. Syntax error.
        *   -   E061-08
            -   EXISTS predicate
            -   ``SELECT * FROM t WHERE NOT EXISTS (SELECT * FROM t);``
            -   :ref:`Okay <sql_subquery>`.
        *   -   E061-09   
            -   Subqueries in comparison predicate
            -   ``SELECT * FROM t WHERE s1 > (SELECT s1 FROM t);``
            -   :ref:`Okay <sql_subquery>`.
        *   -   E061-11
            -   Subqueries in IN predicate
            -   ``SELECT * FROM t WHERE s1 IN (SELECT s1 FROM t);``
            -   Okay.
        *   -   E061-12
            -   Subqueries in quantified comparison predicate
            -   ``SELECT * FROM t WHERE s1 >= ALL (SELECT s1 FROM t);``
            -   Fail. Syntax error.
        *   -   E061-13
            -   Correlated subqueries
            -   ``SELECT * FROM t WHERE s1 = (SELECT s1 FROM t2 WHERE t2.s2 = t.s1);``
            -   Okay.
        *   -   E061-14
            -   Search condition
            -   ``SELECT * FROM t WHERE 0 <> 0 OR 'a' < 'b' AND s1 IS NULL;``
            -   Okay.


E071, Basic query expressions
-----------------------------

..  container:: table

    ..  list-table::
        :widths: 15 30 30 25
        :header-rows: 1

        *   -   Feature ID
            -   Feature
            -   Example
            -   Tests
        *   -   E071-01
            -   UNION DISTINCT table operator
            -   ``SELECT * FROM t UNION DISTINCT SELECT * FROM t;``
            -   Fail. However,
                ``SELECT * FROM t UNION SELECT * FROM t;`` is okay.
        *   -   E071-02
            -   UNION ALL table operator
            -   ``SELECT * FROM t UNION ALL SELECT * FROM t;``
            -   :ref:`Okay <sql_union>`.
        *   -   E071-03
            -   EXCEPT DISTINCT table operator
            -   ``SELECT * FROM t EXCEPT DISTINCT SELECT * FROM t;``
            -   Fail. However,   
                ``SELECT * FROM t EXCEPT SELECT * FROM t;`` is okay.  
        *   -   E071-05
            -   Columns combined via table operators need not
                have exactly the same data type
            -   ``SELECT s1 FROM t UNION SELECT 5 FROM t;``
            -   Okay.
        *   -   E071-06
            -   Table operators in subqueries
            -   ``SELECT * FROM t WHERE 'a' IN (SELECT * FROM t UNION SELECT * FROM t);``
            -   Okay.


E081, Basic privileges
----------------------

Tarantool doesn't support privileges except via NoSQL.


E091, Set functions
-------------------

..  container:: table

    ..  list-table::
        :widths: 15 30 30 25
        :header-rows: 1

        *   -   Feature ID
            -   Feature
            -   Example
            -   Tests        
        *   -   E091-01
            -   AVG
            -   ``SELECT avg(s1) FROM t7;``
            -   Fail. Tarantool supports   
                :ref:`AVG <sql_aggregate_avg>` but there is no warning
                that NULLs are eliminated.   
        *   -   E091-02   
            -   COUNT
            -   ``SELECT count(*) FROM t7 WHERE s1 > 0;``
            -   :ref:`Okay <sql_aggregate_count_row>`.
        *   -   E091-03   
            -   MAX
            -   ``SELECT max(s1) FROM t7 WHERE s1 > 0;``
            -   :ref:`Okay <sql_aggregate_max>`.
        *   -   E091-04   
            -   MIN
            -   ``SELECT min(s1) FROM t7 WHERE s1 > 0;``
            -   :ref:`Okay <sql_aggregate_min>`.   
        *   -   E091-05   
            -   SUM
            -   ``SELECT sum(1) FROM t7 WHERE s1 > 0;``
            -   :ref:`Okay <sql_aggregate_sum>`.   
        *   -   E091-06   
            -   ALL quantifier
            -   ``SELECT sum(ALL s1) FROM t7 WHERE s1 > 0;``   
            -   Okay.   
        *   -   E091-07   
            -   DISTINCT quantifier
            -   ``SELECT sum(DISTINCT s1) FROM t7 WHERE s1 > 0;``
            -   Okay.  


E101, Basic data manipulation
-----------------------------

..  container:: table

    ..  list-table::
        :widths: 15 30 30 25
        :header-rows: 1

        *   -   Feature ID
            -   Feature
            -   Example
            -   Tests
        *   -   E101-01   
            -   INSERT statement
            -   ``INSERT INTO t (s1,s2) VALUES (1,''), (2,NULL), (3,55);``
            -   :ref:`Okay <sql_insert>`.      
        *   -   E101-03
            -   Searched UPDATE statement
            -   ``UPDATE t SET s1 = NULL WHERE s1 IN (SELECT s1 FROM t2);``
            -   :ref:`Okay <sql_update>`.   
        *   -   E101-04   
            -   Searched DELETE statement
            -   ``DELETE FROM t WHERE s1 IN (SELECT s1 FROM t);``
            -   :ref:`Okay <sql_delete>`.   


E111, Single row SELECT statement
---------------------------------   

..  container:: table

    ..  list-table::
        :widths: 15 30 30 25
        :header-rows: 1

        *   -   Feature ID
            -   Feature
            -   Example
            -   Tests
        *   -   E111   
            -   Single row SELECT statement
            -   ``SELECT count(*) FROM t;``
            -   :ref:`Okay <sql_SELECT>`.   
   
   
E121, Basic cursor support   
--------------------------

..  container:: table

    ..  list-table::
        :widths: 15 30 30 25
        :header-rows: 1

        *   -   Feature ID
            -   Feature
            -   Example
            -   Tests
        *   -   E121-01   
            -   DECLARE CURSOR   
            -
            -   Fail. Tarantool doesn't support cursors.   
        *   -   E121-02   
            -   ORDER BY columns need not be in select list
            -   ``SELECT s1 FROM t ORDER BY s2;``
            -   :ref:`Okay <sql_order_by>`.   
        *   -   E121-03   
            -   Value expressions in ORDER BY clause
            -   ``SELECT s1 FROM t7 ORDER BY -s1;``
            -   Okay.   
        *   -   E121-04   
            -   OPEN statement   
            -
            -   Fail. Tarantool doesn't support cursors.   
        *   -   E121-06   
            -   Positioned UPDATE statement   
            -
            -   Fail. Tarantool doesn't support cursors.   
        *   -   E121-07   
            -   Positioned DELETE statement   
            -
            -   Fail. Tarantool doesn't support cursors.   
        *   -   E121-08   
            -   CLOSE statement   
            -
            -   Fail. Tarantool doesn't support cursors.   
        *   -   E121-10   
            -   FETCH statement implicit next   
            -
            -   Fail. Tarantool doesn't support cursors. 
        *   -   E121-17   
            -   WITH HOLD cursors   
            -
            -   Fail. Tarantool doesn't support cursors.   


E131, Null value support
------------------------

..  container:: table

    ..  list-table::
        :widths: 15 30 30 25
        :header-rows: 1

        *   -   Feature ID
            -   Feature
            -   Example
            -   Tests
        *   -   E131   
            -   Null value support (nulls in lieu of values)
            -   ``SELECT s1 FROM t7 WHERE s1 IS NULL;``   
            -   Okay.   
   
   
E141, Basic integrity constraints   
---------------------------------   
   
..  container:: table

    ..  list-table::
        :widths: 15 30 30 25
        :header-rows: 1

        *   -   Feature ID
            -   Feature
            -   Example
            -   Tests
        *   -   E141-01   
            -   NOT NULL constraints
            -   ``CREATE TABLE t8 (s1 INT PRIMARY KEY, s2 INT NOT NULL);``
            -   :ref:`Okay <sql_table_constraint_def>`.   
        *   -   E141-02   
            -   UNIQUE constraints of NOT NULL columns
            -   ``CREATE TABLE t9 (s1 INT PRIMARY KEY , s2 INT NOT NULL UNIQUE);``
            -   :ref:`Okay <sql_table_constraint_def>`.   
        *   -   E141-03   
            -   PRIMARY KEY constraints
            -   ``CREATE TABLE t10 (s1 INT PRIMARY KEY);``   
            -   Okay, although Tarantool shouldn't always insist on   
                having a primary key.   
        *   -   E141-04   
            -   Basic FOREIGN KEY constraint with the NO ACTION default
                for both referential delete and referential update actions
            -   ``CREATE TABLE t11 (s0 INT PRIMARY KEY, s1 INT REFERENCES t10);``
            -   :ref:`Okay <sql_foreign_key>`.   
        *   -   E141-06   
            -   CHECK constraints
            -   ``CREATE TABLE t12 (s1 INT PRIMARY KEY, s2 INT, CHECK (s1 = s2));``
            -   Okay.  
        *   -   E141-07   
            -   Column defaults
            -   ``CREATE TABLE t13 (s1 INT PRIMARY KEY, s2 INT DEFAULT -1);``   
            -   Okay.
        *   -   E141-08   
            -   NOT NULL inferred on primary key
            -   ``CREATE TABLE t14 (s1 INT PRIMARY KEY);``   
            -   Okay. We are unable to insert NULL although we don't
                explicitly say the column is NOT NULL.   
        *   -   E141-10   
            -   Names in a foreign key can be specified in any order
            -   ``CREATE TABLE t15 (s1 INT, s2 INT, PRIMARY KEY (s1,s2));``
                ``CREATE TABLE t16 (s1 INT PRIMARY KEY, s2 INT, FOREIGN KEY (s2,s1) REFERENCES t15 (s1,s2));``   
            -   Okay.  
   
   
E151, Transaction support   
-------------------------

..  container:: table

    ..  list-table::
        :widths: 15 30 30 25
        :header-rows: 1

        *   -   Feature ID
            -   Feature
            -   Example
            -   Tests
        *   -   E151-01   
            -   COMMIT statement
            -   ``COMMIT;``   
            -   Fail. Tarantool supports   
                :ref:`COMMIT <sql_commit>` but it is necessary to say 
                :ref:`START TRANSACTION <sql_start_transaction>` first.
        *   -   E151-02   
            -   ROLLBACK statement
            -   ``ROLLBACK;``
            -   :ref:`Okay <sql_rollback>`.   
   
   
E152, Basic SET TRANSACTION statement
-------------------------------------

..  container:: table

    ..  list-table::
        :widths: 15 30 30 25
        :header-rows: 1

        *   -   Feature ID
            -   Feature
            -   Example
            -   Tests
        *   -   E152-01   
            -   SET TRANSACTION statement: ISOLATION SERIALIZABLE clause
            -   ``SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;``   
            -   Fail. Syntax error.   
        *   -   E152-02
            -   SET TRANSACTION statement: READ ONLY and READ WRITE clauses
            -   ``SET TRANSACTION READ ONLY;``   
            -   Fail. Syntax error.   
         

E*, Other
---------

..  container:: table

    ..  list-table::
        :widths: 15 30 30 25
        :header-rows: 1

        *   -   Feature ID
            -   Feature
            -   Example
            -   Tests
        *   -   E153   
            -   Updatable queries with subqueries
            -   ``UPDATE "view_containing_subquery" SET column1=0;``
            -   Fail.     
        *   -   E161   
            -   SQL comments using leading double minus
            -   ``--comment;``
            -   :ref:`Okay <sql_tokens>`.   
        *   -   E171   
            -   SQLSTATE support
            -   ``DROP TABLE no_such_table;``   
            -   Fail. Tarantool returns an error message but not an SQLSTATE string.   
        *   -   E182
            -   Host language binding   
            -
            -   Okay. Any of the Tarantool connectors should be able
                to call :ref:`box.execute() <box-sql>`.   
   

F021, Basic information schema
------------------------------

..  container:: table

    ..  list-table::
        :widths: 15 30 30 25
        :header-rows: 1

        *   -   Feature ID
            -   Feature
            -   Example
            -   Tests
        *   -   F021   
            -   Basic information schema
            -   ``SELECT * from information_schema.tables;``   
            -   Fail. Tarantool's metadata is not in a schema with that
                name (not counted in the final score). 
   

F031, Basic schema manipulation
-------------------------------

..  container:: table

    ..  list-table::
        :widths: 15 30 30 25
        :header-rows: 1

        *   -   Feature ID
            -   Feature
            -   Example
            -   Tests
        *   -   F031-01   
            -   CREATE TABLE statement to create persistent base tables 
            -   ``CREATE TABLE t20 (t20_1 INT NOT NULL);``   
            -   Fail. We always have to specify PRIMARY KEY (we only count this flaw once).   
        *   -   F031-02   
            -   CREATE VIEW statement
            -   ``CREATE VIEW t21 AS SELECT * FROM t20;``
            -   :ref:`Okay <sql_create_view>`.   
        *   -   F031-03   
            -   GRANT statement   
            -
            -   Fail. Tarantool doesn't support privileges except via NoSQL. 
        *   -   F031-04   
            -   ALTER TABLE statement: add column
            -   ``ALTER TABLE t7 ADD COLUMN t7_2 VARCHAR(1) DEFAULT 'q';``
            -   Okay. Tarantool supports :ref:`ALTER TABLE <sql_alter_table>`,
                and support for ADD COLUMN was added in Tarantool 2.7.
        *   -   F031-13   
            -   DROP TABLE statement: RESTRICT clause
            -   ``DROP TABLE t20 RESTRICT;``   
            -   Fail. Tarantool supports :ref:`DROP TABLE <sql_drop_table>` but not this clause.   
        *   -   F031-16   
            -   DROP VIEW statement: RESTRICT clause
            -   ``DROP VIEW v2 RESTRICT;``   
            -   Fail. Tarantool supports :ref:`DROP VIEW <sql_drop_view>` but not this clause. 
        *   -   F031-19   
            -   REVOKE statement: RESTRICT clause   
            -
            -   Fail. Tarantool does not support privileges except via NoSQL.   

   
F041, Basic joined table   
------------------------
   
..  container:: table

    ..  list-table::
        :widths: 15 30 30 25
        :header-rows: 1

        *   -   Feature ID
            -   Feature
            -   Example
            -   Tests
        *   -   F041-01   
            -   Inner join but not necessarily the INNER keyword
            -   ``SELECT a.s1 FROM t7 a JOIN t7 b;``
            -   :ref:`Okay <sql_from>`.   
        *   -   F041-02   
            -   INNER keyword
            -   ``SELECT a.s1 FROM t7 a INNER JOIN t7 b;``   
            -   Okay.   
        *   -   F041-03   
            -   LEFT OUTER JOIN
            -   ``SELECT t7.*,t22.* FROM t22 LEFT OUTER JOIN t7 ON (t22_1 = s1);``   
            -    Okay.
        *   -   F041-04   
            -   RIGHT OUTER JOIN
            -   ``SELECT t7.*,t22.* FROM t22 RIGHT OUTER JOIN t7 ON (t22_1 = s1);``   
            -   Fail. Syntax error.   
        *   -   F041-05   
            -   Outer joins can be nested
            -   ``SELECT t7.*,t22.* FROM t22 LEFT OUTER JOIN t7 ON (t22_1 = s1) LEFT OUTER JOIN t23;``
            -   Okay.
        *   -   F041-07  
            -   The inner table in a left or right outer join can also be used in an inner join
            -   ``SELECT t7.* FROM (t22 LEFT OUTER JOIN t7 ON (t22_1 = s1)) j INNER JOIN t22 ON (j.t22_4 = t7.s1);``
            -   Okay.   
        *   -   F041-08   
            -   All comparison operators are supported
            -   ``SELECT * FROM t WHERE 0 = 1 OR 0 > 1 OR 0 < 1 OR 0 <> 1;``   
            -   :ref:`Okay <sql_operator_comparison>`.   

   
F051, Basic date and time   
-------------------------
   
..  container:: table

    ..  list-table::
        :widths: 15 30 30 25
        :header-rows: 1

        *   -   Feature ID
            -   Feature
            -   Example
            -   Tests
        *   -   F051-01   
            -   DATE data type (including support of DATE literal)
            -   ``CREATE TABLE dates (s1 DATE);``   
            -   Fail. Tarantool does not support the DATE data type.  
        *   -   F051-02   
            -   TIME data type (including support of TIME literal)
            -   ``CREATE TABLE times (s1 TIME DEFAULT TIME '1:2:3');``
            -   Fail. Syntax error.
        *   -   F051-03   
            -   TIMESTAMP data type (including support of TIMESTAMP literal)  
            -   ``CREATE TABLE timestamps (s1 TIMESTAMP);``   
            -   Fail. Syntax error.   
        *   -   F051-04   
            -   Comparison predicate on DATE, TIME and TIMESTAMP data types   
            -   ``SELECT * FROM dates WHERE s1 = s1;``   
            -   Fail. Date and time data types are not supported.   
        *   -   F051-05   
            -   Explicit CAST between date-time types and character string types   
            -   ``SELECT cast(s1 AS VARCHAR(10)) FROM dates;``   
            -   Fail. Date and time data types are not supported.   
        *   -   F051-06   
            -   CURRENT_DATE
            -   ``SELECT current_date FROM t;``   
            -   Fail. Syntax error.   
        *   -   F051-07   
            -   LOCALTIME
            -   ``SELECT localtime FROM t;``   
            -   Fail. Syntax error.   
        *   -   F051-08   
            -   LOCALTIMESTAMP
            -   ``SELECT localtimestamp FROM t;``   
            -   Fail. Syntax error.   
   

F081, UNION and EXCEPT in views
-------------------------------
   
..  container:: table

    ..  list-table::
        :widths: 15 30 30 25
        :header-rows: 1

        *   -   Feature ID
            -   Feature
            -   Example
            -   Tests        
        *   -   F081   
            -   UNION and EXCEPT in views
            -   ``CREATE VIEW vv AS SELECT * FROM t7 EXCEPT SELECT * * FROM t15;``
            -   Okay.   
   
   
F131, Grouped operations
------------------------
   
..  container:: table

    ..  list-table::
        :widths: 15 30 30 25
        :header-rows: 1

        *   -   Feature ID
            -   Feature
            -   Example
            -   Tests   
        *   -   F131-01   
            -   WHERE, GROUP BY, and HAVING clauses supported in queries with grouped views
            -   ``CREATE VIEW vv2 AS SELECT * FROM vv GROUP BY s1;``   
            -   Okay.   
        *   -   F131-02   
            -   Multiple tables supported in queries with grouped views
            -   ``CREATE VIEW vv3 AS SELECT * FROM vv2,t30;``   
            -   Okay.   
        *   -   F131-03   
            -   Set functions supported in queries with grouped views
            -   ``CREATE VIEW vv4 AS SELECT count(*) FROM vv2;``   
            -   Okay.   
        *   -   F131-04   
            -   Subqueries with GROUP BY and HAVING clauses and grouped views
            -   ``CREATE VIEW vv5 AS SELECT count(*) FROM vv2 GROUP BY s1 HAVING count(*) > 0;``   
            -   Okay.
        *   -   F131-05   
            -   Single row SELECT with GROUP BY and HAVING clauses and grouped views   
            -   ``SELECT count(*) FROM vv2 GROUP BY s1 HAVING count(*) > 0;``   
            -   Okay.
   
   
F181, Multiple module support   
-----------------------------

Fail. Tarantool doesn't have modules.   
   

F201, CAST function
-------------------

..  container:: table

    ..  list-table::
        :widths: 15 30 30 25
        :header-rows: 1

        *   -   Feature ID
            -   Feature
            -   Example
            -   Tests 
        *   -   F201
            -   CAST function
            -   ``SELECT cast(s1 AS INT) FROM t;``
            -   :ref:`Okay <sql_function_cast>`.   


F221, Explicit defaults
-----------------------

..  container:: table

    ..  list-table::
        :widths: 15 30 30 25
        :header-rows: 1

        *   -   Feature ID
            -   Feature
            -   Example
            -   Tests    
        *   -   F221   
            -   Explicit defaults
            -   ``UPDATE t SET s1 = DEFAULT;``   
            -   Fail. Syntax error.   
     

F261, CASE expression   
---------------------

..  container:: table

    ..  list-table::
        :widths: 15 30 30 25
        :header-rows: 1

        *   -   Feature ID
            -   Feature
            -   Example
            -   Tests 
        *   -   F261-01   
            -   Simple CASE
            -   ``SELECT CASE WHEN 1 = 0 THEN 5 ELSE 7 END FROM t;``   
            -   Okay.   
        *   -   F261-02   
            -   Searched CASE
            -   ``SELECT CASE 1 WHEN 0 THEN 5 ELSE 7 END FROM t;``   
            -   Okay.   
        *   -   F261-03   
            -   NULLIF
            -   ``SELECT nullif(s1,7) FROM t;``
            -   :ref:`Okay <sql_function_nullif>`   
        *   -   F261-04   
            -   COALESCE
            -   ``SELECT coalesce(s1,7) FROM t;``
            -   :ref:`Okay <sql_function_coalesce>`.   
  
   
F311, Schema definition statement
---------------------------------
   
..  container:: table

    ..  list-table::
        :widths: 20 40 40
        :header-rows: 1

        *   -   Feature ID
            -   Feature
            -   Tests 
        *   -   F311-01   
            -   CREATE SCHEMA   
            -   Fail. Tarantool doesn't have schemas or databases.   
        *   -   F311-02   
            -   CREATE TABLE for persistent base tables   
            -   Fail. Tarantool doesn't have CREATE TABLE inside CREATE SCHEMA.   
        *   -   F311-03   
            -   CREATE VIEW   
            -   Fail. Tarantool doesn't have CREATE VIEW inside CREATE SCHEMA.   
        *   -   F311-04   
            -   CREATE VIEW: WITH CHECK OPTION   
            -   Fail. Tarantool doesn't have CREATE VIEW inside CREATE SCHEMA.   
        *   -   F311-05   
            -   GRANT statement
            -   Fail. Tarantool doesn't have GRANT inside CREATE SCHEMA.   
   
   
F*, Other
---------

..  container:: table

    ..  list-table::
        :widths: 15 30 30 25
        :header-rows: 1

        *   -   Feature ID
            -   Feature
            -   Example
            -   Tests 
        *   -   F471
            -   Scalar subquery values
            -   ``SELECT s1 FROM t WHERE s1 = (SELECT count(*) FROM t);``   
            -   Okay.
        *   -   F481   
            -   Expanded NULL predicate
            -   ``SELECT * FROM t WHERE row(s1,s1) IS NOT NULL;``   
            -   Fail. Syntax error.   
        *   -   F812   
            -   Basic flagging   
            -
            -   Fail. Tarantool doesn't support any flagging.   
        
   
S011, Distinct types
--------------------

..  container:: table

    ..  list-table::
        :widths: 15 30 30 25
        :header-rows: 1

        *   -   Feature ID
            -   Feature
            -   Example
            -   Tests 
        *   -   S011   
            -   Distinct types
            -   ``CREATE TYPE x AS FLOAT;``   
            -   Fail. Tarantool doesn't support distinct types.   
  
   
T321, Basic SQL-invoked routines
--------------------------------

..  container:: table

    ..  list-table::
        :widths: 15 30 30 25
        :header-rows: 1

        *   -   Feature ID
            -   Feature
            -   Example
            -   Tests 
        *   -   T321-01   
            -   User-defined functions with no overloading
            -   ``CREATE FUNCTION f() RETURNS INT RETURN 5;``   
            -   Fail. User-defined functions for SQL are created in   
                :ref:`Lua <sql_calling_lua>` with a different syntax.   
        *   -   T321-02   
            -   User-defined procedures with no overloading
            -   ``CREATE PROCEDURE p() BEGIN END;``   
            -   Fail. User-defined functions for SQL are created in   
                :ref:`Lua <sql_calling_lua>` with a different syntax.   
        *   -   T321-03
            -   Function invocation
            -   ``SELECT f(1) FROM t;``   
            -   Okay. Tarantool can invoke Lua user-defined functions.
        *   -   T321-04   
            -   CALL statement
            -   ``CALL p();``   
            -   Fail. Tarantool doesn't support CALL statements.   
        *   -   T321-05   
            -   RETURN statement
            -   ``CREATE FUNCTION f() RETURNS INT RETURN 5;``   
            -   Fail. Tarantool doesn't support RETURN statements.   


T*, Other
---------

..  container:: table

    ..  list-table::
        :widths: 15 30 30 25
        :header-rows: 1

        *   -   Feature ID
            -   Feature
            -   Example
            -   Tests 
        *   -   T631   
            -   IN predicate with one list element
            -   ``SELECT * FROM t WHERE 1 IN (1);``   
            -   Okay.   


Total number of items marked "Fail": 67

Total number of items marked "Okay": 79
