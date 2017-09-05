:orphan:
:priority: 0.99

-------------------------------
Tarantool - RHEL/CentOS 6 and 7
-------------------------------

.. container:: b-os-installation-body

    .. container:: b-os-installation-menu

        .. include:: menu.rst

    .. wp_section::
        :title: RHEL/CentOS 6 and 7
        :class: b-os-installation-content

        We maintain an always up-to-date package repository for the
        derivatives of RHEL 6 and 7.

        Copy and paste the script below to the *root* terminal prompt:

        .. code-block:: bash

            # Clean up yum cache
            yum clean all
            # Add Tarantool repository
            rm -f /etc/yum.repos.d/*tarantool*.repo
            tee /etc/yum.repos.d/tarantool_1_6.repo <<- EOF
            [tarantool_1_6]
            name=EnterpriseLinux-\$releasever - Tarantool
            baseurl=http://download.tarantool.org/tarantool/1.6/el/\$releasever/\$basearch/
            gpgkey=http://download.tarantool.org/tarantool/1.6/gpgkey
            repo_gpgcheck=1
            gpgcheck=0
            enabled=1

            [tarantool_1_6-source]
            name=EnterpriseLinux-\$releasever - Tarantool Sources
            baseurl=http://download.tarantool.org/tarantool/1.6/el/\$releasever/SRPMS
            gpgkey=http://download.tarantool.org/tarantool/1.6/gpgkey
            repo_gpgcheck=1
            gpgcheck=0
            EOF

            # Update metadata
            yum makecache -y --disablerepo='*' --enablerepo='tarantool_1_6'

            # Install Tarantool
            yum -y install tarantool