tt CLI arguments
================

``tt`` has the following arguments:

..  container:: table

    ..  list-table::
        :widths: 40 60
        :header-rows: 0

        *   -   ``--cfg=FILE``

                ``-c=FILE``
            -   Path to the :ref:`configuration file <tt-config_file>`.
        *   -   ``--internal``

                ``-i``
            -   Force the use of an internal module even if there is an external module with the same name.

                .. // TODO: add link to external modules doc page when it's ready
        *   -   ``--local=DIRECTORY``

                ``-L=DIRECTORY``
            -   Use the ``tt`` environment from the specified directory.
                Learn more about the :ref:`local launch mode <tt-config_modes>`.
        *   -   ``--system``

                ``-S``
            -   Use the ``tt`` environment installed in the system.
                Learn more about the :ref:`system launch mode <tt-config_modes>`.
        *   -   ``--help``

                ``-h``
            -   Display help.