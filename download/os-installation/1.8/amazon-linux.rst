:orphan:
:priority: 0.99

------------------------
Tarantool - Amazon Linux
------------------------

.. container:: b-os-installation-body

    .. container:: b-os-installation-menu

        .. include:: menu.rst

    .. wp_section::
      :title: Amazon Linux
      :class: b-os-installation-content

      Amazon Linux is based on RHEL 6 / CentOS 6.
      We maintain an always up-to-date package repository for RHEL 6
      derivatives. You may need to enable the `EPEL`_ repository for some
      packages.

      | In these instructions,
      | ``$releasever`` (i.e. RHEL / CentOS release version) must be 6, and
      | ``$basearch`` (i.e. base architecture) must be either i386 or x86_64.

      Copy and paste the script below to the *root* terminal prompt:

      .. code-block:: bash

          # Clean up yum cache
          yum clean all
          # Enable EPEL repository
          yum -y install http://dl.fedoraproject.org/pub/epel/epel-release-latest-6.noarch.rpm
          sed 's/enabled=.*/enabled=1/g' -i /etc/yum.repos.d/epel.repo

          # Add Tarantool repository
          rm -f /etc/yum.repos.d/*tarantool*.repo
          tee /etc/yum.repos.d/tarantool_1_8.repo <<- EOF
          [tarantool_1_8]
          name=EnterpriseLinux-\$releasever - Tarantool
          baseurl=http://download.tarantool.org/tarantool/1.8/el/6/\$basearch/
          gpgkey=http://download.tarantool.org/tarantool/1.8/gpgkey
          repo_gpgcheck=1
          gpgcheck=0
          enabled=1

          [tarantool_1_8-source]
          name=EnterpriseLinux-\$releasever - Tarantool Sources
          baseurl=http://download.tarantool.org/tarantool/1.8/el/6/SRPMS
          gpgkey=http://download.tarantool.org/tarantool/1.8/gpgkey
          repo_gpgcheck=1
          gpgcheck=0
          EOF

          # Update metadata
          yum makecache -y --disablerepo='*' --enablerepo='tarantool_1_8' --enablerepo='epel'

          # Install Tarantool
          yum -y install tarantool

.. _EPEL:    https://fedoraproject.org/wiki/EPEL
