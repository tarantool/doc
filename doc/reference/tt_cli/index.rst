Command-line interface: tt utility
==================================

``tt`` is a command-line utility for managing Tarantool instances and Tarantool-based
applications. It covers a wide range of Tarantool-related tasks from installation
of a specific Tarantool version to remote instance management and application
development.

``tt`` is going to eventually become a single tool for working with Tarantool
from the command line, replacing :doc:`tarantoolctl </reference/tarantoolctl>` and
:doc:`Cartridge CLI </book/cartridge/cartridge_cli/index>`

.. important::

    ``tt`` is currently in the early development stage.

    * Current version includes only basic functionality. See
      See :doc:`Commands <commands>` for details.

    * It may contain issues

    To use ``tt``, you need to build it from sources manually.
    See :doc:`Installation <installation>` for details.

.. toctree::
    :maxdepth: 1
    :numbered: 0

    installation
    configuration
    commands
    global_flags