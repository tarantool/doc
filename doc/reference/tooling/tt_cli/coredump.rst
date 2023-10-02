.. _tt-coredump:

Manipulating Tarantool core dumps
=================================

..  code-block:: console

    tt coredump COMMAND [ARGUMENT]

``tt coredump`` provides commands for manipulating Tarantool core dumps.

..  important::

        ``tt coredump`` does not support macOS.

Commands
--------

..  container:: table

    ..  list-table::
        :widths: 20 80
        :header-rows: 0

        *   -   ``pack``
            -   Pack a Tarantool core dump and supporting data into a ``tar.gz`` archive
        *   -   ``unpack``
            -   Unpack a Tarantool core dump archive
        *   -   ``inspect``
            -   Inspect a Tarantool core dump directory with the
                `GNU debugger <https://www.sourceware.org/gdb/>`__ (``gdb``)


Details
-------

To be able to investigate Tarantool crashes, make sure that core dumps are enabled
on the host. Here is the :ref:`instruction on enabling core dumps on Unix systems <admin-core_dumps>`.

``tt coredump pack`` packs the given core dump together with files and data
that can help the crash investigation. This includes:

*   Tarantool executable
*   Tarantool version information
*   OS information
*   Shared libraries

``tt coredump inspect`` requires ``gdb`` installed on the host.
The directory being inspected must have the same structure as the core dump archive
created by ``tt coredump pack``.

Examples
--------

*   Pack a ``tar.gz`` file with a Tarantool core dump and supporting data:

    ..  code-block:: console

        $ tt coredump pack name.core


*   Unpack a ``tar.gz`` archive packed by ``tt coredump pack``:

    ..  code-block:: console

        $ tt coredump unpack tarantool-core-dump.tar.gz


*   Inspect the unpacked core dump with ``gdb``:

    ..  code-block:: console

        $ tt coredump inspect tarantool-core-dump