.. _tarantool_enterprise:

Tarantool Enterprise Edition
============================

.. ifconfig:: language == 'en'

    .. container:: documentation-main-page-description

        This section describes the Enterprise Edition of Tarantool software -- a Lua
        application server integrated with a DBMS for deploying fault-tolerant
        distributed data storages.

        The Enterprise Edition provides an `extended feature set <https://www.tarantool.io/en/compare/>`__ for developing
        and managing clustered Tarantool applications, for example:

        * Static package for standalone Linux systems.
        * Tarantool bindings to OpenLDAP.
        * Security :ref:`audit log <enterprise-logging>`.
        * Enterprise database connectivity:
          Oracle and any ODBC-supported DBMS
          (for example, MySQL, Microsoft SQL Server).
        * SSL support for :ref:`traffic encryption <enterprise-iproto-encryption>`.
        * :doc:`Tuple compression <tuple_compression>`.
        * :doc:`Non-blocking DDL <space_upgrade>`.

        The Enterprise Edition is distributed in the form of an SDK, which includes
        the following key components:

        * The Tarantool EE binary, which can use :ref:`centralized configuration <configuration_etcd_overview>`.
        * The extended Enterprise version of the :ref:`tt <tt-cli>` utility.
        * :ref:`Tarantool Cluster Manager <tcm>` -- a web-based visual tool for managing Tarantool clusters.



.. ifconfig:: language == 'ru'

    .. container:: documentation-main-page-description

        Данное руководство посвящено Enterprise-версии продукта Tarantool,
        который сочетает в себе сервер приложений Lua и отказоустойчивую
        распределенную СУБД.

        Enterprise-версия предлагает `дополнительные возможности <https://www.tarantool.io/ru/compare/>`__ по
        разработке и эксплуатации кластерных приложений, например:

        * Статическая сборка для автономных Linux-систем.
        * Модуль интеграции с OpenLDAP.
        * :ref:`Журнал аудита безопасности <enterprise-logging>`.
        * Подключения к корпоративным базам данных:
          Oracle и любым СУБД с интерфейсом ODBC (например, MySQL, Microsoft SQL Server).
        * :ref:`Шифрование трафика <enterprise-iproto-encryption>` с помощью SSL.
        * :doc:`Сжатие кортежей <tuple_compression>`.
        * :doc:`Смена схемы данных в фоновом режиме <space_upgrade>`.

        Enterprise-версия распространяется в форме SDK, который включает следующие
        ключевые компоненты:

        * Исполняемый файл Tarantool EE binary, который может работать с :ref:`цетрализованной конфигурацией <configuration_etcd_overview>`.
        * Расширенная Enterprise-версия утилиты :ref:`tt <tt-cli>`.
        * :ref:`Tarantool Cluster Manager <tcm>` -- визуальный веб-инструмент для управления кластерами Tarantool.

..  toctree::
    :hidden:

    security
    audit
    tuple_compression
    wal_extensions
    read_views
    flight_recorder
    audit_log
    space_upgrade
    system_metrics
    deprecated
    rocksref
