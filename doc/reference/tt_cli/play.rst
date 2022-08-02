Playing the contents of .snap and .xlog files to a Tarantool instance
=====================================================================

..  code-block:: bash

    tt play URI FILE .. [flags]

``tt cat`` plays the contents of :ref:`snapshot <internals-snapshot>` (``.snap``) and
:ref:`WAL <internals-wal>` (``.xlog``) files to another Tarantool instance.
A single call of ``tt play`` can play the contents of multiple files.

Flags
-----

..  container:: table

    ..  list-table::
        :widths: 20 80
        :header-rows: 0

        *   -   ``--from``
            -   Show operations starting from the given LSN
        *   -   ``--to``
            -   Show operations until the given LSN. Default: 18446744073709551615
        *   -   ``--replica``
            -   Filter the output by replica id. May be passed more than once
        *   -   ``--space``
            -    Filter the output by space id. May be passed more than once
        *   -   ``--show-system``
            -   Show the contents of system spaces

Details
-------


Examples
--------

*   Play the contents of ``00000000000000000000.xlog`` into the instance that listens on
    ``192.168.10.10:3301``:

    ..  code-block:: bash

        tt play 192.168.10.10:3301 00000000000000000000.xlog

