tt CLI utility
==========

``tt`` is a utility that provides a unified command-line interface for managing
Tarantool-based applications. It covers a wide range of tasks from installation
of a specific Tarantool version to remote instance
management and application development.

``tt`` is going to become a single tool for working with Tarantool
from the command line and replace :doc:`tarantoolctl </reference/tarantoolctl>` and
:doc:`Cartridge CLI </book/cartridge/cartridge_cli/index>` in the future.

.. warning::

    ``tt`` is currently in the early development stage. It includes
    only basic functionality and may be unstable. We don't recommend using it
    in production environments. Check out the list  of :doc:`supported commands <commands>`.

    To use ``tt``, you need to build it from sources.
    See :doc:`Installation <installation>` for details.

.. toctree::
    :maxdepth: 1
    :numbered: 0

    Installation <installation>
    Configuration <configuration>
    Arguments <arguments>
    Commands <commands>