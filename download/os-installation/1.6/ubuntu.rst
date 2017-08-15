:orphan:
:priority: 0.99

------------------
Tarantool - Ubuntu
------------------

.. container:: b-os-installation-body

    .. container:: b-os-installation-menu

        .. include:: menu.rst

    .. wp_section::
        :title: Ubuntu precise
        :class: b-os-installation-content

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
