:orphan:
:noindex:
:fullwidth:
:priority: 0.95

..  _index:

-------------------------------------------------------------------------------
                           Tarantool -- Documentation
-------------------------------------------------------------------------------

.. wp_section::
    :class: b-documentation-toc

    .. container:: documentation-main-page

        .. container:: documentation-main-page-content

            .. ifconfig:: language == 'ru'

                .. note::

                   Документация на русском языке
                   `поддерживается сообществом <https://github.com/tarantool/doc/discussions/2738>`__
                   и может отставать от англоязычной.
                   `Перейти в английскую версию <../../../en/doc>`__.

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

            ..  toctree::
                :maxdepth: 1

                overview
                getting_started/index
                book/box/data_model
                CRUD operations <reference/reference_lua/box_space>
                book/box/indexes
                book/box/atomic
                book/box/authentication
                book/box/triggers
                reference/reference_rock/vshard/vshard_index
                Cluster on Cartridge <book/cartridge/index>
                book/app_server/index
                book/admin/index
                book/replication/index
                book/box/engines/index
                book/connectors
                how-to/index
                reference/index
                contributing/index
                release/index
