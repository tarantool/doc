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

        Copy and paste the script below to the *root* terminal prompt:

        .. code-block:: bash

            # Clean up yum cache
            yum clean all

            # Enable EPEL repository
            yum -y install http://dl.fedoraproject.org/pub/epel/epel-release-latest-6.noarch.rpm
            sed 's/enabled=.*/enabled=1/g' -i /etc/yum.repos.d/epel.repo

            # Add Tarantool repository
            rm -f /etc/yum.repos.d/*tarantool*.repo
            tee /etc/yum.repos.d/tarantool_1_9.repo <<- EOF
            [tarantool_1_9]
            name=EnterpriseLinux-6 - Tarantool
            baseurl=http://download.tarantool.org/tarantool/1.9/el/6/x86_64/
            gpgkey=http://download.tarantool.org/tarantool/1.9/gpgkey
            repo_gpgcheck=1
            gpgcheck=0
            enabled=1

            [tarantool_1_9-source]
            name=EnterpriseLinux-6 - Tarantool Sources
            baseurl=http://download.tarantool.org/tarantool/1.9/el/6/SRPMS
            gpgkey=http://download.tarantool.org/tarantool/1.9/gpgkey
            repo_gpgcheck=1
            gpgcheck=0
            EOF

            # Update metadata
            yum makecache -y --disablerepo='*' --enablerepo='tarantool_1_9' --enablerepo='epel'

            # Install Tarantool
            yum -y install tarantool

.. _EPEL:    https://fedoraproject.org/wiki/EPEL
