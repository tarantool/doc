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
:ref:`option <tt-global-options>`.

The ``tt`` configuration file is a YAML file with the following content:

..  code-block:: yaml

    tt:
      modules:
        directory: path/to/modules/dir
      app:
        instances_enabled: path/to/applications
        run_dir: path/to/run_dir
        log_dir: path/to/log_dir
        bin_dir: path/to/bin_dir
        inc_dir: path/to/inc_dir
        wal_dir: path/to/wal_dir
        vinyl_dir: path/to/vinyl_dir
        memtx_dir: path/to/memtx_dir
        log_maxsize: num (MB)
        log_maxage: num (days)
        log_maxbackups: num
        restart_on_failure: bool
      repo:
        rocks: path/to/rocks
        distfiles: path/to/install
      ee:
        credential_path: path/to/file
      templates:
        - path: path/to/app/templates1
        - path: path/to/app/templates2

modules section
~~~~~~~~~~~~~~~

*   ``directory`` -- the directory where :doc:`external modules <external_modules>`
    are stored.

.. _tt-config_file_app:

app section
~~~~~~~~~~~

*   ``instances_enabled`` -- the directory where :ref:`instances <admin-instance_file>`
    are stored.
*   ``run_dir``-- the directory for instance runtime artifacts, such as console
    sockets or PID files. Default: ``var/run``.
*   ``log_dir`` -- the directory where log files are stored. Default: ``var/log``.
*   ``bin_dir`` -- the directory where binary files are stored. Default: ``bin``.
*   ``inc_dir`` -- the base directory for storing header files. They will
    be placed in the ``include`` subdirectory inside the specified directory.
    Default: ``include``.
*   ``wal_dir`` -- the directory where write-ahead log (``.xlog``) files are stored.
    Default: ``var/lib``.
*   ``memtx_dir`` -- the directory where memtx stores snapshot (``.snap``) files.
    Default: ``var/lib``.
*   ``vinyl_dir`` -- the directory where vinyl files or subdirectories are stored.
    Default: ``var/lib``.

    .. note::

        In all directories specified in ``*_dir`` parameters, ``tt`` creates a
        directory for each application and instance directories inside it.
        Names of these directories match the names of applications and instances.

*   ``log_maxsize`` -- the maximum size of the log file before it gets rotated,
    in megabytes. Default: 100.
*   ``log_maxage`` -- the maximum age of log files in days. The age of a log
    file is defined by the timestamp encoded in its name. Default: not defined
    (log files aren't deleted based on their age).

    ..  note::

        A day is defined as exactly 24 hours. It may not exactly correspond to
        calendar days due to daylight savings, leap seconds, and other time adjustments.

*   ``log_maxbackups`` -- the maximum number of stored log files.
    Default: not defined (log files aren't deleted based on their count).
*   ``restart_on_failure`` -- restart the instance on failure: ``true`` or ``false``.
    Default: ``false``.

.. _tt-config_file_repo:

repo section
~~~~~~~~~~~~

*   ``rocks`` -- the directory where rocks files are stored.
*   ``distfiles`` -- the directory where installation files are stored.

.. _tt-config_file_ee:

ee section
~~~~~~~~~~

*   ``credential_path`` -- a path to the file with credentials used for
    downloading Tarantool Enterprise.

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