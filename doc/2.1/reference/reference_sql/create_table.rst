.. _sql_create_table:

===============================================================================
CREATE TABLE statement
===============================================================================

:samp:`CREATE TABLE [IF NOT EXISTS] {table-name} ((column-definition or table-constraint list);`

.. image:: create_table.svg
    :align: left

Create a new base table, usually called a "table".
(A table is a base table if is created with CREATE TABLE and contains data in persistent storage; a table is a viewed table, or just "view", if it is created with CREATE VIEW and gets its data from other views or from base tables.)

The table-name must be an identifier which is valid according to the rules for identifiers, and must not be the name of an already existing base table or view.

The column-definition or table-constraint list is a comma-separated list
of column definitions or table constraints.

A table-element-list must be a comma-separated list of table elements; each table element may be either a column definition or a table constraint definition.


Rules: |br|
A primary key is necessary; it can be specified with a table constraint PRIMARY KEY ...
There must be at least one column.


If IF NOT EXISTS is specified, and there is already a table with the same name, the statement is ignored.

Actions: |br|
1 Tarantool evaluates each column definition and table-constraint,
and returns an error if any of the rules is violated. |br|
2 Tarantool makes a new definition in the schema. |br|
3 Tarantool makes new indexes for PRIMARY KEY or UNIQUE constraints. A unique Index name is created automatically. |br|
4 Tarantool effectively executes a COMMIT statement.

Examples:

.. code-block:: sql

   -- the simplest form, with one column and one constraint
   CREATE TABLE t1 (s1 INTEGER, PRIMARY KEY (s1));

   -- You can see the effect of the statement by querying Tarantool system spaces:
   SELECT * FROM "_space" WHERE "name" = 'T1';
   SELECT * FROM "_index" JOIN "_space" ON "_index"."id" = "_space"."id" WHERE "_space"."name" = 'T1';

   -- variation of the simplest form, with delimited identifiers and an inline comment
   CREATE TABLE "t1" ("s1" INT /* synonym of INTEGER */, PRIMARY KEY ("s1"));

   -- two columns, one named constraint
   CREATE TABLE t1 (s1 INTEGER, s2 TEXT, CONSTRAINT c1 PRIMARY KEY (s1, s2));

Limitations:

* The maximum number of columns is 2000.
* The maximum length of a row depends on the
  :ref:`memtx_max_tuple_size <cfg_storage-memtx_max_tuple_size>` or
  :ref:`vinyl_max_tuple_size  <cfg_storage-memtx_max_tuple_size>` configuration option.
