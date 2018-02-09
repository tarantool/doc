:orphan:
:priority: 0.99

------------------
Tarantool - Ubuntu
------------------

.. container:: b-os-installation-body

    .. container:: b-os-installation-menu

        .. include:: menu.rst

    .. wp_section::
        :title: Ubuntu
        :class: b-os-installation-content

        We maintain an always up-to-date Ubuntu package repository.
        At the moment, the repository contains builds for Ubuntu
        "xenial", "wily", "trusty", "precise".

        Copy and paste the script below to the terminal prompt (if you want
        the version that comes with Ubuntu, start with the lines that follow
        the '# install...' comment):

        * For Ubuntu "xenial":

          .. code-block:: bash

            curl http://download.tarantool.org/tarantool/1.8/gpgkey | sudo apt-key add -
            release=`lsb_release -c -s`

            # install https download transport for APT
            sudo apt-get -y install apt-transport-https

            # append two lines to a list of source repositories
            sudo rm -f /etc/apt/sources.list.d/*tarantool*.list
            echo "deb http://download.tarantool.org/tarantool/1.8/ubuntu/ xenial main" > /etc/apt/sources.list.d/tarantool_1_8.list
            echo "deb-src http://download.tarantool.org/tarantool/1.8/ubuntu/ xenial main" >> /etc/apt/sources.list.d/tarantool_1_8.list

            # install
            sudo apt-get update
            sudo apt-get -y install tarantool

        * For Ubuntu "wily":

          .. code-block:: bash

            curl http://download.tarantool.org/tarantool/1.8/gpgkey | sudo apt-key add -
            release=`lsb_release -c -s`

            # install https download transport for APT
            sudo apt-get -y install apt-transport-https

            # append two lines to a list of source repositories
            sudo rm -f /etc/apt/sources.list.d/*tarantool*.list
            echo "deb http://download.tarantool.org/tarantool/1.8/ubuntu/ wily main" > /etc/apt/sources.list.d/tarantool_1_8.list
            echo "deb-src http://download.tarantool.org/tarantool/1.8/ubuntu/ wily main" >> /etc/apt/sources.list.d/tarantool_1_8.list

            # install
            sudo apt-get update
            sudo apt-get -y install tarantool

        * For Ubuntu "trusty":

          .. code-block:: bash

            curl http://download.tarantool.org/tarantool/1.8/gpgkey | sudo apt-key add -
            release=`lsb_release -c -s`

            # install https download transport for APT
            sudo apt-get -y install apt-transport-https

            # append two lines to a list of source repositories
            sudo rm -f /etc/apt/sources.list.d/*tarantool*.list
            echo "deb http://download.tarantool.org/tarantool/1.8/ubuntu/ trusty main" > /etc/apt/sources.list.d/tarantool_1_8.list
            echo "deb-src http://download.tarantool.org/tarantool/1.8/ubuntu/ trusty main" >> /etc/apt/sources.list.d/tarantool_1_8.list

            # install
            sudo apt-get update
            sudo apt-get -y install tarantool

        * For Ubuntu "precise":

          .. code-block:: bash

            curl http://download.tarantool.org/tarantool/1.8/gpgkey | sudo apt-key add -
            release=`lsb_release -c -s`

            # install https download transport for APT
            sudo apt-get -y install apt-transport-https

            # append two lines to a list of source repositories
            sudo rm -f /etc/apt/sources.list.d/*tarantool*.list
            echo "deb http://download.tarantool.org/tarantool/1.8/ubuntu/ precise main" > /etc/apt/sources.list.d/tarantool_1_8.list
            echo "deb-src http://download.tarantool.org/tarantool/1.8/ubuntu/ precise main" >> /etc/apt/sources.list.d/tarantool_1_8.list

            # install
            sudo apt-get update
            sudo apt-get -y install tarantool
