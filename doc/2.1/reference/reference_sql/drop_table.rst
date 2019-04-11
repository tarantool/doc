.. _sql_drop_table:

===============================================================================
DROP TABLE statement
===============================================================================

:samp:`DROP TABLE [IF EXISTS] {table-name};`

.. image:: drop_table.svg
    :align: left

Drop a table.

The table-name must identify a table that was created earlier with the :ref:`CREATE TABLE statement <sql_create_table>`.

Rules: |br|
If there is a view that references the table, the drop will fail. Please drop the referencing view with DROP VIEW first. |br|
If there is a foreign key that references the table, the drop will fail. Please drop the referencing constraint with ALTER TABLE DROP FOREIGN KEY first.

Actions: |br|
1 Tarantool returns an error if the table does not exist. |br|
2 The table and all its data are dropped. |br|
3 All indexes for the table are dropped. |br|
4 All triggers for the table are dropped. |br|
5 Tarantool effectively executes a COMMIT statement.

Examples:

.. code-block:: sql

   -- the simple case
   DROP TABLE t31;
   -- with an IF EXISTS clause
   DROP TABLE IF EXISTS t31;

See also: DROP VIEW
