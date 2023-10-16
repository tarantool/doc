Overview
========

What is Tarantool?
------------------

Tarantool combines an in-memory DBMS and a Lua server in a single platform
providing ACID-compliant storage. It comes in two :ref:`editions <overview-editions>`:
Community and Enterprise.
The :ref:`use cases <overview-use_cases>` for Tarantool vary from ultra-fast cache
to product data marts and smart queue services.

Here are some of Tarantool's key characteristics:

*   **Easy handling of OLTP workloads**: processes hundreds of thousands RPS

*   **Data integrity**: :ref:`write-ahead log (WAL) <concepts-data_model-persistence>`
    and :ref:`data snapshots <concepts-data_model-persistence>` 

*   **Cooperative multitasking**: transactions are performed in
    :ref:`lightweight coroutines <concepts-coop_multitasking>` with no interthread locking

*   **Advanced indexing**: :ref:`composite indexes <concepts-data_model_indexes>`,
    :ref:`locale support <index-collation>`,
    indexing by :ref:`nested fields and arrays <index-box_indexed-field-types>`

*   **Compute close to data**: :ref:`Lua server <concepts-application_server>`
    and Just-In-Time compiler on board

*   **Durable distributed storage**: multiple failover modes and
    :ref:`RAFT-based synchronous replication <repl_sync>` available
    

Tarantool allows executing code alongside data, which helps increase the speed of operations.
Developers can :ref:`implement any business logic with Lua <app_server-creating_app>`,
and a single Tarantool instance can also receive :ref:`SQL requests <sql_tutorial>`.

Tarantool has a variety of compatible `modules <https://www.tarantool.io/en/download/rocks>`__ (Lua rocks).
You can pick the ones that you need and install them manually.

Tarantool runs on Linux (x86_64, aarch64), Mac OS X (x86_64, M1), and FreeBSD (x86_64).

You can use Tarantool with a programming language you're familiar with.
For this purpose, a number of :ref:`connectors <getting_started_connectors>` are provided.

..  _overview-editions:

Editions
--------

Tarantool comes in two editions: the open-source **Community Edition (CE)**
and the commercial **Enterprise Edition (EE)**.

**Tarantool Community Edition** lets you develop applications and speed up a system in operation.
It features :ref:`synchronous replication <repl_sync>`, affords easy :ref:`scalability <sharding>`,
and includes tools to develop efficient :ref:`applications <app_server>`.
The `Tarantool community <https://t.me/tarantool>`__ helps with any practical questions
regarding the Community Edition.

**Tarantool Enterprise Edition** `provides advanced tools <https://www.tarantool.io/en/compare/>`__ for
administration, deployment, and security management, along with premium support services.
This edition includes all the Community Edition features
and is more predictable in terms of solution cost and maintenance.
The Enterprise Edition is shipped as an SDK and includes a number of closed-source modules.
See the :ref:`Tarantool Enterprise Edition <tarantool_enterprise>` documentation.

..  _overview-use_cases:

Use cases
---------

Fast first-class storage
~~~~~~~~~~~~~~~~~~~~~~~~

*   Primary storage

    -   No secondary storage required

*   Tolerance to high write loads
*   Support of relational approaches
*   Composite secondary indexes

    -   Data access, data slices

*   Predictable request latency

Advanced cache
~~~~~~~~~~~~~~

*   Write-behind caching
*   Secondary index support
*   Complex invalidation algorithm support

Smart queue
~~~~~~~~~~~

*   Support of various identification techniques
*   Advanced task lifecycle management

    -   Task scheduling
    -   Archiving of completed tasks

Data-centric applications
~~~~~~~~~~~~~~~~~~~~~~~~~

*   Arbitrary data flows from many sources
*   Incoming data processing
*   Storage
*   Background cycle processing

    -   Scheduling support
