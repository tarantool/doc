.. _tt-init:

Creating a tt environment
=========================

..  code-block:: console

    tt init

``tt init`` creates a ``tt`` environment in the current directory. This includes:

*   Setting up directories for working files: binaries, templates, and so on.
*   Creating a corresponding ``tt.yaml`` :ref:`configuration file <tt-config_file>`.

Details
-------

``tt init`` checks the existence of configuration files for Cartridge (``cartridge.yml``)
or the ``tarantoolctl`` utility (``.tarantoolctl``) in the current directory.
If such files are found, ``tt`` generates an environment that uses the same
directories:

*   ``cartridge.yml`` -- the directories specified in the file.
*   ``.tarantoolctl`` -- the directories specified in the ``default_cfg`` table.

    .. note::

        ``init`` is the only ``tt`` command that invokes ``.tarantoolctl`` files.
        Thus, variables defined in this script will not be available in
        applications launched by a ``tt start`` call.

If there is no ``cartridge.yml`` or ``.tarantoolctl`` files in the current directory,
``tt init`` creates a default environment in it. This includes creating the
following directories and files:

*   ``bin`` -- the directory for storing binary files.
*   ``include`` -- the directory for storing  header files.
*   ``distfiles`` -- the directory for storing installation files.
*   ``instances.enabled`` -- the directory for storing running applications or symlinks.
*   ``modules`` -- the directory for storing external modules.
*   ``tt.yaml`` -- the configuration file.
*   ``templates`` -- the directory for storing application templates.


Example
--------

Create a ``tt`` environment in the current directory:

..  code-block:: console

    $ tt init