.. _admin-logs:

Logs
====

Each Tarantool instance logs important events to its own log file ``<instance-name>.log``.
For instances started with :ref:`tt <tt-cli>`, the log location is defined by
the ``log_dir`` parameter in the :ref:`tt configuration <tt-config>`.
By default, it's ``/var/log/tarantool`` in the ``tt`` :ref:`system mode <config_modes>`,
and the ``var/log/`` subdirectory of the ``tt`` working directory in the :ref:`local mode <config_modes>`.
In the specified location, ``tt`` creates separate directories for each instance's logs.

To check how logging works, write something to the log using the :ref:`log <log-module>` module:

.. code-block:: console

    $ tt connect my_app
       • Connecting to the instance...
       • Connected to /var/run/tarantool/my_app.control

    /var/run/tarantool/my_app.control> require('log').info("Hello for the manual readers")

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

.. _admin-logs-rotation:

Log rotation
------------

When :ref:`logging to a file <cfg_logging-log>`, the system administrator must ensure logs are
rotated timely and do not take up all the available disk space.
To prevent log files from growing infinitely, ``tt`` automatically rotates instance
logs. The following ``tt`` configuration parameters define the log rotation:
``log_maxsize`` (in megabytes) and ``log_maxage`` (in days). When any of these
limits is reached, the log is rotated.
Additionally, there is the ``log_maxbackups`` parameter (the number of stored log
files for an instance), which enables automatic removal of old log files.

..  code-block:: yaml

    # tt.yaml
    tt:
      app:
        log_maxsize: 100
        log_maxage: 3
        log_maxbackups: 50
        # ...

There is also the :ref:`tt logrotate <tt-logrotate>` command that performs log
rotation on demand.

..  code-block:: bash

    tt logrotate my_app

To learn about log rotation in the deprecated ``tarantoolctl`` utility,
check its :ref:`documentation <tarantoolctl-log-rotation>`.


.. _admin-logs-formats:

Log formats
-----------

Tarantool can write its logs to a log file, to ``syslog``, or to a specified program
through a pipe.

File is the default log format for ``tt``. To send logs to a pipe or ``syslog``,
specify the :ref:`box.cfg.log <cfg_logging-log>` parameter, for example:

.. code-block:: lua

    box.cfg{log = '| cronolog tarantool.log'}
    -- or
    box.cfg{log = 'syslog:identity=tarantool,facility=user'}

In such configurations, log rotation is usually handled by the external program
used for logging.