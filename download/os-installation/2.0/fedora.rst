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
        moment, the repository contains builds for Fedora 25 and 26.

        Copy and paste the script below to the terminal prompt:

        * For Fedora 25:

          .. code-block:: bash

              sudo rm -f /etc/yum.repos.d/*tarantool*.repo
              sudo tee /etc/yum.repos.d/tarantool_2_0.repo <<- EOF
              [tarantool_2_0]
              name=Fedora-25 - Tarantool
              baseurl=http://download.tarantool.org/tarantool/2.0/fedora/25/x86_64/
              gpgkey=http://download.tarantool.org/tarantool/2.0/gpgkey
              repo_gpgcheck=1
              gpgcheck=0
              enabled=1

              [tarantool_2_0-source]
              name=Fedora-25 - Tarantool Sources
              baseurl=http://download.tarantool.org/tarantool/2.0/fedora/25/SRPMS
              gpgkey=http://download.tarantool.org/tarantool/2.0/gpgkey
              repo_gpgcheck=1
              gpgcheck=0
              EOF

              sudo dnf -q makecache -y --disablerepo='*' --enablerepo='tarantool_2_0'
              sudo dnf -y install tarantool

        * For Fedora 26:

          .. code-block:: bash

              sudo rm -f /etc/yum.repos.d/*tarantool*.repo
              sudo tee /etc/yum.repos.d/tarantool_2_0.repo <<- EOF
              [tarantool_2_0]
              name=Fedora-26 - Tarantool
              baseurl=http://download.tarantool.org/tarantool/2.0/fedora/26/x86_64/
              gpgkey=http://download.tarantool.org/tarantool/2.0/gpgkey
              repo_gpgcheck=1
              gpgcheck=0
              enabled=1

              [tarantool_2_0-source]
              name=Fedora-26 - Tarantool Sources
              baseurl=http://download.tarantool.org/tarantool/2.0/fedora/26/SRPMS
              gpgkey=http://download.tarantool.org/tarantool/2.0/gpgkey
              repo_gpgcheck=1
              gpgcheck=0
              EOF

              sudo dnf -q makecache -y --disablerepo='*' --enablerepo='tarantool_2_0'
              sudo dnf -y install tarantool
