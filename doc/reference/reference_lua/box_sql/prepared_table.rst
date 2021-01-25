
===============================================================================
object prepared_table
===============================================================================

..  class:: prepared_table

    .. _box-sql_box_execute_prepared_statement:

    .. method:: execute([extra-parameters])

        Execute a statement that has been prepared with
        :doc:`/reference/reference_lua/box_sql/prepare`.

        Parameter ``prepared_table`` should be the result from ``box.prepare()``.

        Parameter ``extra-parameters`` should be an optional table to match
        :ref:`placeholders or named parameters <box-sql_extra_parameters>` in
        the statement.

        There are two ways to execute: with the method or with the statement id.
        That is, :samp:`{prepared_table}:execute()` and
        :samp:`box.execute({prepared_table}.stmt_id)` do the same thing.

        Example: here is a test. This function inserts a million rows in a table
        using a prepared INSERT statement.

        .. code-block:: Lua

            function f()
              local p, start_time
              box.execute([[DROP TABLE IF EXISTS t;]])
              box.execute([[CREATE TABLE t (s1 INTEGER PRIMARY KEY);]])
              start_time = os.time()
              p = box.prepare([[INSERT INTO t VALUES (?);]])
              for i=1,1000000 do p:execute({i}) end
              p:unprepare()
              end_time = os.time()
              box.execute([[COMMIT;]])
              print(end_time - start_time) -- elapsed time
            end
            f()

        Take note of the elapsed time. Now change the line with the loop to: |br|
        ``for i=1,1000000 do box.execute([[INSERT INTO t VALUES (?);]], {i}) end`` |br|
        Run the function again, and take note of the elapsed time again.
        The function which executes the prepared statement will be about 15% faster,
        though of course this will vary depending on Tarantool version and
        environment.

    .. _box-sql_box_unprepare_prepared_statement:

    .. method:: unprepare()

        Undo the result of an earlier :doc:`/reference/reference_lua/box_sql/prepare`
        request. This is equivalent to standard-SQL DEALLOCATE PREPARE.

        Parameter ``prepared_table`` should be the result from ``box.prepare()``.

        There are two ways to unprepare: with the method or with the statement id.
        That is, :samp:`{prepared_table}:unprepare()` and
        :samp:`box.unprepare({prepared_table}.stmt_id)` do the same thing.

        Tarantool strongly recommends using ``unprepare`` as soon as the immediate
        objective (executing a prepared statement multiple times) is done, or
        whenever a prepared statement expires.
        There is no automatic eviction policy, although automatic ``unprepare``
        will happen when the session disconnects (the session's prepared
        statements will be removed from the prepared-statement cache).
