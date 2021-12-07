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

    Cluster

    ^^^



    ---

    Application server

    ^^^

    Working with Tarantool as a Lua application server.

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

    How the create, read, update and delete operations are implemented in Tarantool.

    ---

    Indexes

    ^^^

    How the create, read, update and delete operations are implemented in Tarantool.

    ---

    Transactions

    ^^^

    How the create, read, update and delete operations are implemented in Tarantool.

    ---

    Storage engines

    ^^^


    ---

    Streams

    ^^^



    ---

    Connectors

    ^^^

    How the create, read, update and delete operations are implemented in Tarantool.

    ---

    Access control

    ^^^

    How the create, read, update and delete operations are implemented in Tarantool.

    ---

    Reference

    ^^^

    How the create, read, update and delete operations are implemented in Tarantool.

    ---

    Replication

    ^^^

    How the create, read, update and delete operations are implemented in Tarantool.

    ---

    Triggers

    ^^^



    ---

    Tutorials

    ^^^



    ---

    Sharding

    ^^^


    ---

    Contributing

    ^^^



    ---

    Release notes

    ^^^












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

    Enterprise data services with ease.

    ---


    [img]

    ^^^

    Tarantool Enterprise

    +++

    Enterprise data services with ease.

    ---


    [img]

    ^^^

    Tarantool Cartridge

    +++

    Enterprise data services with ease.

    ---


    [img]

    ^^^

    Drivers

    +++

    Enterprise data services with ease.

    ---


    [img]

    ^^^

    Tools

    +++

    Enterprise data services with ease.

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
