.. _concepts:

Concepts
========

This chapter considers the basic concepts of Tarantool.

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

..  toctree::
    :hidden:

    data_model/index


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

..  toctree::
    :hidden:

    modules
    Tarantool Cartridge <https://tarantool.io/doc/latest/book/cartridge>
    Tooling <https://tarantool.io/doc/latest/reference/tooling>


Fibers and cooperative multitasking
-----------------------------------

Tarantool executes code in :ref:`fibers <concepts-coop_multitasking>` that are managed via
:ref:`cooperative multitasking <concepts-coop_multitasking>`.
Learn more about Tarantool's :ref:`thread model <thread_model>`.

..  toctree::
    :hidden:

    coop_multitasking

..  toctree::
    :hidden:

    .. transactions
    .. sharding
    .. replication
    .. storage_engines

- Transactions (перемещаем весь раздел)
- Sharding
- Replication — сюда скопировать часть из Cluster on Cartridge, сам раздел про карж пока не трогаем
- Binary protocol ([https://www.tarantool.io/en/doc/latest/dev_guide/internals/box_protocol/](https://www.tarantool.io/en/doc/latest/dev_guide/internals/box_protocol/)) — не забыть про переводы
  Tarantool instances communicate with each other using IProto -- a binary protocol.
- Storage engines (перемещаем весь раздел и переводы тоже)
