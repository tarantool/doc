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
    :ref:`lightweight coroutines <concepts-coop_multitasking>` with no inter-thread locking

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

Tarantool runs on Linux (x86_64, aarch64), macOS (x86_64, aarch64), and FreeBSD (x86_64).

You can use Tarantool with a programming language you're familiar with.
For this purpose, a number of :ref:`connectors <getting_started_connectors>` are provided.

..  _overview-editions:

Editions
--------

Tarantool comes in two editions: the open-source **Community Edition (CE)**
and the commercial **Enterprise Edition (EE)**.

.. _tarantool_community_edition:

Tarantool Community Edition
~~~~~~~~~~~~~~~~~~~~~~~~~~~

**Tarantool Community Edition** lets you develop applications and speed up a system in operation.
It features :ref:`synchronous replication <repl_sync>`, affords easy :ref:`scalability <sharding>`,
and includes tools to develop efficient :ref:`applications <app_server>`.
The `Tarantool community <https://t.me/tarantool>`__ helps with any practical questions
regarding the Community Edition.


.. _tarantool_enterprise:
.. _tarantool_enterprise_edition:

Tarantool Enterprise Edition
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

**Tarantool Enterprise Edition** `provides advanced tools <https://www.tarantool.io/en/compare/>`__ for
administration, deployment, and security management, along with premium support services.
This edition includes all the Community Edition features
and is more predictable in terms of solution cost and maintenance.
The Enterprise Edition is shipped as an SDK and includes a number of closed-source modules.

.. NOTE::

    In this documentation, topics related to Enterprise Edition features are marked with an ``Enterprise Edition`` admonition.

.. ifconfig:: language == 'en'

    .. container:: documentation-main-page-description

        The Enterprise Edition provides an extended feature set for developing
        and managing clustered Tarantool applications, for example:

        * :ref:`Static package <enterprise-package-contents>` for standalone Linux systems.
        * Security :ref:`audit log <enterprise_audit_module>`.
        * SSL support for :ref:`traffic encryption <enterprise-iproto-encryption>`.
        * :ref:`Centralized configuration storage <configuration_etcd_overview>`.
        * :ref:`Supervised failover <repl_supervised_failover>`.
        * :ref:`Tuple compression <tuple_compression>`.
        * :ref:`Non-blocking DDL <enterprise-space_upgrade>`.
        * :ref:`Security enforcement features <configuration_authentication>`.
        * :ref:`Read views <read_views>`.
        * :ref:`Write-ahead log extensions <wal_extensions>`.
        * :ref:`Flight recorder <enterprise-flight-recorder>`.
        * Tarantool bindings to OpenLDAP.
        * Enterprise database connectivity:
          Oracle and any ODBC-supported DBMS
          (for example, MySQL, Microsoft SQL Server).

        The Enterprise Edition is distributed in the form of an SDK, which includes
        the following key components:

        * The extended Enterprise version of the :ref:`tt <tt-cli>` utility.
        * :ref:`Tarantool Cluster Manager <tcm>` -- a web-based visual tool for managing Tarantool clusters.



.. ifconfig:: language == 'ru'

    .. container:: documentation-main-page-description

        Enterprise-версия предлагает `дополнительные возможности <https://www.tarantool.io/ru/compare/>`__ по
        разработке и эксплуатации кластерных приложений, например:

        * :ref:`Статическая сборка <enterprise-package-contents>` для автономных Linux-систем.
        * Модуль интеграции с OpenLDAP.
        * :ref:`Журнал аудита безопасности <enterprise_audit_module>`.
        * Подключения к корпоративным базам данных:
          Oracle и любым СУБД с интерфейсом ODBC (например, MySQL, Microsoft SQL Server).
        * :ref:`Шифрование трафика <enterprise-iproto-encryption>` с помощью SSL.
        * :ref:`Централизованная конфигурация <configuration_etcd_overview>`.
        * :ref:`Сжатие кортежей <tuple_compression>`.
        * :ref:`Смена схемы данных в фоновом режиме <enterprise-space_upgrade>`.
        * :ref:`Функции обеспечения безопасности <configuration_authentication>`.
        * :ref:`Представления для чтения (read views) <read_views>`.
        * :ref:`Расширения для Write-ahead log <wal_extensions>`.
        * :ref:`Flight recorder <enterprise-flight-recorder>`.

        Enterprise-версия распространяется в форме SDK, который включает следующие
        ключевые компоненты:

        * Расширенная Enterprise-версия утилиты :ref:`tt <tt-cli>`.
        * :ref:`Tarantool Cluster Manager <tcm>` -- визуальный веб-инструмент для управления кластерами Tarantool.

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
