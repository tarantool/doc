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

|br|

.. image:: alter_table.svg
    :align: left

|br|

ALTER is used to either change a table's name or to add new constraints.

Examples:

.. code-block:: sql

   -- renaming a table:
   ALTER TABLE t1 RENAME TO t2;

For ``ALTER ... RENAME``, the *old-table* must exist, the *new-table* must not
exist.

.. code-block:: sql

   -- adding a foreign-key constraint definition:
   ALTER TABLE t1 ADD CONSTRAINT c FOREIGN KEY (s1) REFERENCES t1;

For ``ALTER ... ADD CONSTRAINT``, the table must exist, the constraint type must
be foreign-key or PRIMARY or UNIQUE (not CHECK), the constraint name must not
already exist for the table.

It is not possible to say ``CREATE TABLE table_a ... REFERENCES table_b ...``
if table ``b`` does not exist yet. This is a situation where ``ALTER TABLE`` is
handy -- users can ``CREATE TABLE table_a`` without the foreign key, then
``CREATE TABLE table_b``, then ``ALTER TABLE table_a ... REFERENCES table_b ...``.
This is only legal if the table is empty.

.. code-block:: sql

   -- adding a primary-key constraint definition:
   ALTER TABLE t1 ADD CONSTRAINT primary_key PRIMARY KEY (s1);

.. // See "Constraint Definition for foreign keys" foreign-constraint-definition.

.. code-block:: sql

   -- adding a unique-constraint definition:
   ALTER TABLE t1 ADD CONSTRAINT unique_key UNIQUE (s1);

This is unusual because primary keys are created automatically and it is illegal
to have two primary keys for the same table. However, it is possible to drop
a primary-key index, and this is a way to restore the primary key if that happens.
Alternatively, you can say ``CREATE UNIQUE INDEX unique_key ON t1 (s1);``.

.. _sql_alter_table_drop_constraint:

.. code-block:: sql

   -- dropping a constraint:
   ALTER TABLE t1 DROP CONSTRAINT c;

It is only legal to drop a named constraint, and only foreign-key constraints
can have names. (Tarantool generates the constraint names automatically if the
user does not provide them.)

To remove a unique constraint, use DROP INDEX, which will drop the constraint
as well.

Limitations:

* It is not possible to add or drop a column.
* It is not possible to modify NOT NULL constraints or column properties DEFAULT
  and data type.
  However, it is possible to modify them with Tarantool/NOSQL, for example by
  calling :ref:`space_object:format() <box_space-format>` with a different
  ``is_nullable`` value.

.. _sql_create_table:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
CREATE TABLE
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Syntax:

:samp:`CREATE TABLE [IF NOT EXISTS] {table-name} ((column-definition or table-constraint list);`

|br|

.. image:: create_table.svg
    :align: left

|br|

Create a new base table, usually called a "table".

.. NOTE::

   A table is a *base table* if is created with CREATE TABLE and contains
   data in persistent storage.

   A table is a *viewed table*, or just "view", if it is created with
   CREATE VIEW and gets its data from other views or from base tables.

The *table-name* must be an identifier which is valid according to the rules for
identifiers, and must not be the name of an already existing base table or view.

The *column-definition* or *table-constraint* list is a comma-separated list
of column definitions or table constraints.

A *table-element-list* must be a comma-separated list of table elements;
each table element may be either a column definition or a table constraint
definition.

Rules:

* A primary key is necessary; it can be specified with a table constraint
  PRIMARY KEY.
* There must be at least one column.
* When IF NOT EXISTS is specified, and there is already a table with the same
  name, the statement is ignored.

Actions:

#. Tarantool evaluates each column definition and *table-constraint*,
   and returns an error if any of the rules is violated.
#. Tarantool makes a new definition in the schema.
#. Tarantool makes new indexes for PRIMARY KEY or UNIQUE constraints.
   A unique index name is created automatically.
#. Tarantool effectively executes a ``COMMIT`` statement.

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
   -- and an inline comment:
   CREATE TABLE "t1" ("s1" INT /* synonym of INTEGER */, PRIMARY KEY ("s1"));

   -- two columns, one named constraint
   CREATE TABLE t1 (s1 INTEGER, s2 TEXT, CONSTRAINT c1 PRIMARY KEY (s1, s2));

