tt configuration
================

tt configuration file
---------------------

By default, ``tt`` uses the ``tarantool.yaml`` file.
With the ``--cfg`` flag you can specify the path to configration file.

Example of configuration file format:

..  code:: yaml

    tt:
        modules:
            directory: path/to/modules/dir
    app:
        instances_available: path/to/available/applications
        run_dir: path/to/run_dir
        log_dir: path/to/log_dir
        log_maxsize: num (MB)
        log_maxage: num (Days)
        log_maxbackups: num
        restart_on_failure: bool

modules section
~~~~~~~~~~~~~~~

* ``directory`` -- a directory where external modules are stored.

app section
~~~~~~~~~~~

* ``instances_available`` -- a directory where :ref:`instances <admin-instance_file>`
  are stored.
* ``run_dir``-- a directory in which ``tt`` stores instance runtime artifacts,
  such as console sockets or PID files.
* ``log_dir`` -- a directory where log files are stored.
* ``log_maxsize`` -- the maximum size of the log file before it gets rotated,
  in megabytes. Default: 100 MB.
* ``log_maxage`` -- the maximum age of log files in days. The age of a log
file is defined by the timestamp encoded in its name. Default: not defined
(don't delete log files based on their age).

  ..  note:
      A day is defined as exactly 24 hours. It may not exactly correspond to
      calendar days due to daylight savings, leap seconds, and other.

* ``log_maxbackups`` -- the maximum number of stored log files.
  Default: not defined (don't delete log files based on their count).
* ``restart_on_failure`` -- restart the instance on failure: ``true`` or ``false``.

tt modes
--------

``tt`` launch mode defines its working directory and the way it searches the configuration file:

..  container:: table

    ..  list-table::
        :widths: 15 10 35 40
        :header-rows: 1

        *   -   Mode
            -   Flag
            -   Configuration file
            -   Working directory
        *   -   Default
            -   --
            -   Searched from the current directory to the root.
                ``/etc/tarantool`` if the file is not found.
            -   The directory where the configuration file is found.
        *   -   System launch
            -   ``-S``
            -   ``/etc/tarantool``
            -   Current directory
        *   -   Local launch
            -   ``-L [path]``
            -   The specified directory.
                If tarantool or tt executable files are found in working directory,
                they will be used further.
            -   Searched from the working directory to the root.
                ``/etc/tarantool`` if the file is not found.
