Major features
==============

Every released version of Tarantool brings some notable features and fixes, which are all listed in
the :doc:`release notes </release/index>`.

To keep track of the major features in each version of the Tarantool easier, you can use the table below.

Later versions inherit features from earlier ones in the same release series.
Note that versions before 2.10.* are numbered according to the :doc:`legacy release policy </release/legacy-policy>`,
while versions 2.10.0-beta1 and later adhere to the :doc:`current release policy </release/policy>`.
Versions that only include bug fixes are not listed in this table.

..  container:: table

    ..  list-table::
        :widths: 20 80
        :header-rows: 1

        *   -   Since version
            -   Feature

        *   -   2.10.5
            -   Introduced the ``_vspace_sequence`` system space view of the ``_space_sequence``
                system space (:tarantool-issue:`7858`). |br|
                The log produced during ``box.cfg{}`` now contains the build target
                triplet (for example, ``Linux-x86_64-RelWithDebInfo``).

        *   -   2.10.4
            -   The JSON log format can now be used with the syslog logger (:tarantool-issue:`7860`).  |br|
                SQL improvements: ``CASE`` (:tarantool-issue:`6990`) and ``NULLIF()`` (:tarantool-issue:`6989`).   |br|
                Diagnostics now provide relative file paths instead of absolute ones (:tarantool-issue:`7808`).

        *   -   2.10.3
            -   RedOS 7.3 is now supported.  |br|
                Added the ``-DENABLE_HARDENING=ON/OFF`` CMake option that enables
                hardening against memory corruption attacks (:tarantool-issue:`7536`).

        *   -   2.10.2
            -   Internal fibers cannot be cancelled from the Lua public API anymore (:tarantool-issue:`7473`)

        *   -   2.10.1
            -   Interactive transactions are now possible in remote binary consoles (:tarantool-issue:`7413`) |br|
                Improved string representation of datetime intervals (:tarantool-issue:`7045`)

        *   -   2.10.0
            -   Transaction isolation levels in Lua and IPROTO (:tarantool-issue:`6930`) |br|
                Fencing and pre-voting in RAFT (:tarantool-issue:`6661`) |br|
                :ref:`Foreign keys <index-box_foreign_keys>` and :ref:`constraints <index-constraints>` support (:tarantool-issue:`6436`) |br|
                :ref:`New DATETIME type <2.10.0-datetime>` |br|
                HTTP/2 support for the HTTP client |br|
                Preliminary support for GNU/Linux ARM64 and MacOS M1 (:tarantool-issue:`2712`, :tarantool-issue:`6065`,
                :tarantool-issue:`6066`, :tarantool-issue:`6084`, :tarantool-issue:`6093`, :tarantool-issue:`6098`,
                :tarantool-issue:`6189`) |br|
                :ref:`Streams and interactive transactions in iproto <txn_mode_stream-interactive-transactions>`
                (:tarantool-issue:`5860`) |br|
                :ref:`Consistent SQL type system <2.10.0-sql>` |br|
                Faster `net.box` module performance (improved up to 70%) (:tarantool-issue:`6241`) |br|
                Compact mode for tuples (:tarantool-issue:`5385`) |br|
                `memtx_allocator` option in `box.cfg{}` (:tarantool-issue:`5419`)

        *   -   2.8.2
            -   Symbolic log levels in the `log` module (:tarantool-issue:`5882`)

        *   -   2.7.3, 1.10.11
            -   `LJ_DUALNUM` mode support in `luajit-gdb` (:tarantool-issue:`6224`)

        *   -   2.7.3
            -   New `table.equals` method in Lua |br|
                `box.info.synchro` interface for synchronous replication statistics (:tarantool-issue:`5191`)

        *   -   2.8.1
            -   :ref:`Multiple iproto threads <cfg_networking-iproto_threads>` (:tarantool-issue:`5645`) |br|
                Set :doc:`box.cfg </reference/reference_lua/box_cfg>` options with environment variables (:tarantool-issue:`5602`) |br|
                Friendly :ref:`LuaJIT memory profiler report <profiler_analysis>` (:tarantool-issue:`5811`) |br|
                ``--leak-only`` LuaJIT memory profiler option (:tarantool-issue:`5812`)

        *   -   2.7.1
            -   :ref:`LuaJIT memory profiler <luajit_memprof>` (:tarantool-issue:`5442`) |br|
                SQL :doc:`ALTER TABLE ADD COLUMN </reference/reference_sql/sql_statements_and_clauses>` statement support for empty tables (:tarantool-issue:`2349`, :tarantool-issue:`3075`)

        *   -   2.6.3, 2.7.2
            -   The concept of WAL queue (:tarantool-issue:`5536`)

        *   -   2.6.3, 2.7.2, 2.8.1
            -   :doc:`box.ctl.promote() </reference/reference_lua/box_ctl/promote>` and the concept of manual elections (:tarantool-issue:`3055`)

        *   -   2.6.1
            -   :ref:`LuaJIT platform metrics <metrics-reference-luajit>` (:tarantool-issue:`5187`) |br|
                :ref:`Automated leader election <repl_leader_elect>` based on Raft algorithm (:tarantool-issue:`1146`) |br|
                :ref:`Transactional manager <txn_mode_transaction-manager>` for memtx engine (:tarantool-issue:`4897`)

        *   -   2.5.3, 2.6.2, 2.7.1
            -   Expression evaluation for :ref:`replication_synchro_quorum <cfg_replication-replication_synchro_quorum>` (:tarantool-issue:`5446`)

        *   -   2.5.3, 2.6.2
            -   :doc:`box.ctl.is_recovery_finished() </reference/reference_lua/box_ctl/is_recovery_finished>` for memtx engine (:tarantool-issue:`5187`)

        *   -   2.5.1
            -   :ref:`Synchronous replication <repl_sync>` (beta) (:tarantool-issue:`4842`) |br|
                Allow an :doc:`anonymous replica </reference/reference_lua/box_info/replication_anon>` to follow another anonymous replica (:tarantool-issue:`4696`)

        *   -   2.4.1
            -   :ref:`UUID type for field and index <index-box_uuid>` (:tarantool-issue:`4268`, :tarantool-issue:`2916`) |br|
                :doc:`popen </reference/reference_lua/popen>` built-in module (:tarantool-issue:`4031`) |br|
                Ability to create :doc:`custom error types </reference/reference_lua/box_error/custom_type>` (:tarantool-issue:`4398`) |br|
                :doc:`Transparent marshalling </reference/reference_lua/box_error/new>` through ``net.box`` (:tarantool-issue:`4398`) |br|
                :doc:`Stacked diagnostic area </reference/reference_lua/box_error/error_object>` (:tarantool-issue:`1148`) |br|

        *   -   2.3.1
            -   :doc:`Field name and JSON path updates </reference/reference_lua/json_paths>` (:tarantool-issue:`1261`) |br|
                :ref:`Anonymous replica <cfg_replication-replication_anon>` type (:tarantool-issue:`3186`) |br|
                :doc:`DOUBLE </reference/reference_sql/sql_user_guide>` type in SQL (:tarantool-issue:`3812`) |br|
                Support for :ref:`decimals <index-box_data-types>` in spaces, ``decimal`` field type (:tarantool-issue:`4333`) |br|
                :ref:`fiber.top() <fiber-top>` function in Lua (:tarantool-issue:`2694`) |br|
                Feed data from memory during replica initial join (:tarantool-issue:`1271`) |br|
                SQL prepared statements support and cache (:tarantool-issue:`2592`, :tarantool-issue:`3292`) |br|
                :doc:`_session_settings </reference/reference_lua/box_space/_session_settings>` service space (:tarantool-issue:`4511`)



