:orphan:
:priority: 0.99

---------------------------
Tarantool - Downloads (1.7)
---------------------------

.. container:: p-download p-download-mainpage

    .. wp_section::
        :class: p-download-header

        .. container:: b-download-header

            .. container:: b-download-header-path

                Downloads >

            .. container:: b-download-header-versions

                Available versions: :doc:`1.6 (stable) <download_16>` :currentversion:`1.7 (rc)`   :doc:`1.8 (alpha) <download_18>`

    .. wp_section::
        :class: p-download-mainpage-general

        .. container:: b-general-download

            .. raw:: html

                <div class="b-general-download-icon tarantool-download-icon"></div>

            .. container:: b-general-download-text-group

                .. container:: b-general-download-title

                    :doc:`Tarantool 1.6 Download <download>`

                .. container:: b-general-download-description

                    Here is bunch of sources you can check out also you can Download them at oncere pre-installed
                    so that you can get up and running quickly.
                    Here is bunch of sources you can check out also you can Download them at once

    .. wp_section::
        :class: p-download-mainpage-blocks

        .. container:: b-download-block

            .. raw:: html

                <div class="b-download-block-icon-container">
                    <i class="os-installation-icon"></i>
                </div>

            .. container:: b-download-block-text-group

                .. container:: b-download-block-title

                    OS Installation

                .. container:: b-download-block-description

                    There is some instructions how to install tarantool for your OS type.
                    You can choose your OS type insde this card and see other inctructions.

                .. _os-install:    
                .. container:: b-download-block-button

                    :doc:`Learn more → <download/os-installation/ubuntu>`

        .. container:: b-download-block

            .. raw:: html

                <div class="b-download-block-icon-container">
                    <i class="connectors-icon"></i>
                </div>

            .. container:: b-download-block-text-group

                .. container:: b-download-block-title

                    Connectors

                .. container:: b-download-block-description

                    If you’re looking for the latest version of a client driver, prefer rocks and gems to rpms and debs,
                    or looking for an alternative, select a driver from a community-maintained list

                .. container:: b-download-block-button

                    :doc:`Learn more → <download/connectors>`

        .. container:: b-download-block

            .. raw:: html

                <div class="b-download-block-icon-container">
                    <i class="docker-icon"></i>
                </div>

            .. container:: b-download-block-text-group

                .. container:: b-download-block-title

                    Docker

                .. container:: b-download-block-description

                    Tarantool official docker images come with batteries on board:
                    rocks, connectors, and perks are pre-installed so that you can get up and running quickly.

                .. container:: b-download-block-button

                    Learn more →

        .. container:: b-download-block

            .. raw:: html

                <div class="b-download-block-icon-container">
                    <i class="rocks-icon"></i>
                </div>

            .. container:: b-download-block-text-group

                .. container:: b-download-block-title

                    Rocks

                .. container:: b-download-block-description

                    An exhaustive list of all Tarantool modules, installable with luarocks or tarantoolctl.

                .. container:: b-download-block-button

                    Learn more →

    .. container:: p-download-mainpage-enterprise-downloads

        .. container:: b-enterprise-downloads

            .. raw:: html

                <div class="b-enterprise-downloads-icon enterprise-icon"></div>

            .. container:: b-enterprise-downloads-text-group

                .. container:: b-enterprise-downloads-title

                    Enterprise downloads

                .. container:: b-enterprise-downloads-description

                    All tools and everything you need for critical deployments,
                    make your work more comfortable and faster

            .. container:: b-enterprise-downloads-buttons-container

                .. wp_button::
                    :class: b-enterprise-downloads-button
                    :link: https://tarantool.io/unwired
                    :title: Unwired IIOT

                .. wp_button::
                    :class: b-enterprise-downloads-button
                    :link: https://tarantool.io/enterprise
                    :title: Enterprise

.. wp_section::
    :title: Connectors & Extras
    :class: b-block-lightgray b-downloads_top

.. wp_section::
    :class: b-block b-downloads

    .. ddlist::

        * Connectors

          - PHP PECL driver,           `<https://github.com/tarantool/tarantool-php>`_
          - Pure PHP driver,           `<https://github.com/tarantool-php/client>`_
          - Java driver,               `Maven repository`_ or `Java connector GitHub page`_
          - Pure Python driver,        `<http://pypi.python.org/pypi/tarantool>`_
          - Python Gevent driver,      `<https://github.com/shveenkov/gtarantool>`_
          - Python 3.5 asyncio driver, `<https://github.com/igorcoding/asynctnt>`_
          - Python 3.4 asyncio driver, `<https://github.com/shveenkov/aiotarantool>`_
          - Ruby driver,               `<https://github.com/tarantool/tarantool-ruby>`_
          - Perl driver,               `DR:Tarantool`_
          - C connector                `<https://github.com/tarantool/tarantool-c>`_
          - node.js driver,            `<https://github.com/KlonD90/node-tarantool-driver>`_
          - Erlang driver,             `<https://github.com/umatomba/tara>`_
          - Erlang driver,             `<https://github.com/stofel/taran>`_
          - Go driver,                 `<https://github.com/tarantool/go-tarantool>`_
          - Lua-nginx driver,          `<https://github.com/ziontab/lua-nginx-tarantool>`_
          - Lua-resty driver,          `<https://github.com/perusio/lua-resty-tarantool>`_
          - Nginx Upstream module,     `<https://github.com/tarantool/nginx_upstream_module>`_
          - C# driver,                 `<https://github.com/progaudi/tarantool-csharp>`_
          - C# driver,                 `<https://github.com/donmikel/tarantool-net>`_
          - Swift driver and stored procedures, `<https://github.com/tris-foundation/tarantool>`_

.. |packagecloud| image:: /images/packagecloud.png
    :height: 1em
    :target: https://packagecloud.io/

.. _DR\:Tarantool:              http://search.cpan.org/~unera/DR-Tarantool-0.42/lib/DR/Tarantool.pm
.. _Maven repository:           http://github.com/tarantool/tarantool-java
.. _Java connector GitHub page: https://github.com/tarantool/tarantool-java
.. _GitHub:  http://github.com/tarantool/tarantool/tree/1.7
.. _tarball: http://download.tarantool.org/tarantool/1.7/src/
.. _EPEL:    https://fedoraproject.org/wiki/EPEL
