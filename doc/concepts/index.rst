:fullwidth:

.. _concepts:

Concepts
========

Data model
----------

Tarantool is a NoSQL database. It stores data in :ref:`spaces <index-box_space>`,
which can be thought of as tables in a relational database, and :ref:`tuples <index-box_tuple>`,
which are analogous to rows. There are six basic :ref:`data operations <index-box_operations>` in Tarantool.

The platform allows :ref:`describing the data schema <index-box-data_schema_description>` but does not require it.

Tarantool supports highly customizable :ref:`indexes <index-box_index>` of various types.

To ensure :ref:`data persistence <index-box_persistence>` and recover quickly in case of failure,
Tarantool uses mechanisms like the write-ahead log (WAL) and snapshots.

For details, check the :ref:`Data model <box_data_model>` page.

Fibers and cooperative multitasking
-----------------------------------

Tarantool executes code in :ref:`fibers <concepts-coop_multitasking>` that are managed via
:ref:`cooperative multitasking <concepts-coop_multitasking>`.
Learn more about Tarantool's :ref:`thread model <thread_model>`.

For details, check the page :ref:`Fibers, yields, and cooperative multitasking <concepts-coop_multitasking>`.

Transactions
------------

Tarantool's ACID-compliant :ref:`transaction model <atomic-atomic_execution>` lets the user choose
between two modes of transactions.

The :ref:`default mode <txn_mode-default>` allows for fast monopolistic atomic transactions.
It doesn't support interactive transactions, and in case of an error, all transaction changes are rolled back.

The :ref:`MVCC mode <txn_mode_transaction-manager>` relies on a multi-version concurrency control engine
that allows yielding within a longer transaction.
This mode only works with the default in-memory :ref:`memtx <engines-chapter>` storage engine.

For details, check the :ref:`Transactions <atomic-atomic_execution>` page.

..  _concepts-application_server:

Application server
------------------

Using Tarantool as an application server, you can write
applications in Lua, C, or C++. You can also create reusable :ref:`modules <concepts-modules>`.

To increase the speed of code execution, Tarantool has a Lua Just-In-Time compiler (LuaJIT) on board.
LuaJIT compiles hot paths in the code -- paths that are used many times --
thus making the application work faster. 
To enable developers to work with LuaJIT, Tarantool provides tools like the :ref:`memory profiler <luajit_memprof>`
and the :ref:`getmetrics <luajit_getmetrics>` module.

For details on Tarantool's modular structure, check the :ref:`Modules <concepts-modules>` page.

To learn how to use Tarantool as an application server, refer to the :ref:`guides <how-to-app-server>` in the How-to section.

Sharding
--------

Tarantool implements database sharding via the ``vshard`` module.
For details, go to the :ref:`Sharding <sharding>` page.

Triggers
--------

Tarantool allows specifying callback functions that run upon certain database events.
They can be useful for resolving replication conflicts.
For details, go to the :ref:`Triggers <triggers>` page.

Replication
-----------

Replication allows keeping the data in copies of the same database for better reliability.

Several Tarantool instances can be organized in a replica set.
They communicate and transfer data via the :ref:`iproto <box_protocol-iproto_protocol>` binary protocol.
Learn more about Tarantool's :ref:`replication architecture <replication-architecture>`.

By default, replication in Tarantool is asynchronous.
A transaction committed locally on the master node
may not get replicated onto other instances before the client receives a success response.
Thus, if the master reports success and then dies, the client might not see the result of the transaction.

With :ref:`synchronous replication <repl_sync>`, transactions on the master node are not considered committed
or successful before they are replicated onto a number of instances. This is slower, but more reliable.
Synchronous replication in Tarantool is based on an :ref:`implementation of the RAFT algorithm <repl_leader_elect>`.

For details, check the :ref:`Replication <replication>` section.

Storage engines
---------------

A storage engine is a set of low-level routines that store and
retrieve values. Tarantool offers a choice of two storage engines:

*   :ref:`memtx <engines-memtx>` is the in-memory storage engine used by default.
*   :ref:`vinyl <engines-vinyl>` is the on-disk storage engine.

For details, check the :ref:`Storage engines <engines-chapter>` section.


..  toctree::
    :hidden:

    data_model/index
    coop_multitasking
    atomic
    modules      
    sharding/index
    replication/index  
    triggers
    engines/index
