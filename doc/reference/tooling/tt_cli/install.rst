.. _tt-install:

Installing Tarantool software
=============================

..  code-block:: bash

    tt install PROGRAM_NAME[=version] [flags]

``tt install`` installs the latest or an explicitly specified version of Tarantool
or ``tt``. The possible values of ``PROGRAM_NAME`` are:

*   ``tarantool``
*   ``tarantool-ee``
*   ``tt``

.. note::

    For ``tarantool-ee``, account credentials are required. Specify them in a file
    (see the :ref:`ee section <tt-config_file_ee>` of the configuration file) or
    provide them interactively.

Flags
-----

..  container:: table

    ..  list-table::
        :widths: 20 80
        :header-rows: 0

        *   -   ``-f``

                ``--force``
            -   Skip dependency check before installation
        *   -   ``--local-repo``
            -   Install a program from the local repository, which is specified
                in the :ref:`repo section <tt-config_file_repo>` of the ``tt``
                configuration file
        *   -   ``--no-clean``
            -   Don't delete temporary files
        *   -   ``--reinstall``
            -   Reinstall a previously installed program
        *   -   ``--use-docker``
            -   Build Tarantool in an Ubuntu 16.04 Docker container

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
To use it, specify its location in the :ref:`repo section` of the ``tt`` configuration
file and run ``tt install`` with the ``--local-repo`` flag.

To uninstall a Tarantool or ``tt`` version, use :doc:`tt uninstall <uninstall>`.

Example
--------

*   Install the latest available version of Tarantool:

    ..  code-block:: bash

        tt install tarantool

*   Install Tarantool 2.10.5 from the local repository:

    ..  code-block:: bash

        tt install tarantool=2.10.5 --local-repo

*   Reinstall Tarantool 2.10.5:

    ..  code-block:: bash

        tt install tarantool=2.10.5 --reinstall