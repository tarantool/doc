.. _tt-config:

Configuration
=============

.. _tt-config_file:

Configuration file
------------------

The key artifact that defines the ``tt`` environment and various aspects of its
execution is its configuration file. You can generate it with a :ref:`tt init <tt-init>` call.
In the :ref:`default launch mode <tt-config_modes-default>`, the file is generated
in the current directory, making it the environment root.

.. _tt-config_file_name:

Name and location
~~~~~~~~~~~~~~~~~

By default, the configuration file is called ``tt.yaml`` and located in the ``tt``
environment root directory. It depends on the :ref:`launch mode <tt-config_modes>`.

It is also possible to pass the configuration file name and location explicitly using
the following ways:

#.  ``-c``/``--cfg`` :ref:`global option <tt-global-options>`
#.  ``TT_CLI_CFG`` environment variable.

The ``TT_CLI_CFG`` variable has a lower priority than the ``--cfg`` option.

.. _tt-config_file_structure:

Structure
~~~~~~~~~

The ``tt`` configuration file is a YAML file with the following structure:

..  code-block:: yaml

    env:
      instances_enabled: path/to/available/applications
      bin_dir: path/to/bin_dir
      inc_dir: path/to/inc_dir
      restart_on_failure: bool
      tarantoolctl_layout: bool
    modules:
      directory: path/to/modules/dir
    app:
      run_dir: path/to/run_dir
      log_dir: path/to/log_dir
      wal_dir: path/to/wal_dir
      vinyl_dir: path/to/vinyl_dir
      memtx_dir: path/to/memtx_dir
    repo:
      rocks: path/to/rocks
      distfiles: path/to/install
    ee:
      credential_path: path/to/file
    templates:
      - path: path/to/app/templates1
      - path: path/to/app/templates2

.. note::

    The ``tt`` configuration format and application layout have been changed in version
    2.0. Learn how to upgrade from earlier versions in :ref:`tt-config_migrating-from-1`.

.. _tt-config_file_env:

env section
~~~~~~~~~~~

.. note::

    The paths specified in ``env.*`` parameters are relative to the current ``tt``
    environment's root.

*   ``instances_enabled`` -- the directory where :ref:`instances <admin-instance_file>`
    are stored. Default: ``instances.enabled``.
*   ``bin_dir`` -- the directory where binary files are stored. Default: ``bin``.
*   ``inc_dir`` -- the base directory for storing header files. They will
    be placed in the ``include`` subdirectory inside the specified directory.
    Default: ``include``.

    .. note::

        The header files directory path can also be passed using the ``TT_CLI_TARANTOOL_PREFIX``
        environment variable. If it is set, ``tt rocks`` and ``tt build`` commands use the
        ``include/tarantool`` directory inside ``TT_CLI_TARANTOOL_PREFIX`` as the
        header files directory.

*   ``restart_on_failure`` -- restart the instance on failure: ``true`` or ``false``.
    Default: ``false``.
*   ``tarantoolctl_layout`` -- use a layout compatible with the deprecated ``tarantoolctl``
    utility for artifact files: control sockets, ``.pid`` files, log files.
    Default: ``false``.

.. _tt-config_file_modules:

modules section
~~~~~~~~~~~~~~~

*   ``directory`` -- the directory where :doc:`external modules <external_modules>`
    are stored.

.. _tt-config_file_app:

app section
~~~~~~~~~~~

.. note::

    The paths specified in ``app.*_dir`` parameters are relative to the application
    location inside the ``instances.enabled`` directory specified in the ``env``
    configuration section. For example, the default location of the ``myapp``
    application's logs is ``instances.enabled/myapp/var/log``.
    Inside this location, ``tt`` creates separate directories for each application
    instance that runs in the current environment.

*   ``run_dir``-- the directory for instance runtime artifacts, such as console
    sockets or PID files. Default: ``var/run``.
*   ``log_dir`` -- the directory where log files are stored. Default: ``var/log``.
*   ``wal_dir`` -- the directory where write-ahead log (``.xlog``) files are stored.
    Default: ``var/lib``.
*   ``memtx_dir`` -- the directory where memtx stores snapshot (``.snap``) files.
    Default: ``var/lib``.
*   ``vinyl_dir`` -- the directory where vinyl files or subdirectories are stored.
    Default: ``var/lib``.

