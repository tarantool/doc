Playing the contents of .snap and .xlog files to a Tarantool instance
=====================================================================

..  code-block:: bash

    tt play URI FILE .. [flags]

``tt play`` plays the contents of :ref:`snapshot <internals-snapshot>` (``.snap``) and
:ref:`WAL <internals-wal>` (``.xlog``) files to another Tarantool instance.
A single call of ``tt play`` can play the contents of multiple files.

Flags
-----

..  container:: table

    ..  list-table::
        :widths: 20 80
        :header-rows: 0

        *   -   ``--from``
            -   Play operations starting from the given LSN
        *   -   ``--to``
            -   Play operations until the given LSN. Default: 18446744073709551615
        *   -   ``--replica``
            -   Filter the operations by replica id. May be passed more than once
        *   -   ``--space``
            -   Filter the operations by space id. May be passed more than once
        *   -   ``--show-system``
            -   Play the operations on system spaces

Details
-------

``tt play`` plays operations from ``.xlog`` and ``.snap`` files to the given instance
one by one.

Examples
--------

*   Play the contents of ``00000000000000000000.xlog`` to the instance on
    ``192.168.10.10:3301``:

    ..  code-block:: bash

        tt play 192.168.10.10:3301 00000000000000000000.xlog

