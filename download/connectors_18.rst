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

                :doc:`Downloads <download_18>` > :doc:`Connectors <connectors_18>`

            .. container:: b-download-header-versions

                Available versions:

                :doc:`1.7 (stable) <connectors>`   :currentversion:`1.8 (alpha)`

    .. wp_section::
        :title: Connectors
        :class: p-connectors-page-header

        .. container:: p-connectors-page-header-description

            The recommended connector for each language is marked with a star |starimage|.

            Want your connector listed here? Please drop us a line at `support@tarantool.org <mailto:support@tarantool.org>`_.

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
                        :title:
                        :icon: github-icon

                    .. container:: b-connector-owner

                        Owner: `@bigbes <https://github.com/bigbes>`_

                -   A plain msgpack serialization library. Use it if you wish to write your own
                    connector or embed Tarantool protocol into your application.

                    .. wp_button::
                        :class: b-connector-source-link
                        :link: https://github.com/tarantool/msgpuck
                        :title:
                        :icon: github-icon

                    .. container:: b-connector-owner

                        Owner: `@rtisisyk <https://github.com/rtisisyk>`_

            .. _C#:
            .. container:: b-connector

                C#

                -   .Net connector for Tarantool 1.6+. Offers a full-featured support of Tarantool's binary protocol,
                    async API and multiplexing.
                    |star|

                    .. wp_button::
                        :class: b-connector-source-link
                        :link: https://github.com/progaudi/progaudi.tarantool
                        :title:
                        :icon: github-icon

                    .. container:: b-connector-owner

                        Owner: `@aensidhe <https://github.com/aensidhe>`_, `@roman-kozachenko <https://github.com/roman-kozachenko>`_

                -   .Net connector for Tarantool 1.6. Based on the Akka.Net I/O package.

                    .. wp_button::
                        :class: b-connector-source-link
                        :link: https://github.com/donmikel/tarantool-net
                        :title:
                        :icon: github-icon

                    .. container:: b-connector-owner

                        Owner: `@donmikel <https://github.com/donmikel>`_

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
                        :title:
                        :icon: github-icon

                    .. container:: b-connector-owner

                        Owner: `@stofel <https://github.com/stofel>`_

                -   Erlang connector for Tarantool 1.7+. Based on simplepool.

                    .. wp_button::
                        :class: b-connector-source-link
                        :link: https://github.com/umatomba/tara
                        :title:
                        :icon: github-icon

                    .. container:: b-connector-owner

                        Owner: `@brigadier <https://github.com/brigadier>`_

                -   Native Elixir connector for Tarantool 1.6.

                    .. wp_button::
                        :class: b-connector-source-link
                        :link: https://github.com/progress-engine/tarantool.ex
                        :title:
                        :icon: github-icon

                    .. container:: b-connector-owner

                        Owner: `@spscream <https://github.com/spscream>`_

            .. _Go:
            .. container:: b-connector

                Go

                -   Go connector for Tarantool 1.6+.
                    |star|

                    .. wp_button::
                        :class: b-connector-source-link
                        :link: https://github.com/tarantool/go-tarantool
                        :title:
                        :icon: github-icon

                    .. container:: b-connector-owner

                        Owner: `@funny-falcon <https://github.com/funny-falcon>`_, `@mialinx <https://github.com/mialinx>`_

                -   Go connector for Tarantool 1.6+.

                    .. wp_button::
                        :class: b-connector-source-link
                        :link: https://github.com/viciious/go-tarantool
                        :title:
                        :icon: github-icon

                    .. container:: b-connector-owner

                        Owner: `@viciious <https://github.com/viciious>`_

            .. _Java:
            .. container:: b-connector

                Java

                -   Java connector for Tarantool 1.6+
                    |star|

                    .. wp_button::
                        :class: b-connector-source-link
                        :link: https://github.com/tarantool/tarantool-java
                        :title:
                        :icon: github-icon

                    .. container:: b-connector-owner

                        Owner: `@dgreenru <https://github.com/dgreenru>`_

            .. _Lua:
            .. container:: b-connector

                Lua

                -   Pure Lua connector for Tarantool 1.7+. Works on nginx cosockets and plain Lua sockets.
                    |star|

                    .. wp_button::
                        :class: b-connector-source-link
                        :link: https://github.com/tarantool/tarantool-lua
                        :title:
                        :icon: github-icon

                    .. container:: b-connector-owner

                        Owner: `@csteenberg <https://github.com/csteenberg>`_

            .. _Node.js:
            .. container:: b-connector

                Node.js

                -   Node connector for Tarantool 1.6+.
                    |star|

                    .. wp_button::
                        :class: b-connector-source-link
                        :link: https://github.com/tarantool/tarantool-node
                        :title:
                        :icon: github-icon

                    .. container:: b-connector-owner

                        Owner: `@KlonD90 <https://github.com/KlonD90>`_

            .. _NginX:
            .. container:: b-connector

                NginX

                -   NginX upstream module for Tarantool 1.6+. Features REST, JSON API, websockets, load balancing.
                    |star|

                    .. wp_button::
                        :class: b-connector-source-link
                        :link: https://github.com/tarantool/nginx_upstream_module
                        :title:
                        :icon: github-icon

                    .. container:: b-connector-owner

                        Owner: `@dedok <https://github.com/dedok>`_

            .. _OpenResty:
            .. container:: b-connector

                OpenResty

                -   Connector for working with Tarantool 1.6 from nginx with an embedded Lua module or with OpenResty.
                    |star|

                    .. wp_button::
                        :class: b-connector-source-link
                        :link: https://github.com/perusio/lua-resty-tarantool
                        :title:
                        :icon: github-icon

                    .. container:: b-connector-owner

                        Owner: `@perusio <https://github.com/perusio>`_

                -   Lua connector for Tarantool 1.6 on OpenResty nginx cosockets.

                    .. wp_button::
                        :class: b-connector-source-link
                        :link: https://github.com/ziontab/lua-nginx-tarantool
                        :title:
                        :icon: github-icon

                    .. container:: b-connector-owner

                        Owner: `@hengestone <https://github.com/hengestone>`_

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
                        :title:
                        :icon: github-icon

                    .. container:: b-connector-owner

                        Owner: `@Awety <https://github.com/Awety>`_

                -   EV connector for Tarantool 1.6+. Asynchronous, fast, supports schemas
                    (incl. fields) for on-the-fly tuple-to-hash and backward transformations,
                    supports Types::Serializer for transparent conversion to JSON.

                    .. wp_button::
                        :class: b-connector-source-link
                        :link: https://github.com/igorcoding/EV-Tarantool16
                        :title:
                        :icon: github-icon

                    .. container:: b-connector-owner

                        Owner: `@igorcoding <https://github.com/igorcoding>`_, `@mons <https://github.com/mons>`_

            .. _PHP:
            .. container:: b-connector

                PHP

                -   PECL PHP connector for Tarantool 1.6+
                    |star|

                    .. wp_button::
                        :class: b-connector-source-link
                        :link: https://github.com/tarantool/tarantool-php
                        :title:
                        :icon: github-icon

                    .. container:: b-connector-owner

                        Owner: `@bigbes <https://github.com/bigbes>`_

                -   Pure PHP connector for Tarantool 1.6+. Includes a client and a mapper.

                    .. wp_button::
                        :class: b-connector-source-link
                        :link: https://github.com/tarantool-php
                        :title:
                        :icon: github-icon

                    .. container:: b-connector-owner

                        Owner: `@rybakit <https://github.com/rybakit>`_, `@nekufa <https://github.com/nekufa>`_

            .. _Python:
            .. container:: b-connector

                Python

                -   Pure Python connector for Tarantool 1.6+, also available from
                    `pypi <http://pypi.python.org/pypi/tarantool>`_
                    |star|

                    .. wp_button::
                        :class: b-connector-source-link
                        :link: https://github.com/tarantool/tarantool-python
                        :title:
                        :icon: github-icon

                    .. container:: b-connector-owner

                        Owner: `@bigbes <https://github.com/bigbes>`_

                -   Python Gevent driver for Tarantool 1.6

                    .. wp_button::
                        :class: b-connector-source-link
                        :link: https://github.com/shveenkov/gtarantool
                        :title:
                        :icon: github-icon

                    .. container:: b-connector-owner

                        Owner: `@shveenkov <https://github.com/shveenkov>`_

                -   Python 3.5 asyncio driver for Tarantool 1.6+

                    .. wp_button::
                        :class: b-connector-source-link
                        :link: https://github.com/igorcoding/asynctnt
                        :title:
                        :icon: github-icon

                    .. container:: b-connector-owner

                        Owner: `@igorcoding <https://github.com/igorcoding>`_

                -   Python 3.4 asyncio driver for Tarantool 1.6

                    .. wp_button::
                        :class: b-connector-source-link
                        :link: https://github.com/shveenkov/aiotarantool
                        :title:
                        :icon: github-icon

                    .. container:: b-connector-owner

                        Owner: `@shveenkov <https://github.com/shveenkov>`_

            .. _R language:
            .. container:: b-connector

                R

                -   R connector for Tarantool 1.6+
                    |star|

                    .. wp_button::
                        :class: b-connector-source-link
                        :link: https://github.com/thekvs/tarantoolr
                        :title:
                        :icon: github-icon

                    .. container:: b-connector-owner

                        Owner: `@thekvs <https://github.com/thekvs>`_

            .. _Ruby:
            .. container:: b-connector

                Ruby

                -   Ruby connector for Tarantool 1.6+
                    |star|

                    .. wp_button::
                        :class: b-connector-source-link
                        :link: https://github.com/tarantool/tarantool-ruby
                        :title:
                        :icon: github-icon

                    .. container:: b-connector-owner

                        Owner: `@funny-falcon <https://github.com/funny-falcon>`_

            .. _Rust:
            .. container:: b-connector

                Rust

                -   Rust connector for Tarantool 1.6+
                    |star|

                    .. wp_button::
                        :class: b-connector-source-link
                        :link: https://github.com/rtsisyk/tarantool-rust
                        :title:
                        :icon: github-icon

                    .. container:: b-connector-owner

                        Owner: `@rtsisyk <https://github.com/rtsisyk>`_

            .. _Smalltalk:
            .. container:: b-connector

                Smalltalk

                -   Pharo Smalltalk connector for Tarantool 1.6+. Includes object-oriented
                    wrapper classes for easier use, automatic connection handling (pooling,
                    reconnect). An additional module
                    (`Tarantube <http://smalltalkhub.com/#!/~MasashiUmezawa/Tarantube>`_)
                    provides queue interfaces.

                    |star|

                    .. wp_button::
                        :class: b-connector-source-link
                        :link: https://github.com/mumez/Tarantalk
                        :title:
                        :icon: github-icon

                    .. container:: b-connector-owner

                        Owner: `@mumez <https://github.com/mumez/>`_

            .. _Swift:
            .. container:: b-connector

                Swift

                -   Swift connector and stored procedures for Tarantool 1.7
                    |star|

                    .. wp_button::
                        :class: b-connector-source-link
                        :link: https://github.com/tris-foundation/tarantool
                        :title:
                        :icon: github-icon

                    .. container:: b-connector-owner

                        Owner: `@tonyfreeman <https://github.com/tonyfreeman>`_

            .. _Tarantool:
            .. container:: b-connector

                Tarantool

                -   Built-in net.box module. Ships together with any Tarantool
                    package. See more `here <https://tarantool.org/en/doc/1.7/reference/reference_lua/net_box.html>`_.
                    |star|

                    .. wp_button::
                        :class: b-connector-source-link
                        :link: https://github.com/tris-foundation/tarantool
                        :title:
                        :icon: github-icon

                    .. container:: b-connector-owner

                        Owner: `@tonyfreeman <https://github.com/tonyfreeman>`_

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

.. |starimage| image:: /images/star-icon.png
    :height: 18px

.. |point| unicode:: U+2022

.. |star| raw:: html

    <div class="b-connector-star-container"><i class="star-icon"></i></div>