Limitations:

* The maximum number of columns is 2000.
* The maximum length of a row depends on the
  :ref:`memtx_max_tuple_size <cfg_storage-memtx_max_tuple_size>` or
  :ref:`vinyl_max_tuple_size  <cfg_storage-memtx_max_tuple_size>`
  configuration option.

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
  Please drop the referencing view with DROP VIEW first.
* If there is a foreign key that references the table, the drop will fail.
  Please drop the referencing constraint with
  :ref:`ALTER TABLE ... DROP <sql_alter_table_drop_constraint>` first.

Actions:

#. Tarantool returns an error if the table does not exist.
#. The table and all its data are dropped.
#. All indexes for the table are dropped.
#. All triggers for the table are dropped.
#. Tarantool effectively executes a COMMIT statement.

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

The syntax of the subquery must be the same as the syntax of a SELECT statement,
or of a VALUES clause.

Rules:

* There must not already be a base table or view with the same name as
  *view-name*.
* If *column-list* is specified, the number of columns in *column-list* must be
  the same as the number of columns in the *select-list* of the subquery.

Actions:

#. Tarantool will throw an error if a rule is violated.
#. Tarantool will create a new persistent object with *column-names* equal to
   the names in the *column-list* or the names in the subquery's *select-list*.
#. Tarantool effectively executes a COMMIT statement.

Examples:

.. code-block:: sql

   -- the simple case:
   CREATE VIEW v AS SELECT column1, column2 FROM t;
   -- with a column-list:
   CREATE VIEW v (a,b) AS SELECT column1, column2 FROM t;

Limitations:

* It is not possible to insert or update or delete from a view, although
  sometimes a possible substitution is to create an INSTEAD OF trigger.

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

#. Tarantool returns an error if the view does not exist.
#. The view is dropped.
#. All triggers for the view are dropped.
#. Tarantool effectively executes a COMMIT statement.

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
* An index name is local to the table the index is defined on.
* The maximum number of indexes per table is 128.

Actions:

#. Tarantool will throw an error if a rule is violated.
#. If the new index is UNIQUE, Tarantool will throw an error if any row exists
   with columns that have duplicate values.
#. Tarantool will create a new index.
#. Tarantool effectively executes a COMMIT statement.

Automatic indexes:

Indexes may be created automatically for columns mentioned in the PRIMARY KEY
or UNIQUE clauses of a CREATE TABLE statement.
If an index was created automatically, then the *index-name* is based on four
items:

#. ``pk`` if this is for a PRIMARY KEY clause, ``unique`` if this is for
   a UNIQUE clause;
#. ``_unnamed_``;
#. the name of the table;
#. ``_`` and an ordinal number; the first index is 1, the second index is 2,
   and so on.

For example, after ``CREATE TABLE t (s1 INT PRIMARY KEY, s2 INT, UNIQUE (s2));``
there are two indexes named ``pk_unnamed_T_1`` and ``unique_unnamed_T_2``.
You can confirm this by saying ``SELECT * FROM "_index";`` which will list all
indexes on all tables.
There is no need to say ``CREATE INDEX`` for columns that already have
automatic indexes.

Examples:

.. code-block:: sql

   -- the simple case
   CREATE INDEX i ON t (column1);
   -- with IF NOT EXISTS clause
   CREATE INDEX IF NOT EXISTS i ON t (column1);
   -- with UNIQUE specifier and more than one column
   CREATE UNIQUE INDEX i ON t (column1, column2);

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
CREATE INDEX.
Or, the *index-name* must be the name of an index that was created automatically
due to a PRIMARY KEY or UNIQUE clause in the CREATE TABLE statement.
To see what a table's indexes are, use ``PRAGMA index_list (table-name)``.

Rules: none

Actions:

#. Tarantool throws an error if the index does not exist, or is an automatically
   created index.
#. Tarantool will drop the index.
#. Tarantool effectively executes a COMMIT statement.

Example:

.. code-block:: sql

   -- the simplest form
   DROP INDEX i ON t;

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

The *table-name* must be a name of a table defined earlier with CREATE TABLE.

The optional *column-list* must be a comma-separated list of names of columns
in the table.

The *expression-list* must be a comma-separated list of expressions; each
expression may contain literals and operators and subqueries and function invocations.

