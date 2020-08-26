.. _cfg_logging:

* :ref:`log_level <cfg_logging-log_level>`
* :ref:`log <cfg_logging-log>`
* :ref:`log_nonblock <cfg_logging-log_nonblock>`
* :ref:`too_long_threshold <cfg_logging-too_long_threshold>`
* :ref:`log_format <cfg_logging-log_format>`

.. _cfg_logging-log_level:

.. confval:: log_level

    Since version 1.6.2.
    What level of detail the :ref:`log <admin-logs>` will have. There are seven levels:

    * 1 – ``SYSERROR``
    * 2 – ``ERROR``
    * 3 – ``CRITICAL``
    * 4 – ``WARNING``
    * 5 – ``INFO``
    * 6 – ``VERBOSE``
    * 7 – ``DEBUG``

    By setting log_level, one can enable logging of all classes below
    or equal to the given level. Tarantool prints its logs to the standard
    error stream by default, but this can be changed with the
    :ref:`log <cfg_logging-log>` configuration parameter.

    | Type: integer
    | Default: 5
    | Dynamic: **yes**

    Warning: prior to Tarantool 1.7.5 there were only six levels and ``DEBUG`` was
    level 6. Starting with Tarantool 1.7.5 ``VERBOSE`` is level 6 and ``DEBUG`` is level 7.
    ``VERBOSE`` is a new level for monitoring repetitive events which would cause
    too much log writing if ``INFO`` were used instead.

.. _cfg_logging-log:

.. confval:: log

    Since version 1.7.4.
    By default, Tarantool sends the log to the standard error stream
    (``stderr``). If ``log`` is specified, Tarantool sends the log to a file,
    or to a pipe, or to the system logger.

    Example setting for sending the log to a file:

    .. code-block:: lua

        box.cfg{log = 'tarantool.log'}
        -- or
        box.cfg{log = 'file:tarantool.log'}

    This will open the file ``tarantool.log`` for output on the server’s default
    directory. If the ``log`` string has no prefix or has the prefix "file:",
    then the string is interpreted as a file path.

    Example setting for sending the log to a pipe:

    .. code-block:: lua

        box.cfg{log = '| cronolog tarantool.log'}
        -- or
        box.cfg{log = 'pipe: cronolog tarantool.log'}'

    This will start the program `cronolog <https://linux.die.net/man/1/cronolog>`_ when the server starts, and
    will send all log messages to the standard input (``stdin``) of cronolog.
    If the ``log`` string begins with '|' or has the prefix "pipe:",
    then the string is interpreted as a Unix
    `pipeline <https://en.wikipedia.org/wiki/Pipeline_%28Unix%29>`_.

    Example setting for sending the log to syslog:

    .. code-block:: lua

        box.cfg{log = 'syslog:identity=tarantool'}
        -- or
        box.cfg{log = 'syslog:facility=user'}
        -- or
        box.cfg{log = 'syslog:identity=tarantool,facility=user'}
        -- or
        box.cfg{log = 'syslog:server=unix:/dev/log'}

    If the ``log`` string begins with "syslog:", then it is
    interpreted as a message for the
    `syslogd <http://www.rfc-base.org/txt/rfc-5424.txt>`_ program which normally
    is running in the background of any Unix-like platform.
    The setting can be 'syslog:', 'syslog:facility=...', 'syslog:identity=...',
    'syslog:server=...', or a combination.

    The ``syslog:identity`` setting is an arbitrary string which will be placed at
    the beginning of all messages. The default value is: tarantool.

    The ``syslog:facility`` setting is currently ignored but will be used in the future.
    The value must be one of the `syslog <https://en.wikipedia.org/wiki/Syslog>`_
    keywords, which tell syslogd where the message should go.
    The possible values are: auth, authpriv, cron, daemon, ftp,
    kern, lpr, mail, news, security, syslog, user, uucp, local0, local1, local2,
    local3, local4, local5, local6, local7. The default value is: user.

    The ``syslog:server`` setting is the locator for the syslog server.
    It can be a Unix socket path beginning with "unix:", or an ipv4 port number.
    The default socket value is: dev/log (on Linux) or /var/run/syslog (on Mac OS).
    The default port value is: 514, the UDP port.

    When logging to a file, Tarantool reopens the log on `SIGHUP <https://en.wikipedia.org/wiki/SIGHUP>`_.
    When log is
    a program, its pid is saved in the :ref:`log.logger_pid <log-logger_pid>`
    variable. You need to send it a signal to rotate logs.

    | Type: string
    | Default: null
    | Dynamic: no

.. _cfg_logging-log_nonblock:

.. confval:: log_nonblock

    Since version 1.7.4.
    If ``log_nonblock`` equals true, Tarantool does not block on the log
    file descriptor when it’s not ready for write, and drops the message
    instead. If :ref:`log_level <cfg_logging-log_level>` is high, and many
    messages go to the log file, setting ``log_nonblock`` to true may improve
    logging performance at the cost of some log messages getting lost.

    This parameter has effect only if the output is going to ``syslog`` or
    to a pipe.

    | Type: boolean
    | Default: true
    | Dynamic: no

.. _cfg_logging-too_long_threshold:

