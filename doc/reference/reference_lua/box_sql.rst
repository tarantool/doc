.. _box-sql:

--------------------------------------------------------------------------------
Functions for SQL
--------------------------------------------------------------------------------

The ``box`` module contains some functions related to SQL:

* ``box.schema.func.create`` -- for making Lua functions callable from
  SQL statements. See :ref:`Calling Lua routines from SQL <sql_calling_lua>`
  in the :ref:`SQL Plus Lua <sql_plus_lua>` section.

* ``box.execute`` -- for making SQL statements callable from Lua functions.
  See the :ref:`SQL user guide <sql_user_guide>`.

* ``box.prepare`` and ``box.unprepare``.

Some SQL statements are illustrated in the :ref:`SQL tutorial <sql_tutorial>`.

Below is a list of all SQL functions and members.

..  container:: table

    ..  rst-class:: left-align-column-1
    ..  rst-class:: left-align-column-2

    ..  list-table::
        :widths: 25 75
        :header-rows: 1

        *   - Name
            - Use

        *  - :doc:`./box_sql/execute`
           - Make Lua functions callable from SQL statements.
             See :ref:`Calling Lua routines from SQL <sql_calling_lua>`
             in the :ref:`SQL Plus Lua <sql_plus_lua>` section

        *  - :doc:`./box_sql/prepare`
           - Make SQL statements callable from Lua functions.
             See the :ref:`SQL user guide <sql_user_guide>`

        *  - :doc:`./box_sql/prepared_table`
           - Methods for prepared SQL statement

.. toctree::
    :hidden:

    box_sql/execute
    box_sql/prepare
    box_sql/prepared_table