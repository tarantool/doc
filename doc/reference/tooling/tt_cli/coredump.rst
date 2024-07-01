.. _tt-coredump:

Manipulating Tarantool core dumps
=================================

..  code-block:: console

    $ tt coredump COMMAND [COMMAND_OPTION ...]

``tt coredump`` provides commands for manipulating Tarantool core dumps.

To be able to investigate Tarantool crashes, make sure that core dumps are enabled
on the host. Here is the :ref:`instruction on enabling core dumps on Unix systems <admin-core_dumps>`.

``COMMAND`` is one of the following:

*   :ref:`pack <tt-coredump-pack>`
*   :ref:`unpack <tt-coredump-unpack>`
*   :ref:`inspect <tt-coredump-inspect>`

..  important::

    ``tt coredump`` is not supported on macOS.

.. _tt-coredump-pack:

pack
----

..  code-block:: console

    $ tt coredump pack COREDUMP_FILE

Pack a Tarantool core dump and supporting data into a ``tar.gz`` archive.
It includes:

*   the Tarantool executable
*   Tarantool version information
*   OS information
*   shared libraries
*   the `GNU debugger <https://www.sourceware.org/gdb/>`__ with extensions.

Pack a ``tar.gz`` file with a Tarantool core dump and supporting data:

..  code-block:: console

    $ tt coredump pack name.core

.. _tt-coredump-unpack:

unpack
------

..  code-block:: console

    $ tt coredump unpack ARCHIVE

Unpack a Tarantool core dump archive created with ``tt coredump pack`` into a new directory:

..  code-block:: console

    $ tt coredump unpack tarantool-core-dump.tar.gz


.. _tt-coredump-inspect:

inspect
-------

..  code-block:: console

    $ tt coredump inspect [ARCHIVE|DIRECTORY] [-s]

Inspect a Tarantool core dump with the `GNU debugger <https://www.sourceware.org/gdb/>`__ (``gdb``).
The command argument can be either an archive file produced with ``tt coredump pack``
or directory where such an archive is extracted.

Inspect the core dump archive with ``gdb``:

..  code-block:: console

    $ tt coredump inspect tarantool-core-dump.tar.gz

Inspect the unpacked core dump directory with ``gdb``:

..  code-block:: console

    $ tt coredump inspect tarantool-core-dump


Options
-------

..  option:: -s

    **Applicable to**: ``inspect``

    Specify the location of Tarantool sources.