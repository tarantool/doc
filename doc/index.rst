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
                platform/index
                how-to/index
                concepts/index
                CRUD operations <reference/reference_lua/box_space>
                book/admin/index
                tooling/index
                connector/index
                enterprise/index
                reference/index
                contributing/index
                release/index
