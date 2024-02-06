.. _tt-config:

Configuration
=============

.. _tt-config_file:

Configuration file
------------------

The key artifact that defines the ``tt`` environment and various aspects of its
execution is its configuration file.

By default, the configuration file is called ``tt.yaml``. The location
where ``tt`` searches for it depends on the :ref:`launch mode <tt-config_modes>`.
You can also pass the configuration file explicitly in the ``--cfg``
:ref:`global option <tt-global-options>`.

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
    application's logs is ``instances.enabled/myapp/var/log/``.
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
*   ``distfiles`` -- the directory where installation files are stored.

.. _tt-config_file_ee:

ee section
~~~~~~~~~~

*   ``credential_path`` -- a path to the file with credentials used for
    downloading Tarantool Enterprise Edition.

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

Default launch
~~~~~~~~~~~~~~

**Argument**: none

**Configuration file**: searched from the current directory to the root.
Taken from ``/etc/tarantool`` if the file is not found.

**Working directory**: The directory where the configuration file is found.

.. _tt-config_modes-system:

System launch
~~~~~~~~~~~~~

**Argument**: ``--system`` or ``-S``

**Configuration file**: Taken from ``/etc/tarantool``.

**Working directory**: Current directory.

.. _tt-config_modes-local:

Local launch
~~~~~~~~~~~~

**Argument**: ``--local=DIRECTORY`` or ``-L=DIRECTORY``

**Configuration file**: Searched from the specified directory to the root.
Taken from ``/etc/tarantool`` if the file is not found.

**Working directory**: The specified directory. If ``tarantool`` or ``tt``
executable files are found in the working directory, they will be used.