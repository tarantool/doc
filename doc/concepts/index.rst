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


Sharding
--------

Tarantool implements database sharding via the ``vshard`` module.
:ref:`Learn more <sharding>`.


Triggers
--------

Tarantool allows specifying callback functions that run upon certain database events.
They can be useful for resolving replication conflicts.
:ref:`Learn more <triggers>`.


Application server
------------------

Using Tarantool as an application server, you can write
applications in Lua, C, or C++. You can also create reusable :ref:`modules <concepts-modules>`.

A convenient way to serve a clustered application on Tarantool is using :ref:`Tarantool Cartridge <tarantool-cartridge>` --
a framework for developing, deploying, and managing applications.

To increase the speed of code execution, Tarantool has a Lua Just-In-Time compiler (LuaJIT) on board.
LuaJIT compiles hot paths in the code -- paths that are used many times --
thus making the application work faster. 
To enable developers to work with LuaJIT, Tarantool provides tools like the :ref:`memory profiler <luajit_memprof>`
and the :ref:`getmetrics <luajit_getmetrics>` module.


Fibers and cooperative multitasking
-----------------------------------

Tarantool executes code in :ref:`fibers <concepts-coop_multitasking>` that are managed via
:ref:`cooperative multitasking <concepts-coop_multitasking>`.
Learn more about Tarantool's :ref:`thread model <thread_model>`.


Transactions
------------

Tarantool's ACID :ref:`transaction model <atomic-atomic_execution>` lets the user choose
between two modes of transactions.

The :ref:`default mode <txn_mode-default>` allows for fast monopolistic atomic transactions.
It doesn't support interactive transactions, and in case of an error, all transaction changes are rolled back.

The :ref:`MVCC mode <txn_mode_transaction-manager>` involves a multi-version concurrency control engine
that allows yielding within a longer transaction.
This mode only works with the in-memory :ref:`memtx <engines-chapter>` storage engine.


Storage engines
---------------

A storage engine is a set of low-level routines that store and
retrieve values. Tarantool offers a choice of two storage engines:

*   :ref:`memtx <engines-memtx>` is the in-memory storage engine used by default.
*   :ref:`vinyl <engines-vinyl>` is the on-disk storage engine.


..  toctree::
    :hidden:

    data_model/index
    sharding/index
    coop_multitasking
    atomic
    modules
    Tarantool Cartridge <https://tarantool.io/doc/latest/book/cartridge>
    triggers
    engines/index

    .. replication

- Replication — сюда скопировать часть из Cluster on Cartridge, сам раздел про карж пока не трогаем
- Binary protocol ([https://www.tarantool.io/en/doc/latest/dev_guide/internals/box_protocol/](https://www.tarantool.io/en/doc/latest/dev_guide/internals/box_protocol/)) — не забыть про переводы
  Tarantool instances communicate with each other using IProto -- a binary protocol. - в отрывок про репликацию
