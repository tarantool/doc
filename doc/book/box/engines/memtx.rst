.. _engines-memtx:

Storing data with memtx
=======================

.. contents::
   :local:
   :depth: 1

[TODO] -- below is the skeleton of the section

Main big topics to be covered:

* memory model (allocation -- in one thread; the small memory allocator; verify with Lyapunov)
* persisting data on disk (xlog, snapshots) -- and link box ref. about these things
* accessing the data (indexes - as a minimal decription explain TREE index) -- and link to https://www.tarantool.io/en/doc/latest/book/box/indexes/ and box ref. about indexes


Draft storyline:

* All data is in memory
* Access to data is from one thread
* Changes are being written in the Write Ahead Log (WAL)
* Indexes are build to access the data
* Data snapshots are taken periodically
* WAL is replicated

TBD:
- briefly about 3 threads -- link to https://www.tarantool.io/en/doc/latest/book/box/atomic/
- about Arena -- from Mons's presentation and link to box reference where schemas on mem. distribution
- about Actor model?
- how detailed about allocations? to describe the entire hierarchy: slab_arena, slab_cache, mempool, small alloc., ibuf/obuf/region, matras?
- hash and hash table Light -- do we need this here and how detailed?
- tree -- how detailed?
- what about fibers and cooperative multitasking?
- something else?


Memory model
------------

- all data in memory
- 3 threads but only the transaction processor thread can access the database, and there is only one transaction processor thread for each Tarantool instance
- what happens in TX thread -- more detailed about **Arena** structure
- hierarchy of allocators?


Persisting data
---------------

- changes are being written to WAL
- WAL is on disc -- persistence
- DB snapshot is taken periodically -- persistence


Accessing data
--------------

- indexes are build to access the data
- type of indexes -- link to the Indexes chapter
- details about our btree??
- links to the necessary pages to get details about accessing the data
- hashes ??

?Replication
------------

- WAL is replicated -- you can build a distributed application based on Tarantool
- references to the relevant doc sections?
