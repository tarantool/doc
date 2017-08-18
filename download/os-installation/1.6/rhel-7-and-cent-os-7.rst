:orphan:
:priority: 0.99

-------------------------------
Tarantool - RHEL 7 and CentOS 7
-------------------------------

.. container:: b-os-installation-body

    .. container:: b-os-installation-menu

        .. include:: menu.rst

    .. wp_section::
      :title: RHEL 7 and CentOS 7
      :class: b-os-installation-content

      We maintain an always up-to-date package repository for RHEL 7
      derivatives.

      | In these instructions,
      | ``$releasever`` (i.e. CentOS release version) must be 7, and
      | ``$basearch`` (i.e. base architecture) must be either i386 or x86_64.

      Copy and paste the script below to the terminal prompt:

      .. code-block:: bash

          # Add Tarantool repository
          sudo rm -f /etc/yum.repos.d/*tarantool*.repo
          sudo tee /etc/yum.repos.d/tarantool_1_6.repo <<- EOF
          [tarantool_1_6]
          name=EnterpriseLinux-\$releasever - Tarantool
          baseurl=http://download.tarantool.org/tarantool/1.6/el/7/\$basearch/
          gpgkey=http://download.tarantool.org/tarantool/1.6/gpgkey
          repo_gpgcheck=1
          gpgcheck=0
          enabled=1

          [tarantool_1_6-source]
          name=EnterpriseLinux-\$releasever - Tarantool Sources
          baseurl=http://download.tarantool.org/tarantool/1.6/el/7/SRPMS
          gpgkey=http://download.tarantool.org/tarantool/1.6/gpgkey
          repo_gpgcheck=1
          gpgcheck=0
          EOF

          # Update metadata
          sudo yum makecache -y --disablerepo='*' --enablerepo='tarantool_1_6'

          # Install Tarantool
          sudo yum -y install tarantool
