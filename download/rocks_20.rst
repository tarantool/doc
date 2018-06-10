:orphan:
:priority: 0.99

-----------------
Tarantool - Rocks
-----------------

.. container:: p-download p-rocks

    .. _rocks-general-header:
    .. wp_section::
        :class: p-download-header

        .. container:: b-download-header

            .. container:: b-download-header-path

                :doc:`Downloads <download_20>` > :doc:`Modules <rocks_20>`

            .. container:: b-download-header-versions

                Available versions:

                :doc:`1.9 (stable) <rocks>` :currentversion:`2.0 (alpha)`

            .. raw:: html

                <div class="b-download-header-menu-button">
                    <div class="b-download-header-icon compass-icon"></div>
                </div>

    .. wp_section::
        :title: Available modules
        :class: p-rocks-header

        To install a module, say:

        .. code-block:: bash

            $ tarantoolctl rocks install module-name

        Want your module listed here? Please drop us a line at doc@tarantool.org.

        Download a `Lua manifest file <https://github.com/tarantool/rocks/blob/gh-pages/manifest>`_.

    .. _rocks-body:
    .. container:: p-rocks-body

        .. _rocks-menu:
        .. container:: p-rocks-menu b-download-menu

            * `Data formats / Serialization <#data-formats>`_
            * `Database administration`_
            * Databases_
            * `Date and time`_
            * `Development support`_
            * Geo_
            * I18n_
            * Miscellaneous_
            * Networking_
            * `Operating systems/Interfaces <#operating-systems>`_
            * `Power tools`_
            * `Security/Encryption <#security>`_

        .. container:: p-rocks-content

            .. _data-formats:
            .. container:: b-rock

                Data formats / Serialization

                .. module_block::
                    :title: avro-schema
                    :specialtext: External
                    :sourcelink: https://github.com/tarantool/avro-schema

                    Apache Avro schema tools for Tarantool

                .. module_block::
                    :title: csv
                    :specialtext: Built-in

                    Manipulation routines for CSV (Comma-Separated-Values)
                    records

                .. module_block::
                    :title: document
                    :specialtext: External
                    :sourcelink: https://github.com/tarantool/document

                    Efficiently store JSON documents in Tarantool spaces

                .. module_block::
                    :title: json
                    :specialtext: Built-in

                    JSON manipulation routines

                .. module_block::
                    :title: msgpack
                    :specialtext: Built-in

                    MsgPack encoder/decoder

                .. module_block::
                    :title: pickle
                    :specialtext: Built-in

                    ASN1 BER format reader

                .. module_block::
                    :title: xlog
                    :specialtext: Built-in

                    Reader for Tarantool’s snapshot files and write-ahead-log
                    (WAL) files

                .. module_block::
                    :title: yaml
                    :specialtext: Built-in

                    YAML encoder/decoder

            .. _Database administration:
            .. container:: b-rock

                Database administration

                .. module_block::
                    :title: console
                    :specialtext: Built-in

                    Connect remotely to a Tarantool instance via an admin port

                .. module_block::
                    :title: authman
                    :specialtext: External
                    :sourcelink: https://github.com/mailru/tarantool-authman

                    Authorization module for Tarantool providing API for user
                    registration and login

                .. module_block::
                    :title: dump
                    :specialtext: External
                    :sourcelink: https://github.com/tarantool/dump

                    Logical dump and restore for Tarantool

                .. module_block::
                    :title: graphite
                    :specialtext: External
                    :sourcelink: https://github.com/tarantool/graphite

                    Export Tarantool application metrics to Graphite

                .. module_block::
                    :title: prometheus
                    :specialtext: External
                    :sourcelink: https://github.com/tarantool/prometheus

                    Prometheus library to collect metrics from Tarantool

                .. module_block::
                    :title: metrics
                    :specialtext: External
                    :sourcelink: https://github.com/tarantool/metrics

                    Centralized system for collecting and manipulating metrics
                    from multiple clients

                .. module_block::
                    :title: zookeeper
                    :specialtext: External
                    :sourcelink: https://github.com/tarantool/zookeeper

                    ZooKeeper client for Tarantool

            .. _Databases:
            .. container:: b-rock

                Databases

                .. module_block::
                    :title: mysql
                    :specialtext: External
                    :sourcelink: https://github.com/tarantool/mysql

                    Connect to a MySQL database from a Tarantool application

                .. module_block::
                    :title: pg
                    :specialtext: External
                    :sourcelink: https://github.com/tarantool/pg

                    Connect to a PostgreSQL database from a Tarantool application

            .. _Date and time:
            .. container:: b-rock

                Date and time

                .. module_block::
                    :title: clock
                    :specialtext: Built-in

                    Routines to get time values derived from the Posix/C
                    'CLOCK_GETTIME' function
                    or equivalent. Useful for accurate clock and benchmarking.

                .. module_block::
                    :title: icu-date
                    :specialtext: External
                    :sourcelink: https://github.com/tarantool/icu-date

                    LuaJIT FFI bindings to ICU date and time library

            .. _Development support:
            .. container:: b-rock

                Development support

                .. module_block::
                    :title: cbench -- benchmark
                    :specialtext: External
                    :sourcelink: https://github.com/tarantool/cbench

                    Simple tool to benchmark Tarantool internal API

                .. module_block::
                    :title: debug
                    :specialtext: Built-in

                    Tools to print call traces, insert watchpoints,
                    inspect Lua objects

                .. module_block::
                    :title: fun
                    :specialtext: Built-in

                    Functional programming primitives that work well with LuaJIT

                .. module_block::
                    :title: gperftools
                    :specialtext: External
                    :sourcelink: https://github.com/tarantool/gperftools

                    Lua code profiler based on Google Performance Tools

                .. module_block::
                    :title: log
                    :specialtext: Built-in

                    Routines to write messages to the built-in Tarantool log

                .. module_block::
                    :title: modulekit
                    :specialtext: External
                    :sourcelink: https://github.com/tarantool/modulekit

                    Templates to create new Tarantool modules in Lua, C and C++

                .. module_block::
                    :title: strict
                    :specialtext: Built-in

                    Module to prohibit use of undeclared Lua variables

                .. module_block::
                    :title: tap
                    :specialtext: Built-in

                    Tools to write nice unit tests conforming to Test Anything
                    Protocol

                .. module_block::
                    :title: checks
                    :specialtext: External
                    :sourcelink: https://github.com/tarantool/checks

                    Easy, terse, readable and fast check of the Lua functions
                    argument types

                .. module_block::
                    :title: cron-parser
                    :specialtext: External
                    :sourcelink: https://github.com/tarantool/cron-parser

                    Lua wrapper for the 'ccronexpr' C library

                .. module_block::
                    :title: tradeparser
                    :specialtext: External
                    :sourcelink: https://github.com/tarantool/tradeparser

                    Fast specialized XML trade parser

                .. module_block::
                    :title: ldecnumber
                    :specialtext: External
                    :sourcelink: https://github.com/tarantool/ldecnumber

                    Lua wrapper for the 'decNumber' library

                .. module_block::
                    :title: lrexlib
                    :specialtext: External
                    :sourcelink: http://github.com/rrthomas/lrexlib

                    Regular expression library binding (PCRE flavour)

                .. module_block::
                    :title: lua-term
                    :specialtext: External
                    :sourcelink: https://github.com/hoelzro/lua-term

                    Terminal manipulation module

                .. module_block::
                    :title: LuLPeg
                    :specialtext: External
                    :sourcelink: https://github.com/pygy/LuLPeg

                    Port of the LPeg, Roberto Ierusalimschy's Parsing Expression
                    Grammars library

                .. module_block::
                    :title: argparse
                    :specialtext: External
                    :sourcelink: https://github.com/mpeterv/argparse

                    Feature-rich command-line argument parser for Lua

                .. module_block::
                    :title: watchdog
                    :specialtext: External
                    :sourcelink: https://github.com/tarantool/watchdog

                    Simple watchdog module for Tarantool

            .. _Geo:
            .. container:: b-rock

                Geo

                .. module_block::
                    :title: gis
                    :specialtext: External
                    :sourcelink: https://github.com/tarantool/gis

                    Full-featured geospatial extension for Tarantool

            .. _I18n:
            .. container:: b-rock

                I18n

                .. module_block::
                    :title: iconv
                    :specialtext: Built-in

                    Convert data between character sets

            .. _Miscellaneous:
            .. container:: b-rock

                Miscellaneous

                .. module_block::
                    :title: moonwalker
                    :specialtext: External
                    :sourcelink: https://github.com/Mons/tnt-moonwalker

                    Smart algorithm to iterate over a space and make updates
                    without freezing the database

            .. _Networking:
            .. container:: b-rock

                Networking

                .. module_block::
                    :title: connpool
                    :specialtext: External
                    :sourcelink: https://github.com/tarantool/connpool

                    Net.box connection pool for Tarantool

                .. module_block::
                    :title: http
                    :specialtext: Built-in

                    HTTP client with support for HTTPS and keepalive; uses
                    routines in the 'libcurl' library

                .. module_block::
                    :title: mqtt
                    :specialtext: External
                    :sourcelink: https://github.com/tarantool/mqtt

                    Connect from Tarantool to applications which speak the MQTT
                    protocol

                .. module_block::
                    :title: mrasender
                    :specialtext: External
                    :sourcelink: https://github.com/tarantool/mrasender

                    Send messages from Tarantool to Mail.Ru Agent and ICQ

                .. module_block::
                    :title: net.box
                    :specialtext: Built-in

                    Module to connect remotely to a Tarantool instance via a
                    binary port

                .. module_block::
                    :title: smtp
                    :specialtext: External
                    :sourcelink: https://github.com/tarantool/smtp

                    SMTP client for Tarantool

            .. _Operating systems:
            .. container:: b-rock

                Operating systems/Interfaces

                .. module_block::
                    :title: errno
                    :specialtext: Built-in

                    Module to handle errors produced by POSIX APIs

                .. module_block::
                    :title: fio
                    :specialtext: Built-in

                    Routines for file input/output

                .. module_block::
                    :title: os
                    :specialtext: Built-in

                    Faster analogs to the standard 'os' functions in Lua

                .. module_block::
                    :title: socket
                    :specialtext: Built-in

                    Non-blocking routines for socket input/output

            .. _Power tools:
            .. container:: b-rock

                Power tools

                .. module_block::
                    :title: expirationd
                    :specialtext: External
                    :sourcelink: https://github.com/tarantool/expirationd

                    Expiration daemon module to turn Tarantool into a persistent
                    memcache replacement with your own expiration strategy

                .. module_block::
                    :title: memcached
                    :specialtext: External
                    :sourcelink: https://github.com/tarantool/memcached

                    Memcached protocol wrapper for Tarantool

                .. module_block::
                    :title: shard
                    :specialtext: External
                    :sourcelink: https://github.com/tarantool/shard

                    Application-level library that provides sharding,
                    re-sharding and client-side reliable replication
                    for Tarantool

                .. module_block::
                    :title: vshard
                    :specialtext: External
                    :sourcelink: https://github.com/tarantool/vshard

                    Sharding based on virtual buckets

                .. module_block::
                    :title: queue
                    :specialtext: External
                    :sourcelink: https://github.com/tarantool/queue

                    Set of persistent in-memory queues to create task queues,
                    add and take jobs, monitor failed tasks

            .. _Security:
            .. container:: b-rock

                Security/Encryption

                .. module_block::
                    :title: crypto
                    :specialtext: Built-in

                    Routines to work with various cryptographic hash functions

                .. module_block::
                    :title: digest
                    :specialtext: Built-in

                    Routines to work with "digest", a value returned by a hash
                    function
