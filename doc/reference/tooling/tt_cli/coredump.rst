.. _tt-coredump:

Manipulating Tarantool core dumps
=================================

..  code-block:: console

    $ tt coredump COMMAND [COMMAND_OPTION ...]

``tt coredump`` provides commands for manipulating Tarantool core dumps.

To be able to investigate Tarantool crashes, make sure that core dumps are enabled
on the host. Here is the :ref:`instruction on enabling core dumps on Unix systems <admin-core_dumps>`.

..  important::

        ``tt coredump`` does not support macOS.

Commands
--------

pack
~~~~

Pack a Tarantool core dump and supporting data into a ``tar.gz`` archive.
It includes:

*   the Tarantool executable
*   Tarantool version information
*   OS information
*   Shared libraries

Option: a path to a core dump file.

unpack
~~~~~~

Unpack a Tarantool core dump created with ``tt coredump pack`` into a new directory.

Option: a path to a ``tar.gz`` archive packed by ``tt coredump pack``.

inspect
~~~~~~~

Inspect a Tarantool core dump directory with the `GNU debugger <https://www.sourceware.org/gdb/>`__ (``gdb``)
The directory being inspected must have the same structure as the core dump archive
created by ``tt coredump pack``.

.. note::

    ``tt coredump inspect`` requires ``gdb`` installed on the host.

Option: a path to a directory with an unpacked core dump archive.

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