Rules:

* The values in the *expression-list* are evaluated from left to right.
* The order of the values in the *expression-list* must correspond to the order
  of the columns in the table, or (if a *column-list* is specified) to the order
  of the columns in the *column-list*.
* The data type of the value should correspond to the data type of the column,
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
#. Tarantool inserts values into the table.

.. //  append to 3: in the order described by section "Order of Execution in Data-Change Statements"

Examples:

.. code-block:: sql

   -- the simplest form
   INSERT INTO table1 VALUES (1, 'A');
   -- with a column list
   INSERT INTO table1 (column1, column2) VALUES (2, 'B');
   -- with an arithmetic operator in the first expression
   INSERT INTO table1 VALUES (2 + 1, 'C');
   -- put two rows in the table
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
CREATE TABLE or CREATE VIEW.

The *column-name* must be an updatable column in the table.

The *expression* may contain literals and operators and subqueries and function
invocations and column names.

Rules:

* The values in the SET clause are evaluated from left to right.
* The data type of the value should correspond to the data type of the column,
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

   -- the simplest form
   UPDATE t SET column1 = 1;
   -- with more than one assignment in the SET clause
   UPDATE t SET column1 = 1, column2 = 2;
   -- with a WHERE clause
   UPDATE t SET column1 = 5 WHERE column2 = 6;

Special cases:

It is legal to say SET (list of columns) = (list of values). For example:

.. code-block:: sql

   UPDATE t SET (column1, column2, column3) = (1,2,3);

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
CREATE TABLE or CREATE VIEW.

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
#. Tarantool deletes the set of matching rows from the table.

.. // append to 3: in the order described by section Order of Execution in Data-Change Statements.

Examples:

.. code-block:: sql

   -- the simplest form
   DELETE FROM t;
   -- with a WHERE clause
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
DELETE statement followed by an INSERT statement.
Otherwise the action is insert, and the rules are the same as for the
INSERT statement.

Examples:

.. code-block:: sql

   -- the simplest form
   REPLACE INTO table1 VALUES (1, 'A');
   -- with a column list
   REPLACE INTO table1 (column1, column2) VALUES (2, 'B');
   -- with an arithmetic operator in the first expression
   REPLACE INTO table1 VALUES (2 + 1, 'C');
   -- put two rows in the table
   REPLACE INTO table1 VALUES (4, 'D'), (5, 'E');

See also: :ref:`INSERT Statement <sql_insert>`, :ref:`UPDATE Statement <sql_update>`.

.. // and Order of Execution in Data-Change Statements.

.. _sql_create_trigger:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
CREATE TRIGGER
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

:samp:`CREATE TRIGGER [IF NOT EXISTS] {trigger-name}` |br|
:samp:`BEFORE|AFTER|INSTEAD OF` |br|
:samp:`INSERT|UPDATE|DELETE ON {table-name}` |br|
:samp:`FOR EACH ROW` |br|
:samp:`[WHEN (search-condition)]` |br|
:samp:`BEGIN` |br|
:samp:`update-statement | insert-statement | delete-statement | select-statement;` |br|
:samp:`[update-statement | insert-statement | delete-statement | select-statement; ...]` |br|
:samp:`END;`

.. image:: create_trigger.svg
    :align: left


The trigger-name must be valid according to the rules for identifiers. |br|
If the trigger action time is BEFORE or AFTER, then the table-name must refer to an existing base table. |br|
If the trigger action time is INSTEAD OF, then the table-name must refer to an existing view

Rules: |br|
There must not already be a trigger with the same name as trigger-name.
Triggers on different tables or views share the same namespace. |br|
The statements between BEGIN and END should not refer to the table-name mentioned in the ON clause. |br|
The statements between BEGIN and END should not contain an INDEXED BY clause. |br|

SQL triggers are not fired upon Tarantool/NoSQL requests.
This will change in version 2.2.
On a replica, effects of trigger execution are applied, and the SQL triggers themselves are not fired upon replication events.
NoSQL triggers are fired both on replica and master, thus if you have a NoSQL trigger on replica,
it is fired when applying effects of an SQL trigger.


