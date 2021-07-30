.. _engines-memtx:

Storing data with memtx
=======================

This chapter gives an overview of the ``memtx`` in-memory storage engine used in Tarantool by default.
The following topics are described in brief with the references to the chapters explaining the subject matter in details.

..  contents::
    :local:
    :depth: 1

.. _memtx-memory:

Memory model
------------

The ``memtx`` storage engine keeps all data in random-access memory (RAM), and therefore has very low read latency.

There is a fixed number of independent :ref:`execution threads <atomic-threads_fibers_yields>`.
The threads don't share state. Instead they exchange data using low-overhead message queues.
While this approach limits the number of cores that the instance uses,
it removes competition for the memory bus and ensures peak scalability of memory access and network throughput.

Only one thread, namely, the **transaction processor thread** (further, **TX thread**)
can access the database, and there is only one TX thread for each Tarantool instance.
Within the TX thread, there is a memory area allocated for Tarantool to store data. It's called **Arena**.

.. image:: memtx/arena2.svg

Data is stored in :term:`spaces <space>`. Spaces contain database records—:term:`tuples <tuple>`.
To access and manipulate the data stored in spaces and tuples, Tarantool builds :doc:`indexes </book/box/indexes>`.

All that are managed by special `memory allocators <https://github.com/tarantool/small>`__ working within the Arena.
The slab allocator is the main allocator used to store tuples.
Tarantool has a built-in module called ``box.slab`` which provides the slab allocator statistics
that can be used to monitor the total memory usage and memory fragmentation.
For details, see the ``box.slab`` module :doc:`reference </reference/reference_lua/box_slab>`.

.. image:: memtx/spaces_indexes.svg

Also inside the TX thread, there is an event loop. Within the event loop, there are a number of :ref:`fibers <fiber-fibers>`.
Fibers are cooperative primitives that allows interaction with spaces, that is, reading and writting the data.
Fibers can interact with the event loop and between each other directly or by using special primitives called channels.
Due to the usage of fibers and :ref:`cooperative multitasking <atomic-cooperative_multitasking>`, the ``memtx`` engine is lock-free in typical situations.

.. image:: memtx/fibers-channels.svg

To interact with external users, there is a separate :ref:`network thread <atomic-threads_fibers_yields>` also called the **IPROTO thread**.
The IPROTO thread receives a request from the network, parses and checks the statement,
and transforms it into a special structure—a message containing an executable statement and its options.
Then the IPROTO thread ships this message to the TX thread and runs the user's request in a separate fiber.

.. image:: memtx/iproto.svg

.. _memtx-persist:

Data persistence
----------------

To ensure :ref:`data persistence <index-box_persistence>`, Tarantool does two things.

*   After executing data change requests in memory, Tarantool writes each such request to the :ref:`write-ahead log (WAL) <internals-wal>` files (``.xlog``)
    that are stored on disk. Tarantool does this via a separate thread called the **WAL thread**.

.. image:: memtx/wal.svg

*   Tarantool periodically takes the entire :doc:`database snapshot </reference/reference_lua/box_snapshot>` and saves it on disk.
    It is necessary for accelerating restart because when there are too many WAL files, it can be difficult for Tarantool to restart quickly.
    To save a snapshot, there is a special fiber called the **snapshot daemon**.
    It reads the consistent content of the entire Arena and writes it on disk into a snapshot file (``.snap``).
    Due of the cooperative multitasking, Tarantool cannot write directly on disk because it is a locking operation.
    That is why Tarantool interacts with disk via a separate pool of threads from the :doc:`fio </reference/reference_lua/fio>` library.

.. image:: memtx/snapshot03.svg

So, even in emergency situations such as an outage or a Tarantool instance crash,
when the in-memory database is lost, all the data can be restored fully during Tarantool restart.

What happens during the restart:

1.  Tarantool finds the latest snapshot file and reads it.
2.  Tarantool finds all the WAL files created after that snapshot and reads them as well.
3.  When the snapshot and WAL files have been read, there is a fully recovered in-memory data set
    corresponding to the state when the Tarantool instance stopped.
4.  While reading the snapshot and WAL files, Tarantool is building the primary indexes.
5.  When all the data is in memory again, Tarantool is building the secondary indexes.
6.  Tarantool runs an application.

.. _memtx-indexes:

Accessing data
--------------

To access and manipulate the data stored in memory, Tarantool builds indexes.
Indexes are also stored in memory within the Arena.

Tarantool supports a number of :ref:`index types <index-types>` intended for different usage scenarios.
The possible types are TREE, HASH, BITSET, and RTREE.

Select query are possible against secondary index keys as well as primary keys.
Indexes can have multi-part keys.

For detailed information about indexes, refer to the :doc:`/book/box/indexes` page.

.. _memtx-replication:

Replicating data
----------------

Replication allows multiple Tarantool instances to work on copies of the same database.
The copies are kept in sync because each instance can communicate its changes to all the other instances.
It is implemented via WAL replication.

To send data to a replica, Tarantool runs another thread called **relay**.
Its purpose is to read the WAL files and send them to replicas.
On a replica, the fiber called **applier** is run. It receives the changes from a remote node and applies them to the replica's Arena.
All the changes are being written to WAL files via the replica's WAL thread as if they are done locally.

.. image:: memtx/replica-xlogs.svg

For more information on replication, refer to the :doc:`corresponding chapter </book/replication/index>`.

.. _memtx-summary:

Summary
-------

The main key points describing how the in-memory storage engine works can be summarized in the following way:

*   All data is in RAM.
*   Access to data is from one thread.
*   Tarantool writes all data change requests in WAL.
*   Data snapshots are taken periodically.
*   Indexes are build to access the data.
*   WAL can be replicated.
