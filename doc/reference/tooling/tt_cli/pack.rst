.. _tt-pack:

Packaging the application
=========================

..  code-block:: console

    $ tt pack TYPE [OPTION ...] ..

``tt pack`` packages an application into a distributable bundle of the specified ``TYPE``:

-   ``tgz``: create a ``.tgz`` archive.
-   ``deb``: create a DEB package.
-   ``rpm``: create an RPM package.

The command below creates a DEB package for an application:

    .. code-block:: console

        $ tt pack deb

This command generates a ``.deb`` file whose name depends on the environment directory name and the operating system architecture, for example, ``test-env_0.1.0.0-1_x86_64.deb``.
You can also pass various :ref:`options <tt-pack-options>` to the ``tt pack`` command to adjust generation properties, for example, customize a bundle name, choose which artifacts should be included, specify the required application dependencies.


.. _tt-pack-options:

Options
-------

..  option:: --all

    Include all artifacts in a bundle.
    In this case, a bundle might include snapshots, WAL files, and logs.

..  option:: --app-list APPLICATIONS

    Specify the applications included in a bundle.

    **Example**

    .. code-block:: console

        $ tt pack tgz --app-list app1,app3

..  option:: --cartridge-compat

    **Applicable to:** ``tgz``

    Package a Cartridge CLI-compatible archive.

..  option:: --deps STRINGS

    **Applicable to:** ``deb``, ``rpm``

    Specify dependencies included in RPM and DEB packages.

    **Example**

    .. code-block:: console

        $ tt pack deb --deps 'wget,make>0.1.0,unzip>1,unzip<=7'

..  option:: --deps-file STRING

    **Applicable to:** ``deb``, ``rpm``

    Specify the path to a file containing dependencies included in RPM and DEB packages.
    For example, the ``package-deps.txt`` file below contains several dependencies and their versions:

    .. code-block:: text

        unzip==6.0
        neofetch>=6,<7
        gcc>8

    If this file is placed in the current directory, a ``tt pack`` command might look like this:

    .. code-block:: console

        $ tt pack deb --deps-file package-deps.txt

..  option:: --filename

    Specify a bundle name.

    **Example**

    .. code-block:: console

        $ tt pack tgz --filename sample-app.tar.gz

..  option:: --name PACKAGE_NAME

    Specify a package name.

    **Example**

    .. code-block:: console

        $ tt pack tgz --name sample-app --version 1.0.1

..  option:: --preinst

    **Applicable to:** ``deb``, ``rpm``

    Specify the path to a pre-install script for RPM and DEB packages.

    **Example**

    .. code-block:: console

        $ tt pack deb --preinst pre.sh

..  option:: --postinst

    **Applicable to:** ``deb``, ``rpm``

    Specify the path to a post-install script for RPM and DEB packages.

    **Example**

    .. code-block:: console

        $ tt pack deb --postinst post.sh

..  option:: --tarantool-version

    Specify a Tarantool version for packaging in a Docker container.
    For use with ``--use-docker`` only.

..  option:: --use-docker

    Build a package in an Ubuntu 18.04 Docker container. To specify a Tarantool
    version to use in the container, add the ``--tarantool-version`` option.

    Before executing ``tt pack`` with this option, make sure Docker is running.

..  option:: --version PACKAGE_VERSION

    Specify a package version.

    **Example**

    .. code-block:: console

        $ tt pack tgz --name sample-app --version 1.0.1

..  option:: --with-binaries

    Include Tarantool and ``tt`` binaries in a bundle.

..  option:: --without-binaries

    Don't include Tarantool and ``tt`` binaries in a bundle.

..  option:: --without-modules

    Don't include external modules in a bundle.
