.. _tt-tdg2:

Interacting with the Tarantool Data Grid 2
==========================================

..  admonition:: Enterprise Edition
    :class: fact

    This command is supported by the `Enterprise Edition <https://www.tarantool.io/compare/>`_ only.

..  code-block:: console

    $ tt tdg2 COMMAND [COMMAND_OPTION ...]

``tt tdg2`` enables the interaction with `Tarantool Data Grid 2 <https://www.tarantool.io/ru/tdg/latest/>`_ clusters.
``COMMAND`` is one of the following:

*   ``export``: export a TDG2 cluster's data to a file. Learn more at :ref:`Exporting data <tt-export>`.
*   ``import``: import data to a TDG2 cluster from a file. Learn more at :ref:`Importing data <tt-import>`.
