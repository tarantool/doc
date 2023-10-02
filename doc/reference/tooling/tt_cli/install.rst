.. _tt-install:

Installing Tarantool software
=============================

..  code-block:: bash

    $ tt install PROGRAM_NAME [VERSION] [OPTION ...]

``tt install`` installs the latest or an explicitly specified version of Tarantool
or ``tt``. The possible values of ``PROGRAM_NAME`` are:

*   ``tarantool``: Install Tarantool Community edition.
*   ``tarantool-dev``: Install Tarantool from a local build directory.
*   ``tarantool-ee``: Install Tarantool Enterprise edition.
*   ``tt``: Install the ``tt`` command-line utility.

.. note::

    For ``tarantool-ee``, account credentials are required. Specify them in a file
    (see the :ref:`ee section <tt-config_file_ee>` of the configuration file) or
    provide them interactively.

Options
-------

.. option:: --dynamic

    **Applicable to:** ``tarantool``, ``tarantool-ee``

    Use dynamic linking for building Tarantool.

.. option:: -f, --force

    Skip dependency check before installation.

.. option:: --local-repo

    Install a program from the local repository, which is specified in the
    :ref:`repo section <tt-config_file_repo>` of the ``tt`` configuration file.

.. option:: --no-clean

    Don't delete temporary files.

.. option:: --reinstall

    Reinstall a previously installed program.

.. option:: --use-docker

    **Applicable to:** ``tarantool``, ``tarantool-ee``

    Build Tarantool in an Ubuntu 18.04 Docker container.

Details
-------

When called without an explicitly specified version, ``tt install`` installs the
latest available version. To check versions available for installation, use
:doc:`tt search <search>`.

By default, available versions of Tarantool CE and ``tt`` are taken from their git repositories.
Their installation includes building from sources, which requires some tools and
dependencies, such as a C compiler. Make sure they are available in the system.

Tarantool EE is installed from prebuilt packages.

You can also set up a local repository with installation files you need.
To use it, specify its location in the :ref:`repo section <tt-config_file_repo>`
of the ``tt`` configuration file and run ``tt install`` with the ``--local-repo`` flag.

To uninstall a Tarantool or ``tt`` version, use :doc:`tt uninstall <uninstall>`.

Example
--------

*   Install the latest available version of Tarantool:

    ..  code-block:: console

        $ tt install tarantool

*   Install Tarantool 2.11.1 from the local repository:

    ..  code-block:: console

        $ tt install tarantool 2.11.1 --local-repo

*   Reinstall Tarantool 2.10.8:

    ..  code-block:: console

        $ tt install tarantool 2.10.8 --reinstall

*   Install Tarantool :ref:`built from sources <building_from_source>`:

    ..  code-block:: console

        $ tt install tarantool-dev ~/src/tarantool/build
