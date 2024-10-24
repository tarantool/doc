.. _tt-global-options:

Global options
==============

.. important::

    Global options of ``tt`` must be passed before its commands and other options.
    For example:

    .. code-block:: console

        $ tt --cfg tt-conf.yaml start app

``tt`` has the following global options:

.. option:: -c=file, --cfg=file,

    Path to the :ref:`configuration file <tt-config_file>`.

    Alternatively, this path can be passed in the ``TT_CLI_CFG`` environment variable.

.. option:: -h, --help

    Display help.

.. option:: --integrity-check PUBLIC_KEY

    ..  admonition:: Enterprise Edition
        :class: fact

        This option is supported by the `Enterprise Edition <https://www.tarantool.io/compare/>`_ only.

    Perform an integrity check using the specified public key before executing the operation.
    Learn more in :ref:`tt-start-integrity-check`.

.. option:: -I, --internal

    Force the use of an internal module even if there is an
    :doc:`external module <external_modules>` with the same name.

.. option:: -L=DIRECTORY, --local=DIRECTORY

    Use the ``tt`` environment from the specified directory.
    Learn more about the :ref:`local launch mode <tt-config_modes-local>`.

.. option:: -s, --self

    Use the current ``tt`` version instead of executing the one located
    in the :ref:`bin_dir <tt-config_file_env>` directory.

.. option:: -S, --system

    Use the ``tt`` environment installed in the system.
    Learn more about the :ref:`system launch mode <tt-config_modes-system>`.

.. option:: -V, --verbose

    Display detailed processing information (verbose mode).