Actions: |br|
1 Tarantool will throw an error if a rule is violated. |br|
2 Tarantool will create a new trigger. |br|
3 Tarantool effectively executes a COMMIT statement. |br|

Examples:

.. code-block:: sql

   -- the simple case
   CREATE TRIGGER delete_if_insert BEFORE INSERT ON stores FOR EACH ROW
     BEGIN DELETE FROM warehouses; END;
   -- with IF NOT EXISTS clause
   CREATE TRIGGER IF NOT EXISTS delete_if_insert BEFORE INSERT ON stores FOR EACH ROW
     BEGIN DELETE FROM warehouses; END;
   -- with FOR EACH ROW and WHEN clauses
   CREATE TRIGGER delete_if_insert BEFORE INSERT ON stores FOR EACH ROW WHEN a=5
     BEGIN DELETE FROM warehouses; END;
   -- with multiple statements between BEGIN and END
   CREATE TRIGGER delete_if_insert BEFORE INSERT ON stores FOR EACH ROW
     BEGIN DELETE FROM warehouses; INSERT INTO inventories VALUES (1); END;


See also :ref:`Trigger Extra Clauses <sql_trigger_extra>` and
:ref:`Trigger Activation <sql_trigger_activation>`.

.. _sql_trigger_extra:

**Trigger Extra Clauses**

:samp:`UPDATE OF column-list`

After BEFORE|AFTER UPDATE it is optional to add |br|
OF column-list |br|
If any of the columns in column-list is affected at the time the row is processed, then the trigger will be activated for that row.
For example,

.. code-block:: sql

   CREATE TRIGGER trigger_on_table1
    BEFORE UPDATE  OF column1, column2 ON table1
    FOR EACH ROW
    BEGIN UPDATE table2 SET column1 = column1 + 1; END;
   UPDATE table1 SET column3 = column3 + 1; -- Trigger will not be activated
   UPDATE table1 SET column2 = column2 + 0; -- Trigger will be activated

WHEN

After table-name FOR EACH ROW it is optional to add |br|
[``WHEN expression``] |br|
If the expression is true at the time the row is processed, only then the trigger will be activated for that row.
For example,

.. code-block:: sql

   CREATE TRIGGER trigger_on_table1 BEFORE UPDATE ON table1 FOR EACH ROW
    WHEN (SELECT COUNT(*) FROM table1) > 1
    BEGIN UPDATE table2 SET column1 = column1 + 1; END;

This trigger will not be activated unless there is more than one row in table1.

OLD and NEW

The keywords OLD and NEW have special meaning in the context of trigger action: |br|
OLD.column-name refers to the value of column-name before the change. |br|
NEW.column-name refers to the value of column-name after the change.
For example,

.. code-block:: none   

   CREATE TABLE table1 (column1 VARCHAR(15), column2 INT PRIMARY KEY);
   CREATE TABLE table2 (column1 VARCHAR(15), column2 VARCHAR(15), column3 INT PRIMARY KEY);
   INSERT INTO table1 VALUES ('old value', 1);
   INSERT INTO table2 VALUES ('', '', 1);
   CREATE TRIGGER trigger_on_table1 BEFORE UPDATE ON table1 FOR EACH ROW
    BEGIN UPDATE table2 SET column1 = old.column1, column2 = new.column1; END;
   UPDATE table1 SET column1 = 'new value';
   SELECT * FROM table2;

At the beginning of the UPDATE for the single row of table1, the value in column1 is 'old value' -- so that is what is seen as "old.column1".
At the end of the UPDATE for the single row of table1, the value in column1 is 'new value' -- so that is what is seen as "new.column1".
(OLD and NEW are qualifiers for table1, not table2.)
Therefore, SELECT * FROM table2; returns |br|
``- - ['old value', 'new value']`` |br|
OLD.column-name does not exist for an INSERT trigger. |br|
NEW.column-name does not exist for a DELETE trigger. |br|
OLD and NEW are read-only; you cannot change their values.

Deprecated or illegal statements

It is legal for the trigger action to include a SELECT statement or a REPLACE statement, but not recommended.

It is illegal for the trigger action to include a qualified column reference other than OLD.column-name or NEW.column-name. For example, CREATE TRIGGER ... BEGIN UPDATE table1 SET table1.column1=5; END; is illegal.

