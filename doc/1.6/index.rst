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

            Tarantool 1.6 manual

        .. container:: documentation-main-page-description

            This manual embraces all aspects of using Tarantool: from introductory
            information and exercises for beginners -- to advanced instructions and
            detailed references for power users and contributors.

            Before you take a deep dive:

            * Have a quick look at `Tarantool online <https://www.tarantool.io/en/try-dev/>`_!
            * Try it out locally with the `getting started guide <https://www.tarantool.io/en/doc/1.6/book/getting_started/>`_.

            If you are new to Tarantool, start from scratch by learning the :ref:`fundamentals <fundamentals>`.

            If you are a power user, :ref:`skip the basics <beyond_the_basics>`.

            |

            .. _fundamentals:

            |lego| **Level 1 -- fundamentals**

            To understand what Tarantool is all about, check out the `overview <https://www.tarantool.io/en/doc/1.6/intro/>`_.

            To start using Tarantool as a *database manager*, familiarize yourself
            with the `database concepts <https://www.tarantool.io/en/doc/1.6/book/box/>`_.

            To start using Tarantool as an *application server*, create and run
            a real application following our `step-by-step instructions <https://www.tarantool.io/en/doc/1.6/book/app_server/>`_.

            `Connect <https://www.tarantool.io/en/doc/1.6/book/connectors/>`_ to Tarantool
            with your language of choice.

            Finally, learn to `administer Tarantool instances <https://www.tarantool.io/en/doc/1.6/book/admin/>`_
            in a powerful fashion!

            |

            .. _beyond_the_basics:

            |cogs| **Level 2 -- beyond the basics**

            To utilize Tarantool to the fullest:

            * Make it fault-tolerant with the built-in `replication <https://www.tarantool.io/en/doc/1.6/book/replication/>`_.
            * Scale it with the built-in `sharding <https://www.tarantool.io/en/doc/1.10/reference/reference_rock/vshard/>`_.
            * Do not ‘reinvent the wheel’, use the `built-in modules <https://www.tarantool.io/en/doc/1.6/reference/reference_lua/>`_
              or plug `rock modules <https://www.tarantool.io/en/doc/1.6/reference/reference_rock/>`_
              with the functionality you need.
            * Complete our `tutorials <https://www.tarantool.io/en/doc/1.6/tutorials/>`_ to learn more.

            |

            .. _contribute:

            |atom| **Level 3 -- contribute!**

            Tarantool has a growing open source community. Join our friendly developer’s
            `chat in Telegram <https://telegram.me/tarantool>`_.

            Become a Tarantool developer:

            * `Build from source <https://www.tarantool.io/en/doc/1.6/dev_guide/build_contribute_index/>`_.
            * Go through the `guidelines <https://www.tarantool.io/en/doc/1.6/dev_guide/guidelines_index/>`_.
            * `Contribute! <https://github.com/tarantool>`_

        .. container:: documentation-main-page-content

            .. ifconfig:: language == 'ru'

                .. NOTE::

                    Документация находится в процессе перевода и может
                    отставать от английской версии.

            .. include:: singlehtml.rst

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

.. |lego| image:: icons/lego.png
   :scale: 6%

.. |cogs| image:: icons/cogs.png
   :scale: 7%

.. |atom| image:: icons/atom.png
   :scale: 6%
