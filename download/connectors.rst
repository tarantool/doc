:orphan:
:priority: 0.99

----------------------
Tarantool - Connectors
----------------------

.. container:: p-download p-connectors

    .. wp_section::
        :class: p-download-header

        .. container:: b-download-header

            .. container:: b-download-header-path

                Downloads >

            .. container:: b-download-header-versions

                Available versions:

                :doc:`1.6 (stable) <download_16>` :currentversion:`1.7 (rc)`   :doc:`1.8 (alpha) <download_18>`

    .. wp_section::
        :title: Connectors
        :class: p-connectors-page-header

        .. raw:: html

            <i class="star-icon"></i>
            <div class="p-connectors-page-header-description">
                The recommended connector(s) for a language are marked with a star <i class="star-icon"></i>.
                Want your connector listed here? Please drop us a line at <span class="colored">support@tarantool.org</span>.
            </div>

    .. container:: p-connectors-page-body

        .. container:: p-connectors-page-menu b-download-menu

            * `C <#c-language>`_
            * `C#`_
            * Erlang_
            * Go_
            * Java_
            * Lua_
            * `Node.js`_
            * NginX_
            * OpenResty_
            * Perl_
            * PHP_
            * Python_
            * `R <#r-language>`_
            * Ruby_
            * Rust_
            * Smalltalk_
            * Swift_
            * Tarantool_

        .. container:: p-connectors-page-content

            .. _C language:
            .. container:: b-connector

                C

                -   C connector for Tarantool 1.6+. Supports sync and async I/O models.
                    |star|

                    .. wp_button::
                        :class: b-connector-source-link
                        :link: https://github.com/tarantool/tarantool-c
                        :title: Source
                        :icon: github-icon

                    .. container:: b-connector-owner

                        Owner: https://github.com/bigbes

                -   A plain msgpack serialization library. Use it if you wish to write your own
                    connector or embed Tarantool protocol into your application.

                    .. wp_button::
                        :class: b-connector-source-link
                        :link: https://github.com/tarantool/msgpuck
                        :title: Source
                        :icon: github-icon

                    .. container:: b-connector-owner

                        Owner: https://github.com/rtisisyk

            .. _C#:
            .. container:: b-connector

                C#

                -   .Net connector for Tarantool 1.6+. Offers a full-featured support of Tarantool's binary protocol,
                    async API and multiplexing.
                    |star|

                    .. wp_button::
                        :class: b-connector-source-link
                        :link: https://github.com/progaudi/progaudi.tarantool
                        :title: Source
                        :icon: github-icon

                    .. container:: b-connector-owner

                        Owner: https://github.com/aensidhe, https://github.com/roman-kozachenko

                -   .Net connector for Tarantool ???. Based on the Akka.Net I/O package.

                    .. wp_button::
                        :class: b-connector-source-link
                        :link: https://github.com/donmikel/tarantool-net
                        :title: Source
                        :icon: github-icon

                    .. container:: b-connector-owner

                        Owner: https://github.com/donmikel

            .. _Erlang:
            .. container:: b-connector

                Erlang

                -   Erlang connector for Tarantool 1.6+. Supports pools of async
                    connects (OTP supervisor based), automatic connection restore,
                    transparent erlang map <-> Lua table.
                    |star|

                    .. wp_button::
                        :class: b-connector-source-link
                        :link: https://github.com/stofel/taran
                        :title: Source
                        :icon: github-icon

                    .. container:: b-connector-owner

                        Owner: https://github.com/stofel

                -   Erlang connector for Tarantool 1.7+. Based on simplepool.

                    .. wp_button::
                        :class: b-connector-source-link
                        :link: https://github.com/umatomba/tara
                        :title: Source
                        :icon: github-icon

                    .. container:: b-connector-owner

                        Owner: https://github.com/brigadier

                -   Native Elixir connector for Tarantool 1.6.

                    .. wp_button::
                        :class: b-connector-source-link
                        :link: https://github.com/progress-engine/tarantool.ex
                        :title: Source
                        :icon: github-icon

                    .. container:: b-connector-owner

                        Owner: https://github.com/spscream

            .. _Go:
            .. container:: b-connector

                Go

                -   Go connector for Tarantool 1.6+.
                    |star|

                    .. wp_button::
                        :class: b-connector-source-link
                        :link: https://github.com/tarantool/go-tarantool
                        :title: Source
                        :icon: github-icon

                    .. container:: b-connector-owner

                        Owner: https://github.com/funny-falcon, https://github.com/mialinx

            .. _Java:
            .. container:: b-connector

                Java

                -   Java connector for Tarantool 1.6+
                    |star|

                    .. wp_button::
                        :class: b-connector-source-link
                        :link: https://github.com/tarantool/tarantool-java
                        :title: Source
                        :icon: github-icon

                    .. container:: b-connector-owner

                        Owner: https://github.com/dgreenru

            .. _Lua:
            .. container:: b-connector

                Lua

                -   Pure Lua connector for Tarantool 1.7+. Works on nginx cosockets and plain Lua sockets.
                    |star|

                    .. wp_button::
                        :class: b-connector-source-link
                        :link: https://github.com/tarantool/tarantool-lua
                        :title: Source
                        :icon: github-icon

                    .. container:: b-connector-owner

                        Owner: https://github.com/csteenberg

            .. _Node.js:
            .. container:: b-connector

                Node.js

                -   Node connector for Tarantool 1.6+.
                    |star|

                    .. wp_button::
                        :class: b-connector-source-link
                        :link: https://github.com/tarantool/tarantool-node
                        :title: Source
                        :icon: github-icon

                    .. container:: b-connector-owner

                        Owner: https://github.com/KlonD90

            .. _NginX:
            .. container:: b-connector

                NginX

                -   NginX upstream module for Tarantool 1.6+. Features REST, JSON API, websockets, load balancing.
                    |star|

                    .. wp_button::
                        :class: b-connector-source-link
                        :link: https://github.com/tarantool/nginx_upstream_module
                        :title: Source
                        :icon: github-icon

                    .. container:: b-connector-owner

                        Owner: https://github.com/dedok

            .. _OpenResty:
            .. container:: b-connector

                OpenResty

                -   Connector for working with Tarantool ??? from nginx with an embedded Lua module or with OpenResty.
                    |star|

                    .. wp_button::
                        :class: b-connector-source-link
                        :link: https://github.com/perusio/lua-resty-tarantool
                        :title: Source
                        :icon: github-icon

                    .. container:: b-connector-owner

                        Owner: https://github.com/perusio

                -   Lua connector for Tarantool 1.6 on OpenResty nginx cosockets.
                    |star|

                    .. wp_button::
                        :class: b-connector-source-link
                        :link: https://github.com/ziontab/lua-nginx-tarantool
                        :title: Source
                        :icon: github-icon

                    .. container:: b-connector-owner

                        Owner: https://github.com/hengestone

            .. _Perl:
            .. container:: b-connector

                Perl

                -   Perl client for Tarantool 1.6+. Fast, based on AnyEvent (async requests
                    out of the box), provides automatic schema loading and on-fly reloading
                    (which enables one to use spaces' and indexes' names in queries),
                    supports all common tarantool statements to be requested natively
                    (select / insert / delete / update / replace / upsert) or through lua function call.
                    The connection is fully customizable (different timeouts can be set),
                    fault-tolerant (reconnect on fails), and can be lazy initialized (to connect
                    on first request).
                    |star|

                    .. wp_button::
                        :class: b-connector-source-link
                        :link: https://github.com/tarantool/tarantool-perl
                        :title: Source
                        :icon: github-icon

                    .. container:: b-connector-owner

                        Owner: https://github.com/Awety

                -   EV connector for Tarantool 1.6+. Asynchronous, fast, supports schemas
                    (incl. fields) for on-the-fly tuple-to-hash and backward transformations,
                    supports Types::Serializer for transparent conversion to JSON.
                    |star|

                    .. wp_button::
                        :class: b-connector-source-link
                        :link: https://github.com/igorcoding/EV-Tarantool16
                        :title: Source
                        :icon: github-icon

                    .. container:: b-connector-owner

                        Owner: https://github.com/igorcoding, https://github.com/mons

            .. _PHP:
            .. container:: b-connector

                PHP

                -   PECL PHP connector for Tarantool 1.6+
                    |star|

                    .. wp_button::
                        :class: b-connector-source-link
                        :link: https://github.com/tarantool/tarantool-php
                        :title: Source
                        :icon: github-icon

                    .. container:: b-connector-owner

                        Owner: https://github.com/bigbes

                -   Pure PHP connector for Tarantool 1.6+. Includes a client and a mapper.
                    |star|

                    .. wp_button::
                        :class: b-connector-source-link
                        :link: https://github.com/tarantool-php
                        :title: Source
                        :icon: github-icon

                    .. container:: b-connector-owner

                        Owner: https://github.com/rybakit, https://github.com/nekufa

            .. _Python:
            .. container:: b-connector

                Python

                -   Python connector for Tarantool 1.6+
                    |star|

                    .. wp_button::
                        :class: b-connector-source-link
                        :link: https://github.com/tarantool/tarantool-python
                        :title: Source
                        :icon: github-icon

                    .. wp_button::
                        :class: b-connector-source-link
                        :link: http://pypi.python.org/pypi/tarantool
                        :title: Source
                        :icon: github-icon

                    .. container:: b-connector-owner

                        Owner: https://github.com/bigbes

                -   Python Gevent driver.
                    |star|

                    .. wp_button::
                        :class: b-connector-source-link
                        :link: https://github.com/shveenkov/gtarantool
                        :title: Source
                        :icon: github-icon

                    .. container:: b-connector-owner

                        Owner: https://github.com/shveenkov

                -   Python AIO driver.
                    |star|

                    .. wp_button::
                        :class: b-connector-source-link
                        :link: https://github.com/shveenkov/aiotarantool
                        :title: Source
                        :icon: github-icon

                    .. container:: b-connector-owner

                        Owner: https://github.com/shveenkov

            .. _R language:
            .. container:: b-connector

                R

                -   R connector for Tarantool 1.6+
                    |star|

                    .. wp_button::
                        :class: b-connector-source-link
                        :link: https://github.com/thekvs/tarantoolr
                        :title: Source
                        :icon: github-icon

                    .. container:: b-connector-owner

                        Owner: https://github.com/thekvs

            .. _Ruby:
            .. container:: b-connector

                Ruby

                -   Ruby connector for Tarantool 1.6+
                    |star|

                    .. wp_button::
                        :class: b-connector-source-link
                        :link: https://github.com/tarantool/tarantool-ruby
                        :title: Source
                        :icon: github-icon

                    .. container:: b-connector-owner

                        Owner: https://github.com/funny-falcon

            .. _Rust:
            .. container:: b-connector

                Rust

                -   Rust connector for Tarantool 1.6+
                    |star|

                    .. wp_button::
                        :class: b-connector-source-link
                        :link: https://github.com/rtsisyk/tarantool-rust
                        :title: Source
                        :icon: github-icon

                    .. container:: b-connector-owner

                        Owner: https://github.com/rtsisyk

            .. _Smalltalk:
            .. container:: b-connector

                Smalltalk

                -   Pharo Smalltalk connector for Tarantool ???
                    |star|

                    .. wp_button::
                        :class: b-connector-source-link
                        :link: https://github.com/mumez/Tarantalk
                        :title: Source
                        :icon: github-icon

                    .. container:: b-connector-owner

                        Owner: https://github.com/mumez/

            .. _Swift:
            .. container:: b-connector

                Swift

                -   Swift connector and stored procedures for Tarantool 1.7
                    |star|

                    .. wp_button::
                        :class: b-connector-source-link
                        :link: https://github.com/tris-foundation/tarantool
                        :title: Source
                        :icon: github-icon

                    .. container:: b-connector-owner

                        Owner: https://github.com/tonyfreeman

            .. _Tarantool:
            .. container:: b-connector

                Tarantool

                -   Built-in net.box module. Ships together with any Tarantool
                    package. See more `here <https://tarantool.org/en/doc/1.7/reference/reference_lua/net_box.html>`_.
                    |star|

                    .. wp_button::
                        :class: b-connector-source-link
                        :link: https://github.com/tris-foundation/tarantool
                        :title: Source
                        :icon: github-icon

                    .. container:: b-connector-owner

                        Owner: https://github.com/tonyfreeman

        .. container:: p-connectors-page-alphabetical-menu

            .. container:: b-alphabetical-menu

                * `C <#c-language>`_
                * |point|
                * `E <#erlang>`_
                * |point|
                * `G <#go>`_
                * |point|
                * `J <#java>`_
                * |point|
                * `L <#lua>`_
                * |point|
                * `N <#node-js>`_
                * |point|
                * `O <#openresty>`_
                * |point|
                * `P <#perl>`_
                * |point|
                * `R <#r-language>`_
                * |point|
                * `S <#smalltalk>`_
                * |point|
                * `T <#tarantool>`_

.. |point| unicode:: U+2022

.. |star| raw:: html

    <div class="b-connector-star-container"><i class="star-icon"></i></div>
