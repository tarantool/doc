..  _tt-cli:

tt CLI utility
==============

``tt`` is a utility that provides a unified command-line interface for managing
Tarantool-based applications. It covers a wide range of tasks -- from installing
a specific Tarantool version to managing remote instances and developing applications.

``tt`` is developed in its own `GitHub repository <https://github.com/tarantool/tt>`_.
Here you can find its source code, changelog, and releases information.

This section provides instructions on ``tt`` installation and configuration,
concept explanation, and the ``tt`` command reference.

.. toctree::
    :maxdepth: 1
    :numbered: 0

    installation
    configuration
    arguments
    commands
    external_modules
    multiple_instances

..  _tt-cli-environments:

tt environments
---------------

The key aspect of the ``tt`` usage is an *environment*. A ``tt`` environment
is a directory that includes a ``tt`` configuration, Tarantool installations,
application files, and other resources. If you're familiar with `Python virtual
environments <https://packaging.python.org/en/latest/guides/installing-using-pip-and-virtual-environments/#creating-a-virtual-environment>`_,
you can think of ``tt`` environments as their analog.

``tt`` environments enable independent management of multiple Tarantool applications,
each running on its own Tarantool version and configuration, on a single host in
an isolated manner.

To create a ``tt`` environment in a directory, run :ref:`tt init <tt-init>` in it.

Multi-instance applications
---------------------------

``tt`` supports Tarantool applications that run on multiple instances. For example,
you can write an application that includes different source files for storage and router
instances. With ``tt``, you can start and stop them in a single call, or manage
each instance independently.

Learn more about working with multi-instance applications in :ref:`Multi-instance applications <admin-start_stop_instance-multi-instance>`.

Replacement for tarantooctl and Cartridge CLI
---------------------------------------------

A multi-purpose tool for working with Tarantool from the command line, ``tt`` has
come to replace :ref:`tarantoolctl <tarantoolctl>`
and :doc:`Cartridge CLI </book/cartridge/cartridge_cli/index>` command-line utilities.
The instructions on migration to ``tt`` are provided on the corresponding documentation
pages: :ref:`tarantoolctl <tarantoolctl-migration-to-tt>` and :doc:`Cartridge CLI </book/cartridge/cartridge_cli/index>`.


