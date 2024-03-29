.. _tt-cat:

Printing the contents of .snap and .xlog files
==============================================

..  code-block:: console

    $ tt cat FILE ... [OPTION ...]

``tt cat`` prints the contents of :ref:`snapshot <internals-snapshot>` (``.snap``) and
:ref:`WAL <internals-wal>` (``.xlog``) files to stdout. A single call of ``tt cat`` can
print the contents of multiple files.


Options
-------

..  option:: --format FORMAT

    Output format: ``yaml`` (default), ``json``, or ``lua``.

..  option:: --from LSN

    Show operations starting from the given LSN.

..  option:: --to LSN

    Show operations up to the given LSN. Default: ``18446744073709551615``.

..  option:: --replica ID

    Filter the output by replica ID. Can be passed more than once.

    When calling ``tt cat`` with filters by LSN (``--from`` and ``--to`` flags) and
    replica ID (``--replica``), remember that LSNs differ across replicas.
    Thus, if you pass more than one replica ID via ``--from`` or ``--to``,
    the result may not reflect the actual sequence of operations.

..  option:: --space ID

    Filter the output by space ID. Can be passed more than once.

..  option:: --show-system

    Show the contents of system spaces.

Examples
--------

*   Output contents of ``00000000000000000000.xlog`` WAL file in the YAML format:

    ..  code-block:: console

        $ tt cat 00000000000000000000.xlog

*   Output operations on spaces with ``space_id`` 512 and 513 from the
    ``00000000000000000012.snap`` snapshot file in the JSON format:

    ..  code-block:: console

        $ tt cat 00000000000000000012.snap --space 512 --space 513 --format json

*   Output operations on all spaces, including system spaces,
    from the ``00000000000000000000.xlog`` WAL file:

    ..  code-block:: console

        $ tt cat 00000000000000000000.xlog --show-system

*   Output operations with LSNs between 100 and 500 on replica 1
    from the ``00000000000000000000.xlog`` WAL file:

    ..  code-block:: console

        $ tt cat 00000000000000000000.xlog --from 100 --to 500 --replica 1
