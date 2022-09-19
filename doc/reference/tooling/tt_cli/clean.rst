.. _tt-stop:

Cleaning instance files
=======================

..  code-block:: bash

    tt clean INSTANCE

``tt clean`` cleans stored files of a Tarantool instance: logs and snapshots.

Flags
-----

..  container:: table

    ..  list-table::
        :widths: 30 70
        :header-rows: 0

        *   -   ``-f``

                ``--force``
            -   Clean file without confirmation


Examples
--------

*   Clean files of the ``app`` instance:

    ..  code-block:: bash

        tt clean app
