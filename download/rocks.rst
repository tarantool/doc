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

                :doc:`Downloads <download>` > :doc:`Modules <rocks>`

            .. container:: b-download-header-versions

                Available versions:

                :doc:`1.6 (stable) <rocks_16>` :currentversion:`1.7 (rc)` :doc:`1.8 (alpha) <rocks_18>`

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

                -   .. container:: b-rock-block-header

                        avro-schema
                        :specialtext:`External`

                        .. raw:: html

                            <a href="https://github.com/tarantool/avro-schema" class="b-rock-block-header-source-link">
                                <div class="clock-icon"></div>
                                <span>Latest source</span>
                            </a>

                    Apache Avro schema tools for Tarantool

                -   .. container:: b-rock-block-header

                        csv
                        :specialtext:`Built-in`

                    Manipulation routines for CSV (Comma-Separated-Values) records

                -   .. container:: b-rock-block-header

                        document
                        :specialtext:`External`

                        .. raw:: html

                            <a href="https://github.com/tarantool/document" class="b-rock-block-header-source-link">
                                <div class="clock-icon"></div>
                                <span>Latest source</span>
                            </a>

                    Efficiently store JSON documents in Tarantool spaces

                -   .. container:: b-rock-block-header

                        json
                        :specialtext:`Built-in`

                    JSON manipulation routines

                -   .. container:: b-rock-block-header

                        msgpack
                        :specialtext:`Built-in`

                    MsgPack encoder/decoder

                -   .. container:: b-rock-block-header

                        pickle
                        :specialtext:`Built-in`

                    ASN1 BER format reader

                -   .. container:: b-rock-block-header

                        xlog
                        :specialtext:`Built-in`

                    Reader for Tarantool’s snapshot files and write-ahead-log (WAL) files

                -   .. container:: b-rock-block-header

                        yaml
                        :specialtext:`Built-in`

                    YAML encoder/decoder

            .. _Database administration:
            .. container:: b-rock

                Database administration

                -   .. container:: b-rock-block-header

                        console
                        :specialtext:`Built-in`

                    Connect remotely to a Tarantool instance via an admin port

                -   .. container:: b-rock-block-header

                        dump
                        :specialtext:`External`

                        .. raw:: html

                            <a href="https://github.com/tarantool/dump" class="b-rock-block-header-source-link">
                                <div class="clock-icon"></div>
                                <span>Latest source</span>
                            </a>

                    Logical dump and restore for Tarantool

                -   .. container:: b-rock-block-header

                        graphite
                        :specialtext:`External`

                        .. raw:: html

                            <a href="https://github.com/tarantool/graphite" class="b-rock-block-header-source-link">
                                <div class="clock-icon"></div>
                                <span>Latest source</span>
                            </a>

                    Export Tarantool application metrics to Graphite

                -   .. container:: b-rock-block-header

                        prometheus
                        :specialtext:`External`

                        .. raw:: html

                            <a href="https://github.com/tarantool/prometheus" class="b-rock-block-header-source-link">
                                <div class="clock-icon"></div>
                                <span>Latest source</span>
                            </a>

                    Prometheus library to collect metrics from Tarantool

            .. _Databases:
            .. container:: b-rock

                Databases

                -   .. container:: b-rock-block-header

                        mysql
                        :specialtext:`External`

                        .. raw:: html

                            <a href="https://github.com/tarantool/mysql" class="b-rock-block-header-source-link">
                                <div class="clock-icon"></div>
                                <span>Latest source</span>
                            </a>

                    Connect to a MySQL database from a Tarantool application

                -   .. container:: b-rock-block-header

                        pg
                        :specialtext:`External`

                        .. raw:: html

                            <a href="https://github.com/tarantool/pg" class="b-rock-block-header-source-link">
                                <div class="clock-icon"></div>
                                <span>Latest source</span>
                            </a>

                    Connect to a PostgreSQL database from a Tarantool application

            .. _Date and time:
            .. container:: b-rock

                Date and time

                -   .. container:: b-rock-block-header

                        clock
                        :specialtext:`Built-in`

                    Routines to get time values derived from the Posix/C 'CLOCK_GETTIME' function
                    or equivalent. Useful for accurate clock and benchmarking.

            .. _Development support:
            .. container:: b-rock

                Development support

                -   .. container:: b-rock-block-header

                        cbench -- benchmark
                        :specialtext:`External`

                        .. raw:: html

                            <a href="https://github.com/tarantool/cbench" class="b-rock-block-header-source-link">
                                <div class="clock-icon"></div>
                                <span>Latest source</span>
                            </a>

                    Simple tool to benchmark Tarantool internal API

                -   .. container:: b-rock-block-header

                        debug
                        :specialtext:`Built-in`

                    Tools to print call traces, insert watchpoints, inspect Lua objects

                -   .. container:: b-rock-block-header

                        fun
                        :specialtext:`Built-in`

                    Functional programming primitives that work well with LuaJIT

                -   .. container:: b-rock-block-header

                        gperftools
                        :specialtext:`External`

                        .. raw:: html

                            <a href="https://github.com/tarantool/gperftools" class="b-rock-block-header-source-link">
                                <div class="clock-icon"></div>
                                <span>Latest source</span>
                            </a>

                    Lua code profiler based on Google Performance Tools

                -   .. container:: b-rock-block-header

                        log
                        :specialtext:`Built-in`

                    Routines to write messages to the built-in Tarantool log

                -   .. container:: b-rock-block-header

                        modulekit
                        :specialtext:`External`

                        .. raw:: html

                            <a href="https://github.com/tarantool/modulekit" class="b-rock-block-header-source-link">
                                <div class="clock-icon"></div>
                                <span>Latest source</span>
                            </a>

                    Templates to create new Tarantool modules in Lua, C and C++

                -   .. container:: b-rock-block-header

                        strict
                        :specialtext:`Built-in`

                    Module to prohibit use of undeclared Lua variables

                -   .. container:: b-rock-block-header

                        tap
                        :specialtext:`Built-in`

                    Tools to write nice unit tests conforming to Test Anything Protocol

            .. _Geo:
            .. container:: b-rock

                Geo

                -   .. container:: b-rock-block-header

                        gis
                        :specialtext:`External`

                        .. raw:: html

                            <a href="https://github.com/tarantool/gis" class="b-rock-block-header-source-link">
                                <div class="clock-icon"></div>
                                <span>Latest source</span>
                            </a>

                    Full-featured geospatial extension for Tarantool

            .. _I18n:
            .. container:: b-rock

                I18n

                -   .. container:: b-rock-block-header

                        iconv
                        :specialtext:`Built-in`

                    Convert data between character sets

            .. _Miscellaneous:
            .. container:: b-rock

                Miscellaneous

                -   .. container:: b-rock-block-header

                        moonwalker
                        :specialtext:`External`

                        .. raw:: html

                            <a href="https://github.com/Mons/tnt-moonwalker" class="b-rock-block-header-source-link">
                                <div class="clock-icon"></div>
                                <span>Latest source</span>
                            </a>

                    Smart algorithm to iterate over a space and make updates without freezing the database

            .. _Networking:
            .. container:: b-rock

                Networking

                -   .. container:: b-rock-block-header

                        connpool
                        :specialtext:`External`

                        .. raw:: html

                            <a href="https://github.com/tarantool/connpool" class="b-rock-block-header-source-link">
                                <div class="clock-icon"></div>
                                <span>Latest source</span>
                            </a>

                    Net.box connection pool for Tarantool

                -   .. container:: b-rock-block-header

                        http
                        :specialtext:`Built-in`

                    HTTP client with support for HTTPS and keepalive; uses routines in the 'libcurl' library

                -   .. container:: b-rock-block-header

                        mqtt
                        :specialtext:`External`

                        .. raw:: html

                            <a href="https://github.com/tarantool/mqtt" class="b-rock-block-header-source-link">
                                <div class="clock-icon"></div>
                                <span>Latest source</span>
                            </a>

                    Connect from Tarantool to applications which speak MQTT protocol

                -   .. container:: b-rock-block-header

                        mrasender
                        :specialtext:`External`

                        .. raw:: html

                            <a href="https://github.com/tarantool/mrasender" class="b-rock-block-header-source-link">
                                <div class="clock-icon"></div>
                                <span>Latest source</span>
                            </a>

                    Send messages from Tarantool to Mail.Ru Agent and ICQ

                -   .. container:: b-rock-block-header

                        net.box
                        :specialtext:`Built-in`

                        .. raw:: html

                            <a href="https://github.com/tarantool/mrasender" class="b-rock-block-header-source-link">
                                <div class="clock-icon"></div>
                                <span>Latest source</span>
                            </a>

                    Module to connect remotely to a Tarantool instance via a binary port

            .. _Operating systems:
            .. container:: b-rock

                Operating systems/Interfaces

                -   .. container:: b-rock-block-header

                        errno
                        :specialtext:`Built-in`

                    Module to handle errors produced by POSIX APIs

                -   .. container:: b-rock-block-header

                        fio
                        :specialtext:`Built-in`

                    Routines for file input/output

                -   .. container:: b-rock-block-header

                        os
                        :specialtext:`Built-in`

                    Faster analogs to the standard 'os' functions in Lua

                -   .. container:: b-rock-block-header

                        socket
                        :specialtext:`Built-in`

                    Non-blocking routines for socket input/output

            .. _Power tools:
            .. container:: b-rock

                Power tools

                -   .. container:: b-rock-block-header

                        expirationd
                        :specialtext:`External`

                        .. raw:: html

                            <a href="https://github.com/tarantool/expirationd" class="b-rock-block-header-source-link">
                                <div class="clock-icon"></div>
                                <span>Latest source</span>
                            </a>

                    Expiration daemon module to turn Tarantool into a persistent memcache
                    replacement with your own expiration strategy

                -   .. container:: b-rock-block-header

                        memcached
                        :specialtext:`External`

                        .. raw:: html

                            <a href="https://github.com/tarantool/memcached" class="b-rock-block-header-source-link">
                                <div class="clock-icon"></div>
                                <span>Latest source</span>
                            </a>

                    Memcached protocol wrapper for Tarantool.

                -   .. container:: b-rock-block-header

                        shard
                        :specialtext:`External`

                        .. raw:: html

                            <a href="https://github.com/tarantool/shard" class="b-rock-block-header-source-link">
                                <div class="clock-icon"></div>
                                <span>Latest source</span>
                            </a>

                    Application-level library that provides sharding, re-sharding and
                    client-side reliable replication for Tarantool

                -   .. container:: b-rock-block-header

                        queue
                        :specialtext:`External`

                        .. raw:: html

                            <a href="https://github.com/tarantool/queue" class="b-rock-block-header-source-link">
                                <div class="clock-icon"></div>
                                <span>Latest source</span>
                            </a>

                    Set of persistent in-memory queues to create task queues, add and take jobs,
                    monitor failed tasks

                .. _Security:
                .. container:: b-rock

                    Security/Encryption

                    -   .. container:: b-rock-block-header

                            crypto
                            :specialtext:`Built-in`

                        Routines to work with various cryptographic hash functions

                    -   .. container:: b-rock-block-header

                            digest
                            :specialtext:`Built-in`

                        Routines to work with “digest”, a value returned by a hash function
