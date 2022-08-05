Printing the contents of .snap and .xlog files
==============================================

..  code-block:: bash

    tt cat FILE .. [flags]

``tt cat`` prints the contents of :ref:`snapshot <internals-snapshot>` (``.snap``) and
:ref:`WAL <internals-wal>` (``.xlog``) files to stdout. A single call of ``tt cat`` can
print the contents of multiple files.


Flags
-----

..  container:: table

    ..  list-table::
        :widths: 20 80
        :header-rows: 0

        *   -   ``--format``
            -   Output format: ``yaml`` (default), ``json``, or ``lua``
        *   -   ``--from``
            -   Show operations starting from the given LSN
        *   -   ``--to``
            -   Show operations until the given LSN. Default: 18446744073709551615
        *   -   ``--replica``
            -   Filter the output by replica id. May be passed more than once
        *   -   ``--space``
            -   Filter the output by space id. May be passed more than once
        *   -   ``--show-system``
            -   Show the contents of system spaces

Examples
--------

*   Output contents of ``00000000000000000000.xlog`` WAL file in the YAML format:

    ..  code-block:: bash

        tt cat 00000000000000000000.xlog

*   Output operations on spaces with ``space_id`` 512 and 513 from the
    ``00000000000000000012.snap`` snapshot file in the JSON format:

    ..  code-block:: bash

        tt cat 00000000000000000012.snap --space 512 --space 513 --format json

*   Output operations with LSNs between 100 and 500 on all spaces including the system ones
    from the ``00000000000000000000.xlog`` WAL file:

    ..  code-block:: bash

        tt cat 00000000000000000000.xlog --from 100 --to 500 --show-system