It is illegal for the trigger action to include statements that include a WITH clause, a DEFAULT VALUES clause, or an INDEXED BY clause.

It is usually not a good idea to have a trigger on table1 which causes a change on table2, and at the same time have a trigger on table2 which causes a change on table1.
For example,

.. code-block:: none   

   CREATE TRIGGER trigger_on_table1
    BEFORE UPDATE ON table1
    FOR EACH ROW
    BEGIN UPDATE table2 SET column1 = column1 + 1; END;
   CREATE TRIGGER trigger_on_table2
    BEFORE UPDATE ON table2
    FOR EACH ROW
    BEGIN UPDATE table1 SET column1 = column1 + 1; END;

Luckily UPDATE table1 ... will not cause an infinite loop, because Tarantool recognizes when it has already updated so it will stop. However, not every DBMS acts this way.


.. _sql_trigger_activation:

**Trigger Activation**

These are remarks concerning trigger activation.

Standard Terminology: |br|
"trigger action time" = BEFORE or AFTER or INSTEAD OF |br|
"trigger event" = INSERT or DELETE or UPDATE |br|
"triggered statement" = BEGIN ... INSERT|DELETE|UPDATE ... END |br|
"triggered when clause" = WHEN (search condition) |br|
"activate" = execute a triggered statement |br|
Some vendors use the word "fire" instead of "activate".

If there is more than one trigger for the same trigger event, Tarantool may execute the triggers in any order.

It is possible for a triggered statement to cause activation of another triggered statement. For example, this is legal: |br|
``CREATE TRIGGER on_t1 BEFORE DELETE ON t1 BEGIN DELETE FROM t2; END;`` |br|
``CREATE TRIGGER on_t2 BEFORE DELETE ON t2 BEGIN DELETE FROM t3; END;``

Activation occurs FOR EACH ROW, not FOR EACH STATEMENT. Therefore, if no rows are candidates for insert or update or delete, then no triggers are activated.

The BEFORE trigger is activated even if the trigger event fails.

If an UPDATE trigger event does not make a change, the trigger is activated anyway. For example, if row 1 column1 contains 'a', and the trigger event is "UPDATE ... SET column1 = 'a';", the trigger is activated.

The triggered statement may refer to a function |br|
RAISE(FAIL, error-message) |br|
If a triggered statement invokes a RAISE(FAIL, error-message) function, or if a triggered statement causes an error, then statement execution stops immediately.

The triggered statement may refer to column values within the rows being changed. The row "as of before" the change is called the "old" row (which makes sense only for UPDATE and DELETE statements); the row "as of after" the change is called the "new" row (which makes sense only for UPDATE and INSERT statements). This example shows how an INSERT can be done to a view by referring to the "new" row ...

.. code-block:: none   

   CREATE TABLE t (s1 INT PRIMARY KEY, s2 INT);
   CREATE VIEW v AS SELECT s1, s2 FROM t;
   CREATE TRIGGER tv INSTEAD OF INSERT ON v
     FOR EACH ROW
     BEGIN INSERT INTO t VALUES (new.s1, new.s2); END;
   INSERT INTO v VALUES (1,2);

Ordinarily saying ``INSERT INTO view_name ...`` is illegal
in Tarantool, so this is a workaround.

It is possible to generalize this so that all data-change statements
on views will change the base tables, provided that the view contains
all the columns of the base table, and provided that the triggers
refer to those columns when necessary, as in this example:

.. code-block:: none   

   CREATE TABLE base_table (primary_key_column INT PRIMARY KEY, value_column INT);
   CREATE VIEW viewed_table AS SELECT primary_key_column, value_column FROM base_table;
   CREATE TRIGGER viewed_insert INSTEAD OF INSERT ON viewed_table FOR EACH ROW
     BEGIN
       INSERT INTO base_table VALUES (new.primary_key_column, new.value_column);
     END;
   CREATE TRIGGER viewed_update INSTEAD OF UPDATE ON viewed_table FOR EACH ROW
     BEGIN
       UPDATE base_table
       SET primary_key_column = new.primary_key_column, value_column = new.value_column
       WHERE primary_key_column = old.primary_key_column;
     END;
   CREATE TRIGGER viewed_delete INSTEAD OF DELETE ON viewed_table FOR EACH ROW
     BEGIN
       DELETE FROM base_table WHERE primary_key_column = old.primary_key_column;
     END;


