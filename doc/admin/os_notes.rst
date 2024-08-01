.. _admin-os_notes:

================================================================================
Notes for operating systems
================================================================================

.. _admin-os_notes-mac:

macOS
-----

On macOS, no native system tools for administering Tarantool are supported.
The recommended way to administer Tarantool instances is using :ref:`tt CLI <tt-cli>`.

.. _admin-os_notes-gentoo:

Gentoo Linux
------------

The section below is about a dev-db/tarantool package installed from the
official layman overlay (named ``tarantool``).

The default instance directory is ``/etc/tarantool/instances.available``, can be
redefined in ``/etc/default/tarantool``.

Tarantool instances can be managed (start/stop/reload/status/...) using OpenRC.
Consider the example how to create an OpenRC-managed instance:

.. code-block:: console

    $ cd /etc/init.d
    $ ln -s tarantool your_service_name
    $ ln -s /usr/share/tarantool/your_service_name.lua /etc/tarantool/instances.available/your_service_name.lua

Checking that it works:

.. code-block:: console

    $ /etc/init.d/your_service_name start
    $ tail -f -n 100 /var/log/tarantool/your_service_name.log