.. confval:: too_long_threshold

    Since version 1.6.2.
    If processing a request takes longer than the given value (in seconds),
    warn about it in the log. Has effect only if :ref:`log_level
    <cfg_logging-log_level>` is more than or equal to 4 (WARNING).

    | Type: float
    | Default: 0.5
    | Dynamic: **yes**

.. _cfg_logging-log_format:

.. confval:: log_format

    Since version 1.7.6. Log entries have two possible formats:

    * 'plain' (the default), or
    * 'json' (with more detail and with JSON labels).

    Here is what a log entry looks like after ``box.cfg{log_format='plain'}``:

    .. code-block:: text

        2017-10-16 11:36:01.508 [18081] main/101/interactive I> set 'log_format' configuration option to "plain"

    Here is what a log entry looks like after ``box.cfg{log_format='json'}``:

    .. code-block:: text

        {"time": "2017-10-16T11:36:17.996-0600",
        "level": "INFO",
        "message": "set 'log_format' configuration option to \"json\"",
        "pid": 18081,|
        "cord_name": "main",
        "fiber_id": 101,
        "fiber_name": "interactive",
        "file": "builtin\/box\/load_cfg.lua",
        "line": 317}

    The ``log_format='plain'`` entry has time, process id,
    cord name, :ref:`fiber_id <fiber_object-id>`,
    :ref:`fiber_name <fiber_object-name_get>`,
    :ref:`log level <cfg_logging-log_level>`, and message.

    The ``log_format='json'`` entry has the same things along with their labels,
    and in addition has the file name and line number of the Tarantool source.

    | Type: string
    | Default: 'plain'
    | Dynamic: **yes**

.. _cfg_logging-logging_example:

*********************
Logging example
*********************

This will illustrate how "rotation" works, that is, what happens when the server
instance is writing to a log and signals are used when archiving it.

Start with two terminal shells, Terminal #1 and Terminal #2.

On Terminal #1: start an interactive Tarantool session, then say the logging
will go to `Log_file`, then put a message "Log Line #1" in the log file:

.. code-block:: lua

    box.cfg{log='Log_file'}
    log = require('log')
    log.info('Log Line #1')

On Terminal #2: use ``mv`` so the log file is now named `Log_file.bak`.
The result of this is: the next log message will go to `Log_file.bak`.

.. cssclass:: highlight
.. parsed-literal::

    mv Log_file Log_file.bak

On Terminal #1: put a message "Log Line #2" in the log file.

.. code-block:: lua

    log.info('Log Line #2')

On Terminal #2: use ``ps`` to find the process ID of the Tarantool instance.

.. cssclass:: highlight
.. parsed-literal::

    ps -A | grep tarantool

On Terminal #2: use ``kill -HUP`` to send a SIGHUP signal to the Tarantool instance.
The result of this is: Tarantool will open `Log_file` again, and
the next log message will go to `Log_file`.
(The same effect could be accomplished by executing log.rotate() on the instance.)

.. cssclass:: highlight
.. parsed-literal::

    kill -HUP *process_id*

On Terminal #1: put a message "Log Line #3" in the log file.

.. code-block:: lua

    log.info('Log Line #3')

On Terminal #2: use ``less`` to examine files. `Log_file.bak` will have these lines,
except that the date and time will depend on when the example is done:

.. cssclass:: highlight
.. parsed-literal::

    2015-11-30 15:13:06.373 [27469] main/101/interactive I> Log Line #1`
    2015-11-30 15:14:25.973 [27469] main/101/interactive I> Log Line #2`

and `Log_file` will have

.. cssclass:: highlight
.. parsed-literal::

    log file has been reopened
    2015-11-30 15:15:32.629 [27469] main/101/interactive I> Log Line #3

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Feedback
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

* :ref:`feedback_enabled <cfg_logging-feedback_enabled>`
* :ref:`feedback_host <cfg_logging-feedback_host>`
* :ref:`feedback_interval <cfg_logging-feedback_interval>`

By default a Tarantool daemon sends a small packet
once per hour, to https://feedback.tarantool.io.
The packet contains three values from :ref:`box.info <box_introspection-box_info>`:
``box.info.version``, ``box.info.uuid``, and ``box.info.cluster_uuid``.
By changing the feedback configuration parameters, users can
adjust or turn off this feature.

.. _cfg_logging-feedback_enabled:

.. confval:: feedback_enabled

    Since version 1.10.1 Whether to send feedback.

    If this is set to ``true``, feedback will be sent as described above.
    If this is set to ``false``, no feedback will be sent.

    | Type: boolean
    | Default: true
    | Dynamic: **yes**

.. _cfg_logging-feedback_host:

.. confval:: feedback_host

    Since version 1.10.1. The address to which the packet is sent.
    Usually the recipient is Tarantool, but it can be any URL.

    | Type: string
    | Default: 'https://feedback.tarantool.io'
    | Dynamic: **yes**

.. _cfg_logging-feedback_interval:

.. confval:: feedback_interval

    Since version 1.10.1. The number of seconds between sendings, usually 3600 (1 hour).

    | Type: float
    | Default: 3600
    | Dynamic: **yes**