When INSERT or UPDATE or DELETE occurs for table X, Tarantool usually operates in this order described by section "Order of Execution in Data-change statements". Ignoring the details there, one can think of the basic scheme like this:

.. code-block:: none   

   For each row
     Perform constraint checks
     For each BEFORE trigger that refers to table X
       Check that the trigger's WHEN condition is true.
       Execute what is in the trigger's BEGIN|END block.
     Insert or update or delete the row in table X.
     Perform more constraint checks
     For each AFTER trigger that refers to table X
       Check that the trigger's WHEN condition is true.
       Execute what is in the trigger's BEGIN|END block.

However, Tarantool does not guarantee execution order when there are multiple constraints, or multiple triggers for the same event (including NoSQL on_replace triggers or SQL INSTEAD OF triggers that affect a view of table X).

The maximum number of trigger activations per statement is 32.

.. _sql_instead_of_triggers:

**INSTEAD OF Triggers**

A trigger which is created with the clause |br|
:samp:`INSTEAD OF {INSERT|UPDATE|DELETE} ON {view-name}` |br|
is an INSTEAD OF trigger. For each affected row, the trigger action is performed "instead of" the INSERT or UPDATE or DELETE statement that causes trigger activation.

For example:
Ordinarily it is illegal to INSERT rows in a view, but it is legal to create a trigger which intercepts attempts to INSERT, and puts rows in the underlying base table:

.. code-block:: none   

   CREATE TABLE t1 (column1 INT PRIMARY KEY, column2 INT);
   CREATE VIEW v1 AS SELECT column1, column2 FROM t1;
   CREATE TRIGGER t1 INSTEAD OF INSERT ON v1 FOR EACH ROW BEGIN
    INSERT INTO t1 VALUES (NEW.column1, NEW.column2); END;
   INSERT INTO v1 VALUES (1, 1);
   -- ... The result will be: table t1 will contain a new row.

INSTEAD OF triggers are only legal for views. |br|
BEFORE or AFTER triggers are not legal for views. |br|
It is legal to create INSTEAD OF triggers with triggered WHEN clauses.

Limitations:

* It is legal to create INSTEAD OF triggers with UPDATE OF column-list clauses, but they are not standard SQL.
  Example:

.. code-block:: none   

   CREATE TRIGGER et1
     INSTEAD OF UPDATE OF column2,column1 ON ev1
     FOR EACH ROW BEGIN
     INSERT INTO et2 VALUES (NEW.column1, NEW.column2); END;

.. _sql_drop_trigger:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
DROP TRIGGER
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

:samp:`DROP TRIGGER [IF EXISTS] {trigger-name};`

.. image:: drop_trigger.svg
    :align: left


Drop a trigger.

The trigger-name must identify a trigger that was created earlier with the CREATE TRIGGER statement.

Rules: |br|
None.

Actions: |br|
1 Tarantool returns an error if the trigger does not exist. |br|
2 The trigger is dropped. |br|
3 Tarantool effectively executes a COMMIT statement.

Examples:

.. code-block:: none

   -- the simple case
   DROP TRIGGER tr;
   -- with an IF EXISTS clause
   DROP TRIGGER IF EXISTS tr;


.. _sql_truncate:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
TRUNCATE
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


:samp:`TRUNCATE TABLE {table-name};`

.. image:: truncate.svg
    :align: left

Remove all rows in the table.

TRUNCATE is considered to be a schema-change rather than a data-change statement, so it does not work within transactions (it cannot be rolled back).

Rules: |br|
It is illegal to truncate a table which is referenced by a foreign key. |br|
It is illegal to truncate a table which is also a system space, such as "_space". |br|
The table must be a base table rather than a view.

Actions: |br|
All rows in the table are removed. Usually this is faster than DELETE FROM table-name;. |br|
If the table has an autoincrement primary key, its sequence is reset to zero. |br|
There is no effect for any triggers associated with the table. |br|
There is no effect on the counts for the row_count() function. |br|
Only one action is written to the write-ahead log (with "``DELETE FROM table-name;``" there would be one action for each deleted row).

Example:

.. code-block:: none

   TRUNCATE TABLE t;
