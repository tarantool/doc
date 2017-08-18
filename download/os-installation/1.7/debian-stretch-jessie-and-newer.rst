:orphan:
:priority: 0.99

--------------------------------------------
Tarantool - Debian Stretch, Jessie and newer
--------------------------------------------

.. container:: b-os-installation-body

    .. container:: b-os-installation-menu

        .. include:: menu.rst

    .. wp_section::
      :title: Debian Stretch, Jessie and newer
      :class: b-os-installation-content

      We maintain an always up-to-date Debian GNU/Linux
      package repository. At the moment, the repository contains builds for
      Debian "stretch" and "jessie". For Debian "wheezy", see personal
      instructions on this page.

      In these instructions, ``$release`` is an environment variable which
      will contain the Debian version code (e.g. "jessie").

      Copy and paste the script below to the terminal prompt:

      .. code-block:: bash

          curl http://download.tarantool.org/tarantool/1.7/gpgkey | sudo apt-key add -
          release=`lsb_release -c -s`

          # install https download transport for APT
          sudo apt-get -y install apt-transport-https

          # append two lines to a list of source repositories
          sudo rm -f /etc/apt/sources.list.d/*tarantool*.list
          sudo tee /etc/apt/sources.list.d/tarantool_1_7.list <<- EOF
          deb http://download.tarantool.org/tarantool/1.7/debian/ $release main
          deb-src http://download.tarantool.org/tarantool/1.7/debian/ $release main
          EOF

          # install
          sudo apt-get update
          sudo apt-get -y install tarantool
