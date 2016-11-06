:orphan:

---------------------------
Tarantool - Downloads (1.6)
---------------------------

.. wp_section::
    :class: b-block-gray b-downloads-versionlist

    Available version: 1.6 / :doc:`1.7 <download>`

.. wp_section::
    :title: Binary downloads
    :class: b-block-lightgray b-downloads_top

    To simplify problem analysis and avoid various bugs induced by
    compilation parameters and environment, it is recommended that
    production systems use the builds provided on this site.

    All published releases are available at `<http://tarantool.org/dist/1.6>`_

    Hosting is powered by |packagecloud|.

.. wp_section::
    :class: b-block b-downloads

    .. ddlist::

        * Ubuntu

          We maintain an always up-to-date Ubuntu package repository.
          At the moment, the repository contains builds for Ubuntu
          "xenial", "wily", "trusty", "precise".

          In these instructions, ``$release`` is an environment variable which
          will contain the Ubuntu version code (e.g. "precise").

          Copy and paste the script below to the terminal prompt (if you want
          the version that comes with Ubuntu, start with the lines that follow
          the '# install' comment):

          .. code-block:: bash

              curl http://download.tarantool.org/tarantool/1.6/gpgkey | sudo apt-key add -
              release=`lsb_release -c -s`

              # install https download transport for APT
              sudo apt-get -y install apt-transport-https

              # append two lines to a list of source repositories
              sudo rm -f /etc/apt/sources.list.d/*tarantool*.list
              sudo tee /etc/apt/sources.list.d/tarantool_1_6.list <<- EOF
              deb http://download.tarantool.org/tarantool/1.6/ubuntu/ $release main
              deb-src http://download.tarantool.org/tarantool/1.6/ubuntu/ $release main
              EOF

              # install
              sudo apt-get update
              sudo apt-get -y install tarantool

        * Debian Stretch, Jessie and newer

          We maintain an always up-to-date Debian GNU/Linux
          package repository. At the moment, the repository contains builds for
          Debian "stretch" and "jessie". For Debian "wheezy", see personal
          instructions on this page.

          In these instructions, ``$release`` is an environment variable which
          will contain the Debian version code (e.g. "jessie").

          Copy and paste the script below to the terminal prompt:

          .. code-block:: bash

              curl http://download.tarantool.org/tarantool/1.6/gpgkey | sudo apt-key add -
              release=`lsb_release -c -s`

              # install https download transport for APT
              sudo apt-get -y install apt-transport-https

              # append two lines to a list of source repositories
              sudo rm -f /etc/apt/sources.list.d/*tarantool*.list
              sudo tee /etc/apt/sources.list.d/tarantool_1_6.list <<- EOF
              deb http://download.tarantool.org/tarantool/1.6/debian/ $release main
              deb-src http://download.tarantool.org/tarantool/1.6/debian/ $release main
              EOF

              # install
              sudo apt-get update
              sudo apt-get -y install tarantool

        * Debian Wheezy

          We maintain an always up-to-date package repository for Debian "wheezy".

          Copy and paste the script below to the terminal prompt:

          .. code-block:: bash

              curl http://download.tarantool.org/tarantool/1.6/gpgkey | sudo apt-key add -
              release=`lsb_release -c -s`

              # install https download transport for APT
              sudo apt-get -y install apt-transport-https

              # append two lines to a list of source repositories
              sudo rm -f /etc/apt/sources.list.d/*tarantool*.list
              sudo tee /etc/apt/sources.list.d/tarantool_1_6.list <<- EOF
              deb https://packagecloud.io/tarantool/1_6/debian/ wheezy main
              deb-src https://packagecloud.io/tarantool/1_6/debian/ wheezy main
              EOF

              # install
              sudo apt-get update
              sudo apt-get -y install tarantool

        * Fedora

          We maintain an always up-to-date Fedora package repository. At the
          moment, the repository contains builds for Fedora 23 and 24.

          | In these instructions:
          | ``$releasever`` (i.e. Fedora release version) must be 23 or 24
            or rawhide, and
          | ``$basearch`` (i.e. base architecture) must be either i386 or
            x86_64.

          Copy and paste the script below to the terminal prompt:

          .. code-block:: bash

              sudo rm -f /etc/yum.repos.d/*tarantool*.repo
              sudo tee /etc/yum.repos.d/tarantool_1_6.repo <<- EOF
              [tarantool_1_6]
              name=Fedora-\$releasever - Tarantool
              baseurl=http://download.tarantool.org/tarantool/1.6/fedora/\$releasever/\$basearch/
              gpgkey=http://download.tarantool.org/tarantool/1.6/gpgkey
              repo_gpgcheck=1
              gpgcheck=0
              enabled=1

              [tarantool_1_6-source]
              name=Fedora-\$releasever - Tarantool Sources
              baseurl=http://download.tarantool.org/tarantool/1.6/fedora/\$releasever/SRPMS
              gpgkey=http://download.tarantool.org/tarantool/1.6/gpgkey
              repo_gpgcheck=1
              gpgcheck=0
              EOF

              sudo dnf -q makecache -y --disablerepo='*' --enablerepo='tarantool_1_6'
              sudo dnf -y install tarantool

        * RHEL 6 and CentOS 6

          We maintain an always up-to-date package repository for RHEL 6
          derivatives. You may need to enable the `EPEL`_ repository for
          some packages.

          | In these instructions:
          | ``$releasever`` (i.e. CentOS release version) must be 6, and
          | ``$basearch`` (i.e. base architecture) must be either i386
            or x86_64.

          Copy and paste the script below to the terminal prompt:

          .. code-block:: bash

              # Enable EPEL repository
              sudo yum -y install http://dl.fedoraproject.org/pub/epel/epel-release-latest-6.noarch.rpm
              sed 's/enabled=.*/enabled=1/g' -i /etc/yum.repos.d/epel.repo

              # Add Tarantool repository
              sudo rm -f /etc/yum.repos.d/*tarantool*.repo
              sudo tee /etc/yum.repos.d/tarantool_1_6.repo <<- EOF
              [tarantool_1_6]
              name=EnterpriseLinux-\$releasever - Tarantool
              baseurl=http://download.tarantool.org/tarantool/1.6/el/6/\$basearch/
              gpgkey=http://download.tarantool.org/tarantool/1.6/gpgkey
              repo_gpgcheck=1
              gpgcheck=0
              enabled=1

              [tarantool_1_6-source]
              name=EnterpriseLinux-\$releasever - Tarantool Sources
              baseurl=http://download.tarantool.org/tarantool/1.6/el/6/SRPMS
              gpgkey=http://download.tarantool.org/tarantool/1.6/gpgkey
              repo_gpgcheck=1
              gpgcheck=0
              EOF

              # Update metadata
              sudo yum makecache -y --disablerepo='*' --enablerepo='tarantool_1_6' --enablerepo='epel'

              # Install tarantool
              sudo yum -y install tarantool

        * RHEL 7 and CentOS 7

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

        * Amazon Linux

          Amazon Linux is based on RHEL 6 / CentOS 6.
          We maintain an always up-to-date package repository for RHEL 6
          derivatives. You may need to enable the `EPEL`_ repository for some
          packages.

          | In these instructions,
          | ``$releasever`` (i.e. RHEL / CentOS release version) must be 6, and
          | ``$basearch`` (i.e. base architecture) must be either i386 or x86_64.

          Copy and paste the script below to the terminal prompt:

          .. code-block:: bash

              # Enable EPEL repository
              sudo yum -y install http://dl.fedoraproject.org/pub/epel/epel-release-latest-6.noarch.rpm
              sed 's/enabled=.*/enabled=1/g' -i /etc/yum.repos.d/epel.repo

              # Add Tarantool repository
              sudo rm -f /etc/yum.repos.d/*tarantool*.repo
              sudo tee /etc/yum.repos.d/tarantool_1_6.repo <<- EOF
              [tarantool_1_6]
              name=EnterpriseLinux-\$releasever - Tarantool
              baseurl=http://download.tarantool.org/tarantool/1.6/el/6/\$basearch/
              gpgkey=http://download.tarantool.org/tarantool/1.6/gpgkey
              repo_gpgcheck=1
              gpgcheck=0
              enabled=1

              [tarantool_1_6-source]
              name=EnterpriseLinux-\$releasever - Tarantool Sources
              baseurl=http://download.tarantool.org/tarantool/1.6/el/6/SRPMS
              gpgkey=http://download.tarantool.org/tarantool/1.6/gpgkey
              repo_gpgcheck=1
              gpgcheck=0
              EOF

              # Update metadata
              sudo yum makecache -y --disablerepo='*' --enablerepo='tarantool_1_6' --enablerepo='epel'

              # Install Tarantool
              sudo yum -y install tarantool

        * OS X

          You can install Tarantool using ``homebrew``:

          .. code-block:: bash

              $ brew install tarantool
              ==> Downloading https://homebrew.bintray.com/bottles/tarantool-1.6.8-653.el_capitan.bottle.tar.gz
              ######################################################################## 100.0%
              ==> Pouring tarantool-1.6.8-653.el_capitan.bottle.tar.gz
              /usr/local/Cellar/tarantool/1.6.8-653: 17 files, 2.2M

        * FreeBSD

          Tarantool is available from the FreeBSD Ports collection.

          With your browser, go to the `FreeBSD Ports`_ page.
          Enter the search term: `tarantool`.
          Choose the package you want.

          Also, look at the `Fresh Ports`_ page.

          .. _FreeBSD Ports: http://www.freebsd.org/ports/index.html
          .. _Fresh Ports: http://freshports.org/databases/tarantool

        * Microsoft Azure

          Tarantool images are available at `Microsoft Azure`_.

          .. _Microsoft Azure: https://azure.microsoft.com/en-us/marketplace/partners/my-com/tarantool/

        * Docker Hub

          Tarantool images are available at `Docker Hub`_.

          .. _Docker Hub: https://hub.docker.com/r/tarantool/tarantool/

        * Building from source

          To get the latest source files for version 1.6, you can
          clone or download them from the Tarantool repository at `GitHub`_,
          or download them as a `tarball`_.

          Please consult with the Tarantool documentation for
          :ref:`build-from-source <building_from_source>` instructions on
          your system.


.. wp_section::
    :title: Connectors & Extras
    :class: b-block-lightgray b-downloads_top

.. wp_section::
    :class: b-block b-downloads

    .. ddlist::

        * Connectors

          - PHP PECL driver,       `<https://github.com/tarantool/tarantool-php>`_
          - Pure PHP driver,       `<https://github.com/tarantool-php/client>`_
          - Java driver,           `Maven repository`_ or `Java connector GitHub page`_
          - Python driver,         `<http://pypi.python.org/pypi/tarantool>`_
          - Ruby driver,           `<https://github.com/tarantool/tarantool-ruby>`_
          - Perl driver,           `DR:Tarantool`_
          - C connector            `<https://github.com/tarantool/tarantool-c>`_
          - node.js driver,        `<https://github.com/KlonD90/node-tarantool-driver>`_
          - Erlang driver,         `<https://github.com/rtsisyk/etarantool>`_
          - Go driver,             `<https://github.com/tarantool/go-tarantool>`_
          - Lua-nginx driver,      `<https://github.com/ziontab/lua-nginx-tarantool>`_
          - Lua-resty driver,      `<https://github.com/perusio/lua-resty-tarantool>`_
          - Nginx Upstream module, `<https://github.com/tarantool/nginx_upstream_module>`_

.. |packagecloud| image:: packagecloud.png
    :height: 1em
    :target: https://packagecloud.io/

.. _DR\:Tarantool:    http://search.cpan.org/~unera/DR-Tarantool-0.42/lib/DR/Tarantool.pm
.. _Maven repository: http://github.com/tarantool/tarantool-java
.. _Java connector GitHub page: https://github.com/tarantool/tarantool-java
.. _GitHub:    http://github.com/tarantool/tarantool/tree/1.6
.. _tarball:   http://download.tarantool.org/tarantool/1.6/src/
.. _EPEL: https://fedoraproject.org/wiki/EPEL
