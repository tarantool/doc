Restarting a Tarantool instance
===============================

..  code-block:: bash

    tt restart

Flags
-----

..  container:: table

    ..  list-table::
        :widths: 20 80
        :header-rows: 0

        *   -   ``--name``
            -   Application name.
        *   -   ``--from``
            -   Path to the application template. See details below.
        *   -   ``--template``
            -   Name of the application template.
                Currently, only the ``cartridge`` template is supported.

``create`` also supports :doc:`global flags </book/cartridge/cartridge_cli/global-flags>`.

Details
-------

Your application will appear in the ``<path>/<app-name>/`` directory.