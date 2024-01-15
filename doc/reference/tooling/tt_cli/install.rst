.. _tt-install:

Installing Tarantool software
=============================

..  code-block:: console

    $ tt install PROGRAM_NAME [VERSION|COMMIT_HASH|PR_ID] [OPTION ...]

``tt install`` installs the latest or an explicitly specified version of Tarantool
or ``tt``. The possible values of ``PROGRAM_NAME`` are:

*   ``tarantool``: Install Tarantool Community Edition.
*   ``tarantool-dev``: Install Tarantool from a local build directory.
*   ``tarantool-ee``: Install Tarantool Enterprise Edition.
*   ``tt``: Install the ``tt`` command-line utility.

.. note::

    For ``tarantool-ee``, account credentials are required. Specify them in a file
    (see the :ref:`ee section <tt-config_file_ee>` of the configuration file) or
    provide them interactively.

Additionally, ``tt install`` can build open source programs ``tarantool`` and ``tt``
from a specific commit or a pull request on their GitHub repositories.

To uninstall a Tarantool or ``tt`` version, use :doc:`tt uninstall <uninstall>`.

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

By default, available versions of Tarantool Community Edition and ``tt`` are taken from their git repositories.
Their installation includes building from sources, which requires some tools and
dependencies, such as a C compiler. Make sure they are available in the system.

Tarantool Enterprise Edition is installed from prebuilt packages.

Development versions
~~~~~~~~~~~~~~~~~~~~

``tt install`` can be used to build custom Tarantool and ``tt`` versions for
development purposes from commits and pull requests on their GitHub repositories.

To build Tarantool or ``tt`` from a specific commit on their GitHub repository,
pass the commit hash (7 or more characters) after the program name. If you want to use
a PR as a source, provide a ``pr/<PR_ID>`` argument:


..  code-block:: console

    $ tt install tarantool 03c184d
    $ tt install tt pr/50

If you :ref:`build Tarantool from sources <building_from_source>`, you can install
local builds to the current ``tt`` environment by running ``tt install`` with
the ``tarantool-dev`` program name and the path to the build:

..  code-block:: console

    $ tt install tarantool-dev ~/src/tarantool/build

Local repositories
~~~~~~~~~~~~~~~~~~

You can also set up a local repository with installation files you need.
To use it, specify its location in the :ref:`repo section <tt-config_file_repo>`
of the ``tt`` configuration file and run ``tt install`` with the ``--local-repo`` flag.

Example
--------

*   Install the latest available version of Tarantool CE:

    ..  code-block:: console

        $ tt install tarantool

*   Install Tarantool 2.11.1 from the local repository:

    ..  code-block:: console

        $ tt install tarantool 2.11.1 --local-repo

*   Reinstall Tarantool 2.10.8:

    ..  code-block:: console

        $ tt install tarantool 2.10.8 --reinstall

*   Install Tarantool from a PR #1234 on the `tarantool/tarantool GitHub repository <https://github.com/tarantool/tarantool>`__:

    ..  code-block:: console

        $ tt install tarantool pr/1234

*   Install ``tt`` from a commit with a hash ``00a9e59`` on the `tarantool/tt GitHub repository <https://github.com/tarantool/tt>`__:

    ..  code-block:: console

        $ tt install tt 40e696e

*   Install Tarantool :ref:`built from sources <building_from_source>`:

    ..  code-block:: console

        $ tt install tarantool-dev ~/src/tarantool/build