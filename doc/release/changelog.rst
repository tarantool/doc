Changelog
=========

Every released version of Tarantool brings some features and fixes, which are all listed in
:doc:`the release notes </release>`.
To keep track of the most notable features in each version of the Tarantool easier, you can use the table below.

..  container:: table

    ..  rst-class:: left-align-column-1
    ..  rst-class:: left-align-column-2

    ..  list-table::
        :header-rows: 1

        *   -   Since version
            -   Feature

        *   -   2.8
            -   Multiple iproto threads (:tarantool-issue:`5645`)

        *   -   2.8
            -   Set ``box.cfg`` options with environment variables (:tarantool-issue:`5602`)

        *   -   2.8
            -   ``box.ctl.promote()`` and the concept of manual elections (:tarantool-issue:`3055`)

        *   -   2.8
            -   Friendly LuaJIT memory profiler report (:tarantool-issue:`5811`)

        *   -   2.8
            -   ``--leak-only`` LuaJIT memory profiler option (:tarantool-issue:`5812`)

        *   -   2.7
            -   The concept of WAL queue (:tarantool-issue:`5536`)

        *   -   2.7
            -   ``box.ctl.promote()`` and the concept of manual elections (:tarantool-issue:`3055`)

        *   -   2.7
            -   :doc:`LuaJIT memory profiler </book/app_server/luajit_memprof>` (:tarantool-issue:`5442`)

        *   -   2.7
            -   Expression evaluation for ``replication_synchro_quorum`` (:tarantool-issue:`5446`)

        *   -   2.7
            -   SQL :doc:`ALTER TABLE ADD COLUMN </reference/reference_sql/sql_statements_and_clauses>` statement support for empty tables (:tarantool-issue:`2349`, :tarantool-issue:`3075`)

        *   -   2.6
            -   The concept of WAL queue (:tarantool-issue:`5536`)

        *   -   2.6
            -   ``box.ctl.promote()`` and the concept of manual elections (:tarantool-issue:`3055`)

        *   -   2.6
            -   Expression evaluation for ``replication_synchro_quorum`` (:tarantool-issue:`5446`)

        *   -   2.6
            -   :doc:`box.ctl.is_recovery_finished() </reference/reference_lua/box_ctl/is_recovery_finished>` function for memtx engine (:tarantool-issue:`5187`)

        *   -   2.6
            -   LuaJIT platform metrics (:tarantool-issue:`5187`)

        *   -   2.6
            -   :doc:`Automated leader election </book/replication/repl_leader_elect>` based on Raft algorithm (:tarantool-issue:`1146`)

        *   -   2.6
            -   Transactional manager for memtx engine (:tarantool-issue:`4897`)

        *   -   2.5
            -   Expression evaluation for ``replication_synchro_quorum`` (:tarantool-issue:`5446`)

        *   -   2.5
            -   :doc:`box.ctl.is_recovery_finished() </reference/reference_lua/box_ctl/is_recovery_finished>` for memtx engine (:tarantool-issue:`5187`)

        *   -   2.5
            -   Synchronous replication (beta) (:tarantool-issue:`4842`)

        *   -   2.5
            -   Allow an anonymous replica to follow another anonymous replica (:tarantool-issue:`4696`)

        *   -   2.4
            -   UUID type for field and index (:tarantool-issue:`4268`, :tarantool-issue:`2916`)

        *   -   2.4
            -   :doc:`popen </reference/reference_lua/popen>` built-in module (:tarantool-issue:`4031`)

        *   -   2.4
            -   Ability to create custom error types (:tarantool-issue:`4398`)

        *   -   2.4
            -   Transparent marshalling through ``net.box`` (:tarantool-issue:`4398`)

        *   -   2.4
            -   Stacked diagnostic area (:tarantool-issue:`1148`)

        *   -   2.3
            -   Field name and JSON path updates (:tarantool-issue:`1261`)

        *   -   2.3
            -   Anonymous replica type (:tarantool-issue:`3186`)

        *   -   2.3
            -   :doc:`DOUBLE type </reference/reference_sql/sql_user_guide>` in SQL (:tarantool-issue:`3812`)

        *   -   2.3
            -   Support of decimals in spaces, ``decimal`` field type (:tarantool-issue:`4333`)

        *   -   2.3
            -   :ref:`fiber.top() <fiber-top>` function in Lua (:tarantool-issue:`2694`)

        *   -   2.3
            -   Feed data from memory during replica initial join (:tarantool-issue:`1271`)

        *   -   2.3
            -   SQL prepared statements support and cache (:tarantool-issue:`2592`, :tarantool-issue:`3292`)

        *   -   2.3
            -   ``_session_setting`` service space (:tarantool-issue:`4511`)



