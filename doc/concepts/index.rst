.. _concepts:

Concepts
========

This chapter considers the basic concepts of Tarantool.

(Here is some introductory text linking to all the sections)

Application server
------------------

Using Tarantool as an application server, you can write
applications in Lua, C, or C++. You can also create reusable :ref:`modules <concepts-modules>`.

Tarantool executes codes in :ref:`fibers <concepts-coop_multitasking>` that are managed via
:ref:`cooperative multitasking <concepts-coop_multitasking>`.

To increase the speed of code execution, Tarantool has a Lua Just-In-Time compiler (LuaJIT) on board.
LuaJIT compiles hot paths in the code -- paths that are used many times --
thus making the application work faster. 
To enable developers to work with LuaJIT, Tarantool provides tools like the :ref:`memory profiler <luajit_memprof>`
and the :ref:`getmetrics <luajit_getmetrics>` module.

..  toctree::
    :hidden:

    modules
    coop_multitasking


- Data model (включая Indexes)

Data persistence
Quick recovery in case of failure

- Transactions (перемещаем весь раздел)
- Sharding
- Replication — сюда скопировать часть из Cluster on Cartridge, сам раздел про карж пока не трогаем
- Binary protocol ([https://www.tarantool.io/en/doc/latest/dev_guide/internals/box_protocol/](https://www.tarantool.io/en/doc/latest/dev_guide/internals/box_protocol/)) — не забыть про переводы
- Storage engines (перемещаем весь раздел и переводы тоже)
