.. _tt-global-options:

Global options
==============

.. important::

    Global options of ``tt`` must be passed before its commands and other options.
    For example:

    .. code-block:: console

        $ tt --cfg tt-conf.yaml start app

``tt`` has the following global options:

.. option:: -c=FILE, --cfg=FILE,

    Path to the :ref:`configuration file <tt-config_file>`.

.. option:: -h, --help

    Display help.

.. option:: -I, --internal

    Force the use of an internal module even if there is an
    :doc:`external module <external_modules>` with the same name.

.. option:: -L=DIRECTORY, --local=DIRECTORY

    Use the ``tt`` environment from the specified directory.
    Learn more about the :ref:`local launch mode <tt-config_modes-local>`.

.. option:: -S, --system

    Use the ``tt`` environment installed in the system.
    Learn more about the :ref:`system launch mode <tt-config_modes-system>`.

.. option:: -V, --verbose

    Display detailed processing information (verbose mode).
