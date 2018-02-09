:orphan:
:priority: 0.99

------------------
Tarantool - Debian
------------------

.. container:: b-os-installation-body

    .. container:: b-os-installation-menu

        .. include:: menu.rst

    .. wp_section::
        :title: Debian
        :class: b-os-installation-content

        We maintain an always up-to-date Debian GNU/Linux
        package repository. At the moment, the repository contains builds for
        Debian "stretch", "jessie" and "wheezy".

        Copy and paste the script below to the terminal prompt:

        * For Debian "stretch":

          .. code-block:: bash

              curl http://download.tarantool.org/tarantool/1.8/gpgkey | sudo apt-key add -
              release=`lsb_release -c -s`

              # install https download transport for APT
              sudo apt-get -y install apt-transport-https

              # append two lines to a list of source repositories
              sudo rm -f /etc/apt/sources.list.d/*tarantool*.list
              echo "deb http://download.tarantool.org/tarantool/1.8/debian/ stretch main" > /etc/apt/sources.list.d/tarantool_1_8.list
              echo "deb-src http://download.tarantool.org/tarantool/1.8/debian/ stretch main" >> /etc/apt/sources.list.d/tarantool_1_8.list

              # install
              sudo apt-get update
              sudo apt-get -y install tarantool

        * For Debian "jessie":

          .. code-block:: bash

              curl http://download.tarantool.org/tarantool/1.8/gpgkey | sudo apt-key add -
              release=`lsb_release -c -s`

              # install https download transport for APT
              sudo apt-get -y install apt-transport-https

              # append two lines to a list of source repositories
              sudo rm -f /etc/apt/sources.list.d/*tarantool*.list
              echo "deb http://download.tarantool.org/tarantool/1.8/debian/ jessie main" > /etc/apt/sources.list.d/tarantool_1_8.list
              echo "deb-src http://download.tarantool.org/tarantool/1.8/debian/ jessie main" >> /etc/apt/sources.list.d/tarantool_1_8.list

              # install
              sudo apt-get update
              sudo apt-get -y install tarantool

        * For Debian "wheezy":

          .. code-block:: bash

              curl http://download.tarantool.org/tarantool/1.8/gpgkey | sudo apt-key add -
              release=`lsb_release -c -s`

              # install https download transport for APT
              sudo apt-get -y install apt-transport-https

              # append two lines to a list of source repositories
              sudo rm -f /etc/apt/sources.list.d/*tarantool*.list
              echo "deb https://packagecloud.io/tarantool/1_8/debian/ wheezy main" > /etc/apt/sources.list.d/tarantool_1_8.list
              echo "https://packagecloud.io/tarantool/1_8/debian/ wheezy main" >> /etc/apt/sources.list.d/tarantool_1_8.list

              # install
              sudo apt-get update
              sudo apt-get -y install tarantool

