.. _admin-logs:

================================================================================
Logs
================================================================================

Tarantool logs important events to a file, e.g. ``/var/log/tarantool/my_app.log``.
To build the log file path, ``tt`` takes the instance name, prepends
the instance directory and appends “.log” extension.

Let’s write something to the log file:

.. code-block:: console

    $ tt connect my_app
       • Connecting to the instance...
       • Connected to unix/:/var/run/tarantool/my_app.control

    unix/:/var/run/tarantool/my_app.control> require('log').info("Hello for the manual readers")

Then check the logs:

.. code-block:: console

    $ tail /var/log/tarantool/my_app.log
    2023-09-12 18:13:00.396 [67173] main/111/guard of feedback_daemon/box.feedback_daemon V> metrics_collector restarted
    2023-09-12 18:13:00.396 [67173] main/103/-/box.feedback_daemon V> feedback_daemon started
    2023-09-12 18:13:00.396 [67173] main/103/- D> memtx_tuple_new_raw_impl(14) = 0x1090077b4
    2023-09-12 18:13:00.396 [67173] main/103/- D> memtx_tuple_new_raw_impl(26) = 0x1090077ec
    2023-09-12 18:13:00.396 [67173] main/103/- D> memtx_tuple_new_raw_impl(39) = 0x109007824
    2023-09-12 18:13:00.396 [67173] main/103/- D> memtx_tuple_new_raw_impl(24) = 0x10900785c
    2023-09-12 18:13:00.396 [67173] main/103/- D> memtx_tuple_new_raw_impl(39) = 0x109007894
    2023-09-12 18:13:00.396 [67173] main/106/checkpoint_daemon I> scheduled next checkpoint for Tue Sep 12 19:44:34 2023
    2023-09-12 18:13:00.396 [67173] main I> entering the event loop
    2023-09-12 18:13:11.656 [67173] main/114/console/unix/:/tarantool I> Hello for the manual readers

When :ref:`logging to a file <cfg_logging-log>`, the system administrator must ensure logs are
rotated timely and do not take up all the available disk space. With
``tt``, log rotation is pre-configured to use ``logrotate`` program,
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
           /usr/bin/tt logrotate `basename ${1%%.*}`
       endscript
   }

If you use a different log rotation program, you can invoke
:ref:`tt logrotate <tt-logrotate>` command to request instances to reopen their log
files after they were moved by the program of your choice.

Tarantool can write its logs to a log file, ``syslog`` or a program specified
in the configuration file (see :ref:`log <cfg_logging-log>` parameter).

By default, logs are written to a file as defined in ``tt``
defaults. ``tt`` automatically detects if an instance is using
``syslog`` or an external program for logging, and does not override the log
destination in this case. In such configurations, log rotation is usually
handled by the external program used for logging. So,
``tt logrotate`` command works only if logging-into-file is enabled
in the instance file.
