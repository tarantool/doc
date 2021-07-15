.. _engines-memtx:

Storing data with memtx
=======================

``memtx`` is the Tarantool’s in-memory storage engine. It keeps all the data in random-access memory (RAM).
It also keeps persistent copies of the data in non-volatile storage, such as disk, when users request snapshots.
If an instance of the server stops and the random-access memory is lost, then restarts,
it reads the latest snapshot and then replays the transactions that are in the log, and therefore no data is lost.

?TOC here?

..  contents::
    :local:
    :depth: 1

//TBD -- put this at the end as a summary points.
In a nutshell, the main key points describing the principles of how memtx works are:

*   All data is in memory (RAM).
*   Access to data is from one thread.
*   Data change requests are written in the write-ahead log (WAL).
*   Data snapshots are taken periodically.
*   Indexes are build to access the data.
*   WAL can be replicated.

.. _memtx-memory:

Memory model
------------

The ``memtx`` engine keeps all the data in RAM, and therefore has very low read latency.

There is a fixed number of independent :ref:`execution threads <atomic-threads_fibers_yields>`.
The threads do not share state. Instead they exchange data using low-overhead message queues.
While this approach limits the number of cores that the instance uses,
it removes competition for the memory bus and ensures peak scalability of memory access and network throughput.

Only one thread, namely, the **transaction processor thread** (further, **TX thread**)
can access the database, and there is only one TX thread for each Tarantool instance.
Within the TX thread there is a memory area allocated for Tarantool to store data. It's called **Arena**.

.. image:: memtx/arena.svg

Data is stored in :term:`spaces <space>`. Spaces contain database records—:term:`tuples <tuple>`.
To access and manipulate the data stored in spaces and tuples, Tarantool builds :doc:`indexes </book/box/indexes>`.

All that are managed by special memory allocators working within the Arena.
The slab allocator is the main allocator used to store tuples.
Tarantool has a built-in module called ``box.slab`` which provides the slab allocator statistics
that can be used to monitor the total memory usage and memory fragmentation.
For details, see the ``box.slab`` module :doc:`reference </reference/reference_lua/box_slab>`.

.. image:: memtx/spaces_indexes.svg

Also inside the TX thread, there is an event loop. Within the event loop, there are a number of :ref:`fibers <fiber-fibers>`.
Fibers are cooperative primitives that allows interaction with spaces, that is, reading and writting the data.
Fibers can interact with the event loop and between each other directly or by using special primitives called channels.
Due to the usage of fibers and cooperative multitasking, the ``memtx`` engine is lock-free in typical situations.

.. image:: memtx/fibers-channels.svg

To interact with external users, there is a separate :ref:`network thread <atomic-threads_fibers_yields>` also called the **IPROTO thread**.
The IPROTO thread receives a request for the network, parses and checks the statement,
and transforms it into a special structure—a message containing an executable statement and its options.
Then the IPROTO thread ships this message to the TX thread and runs the user's request in a separate fiber.

.. image:: memtx/iproto.svg

.. _memtx-persist:

Data persistence
----------------

To ensure :ref:`data persistence <index-box_persistence>`, Tarantool does two things.

*   After executing a data change request in memory, Tarantool writes each such request to the :ref:`write-ahead log (WAL) <internals-wal>` files (``.xlog``)
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

- indexes are build to access the data
- type of indexes -- link to the Indexes chapter
- details about our btree??
- links to the necessary pages to get details about accessing the data
- hashes ??

https://www.tarantool.io/en/doc/latest/book/box/indexes/
https://www.tarantool.io/en/doc/latest/reference/reference_lua/box_space/create_index/



Replicating data
----------------

Replication allows multiple Tarantool instances to work on copies of the same database.
The copies are kept in sync because each instance can communicate its changes to all the other instances.
It is implemented via WAL replication.

//TBD
To send data to a replica, Tarantool runs another thread called **relay**.
Its purpose is to read the WAL files and send them to replicas.
On a replica, the fiber called **applier** is run. It receives the //information about the changes from a remote node and applies these changes to the replica's Arena.
And all these changes are being written to WAL files via the replica's WAL thread as if the changes are done locally.

.. image:: memtx/replica-xlogs.svg

For more information on replication, refer to the :doc:`corresponding chapter </book/replication/index>`.


//TBD Although this subject matter is not related directly to the memtx engine as such, it helps understand the entire picture how Tarantool works.
Зная, как это все устроено, вы можете понимать и предсказывать поведение того или иного участка Tarantool, и понимать, что с этим делать.


