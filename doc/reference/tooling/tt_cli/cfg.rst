Environment configuration
=========================

..  code-block:: bash

    tt cfg COMMAND [command flags]

``tt cfg`` manages a ``tt`` environment :ref:`configuration <tt-config_file>`.


Commands
--------

..  container:: table

    ..  list-table::
        :widths: 20 80
        :header-rows: 0

        *   -   ``dump``
            -   Print a ``tt`` environment configuration.

                Flags:

                *   ``-r``, ``--raw``: Print a raw content of the ``tt.yaml`` configuration file.


Examples
--------

The following command prints a ``tt`` environment configuration:

..  code-block:: bash

    tt cfg dump
