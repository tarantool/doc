.. _tt-play:

Playing the contents of .snap and .xlog files to a Tarantool instance
=====================================================================

..  code-block:: console

    $ tt play URI FILE ... [OPTION ...]

``tt play`` plays the contents of :ref:`snapshot <internals-snapshot>` (``.snap``) and
:ref:`WAL <internals-wal>` (``.xlog``) files to another Tarantool instance.
A single call of ``tt play`` can play multiple files.

Options
-------

..  option:: --from LSN

    Play operations starting from the given LSN.

..  option:: --to LSN

    Play operations up to the given LSN. Default: ``18446744073709551615``.

..  option:: --replica ID

    Filter the operations by replica ID. Can be passed more than once.

    When calling ``tt cat`` with filters by LSN (``--from`` and ``--to`` flags) and
    replica ID (``--replica``), remember that LSNs differ across replicas.
    Thus, if you pass more than one replica ID via ``--from`` or ``--to``,
    the result may not reflect the actual sequence of operations.

..  option:: --space ID

    Filter the output by space ID. Can be passed more than once.

..  option:: --show-system

    Show the operations on system spaces.

Details
-------

``tt play`` plays operations from ``.xlog`` and ``.snap`` files to the destination
instance one by one. All data changes happen the same way as if they were performed
on this instance. This means that:

*   All affected spaces must exist on the destination instance. They must have the same structure
    and ``space_id`` as on the instance that created the snapshot or WAL file.

    To play a snapshot or a WAL to a clean instance, include the operations on system spaces
    by adding the ``--show-system`` flag. With this flag, ``tt`` plays the operations that
    create and configure user-defined spaces.

*   The operations' LSNs will change unless you play all operations that took place since the instance startup.

*   Replica IDs will change in accordance with the destination instance configuration.

Examples
--------

*   Play the contents of ``00000000000000000000.xlog`` to the instance on
    ``192.168.10.10:3301``:

    ..  code-block:: console

        $ tt play 192.168.10.10:3301 00000000000000000000.xlog

*   Play operations on spaces with ``space_id`` 512 and 513 from the
    ``00000000000000000012.snap`` snapshot file:

    ..  code-block:: console

        $ tt play 192.168.10.10:3301 00000000000000000012.snap --space 512 --space 513

*   Play the contents of ``00000000000000000000.xlog`` including operations on system spaces:

    ..  code-block:: console

        $ tt play 192.168.10.10:3301 00000000000000000000.xlog --show-system
