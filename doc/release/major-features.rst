Major features
==============

Every released version of Tarantool brings some notable features and fixes, which are all listed in
:doc:`the release notes </release>`.
To keep track of the major features in each version of the Tarantool easier, you can use the table below.

..  container:: table

    ..  rst-class:: left-align-column-1
    ..  rst-class:: left-align-column-2

    ..  list-table::
        :widths: 20 80
        :header-rows: 1

        *   -   Since version
            -   Feature

        *   -   2.10.0-beta2
            -   HTTP/2 support for the HTTP client

        *   -   2.10.0-beta2
            -   Preliminary support for the new DATETIME type (:tarantool-issue:`5941`)

        *   -   2.10.0-beta1
            -   Preliminary support for GNU/Linux ARM64 and MacOS M1 (:tarantool-issue:`2712`, :tarantool-issue:`6065`,
                :tarantool-issue:`6066`, :tarantool-issue:`6084`, :tarantool-issue:`6093`, :tarantool-issue:`6098`,
                :tarantool-issue:`6189`)

        *   -   2.10.0-beta1
            -   :ref:`Streams and interactive transactions in binary protocol <cfg_networking-iproto_threads>`
                (:tarantool-issue:`5860`)

        *   -   2.10.0-beta1
            -   Consistent SQL type system

        *   -   2.10.0-beta1
            -   Faster net.box performance (improved up to 70%) (:tarantool-issue:`6241`)

        *   -   2.10.0-beta1
            -   Compact tuples in case of small userdata (:tarantool-issue:`5385`)

        *   -   2.8.1
            -   :ref:`Multiple iproto threads <box_stream>` (:tarantool-issue:`5645`)

        *   -   2.8.1
            -   Set :doc:`box.cfg </reference/reference_lua/box_cfg>` options with environment variables (:tarantool-issue:`5602`)

        *   -   2.8.1
            -   Friendly :ref:`LuaJIT memory profiler report <profiler_analysis>` (:tarantool-issue:`5811`)

        *   -   2.8.1
            -   ``--leak-only`` LuaJIT memory profiler option (:tarantool-issue:`5812`)

        *   -   2.7.1
            -   :doc:`LuaJIT memory profiler </book/app_server/luajit_memprof>` (:tarantool-issue:`5442`)

        *   -   2.7.1
            -   SQL :doc:`ALTER TABLE ADD COLUMN </reference/reference_sql/sql_statements_and_clauses>` statement support for empty tables (:tarantool-issue:`2349`, :tarantool-issue:`3075`)

        *   -   2.6.3, 2.7.2
            -   The concept of WAL queue (:tarantool-issue:`5536`)

        *   -   2.6.3, 2.7.2, 2.8.1
            -   :doc:`box.ctl.promote() </reference/reference_lua/box_ctl/promote>` and the concept of manual elections (:tarantool-issue:`3055`)

        *   -   2.6.1
            -   :ref:`LuaJIT platform metrics <metrics-luajit>` (:tarantool-issue:`5187`)

        *   -   2.6.1
            -   :doc:`Automated leader election </book/replication/repl_leader_elect>` based on Raft algorithm (:tarantool-issue:`1146`)

        *   -   2.6.1
            -   :ref:`Transactional manager <atomic-transactional-manager>` for memtx engine (:tarantool-issue:`4897`)

        *   -   2.5.3, 2.6.2, 2.7.1
            -   Expression evaluation for :ref:`replication_synchro_quorum <cfg_replication-replication_synchro_quorum>` (:tarantool-issue:`5446`)

        *   -   2.5.3, 2.6.2
            -   :doc:`box.ctl.is_recovery_finished() </reference/reference_lua/box_ctl/is_recovery_finished>` for memtx engine (:tarantool-issue:`5187`)

        *   -   2.5.1
            -   :doc:`Synchronous replication </book/replication/repl_sync>` (beta) (:tarantool-issue:`4842`)

        *   -   2.5.1
            -   Allow an :doc:`anonymous replica </reference/reference_lua/box_info/replication_anon>` to follow another anonymous replica (:tarantool-issue:`4696`)

        *   -   2.4.1
            -   :ref:`UUID type for field and index <index-box_uuid>` (:tarantool-issue:`4268`, :tarantool-issue:`2916`)

        *   -   2.4.1
            -   :doc:`popen </reference/reference_lua/popen>` built-in module (:tarantool-issue:`4031`)

        *   -   2.4.1
            -   Ability to create :doc:`custom error types </reference/reference_lua/box_error/custom_type>` (:tarantool-issue:`4398`)

        *   -   2.4.1
            -   :doc:`Transparent marshalling </reference/reference_lua/box_error/new>` through ``net.box`` (:tarantool-issue:`4398`)

        *   -   2.4.1
            -   :doc:`Stacked diagnostic area </reference/reference_lua/box_error/error_object>` (:tarantool-issue:`1148`)

        *   -   2.3.1
            -   :doc:`Field name and JSON path updates </reference/reference_lua/json_paths>` (:tarantool-issue:`1261`)

        *   -   2.3.1
            -   :ref:`Anonymous replica <cfg_replication-replication_anon>` type (:tarantool-issue:`3186`)

        *   -   2.3.1
            -   :doc:`DOUBLE </reference/reference_sql/sql_user_guide>` type in SQL (:tarantool-issue:`3812`)

        *   -   2.3.1
            -   Support of :ref:`decimals <index-box_data-types>` in spaces, ``decimal`` field type (:tarantool-issue:`4333`)

        *   -   2.3.1
            -   :ref:`fiber.top() <fiber-top>` function in Lua (:tarantool-issue:`2694`)

        *   -   2.3.1
            -   Feed data from memory during replica initial join (:tarantool-issue:`1271`)

        *   -   2.3.1
            -   SQL prepared statements support and cache (:tarantool-issue:`2592`, :tarantool-issue:`3292`)

        *   -   2.3.1
            -   :doc:`_session_settings </reference/reference_lua/box_space/_session_settings>` service space (:tarantool-issue:`4511`)



