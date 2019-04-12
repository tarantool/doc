--------------------------------------------------------------------------------
SQL statements and clauses
--------------------------------------------------------------------------------

.. _sql_alter_table:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
ALTER TABLE
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Syntax:

.. code-block:: none

   ALTER TABLE {table-name} RENAME TO {new-table-name};
   -- OR --
   ALTER TABLE {table-name} ADD CONSTRAINT {constraint-name} {constraint-definition};
   -- OR --
   ALTER TABLE {table-name} DROP CONSTRAINT {constraint-name};

|br|

.. image:: alter_table.svg
    :align: left

|br|

ALTER is used to either change a table's name or to add new constraints.

Examples:

.. code-block:: sql

   -- renaming a table:
   ALTER TABLE t1 RENAME TO t2;

For ``ALTER ... RENAME``, the old-table must exist, the new-table must not exist.

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
  calling call :ref:`space_object:format() <box_space-format>` with a different
  ``is_nullable`` value.

.. _sql_create_table:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
CREATE TABLE
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Syntax:

.. code-block:: none

   CREATE TABLE [IF NOT EXISTS] {table-name} ((column-definition or table-constraint list);

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

The table-name must be an identifier which is valid according to the rules for
identifiers, and must not be the name of an already existing base table or view.

The column-definition or table-constraint list is a comma-separated list
of column definitions or table constraints.

A table-element-list must be a comma-separated list of table elements;
each table element may be either a column definition or a table constraint
definition.

Rules:

* A primary key is necessary; it can be specified with a table constraint
  PRIMARY KEY.
* There must be at least one column.
* If IF NOT EXISTS is specified, and there is already a table with the same
  name, the statement is ignored.

Actions:

#. Tarantool evaluates each column definition and table-constraint,
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

.. code-block:: none

   DROP TABLE [IF EXISTS] {table-name};

|br|

.. image:: drop_table.svg
    :align: left

|br|

Drop a table.

The table-name must identify a table that was created earlier with the
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

.. code-block:: none

   CREATE VIEW [IF NOT EXISTS] {view-name} [(column-list)] AS subquery;

|br|

.. image:: create_view.svg
    :align: left

|br|

Create a new viewed table, usually called a "view".

The view-name must be valid according to the rules for identifiers.

The optional column-list must be a comma-separated list of names of columns
in the view.

The syntax of the subquery must be the same as the syntax of a SELECT statement,
or of a VALUES clause.

Rules:

* There must not already be a base table or view with the same name as
  view-name.
* If column-list is specified, the number of columns in column-list must be
  the same as the number of columns in the select-list of the subquery.

Actions:

#. Tarantool will throw an error if a rule is violated.
#. Tarantool will create a new persistent object with column-names equal to
   the names in the column-list or the names in the subquery's select-list.
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

.. code-block:: none

   DROP VIEW [IF EXISTS] {view-name};

|br|

.. image:: drop_view.svg
    :align: left

|br|

Drop a view.

The view-name must identify a view that was created earlier with the
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
