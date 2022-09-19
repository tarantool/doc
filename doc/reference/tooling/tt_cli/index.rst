..  _tt-cli:

tt CLI utility
==============

``tt`` is a utility that provides a unified command-line interface for managing
Tarantool-based applications. It covers a wide range of tasks -- from installing
a specific Tarantool version to managing remote instances and developing applications.

A multi-purpose tool for working with Tarantool from the command line, ``tt`` is
a potential replacement for :ref:`tarantoolctl <tarantoolctl>`
and :doc:`Cartridge CLI </book/cartridge/cartridge_cli/index>`.

.. warning::

    As of Tarantool 2.10, ``tt`` is in the early development stage. It includes
    only basic functionality and may be unstable. We don't recommend using it
    in production environments. Check out the list  of :doc:`supported commands <commands>`.

    To use ``tt``, you need to build it from sources.
    See :doc:`Installation <installation>` for details.

.. toctree::
    :maxdepth: 1
    :numbered: 0

    installation
    configuration
    arguments
    commands
    external_modules