:orphan:
:priority: 0.99

-------------------
Tarantool - FreeBSD
-------------------

.. container:: b-os-installation-body

    .. container:: b-os-installation-menu

        .. include:: menu.rst

    .. wp_section::
        :title: FreeBSD
        :class: b-os-installation-content

        Tarantool is available from the FreeBSD Ports collection.

        With your browser, go to the `FreeBSD Ports`_ page.
        Enter the search term: `tarantool`.
        Choose the package you want.

        Also, look at the `Fresh Ports`_ page.
        At the moment, the port-tree contains versions which succesfully builds for FreeBSD 12.0

        Copy and paste the script below to the terminal prompt:

        * For Port-tree installation:

          .. code-block:: bash

                cd /usr/ports/databases/tarantool
                make config-recursive
                make install clean
                sysrc tarantool_enable=YES
                sysrc tarantool_instances=/usr/local/etc/tarantool/instances.enabled

        * For pkg installation:

          .. code-block:: bash

                pkg install tarantool
                sysrc tarantool_enable=YES
                sysrc tarantool_instances=/usr/local/etc/tarantool/instances.enabled



.. _FreeBSD Ports: http://www.freebsd.org/ports/index.html
.. _Fresh Ports: http://freshports.org/databases/tarantool
