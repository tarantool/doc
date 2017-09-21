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

                :doc:`Downloads <download>` >

            .. container:: b-download-header-versions

                Available versions:

                :currentversion:`1.7 (stable)`  :doc:`1.8 (alpha) <download_18>`

    .. wp_section::
        :class: p-download-mainpage-general

        .. container:: b-general-download

            .. raw:: html

                <div class="b-general-download-icon tarantool-download-icon"></div>

            .. container:: b-general-download-text-group

                .. container:: b-general-download-title

                    :doc:`Tarantool 1.7 downloads <download>`

                .. container:: b-general-download-description

                    Here is a bunch of free downloads and whatever
                    you may need for Tarantool.

                .. container:: b-download-block-button

                    :doc:`Learn more → <os-installation/1.7/docker-hub>`

    .. wp_section::
        :class: p-download-mainpage-blocks

        .. download_page_block::
            :title: Packages
            :class: b-download-block packages
            :icon: os-installation-icon
            :buttontext: Learn more →
            :buttonlink: os-installation/1.7/docker-hub.html

            We're building packages for
            a variety of operating systems.
            Choose your OS and follow the installation instructions.
            Hosting is powered by |packagecloud|

        .. download_page_block::
            :title: Connectors
            :class: b-download-block
            :icon: connectors-icon
            :buttontext: Learn more →
            :buttonlink: connectors.html

            If you’re looking for the latest version of a client driver,
            prefer rocks and gems to rpms and debs,
            or want to try out an alternative, choose a driver from
            a community-maintained list.

        .. download_page_block::
            :title: Docker
            :class: b-download-block
            :icon: docker-icon
            :buttontext: Learn more →
            :buttonlink: https://hub.docker.com/r/tarantool/tarantool/

            Official Tarantool images for Docker come with batteries
            on board: modules, connectors and perks are pre-installed
            so that you can get up and running quickly.

        .. download_page_block::
            :title: Modules
            :class: b-download-block
            :icon: rocks-icon
            :buttontext: Learn more →
            :buttonlink: rocks.html

            An exhaustive list of all Tarantool modules,
            installable with ``luarocks`` or ``tarantoolctl``.

    .. wp_section::
        :class: p-download-mainpage-enterprise-downloads

        .. container:: b-enterprise-downloads

            .. raw:: html

                <div class="b-enterprise-downloads-icon enterprise-icon"></div>

            .. container:: b-enterprise-downloads-text-group

                .. container:: b-enterprise-downloads-title

                    Enterprise downloads

                .. container:: b-enterprise-downloads-description

                    `Carrier-grade edition <https://tarantool.io/try-it>`_
                    for critical deployments.

            .. container:: b-enterprise-downloads-buttons-container

                .. wp_button::
                    :class: b-enterprise-downloads-button
                    :link: https://tarantool.io/unwired
                    :title: Unwired IIOT

                .. wp_button::
                    :class: b-enterprise-downloads-button
                    :link: https://tarantool.io/enterprise
                    :title: Enterprise

.. |packagecloud| image:: /images/packagecloud.png
    :height: 1em
    :target: https://packagecloud.io/

.. _DR\:Tarantool:              http://search.cpan.org/~unera/DR-Tarantool-0.42/lib/DR/Tarantool.pm
.. _Maven repository:           http://github.com/tarantool/tarantool-java
.. _Java connector GitHub page: https://github.com/tarantool/tarantool-java
.. _GitHub:  http://github.com/tarantool/tarantool/tree/1.7
.. _tarball: http://download.tarantool.org/tarantool/1.7/src/
.. _EPEL:    https://fedoraproject.org/wiki/EPEL
