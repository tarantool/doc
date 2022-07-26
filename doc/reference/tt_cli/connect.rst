.. _tt-start:

Connecting to a Tarantool instance
==================================

..  code-block:: bash

    tt connect (<INSTANCE_NAME> | <URI>) [flags]


``tt connect`` connects to a Tarantool instance by its instance name or URI..

Flags
-----

..  container:: table

    ..  list-table::
        :widths: 20 80
        :header-rows: 0

        *   -   ``-u``

                ``--username``
            -   Username.
        *   -   ``-p``

                ``--password``
            -   Password.
        *   -   ``-f``

                ``--file``
            -   File to read the script for evaluation. "-" - read the script from stdin.

Details
-------




Examples
--------

*   Connect to the ``app`` instance without authorization:

    ..  code-block:: bash

        tt connect app
