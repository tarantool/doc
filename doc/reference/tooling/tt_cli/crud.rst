.. _tt-crud:

Interacting with the CRUD module
================================

..  admonition:: Enterprise Edition
    :class: fact

    This command is supported by the `Enterprise Edition <https://www.tarantool.io/compare/>`_ only.

..  code-block:: console

    $ tt crud COMMAND [COMMAND_OPTION ...]

``tt crud`` enables the interaction with a cluster using the `CRUD <https://github.com/tarantool/crud>`_ module.
``COMMAND`` is one of the following:

*   ``export``: export a cluster's data to a file. Learn more at :ref:`Exporting data <tt-export>`.
*   ``import``: import data from a file. Learn more at :ref:`Importing data <tt-import>`.
