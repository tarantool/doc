:orphan:
:priority: 0.99

------------------
Tarantool - Fedora
------------------

.. container:: b-os-installation-body

    .. container:: b-os-installation-menu

        .. include:: menu.rst

    .. wp_section::
      :title: Fedora
      :class: b-os-installation-content

      We maintain an always up-to-date Fedora package repository. At the
      moment, the repository contains builds for Fedora 23 and 24.

      In these instructions, ``$releasever`` is an environment variable which
      will contain the Fedora release version ("23", "24" or "rawhide").

      Copy and paste the script below to the terminal prompt:

      .. code-block:: bash

          sudo rm -f /etc/yum.repos.d/*tarantool*.repo
          sudo tee /etc/yum.repos.d/tarantool_1_7.repo <<- EOF
          [tarantool_1_7]
          name=Fedora-\$releasever - Tarantool
          baseurl=http://download.tarantool.org/tarantool/1.7/fedora/\$releasever/x86_64/
          gpgkey=http://download.tarantool.org/tarantool/1.7/gpgkey
          repo_gpgcheck=1
          gpgcheck=0
          enabled=1

          [tarantool_1_7-source]
          name=Fedora-\$releasever - Tarantool Sources
          baseurl=http://download.tarantool.org/tarantool/1.7/fedora/\$releasever/SRPMS
          gpgkey=http://download.tarantool.org/tarantool/1.7/gpgkey
          repo_gpgcheck=1
          gpgcheck=0
          EOF

          sudo dnf -q makecache -y --disablerepo='*' --enablerepo='tarantool_1_7'
          sudo dnf -y install tarantool
