.. _admin-logs:

Logs
====

Each Tarantool instance logs important events to its own log file ``<instance-name>.log``.
For instances started with :ref:`tt <tt-cli>`, the log location is defined by
the ``log_dir`` parameter in the :ref:`tt configuration <tt-config>`.
By default, it's ``/var/log/tarantool`` in the ``tt`` :ref:`system mode <tt-config_modes>`,
and the ``var/log`` subdirectory of the ``tt`` working directory in the :ref:`local mode <tt-config_modes>`.
In the specified location, ``tt`` creates separate directories for each instance's logs.

To check how logging works, write something to the log using the :ref:`log <log-module>` module:

.. code-block:: console

    $ tt connect application
       • Connecting to the instance...
       • Connected to application

    application> require('log').info("Hello for the manual readers")
    ---
    ...

Then check the logs:

.. code-block:: console

    $ tail instances.enabled/application/var/log/instance001/tt.log
    2024-04-09 17:34:29.489 [49502] main/106/gc I> wal/engine cleanup is resumed
    2024-04-09 17:34:29.489 [49502] main/104/interactive/box.load_cfg I> set 'instance_name' configuration option to "instance001"
    2024-04-09 17:34:29.489 [49502] main/104/interactive/box.load_cfg I> set 'custom_proc_title' configuration option to "tarantool - instance001"
    2024-04-09 17:34:29.489 [49502] main/104/interactive/box.load_cfg I> set 'log_nonblock' configuration option to false
    2024-04-09 17:34:29.489 [49502] main/104/interactive/box.load_cfg I> set 'replicaset_name' configuration option to "replicaset001"
    2024-04-09 17:34:29.489 [49502] main/104/interactive/box.load_cfg I> set 'listen' configuration option to [{"uri":"127.0.0.1:3301"}]
    2024-04-09 17:34:29.489 [49502] main/107/checkpoint_daemon I> scheduled next checkpoint for Tue Apr  9 19:08:04 2024
    2024-04-09 17:34:29.489 [49502] main/104/interactive/box.load_cfg I> set 'metrics' configuration option to {"labels":{"alias":"instance001"},"include":["all"],"exclude":[]}
    2024-04-09 17:34:29.489 [49502] main I> entering the event loop
    2024-04-09 17:34:38.905 [49502] main/116/console/unix/:/tarantool I> Hello for the manual readers

.. _admin-logs-rotation:

Log rotation
------------

When :ref:`logging to a file <cfg_logging-log>`, the system administrator must ensure
logs are rotated timely and do not take up all the available disk space.
The recommended way to prevent log files from growing infinitely is using an external
log rotation program, for example, ``logrotate``, which is pre-installed on most
mainstream Linux distributions.

A Tarantool log rotation configuration for ``logrotate`` can look like this:

.. code-block:: text

    # /var/log/tarantool/<env>/<app>/<instance>/*.log
    /var/log/tarantool/*/*/*/*.log {
        daily
        size 512k
        missingok
        rotate 10
        compress
        delaycompress
        sharedscripts # Run tt logrotate only once after all logs are rotated.
        postrotate
            /usr/bin/tt -S logrotate
        endscript
    }

In this configuration, :ref:`tt logrotate <tt-logrotate>` is called after each log
rotation to reopen the instance log files after they are moved by the ``logrotate``
program.

There is also the built-in function :ref:`log.rotate() <log-rotate>`, which you
can call on an instance to reopen its log file after rotation.

To learn about log rotation in the deprecated ``tarantoolctl`` utility,
check its :ref:`documentation <tarantoolctl-log-rotation>`.


.. _admin-logs-formats:

Log formats
-----------

Tarantool can write its logs to a log file, to ``syslog``, or to a specified program
through a pipe.

File is the default log format for ``tt``. To send logs to a pipe or ``syslog``,
specify the :ref:`log.to <configuration_reference_log_to>` parameter, for example:

..  literalinclude:: /code_snippets/snippets/config/instances.enabled/log_syslog/config.yaml
    :language: yaml
    :start-at: log:
    :end-at: 127.0.0.1:514
    :dedent:

In such configurations, log rotation is usually handled by the external program
used for logging.
