:orphan:
:priority: 0.95

..  _index:

-------------------------------------------------------------------------------
                           Tarantool - Documentation
-------------------------------------------------------------------------------

This manual embraces all aspects of using Tarantool:
from introductory information and exercises for beginners --- to advanced instructions
and detailed references for power users and contributors.


..  panels::
    :container: doc-cards
    :column: doc-card doc-card_medium
    :card: doc-card__content
    :header: doc-card__title
    :body: doc-card__text
    :footer: doc-card__link

    :column: doc-card doc-card_getting-started
    Getting Started

    ^^^

    In this chapter, we show how to work with Tarantool as a DBMS ---
    and how to connect to a Tarantool database from other programming languages.

    +++

    :doc:`Create your first Tarantool database </getting_started/getting_started_db>`

    ---

    Application server

    ^^^

    Working with Tarantool as a Lua application server.

    ---

    Cluster

    ^^^

    Working with Tarantool Cartridge, a framework for developing, deploying and managing applications
    based on Tarantool.

    ---

    Data model

    ^^^

    How Tarantool stores values and what operations with data it supports.

    ---

    Administration

    ^^^

    How to administer Tarantool instances using ``systemd`` and ``tarantoolctl`` utilities.

    ---

    CRUD operations

    ^^^

    How the create, read, update and delete operations are implemented in Tarantool.

    ---

    Replication

    ^^^

    .

    ---

    Indexes

    ^^^

    Special data structure that stores a group of key values and pointers.

    ---

    Transactions

    ^^^

    .

    ---

    Storage engines

    ^^^

    Working with memtx and vinyl storage engines.

    ---

    Streams

    ^^^



    ---

    Connectors

    ^^^

    See the APIs for various programming languages.

    ---

    Access control

    ^^^

    How the access control is implemented in Tarantool.

    ---

    Reference

    ^^^

    .

    ---

    Triggers

    ^^^

    Working with callbacks, functions which the server executes when certain events happen.

    ---

    Tutorials

    ^^^



    ---

    Sharding

    ^^^

    How to use scaling methods when working with databases.

    ---

    Contributing

    ^^^

    See the contributing and building guidelines

    ---

    Release notes

    ^^^

    Check the Tarantool release policy and the release notes.



Main page example
-----------------


..  panels::
    :container: doc-cards
    :column: doc-card doc-card_small
    :card: doc-card__content
    :header: doc-card__logo
    :body: doc-card__title
    :footer: doc-card__text


    :column: doc-card doc-card_getting-started
    Getting Started

    ^^^

    In this chapter, we show how to work with Tarantool as a DBMS ---
    and how to connect to a Tarantool database from other programming languages.

    +++

    :doc:`Create your first Tarantool database </getting_started/getting_started_db>`

    ---

    [img]

    ^^^

    Tarantool Community Edition

    +++

    In-memory computing platform

    ---

    [img]

    ^^^

    Tarantool Data Grid

    +++

    A platform for building data services with ease

    ---

    [img]

    ^^^

    Tarantool Enterprise

    +++

    Enterprise data services with ease

    ---

    [img]

    ^^^

    Tarantool Cartridge

    +++

    Tarantool cluster management with Cartridge network

    ---

    [img]

    ^^^

    Drivers

    +++

    Connectors from various programming languages

    ---

    [img]

    ^^^

    Tools

    +++



    ---


.. wp_section::
    :class: documentation-main-page-header

    .. container:: documentation-main-page-header-path

        |nbsp|

.. wp_section::
    :class: b-documentation-toc

    .. container:: documentation-main-page

        .. container:: documentation-main-page-title

            Tarantool documentation

        .. container:: documentation-main-page-description

            This manual embraces all aspects of using Tarantool: from introductory
            information and exercises for beginners -- to advanced instructions and
            detailed references for power users and contributors.

        .. container:: documentation-main-page-content

            .. ifconfig:: language == 'ru'

                .. NOTE::

                    Документация находится в процессе перевода и может
                    отставать от английской версии.

                .. raw:: html

                    <div class="getting-started-button-container">
                        <a href="getting_started/">
                            <button class="getting-started-button btn main-button">
                                Руководство для начинающих
                            </button>
                        </a>
                    </div>

            .. ifconfig:: language == 'en'

                .. raw:: html

                    <div class="getting-started-button-container">
                        <a href="getting_started/">
                            <button class="getting-started-button btn main-button">
                                Getting started
                            </button>
                        </a>
                    </div>

            .. toctree::
                :maxdepth: 1

                getting_started/index
                book/box/data_model
                CRUD operations <reference/reference_lua/box_space>
                book/box/indexes
                book/box/atomic
                Streams <book/box/stream>
                book/box/authentication
                book/box/triggers
                reference/reference_rock/vshard/vshard_index
                Cluster <book/cartridge/index>
                book/app_server/index
                book/admin/index
                book/replication/index
                book/box/engines/index
                book/connectors
                reference/index
                tutorials/index
                contributing/index
                release