.. _tt-config_file_repo:

repo section
~~~~~~~~~~~~

*   ``rocks`` -- the directory where rocks files are stored.

    .. note::

        The rocks directory path can be passed in the ``TT_CLI_REPO_ROCKS``
        environment variable instead. The variable is also used if the directory
        specified in ``repo.rocks`` does not include a repository manifest.

*   ``distfiles`` -- the directory where installation files are stored.

.. _tt-config_file_ee:

ee section
~~~~~~~~~~

*   ``credential_path`` -- a path to the file with credentials used for
    downloading Tarantool Enterprise Edition (Tarantool customer zone credentials).
    The file should contain a username and a password, each on a separate line.
    Find an example in the :ref:`tt install <tt-install-authentication>` command
    reference.

    .. note::

        The customer zone credentials can also be passed in the
        ``TT_CLI_EE_USERNAME`` and ``TT_CLI_EE_PASSWORD`` environment variables.

templates section
~~~~~~~~~~~~~~~~~

*   ``path`` -- a path to application templates used for creating applications with
    :ref:`tt create <tt-create>`. May be specified more than once.

.. _tt-config_modes:

Launch modes
------------

``tt`` launch mode defines its working directory and the way it searches for the
configuration file. There are three launch modes:

*   default
*   system
*   local

.. _tt-config_modes-default:

Default launch
~~~~~~~~~~~~~~

**Global option**: none

**Configuration file**: searched from the current directory to the root.
Taken from ``/etc/tarantool`` if the file is not found.

**Working directory**: The directory where the configuration file is found.

.. _tt-config_modes-system:

System launch
~~~~~~~~~~~~~

**Global option**: ``--system`` or ``-S``

**Configuration file**: Taken from ``/etc/tarantool``.

**Working directory**: Current directory.

.. _tt-config_modes-local:

Local launch
~~~~~~~~~~~~

**Global option**: ``--local=DIRECTORY`` or ``-L=DIRECTORY``

**Configuration file**: Searched from the specified directory to the root.
Taken from ``/etc/tarantool`` if the file is not found.

**Working directory**: The specified directory. If ``tarantool`` or ``tt``
executable files are found in the working directory, they will be used.

.. _tt-config_migrating-from-1:

Migrating from tt 1.* to 2.0 or later
-------------------------------------

The `tt` configuration and application layout were changed in version 2.0.
If you are using ``tt`` 1.*, complete the following steps to migrate to ``tt`` 2.0 or later:

#.  **Update the tt configuration file**.
    In tt 2.0, the following changes were made to the configuration file:

    *   The root section ``tt`` was removed. Its child sections -- ``app``, ``repo``,
        ``modules``, and other -- have been moved to the top level.
    *   Environment configuration parameters were moved from the ``app`` section
        to the new section ``env``. These parameters are ``instances.enabled``,
        ``bin_dir``, ``inc_dir``, and ``restart_on_failure``.
    *   The paths in the ``app`` section are now relative to the app directory in ``instances.enabled``
        instead of the environment root.

    You can use :ref:`tt init <tt-init>` to generate a configuration file with
    the new structure and default parameter values.

#.  **Move application artifacts**.
    With ``tt`` 1.*, application artifacts (logs, snapshots, pid, and other files)
    were created in the ``var`` directory inside the *environment root*. Starting from
    ``tt`` 2.0, these artifacts are created in the ``var`` directory inside the
    *application directory*, which is ``instances.enabled/<app-name>``. This is
    how an application directory looks:

    .. code-block:: text

        instances.enabled/app/
        ├── init.lua
        ├── instances.yml
        └── var
            ├── lib
            │   ├── instance1
            │   └── instance2
            ├── log
            │   ├── instance1
            │   └── instance2
            └── run
                ├── instance1
                └── instance2

    To continue using existing application artifacts after migration from ``tt`` 1.*:

    #.  Create the ``var`` directory inside the application directory.
    #.  Create the ``lib``, ``log``, and ``run`` directories inside ``var``.
    #.  Move directories with instance artifacts from the old ``var`` directory
        to the new ``var`` directories in applications' directories.

#.  **Move the files accessed from the application code**.
    The working directory of instance processes was changed from the ``tt`` working
    directory to the application directory inside ``instances.enabled``. If the
    application accesses files using relative paths, move the files accordingly
    or adjust the application code.