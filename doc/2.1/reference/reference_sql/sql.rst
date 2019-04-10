REFERENCE GUIDE

The Reference Guide contains descriptions of all the SQL statements and major clauses.

--------------------------------------------------------------------------------
ALTER TABLE Statement
--------------------------------------------------------------------------------

:samp:`ALTER TABLE {table-name} RENAME TO {new-table-name};`|br|
or |br|
:samp:`ALTER TABLE {table-name} ADD CONSTRAINT {constraint-name} {constraint-definition};` |br|
or |br|
:samp:`ALTER TABLE {table-name} DROP CONSTRAINT {constraint-name};`

ALTER is used to either change a table's name or to add new constraints.

.. image:: alter_table.svg
    :align: center

For ``ALTER ... RENAME``, the old-table must exist, the new-table must not exist. An example is:|br|
:code:`ALTER TABLE t1 RENAME TO t2;`

For ``ALTER ... ADD CONSTRAINT``, the table must exist, the constraint type must be foreign-key or PRIMARY or UNIQUE (not CHECK), the constraint name must not already exist for the table.

An example of adding a foreign-key constraint definition is: |br|
:code:`ALTER TABLE t1 ADD CONSTRAINT c FOREIGN KEY (s1) REFERENCES t1;` |br|
See "Constraint Definition for foreign keys" foreign-constraint-definition.
It is not possible to say "``CREATE TABLE table_a ... REFERENCES table_b ...```" if table b does not exist yet. This is a situation where ``ALTER TABLE`` is handy -- users can "``CREATE TABLE table_a``" without the foreign key, then "``CREATE TABLE table_b``", then "``ALTER TABLE table_a ... REFERENCES table_b ...``".
This is only legal if the table is empty.

An example of adding a primary-key constraint definition is: |br|
:code:`ALTER TABLE t1 ADD CONSTRAINT primary_key PRIMARY KEY (s1);` |br|
This is unusual because primary keys are created automatically and it is illegal to have two primary keys for the same table. However, it is possible to drop a primary-key index, and this is a way to restore the primary key if that happens.

An example of adding a unique-constraint definition is: |br|
:code:`ALTER TABLE t1 ADD CONSTRAINT unique_key UNIQUE (s1);` |br|
Alternatively, users can say ``CREATE UNIQUE INDEX unique_key ON t1 (s1);``

An example of dropping a constraint is: |br|
:code:`ALTER TABLE t1 DROP CONSTRAINT c;` |br|
It is only legal to drop a named constraint, and only foreign-key constraints can have names.
(Tarantool generates the constraint names automatically if the user does not provide them.)
To remove a unique constraint, use DROP INDEX, which will drop the constraint as well.

Limitations; (`Issue #2349 <https://github.com/tarantool/tarantool/issues/2349>`_) |br|
It is not possible to add or drop a column. |br|
It is not possible to modify NOT NULL constraints or column properties DEFAULT and data type. 
However, it is possible to modify them with Tarantool/NOSQL,
for example by calling call :ref:`space_object:format() <box_space-format>` with a different ``is_nullable`` value.

