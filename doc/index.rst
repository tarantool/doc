:orphan:
:priority: 0.95

-------------------------------------------------------------------------------
                           Tarantool - Documentation
-------------------------------------------------------------------------------

.. wp_section::
    :class: documentation-main-page-header

    .. container:: documentation-main-page-header-path

        |nbspc|

.. wp_section::
    :class: b-documentation-toc

    .. container:: documentation-main-page

        .. container:: documentation-main-page-title

            Tarantool 1.10 manual

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
                            <button class="getting-started-button btn">
                                Руководство для начинающих
                            </button>
                        </a>
                    </div>

            .. ifconfig:: language == 'en'

                .. raw:: html

                    <div class="getting-started-button-container">
                        <a href="getting_started/">
                            <button class="getting-started-button btn">
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
                Transactions <book/box/atomic>
                book/box/authentication
                book/box/triggers
                reference/reference_rock/vshard/vshard_index
                Cluster <book/cartridge/index>
                book/app_server/index
                book/admin/index
                book/replication/index
                book/box/engines/index
                book/connectors/index
                reference/index
                tutorials/index
                contributing/index
                whats_new


        .. container:: other-sources-menu

            .. raw:: html

                <div class="badge-icon"></div>

            * **Other formats:**
            * `Single-page HTML <singlehtml.html>`_
            * `PDF <Tarantool.pdf>`_
            - **See also:**
            - `Documentation archive`_
            - `Articles`_
            .. ifconfig:: language == 'ru'

                * **Support:**
                * `Форум в Google`_
                * `Чат в Telegram`_
            .. ifconfig:: language == 'en'

                * **Support:**
                * `Google forum`_
                * `Telegram chat`_

.. _Documentation archive: https://tarantool.io/dist/pdf/
.. _Articles: https://tarantool.io/learn/
.. _Google forum: https://groups.google.com/forum/#!forum/tarantool
.. _Форум в Google: https://googlegroups.com/group/tarantool-ru
.. _Telegram chat: https://t.me/tarantool
.. _Чат в Telegram: https://t.me/tarantoolru
.. |nbspc| unicode:: U+00A0
.. |space| unicode:: U+0020
