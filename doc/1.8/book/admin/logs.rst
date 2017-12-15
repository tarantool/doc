.. _admin-logs:

================================================================================
Logs
================================================================================

Tarantool logs important events to a file, e.g. ``/var/log/tarantool/my_app.log``.
To build the log file path, ``tarantoolctl`` takes the instance name, prepends
the instance directory and appends “.log” extension.

Let’s write something to the log file:

.. code-block:: console

    $ tarantoolctl enter my_app
    /bin/tarantoolctl: connected to unix/:/var/run/tarantool/my_app.control
    unix/:/var/run/tarantool/my_app.control> require('log').info("Hello for the manual readers")
    ---
    ...

Then check the logs:

.. code-block:: console

    $ tail /var/log/tarantool/my_app.log
    2017-04-04 15:54:04.977 [29255] main/101/tarantoolctl C> version 1.7.3-382-g68ef3f6a9
    2017-04-04 15:54:04.977 [29255] main/101/tarantoolctl C> log level 5
    2017-04-04 15:54:04.978 [29255] main/101/tarantoolctl I> mapping 134217728 bytes for tuple arena...
    2017-04-04 15:54:04.985 [29255] iproto/101/main I> binary: bound to [::1]:3301
    2017-04-04 15:54:04.986 [29255] main/101/tarantoolctl I> recovery start
    2017-04-04 15:54:04.986 [29255] main/101/tarantoolctl I> recovering from `/var/lib/tarantool/my_app/00000000000000000000.snap'
    2017-04-04 15:54:04.988 [29255] main/101/tarantoolctl I> ready to accept requests
    2017-04-04 15:54:04.988 [29255] main/101/tarantoolctl I> set 'checkpoint_interval' configuration option to 3600
    2017-04-04 15:54:04.988 [29255] main/101/my_app I> Run console at unix/:/var/run/tarantool/my_app.control
    2017-04-04 15:54:04.989 [29255] main/106/console/unix/:/var/ I> started
    2017-04-04 15:54:04.989 [29255] main C> entering the event loop
    2017-04-04 15:54:47.147 [29255] main/107/console/unix/: I> Hello for the manual readers

When logging to a file, the system administrator must ensure logs are
rotated timely and do not take up all the available disk space. With
``tarantoolctl``, log rotation is pre-configured to use ``logrotate`` program,
which you must have installed.

File ``/etc/logrotate.d/tarantool`` is part of the standard Tarantool
distribution, and you can modify it to change the default behavior. This is what
this file is usually like:

.. code-block:: text

   /var/log/tarantool/*.log {
       daily
       size 512k
       missingok
       rotate 10
       compress
       delaycompress
       create 0640 tarantool adm
       postrotate
           /usr/bin/tarantoolctl logrotate `basename ${1%%.*}`
       endscript
   }

If you use a different log rotation program, you can invoke
``tarantoolctl logrotate`` command to request instances to reopen their log
files after they were moved by the program of your choice.

Tarantool can write its logs to a log file, ``syslog`` or a program specified
in the configuration file (see :ref:`log <cfg_logging-log>` parameter).

By default, logs are written to a file as defined in ``tarantoolctl``
defaults. ``tarantoolctl`` automatically detects if an instance is using
``syslog`` or an external program for logging, and does not override the log
destination in this case. In such configurations, log rotation is usually
handled by the external program used for logging. So,
``tarantoolctl logrotate`` command works only if logging-into-file is enabled
in the instance file.
