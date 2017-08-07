:orphan:
:priority: 0.99

-------------------------
Tarantool - Debian Wheezy
-------------------------

.. container:: b-os-installation-body

    .. container:: b-os-installation-menu

        .. include:: menu.rst

    .. wp_section::
      :title: Debian Wheezy
      :class: b-os-installation-content

      We maintain an always up-to-date package repository for Debian "wheezy".

      Copy and paste the script below to the terminal prompt:

      .. code-block:: bash

          curl http://download.tarantool.org/tarantool/1.7/gpgkey | sudo apt-key add -
          release=`lsb_release -c -s`

          # install https download transport for APT
          sudo apt-get -y install apt-transport-https

          # append two lines to a list of source repositories
          sudo rm -f /etc/apt/sources.list.d/*tarantool*.list
          sudo tee /etc/apt/sources.list.d/tarantool_1_7.list <<- EOF
          deb https://packagecloud.io/tarantool/1_7/debian/ wheezy main
          deb-src https://packagecloud.io/tarantool/1_7/debian/ wheezy main
          EOF

          # install
          sudo apt-get update
          sudo apt-get -y install tarantool
