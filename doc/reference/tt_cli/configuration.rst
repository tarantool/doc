Configuration
=============

.. _tt-config_file:

Configuration file
------------------

The key artifact that defines the ``tt`` environment and various aspects of its
execution is its configuration file.

By default, the configuration file is called ``tarantool.yaml``. The location
where ``tt`` searches for it depends on the :ref:`launch mode <tt-config_modes>`.
You can also pass the configuration file explicitly in the ``--cfg``
:doc:`argument <arguments>`.

The ``tt`` configuration file is a YAML file with the following content:

..  code:: yaml

    tt:
        modules:
            directory: path/to/modules/dir
        app:
            instances_available: path/to/available/applications
            run_dir: path/to/run_dir
            log_dir: path/to/log_dir
            log_maxsize: num (MB)
            log_maxage: num (days)
            log_maxbackups: num
            restart_on_failure: bool

modules section
~~~~~~~~~~~~~~~

* ``directory`` -- the directory where external modules are stored.
.. // TODO: add link to external modules doc page when it's ready

.. _tt-config_file_app:

app section
~~~~~~~~~~~

*   ``instances_available`` -- the directory where :ref:`instances <admin-instance_file>`
    are stored.
*   ``run_dir``-- the directory for instance runtime artifacts, such as console
    sockets or PID files.
*   ``log_dir`` -- the directory where log files are stored.
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