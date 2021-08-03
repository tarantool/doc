Changelog
=========

Every released version of Tarantool brings some features and fixes, which are all listed in the release notes.
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
            -   Set box.cfg options with environment variables (:tarantool-issue:`5602`)

        *   -   2.8
            -   ``box.ctl.promote()`` and the concept of manual elections (:tarantool-issue:`3055`)

        *   -   2.8
            -   Friendly LuaJIT memory profiler report (:tarantool-issue:`5811`)

        *   -   2.8
            -   ``--leak-only`` LuaJIT memory profiler option (:tarantool-issue:`5812`)

        *   -   2.7
            -   LuaJIT memory profiler (:tarantool-issue:`5442`)

        *   -   2.7
            -   Expression evaluation for ``replication_synchro_quorum`` (:tarantool-issue:`5446`)

        *   -   2.7
            -   ``ALTER TABLE ADD COLUMN`` statement support for empty tables (:tarantool-issue:`2349`, :tarantool-issue:`3075`)

        *   -   2.6
            -   LuaJIT platform metrics (:tarantool-issue:`5187`)

        *   -   2.6
            -   Automated leader election based on Raft algorithm (:tarantool-issue:`1146`)

        *   -   2.6
            -   Transactional manager for memtx engine (:tarantool-issue:`4897`)

        *   -   2.5
            -   Synchronous replication (beta) (:tarantool-issue:`4842`)

        *   -   2.5
            -   Allow an anonymous replica to follow another anonymous replica (:tarantool-issue:`4696`)

        *   -   2.5
            -
