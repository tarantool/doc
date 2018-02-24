:orphan:
:priority: 0.99

--------------------------
Tarantool - Snappy package
--------------------------

.. container:: b-os-installation-body

    .. container:: b-os-installation-menu

        .. include:: menu.rst

    .. wp_section::
        :title: Snappy package
        :class: b-os-installation-content

        You can install Tarantool 1.9 (Beta) from a Snappy package:

        .. code-block:: bash

            $ snap install tarantool --channel=beta

        Snaps are universal Linux packages which can be installed across
        a range of Linux distributions.

        Snappy package manager is already pre-installed on Ubuntu Xenial
        and newer. For other distros, you may need to install ``snapd``.
        See http://snapcraft.io/ for detailed instructions.

        Note: initialization scripts, ``systemd`` units and
        ``tarantoolctl`` utility are not included in Snappy packages.
