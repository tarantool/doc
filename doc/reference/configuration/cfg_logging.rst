.. _cfg_logging:

This section provides information on how to configure options related to logging.
You can also use the :ref:`log module <log-module>` to configure logging in your
application.

* :ref:`log_level <cfg_logging-log_level>`
* :ref:`log <cfg_logging-log>`
* :ref:`log_nonblock <cfg_logging-log_nonblock>`
* :ref:`too_long_threshold <cfg_logging-too_long_threshold>`
* :ref:`log_format <cfg_logging-log_format>`
* :ref:`log_modules <cfg_logging-log_modules>`

..  _cfg_logging-log_level:

..  confval:: log_level

    Since version 1.6.2.

    Specify the level of detail the :ref:`log <admin-logs>` has. There are the following levels:

    * 0 -- ``fatal``
    * 1 -- ``syserror``
    * 2 -- ``error``
    * 3 -- ``crit``
    * 4 -- ``warn``
    * 5 -- ``info``
    * 6 -- ``verbose``
    * 7 -- ``debug``

    By setting ``log_level``, you can enable logging of all events with severities above
    or equal to the given level. Tarantool prints logs to the standard
    error stream by default. This can be changed with the
    :ref:`log <cfg_logging-log>` configuration parameter.

    |
    | Type: integer, string
    | Default: 5
    | Environment variable: TT_LOG_LEVEL
    | Dynamic: yes

    ..  note::
        Prior to Tarantool 1.7.5 there were only six levels and ``DEBUG`` was
        level 6. Starting with Tarantool 1.7.5, ``VERBOSE`` is level 6 and ``DEBUG`` is level 7.
        ``VERBOSE`` is a new level for monitoring repetitive events which would cause
        too much log writing if ``INFO`` were used instead.

.. _cfg_logging-log:

.. confval:: log

    Since version 1.7.4.

    By default, Tarantool sends the log to the standard error stream
    (``stderr``). If ``log`` is specified, Tarantool can send the log to a:

    * file

    * pipe

    * system logger

    Example 1: sending the log to the ``tarantool.log`` file.

    .. code-block:: lua

        box.cfg{log = 'tarantool.log'}
        -- or
        box.cfg{log = 'file:tarantool.log'}

    This opens the file ``tarantool.log`` for output on the server's default
    directory. If the ``log`` string has no prefix or has the prefix "file:",
    then the string is interpreted as a file path.

    Example 2: sending the log to a pipe.

    .. code-block:: lua

        box.cfg{log = '| cronolog tarantool.log'}
        -- or
        box.cfg{log = 'pipe: cronolog tarantool.log'}

    This starts the program `cronolog <https://linux.die.net/man/1/cronolog>`_ when the server starts, and
    sends all log messages to the standard input (``stdin``) of ``cronolog``.
    If the ``log`` string begins with '|' or has the prefix "pipe:",
    then the string is interpreted as a Unix
    `pipeline <https://en.wikipedia.org/wiki/Pipeline_%28Unix%29>`_.

    Example 3: sending the log to syslog.

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
    `syslogd <https://linux.die.net/man/8/syslogd>`_ program, which normally
    is running in the background on any Unix-like platform.
    The setting can be ``syslog:``, ``syslog:facility=...``, ``syslog:identity=...``,
    ``syslog:server=...``, or a combination.

    * The ``syslog:identity`` setting is an arbitrary string, which is placed at
      the beginning of all messages. The default value is "tarantool".

    * The ``syslog:facility`` setting is currently ignored but will be used in the future.
      The value must be one of the `syslog <https://en.wikipedia.org/wiki/Syslog>`_
      keywords, which tell syslogd where the message should go.
      The possible values are: auth, authpriv, cron, daemon, ftp,
      kern, lpr, mail, news, security, syslog, user, uucp, local0, local1, local2,
      local3, local4, local5, local6, local7. The default value is: local7.

    * The ``syslog:server`` setting is the locator for the syslog server.
      It can be a Unix socket path beginning with "unix:", or an ipv4 port number.
      The default socket value is: ``dev/log`` (on Linux) or ``/var/run/syslog`` (on macOS).
      The default port value is: 514, the UDP port.

    When logging to a file, Tarantool reopens the log on `SIGHUP <https://en.wikipedia.org/wiki/SIGHUP>`_.
    When log is a program, its PID is saved in the :ref:`log.pid <log-pid>`
    variable. You need to send it a signal to rotate logs.

    |
    | Type: string
    | Default: null
    | Environment variable: TT_LOG
    | Dynamic: no

.. _cfg_logging-log_nonblock:

.. confval:: log_nonblock

    Since version 1.7.4.

    If ``log_nonblock`` equals **true**, Tarantool does not block during logging
    when the system is not ready for writing, and drops the message
    instead. If :ref:`log_level <cfg_logging-log_level>` is high, and many
    messages go to the log, setting ``log_nonblock`` to **true** may improve
    logging performance at the cost of some log messages getting lost.

    This parameter has effect only if :ref:`log <cfg_logging-log>` is
    configured to send logs to a pipe or system logger.
    The default ``log_nonblock`` value is **nil**, which means that
    blocking behavior corresponds to the logger type:

    * **false** for ``stderr`` and file loggers.

    * **true** for a pipe and system logger.

    This is a behavior change: in earlier versions of the Tarantool
    server, the default value was **true**.

    |
    | Type: boolean
    | Default: nil
    | Environment variable: TT_LOG_NONBLOCK
    | Dynamic: no

.. _cfg_logging-too_long_threshold:

.. confval:: too_long_threshold

    Since version 1.6.2.

    If processing a request takes longer than the given value (in seconds),
    warn about it in the log. Has effect only if :ref:`log_level
    <cfg_logging-log_level>` is greater than or equal to 4 (WARNING).

    |
    | Type: float
    | Default: 0.5
    | Environment variable: TT_TOO_LONG_THRESHOLD
    | Dynamic: yes

.. _cfg_logging-log_format:

.. confval:: log_format

    Since version 1.7.6.

    Log entries have two possible formats:

    * 'plain' (the default), or
    * 'json' (with more detail and with JSON labels).

    Here is what a log entry looks like if ``box.cfg{log_format='plain'}``:

    .. code-block:: text

        2017-10-16 11:36:01.508 [18081] main/101/interactive I> set 'log_format' configuration option to "plain"

    Here is what a log entry looks like if ``box.cfg{log_format='json'}``:

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

    The ``log_format='plain'`` entry has a time value, process ID,
    cord name, :ref:`fiber_id <fiber_object-id>`,
    :ref:`fiber_name <fiber_object-name_get>`,
    :ref:`log level <cfg_logging-log_level>`, and message.

    The ``log_format='json'`` entry has the same fields along with their labels,
    and in addition has the file name and line number of the Tarantool source.

    |
    | Type: string
    | Default: 'plain'
    | Environment variable: TT_LOG_FORMAT
    | Dynamic: yes


.. _cfg_logging-log_modules:

.. confval:: log_modules

    Since version :doc:`2.11.0 </release/2.11.0>`.

    Configure the specified log levels (:ref:`log_level <cfg_logging-log_level>`) for different modules.

    You can specify a logging level for the following module types:

    *   Modules (files) that use the default logger.
        Example: :ref:`Set log levels for files that use the default logger <cfg_logging-logging_example_existing_modules>`.

    *   Modules that use custom loggers created using the :ref:`log.new() <log-new>` function.
        Example: :ref:`Set log levels for modules that use custom loggers <cfg_logging-logging_example_new_modules>`.

    *   The ``tarantool`` module that enables you to configure the logging level for Tarantool core messages. Specifically, it configures the logging level for messages logged from non-Lua code, including C modules.
        Example: :ref:`Set a log level for C modules <cfg_logging-logging_example_tarantool_module>`.

    |
    | Type: table
    | Default: blank
    | Environment variable: TT_LOG_MODULES
    | Dynamic: yes


    .. _cfg_logging-logging_example_existing_modules:

    **Example 1: Set log levels for files that use the default logger**

    Suppose you have two identical modules placed by the following paths: ``test/logging/module1.lua`` and ``test/logging/module2.lua``.
    These modules use the default logger and look as follows:

    ..  literalinclude:: /code_snippets/test/logging/module1.lua
        :language: lua
        :dedent:

    To load these modules in your application, you need to add the corresponding ``require`` directives:

    ..  literalinclude:: /code_snippets/test/logging/log_existing_modules_test.lua
        :language: lua
        :lines: 7-8
        :dedent:

    To configure logging levels, you need to provide module names corresponding to paths to these modules.
    In the example below, the ``box_cfg`` variable contains logging settings that can be passed to the ``box.cfg()`` function:

    ..  literalinclude:: /code_snippets/test/logging/log_existing_modules_test.lua
        :language: lua
        :lines: 17-20
        :dedent:

    Given that ``module1`` has the ``verbose`` logging level and ``module2`` has the ``error`` level, calling ``module1.say_hello()`` shows a message but ``module2.say_hello()`` is swallowed:

    ..  literalinclude:: /code_snippets/test/logging/log_existing_modules_test.lua
        :language: lua
        :lines: 24-37
        :dedent:

    .. _cfg_logging-logging_example_new_modules:

    **Example 2: Set log levels for modules that use custom loggers**

    In the example below, the ``box_cfg`` variable contains logging settings that can be passed to the ``box.cfg()`` function.
    This example shows how to set the ``verbose`` level for ``module1`` and the ``error`` level for ``module2``:

    ..  literalinclude:: /code_snippets/test/logging/log_new_modules_test.lua
        :language: lua
        :lines: 9-13
        :dedent:

    To create custom loggers, call the :ref:`log.new() <log-new>` function:

    ..  literalinclude:: /code_snippets/test/logging/log_new_modules_test.lua
        :language: lua
        :lines: 17-19
        :dedent:

    Given that ``module1`` has the ``verbose`` logging level and ``module2`` has the ``error`` level, calling ``module1_log.info()`` shows a message but ``module2_log.info()`` is swallowed:

    ..  literalinclude:: /code_snippets/test/logging/log_new_modules_test.lua
        :language: lua
        :lines: 21-41
        :dedent:

    .. _cfg_logging-logging_example_tarantool_module:

    **Example 3: Set a log level for C modules**

    In the example below, the ``box_cfg`` variable contains logging settings that can be passed to the ``box.cfg()`` function.
    This example shows how to set the ``info`` level for the ``tarantool`` module:

    ..  literalinclude:: /code_snippets/test/logging/log_existing_c_modules_test.lua
        :language: lua
        :lines: 9-10
        :dedent:

    The specified level affects messages logged from C modules:

    ..  literalinclude:: /code_snippets/test/logging/log_existing_c_modules_test.lua
        :language: lua
        :lines: 14-29
        :dedent:

    The example above uses the `LuaJIT ffi library <http://luajit.org/ext_ffi.html>`_ to call C functions provided by the ``say`` module.


.. _cfg_logging-logging_example:

*********************
Logging example
*********************

This example illustrates how "rotation" works, that is, what happens when the server
instance is writing to a log and signals are used when archiving it.

1. Start with two terminal shells: Terminal #1 and Terminal #2.

2. In Terminal #1, start an interactive Tarantool session.
   Then, use the ``log`` property to send logs to `Log_file` and
   call ``log.info`` to put a message in the log file.

   .. code-block:: lua

       box.cfg{log='Log_file'}
       log = require('log')
       log.info('Log Line #1')

3. In Terminal #2, use the ``mv`` command to rename the log file to `Log_file.bak`.

   .. cssclass:: highlight
   .. parsed-literal::

       mv Log_file Log_file.bak

   As a result, the next log message will go to `Log_file.bak`.

4. Go back to Terminal #1 and put a message "Log Line #2" in the log file.

   .. code-block:: lua

       log.info('Log Line #2')

5. In Terminal #2, use ``ps`` to find the process ID of the Tarantool instance.

   .. cssclass:: highlight
   .. parsed-literal::

       ps -A | grep tarantool

6. In Terminal #2, execute ``kill -HUP`` to send a SIGHUP signal to the Tarantool instance.
   Tarantool will open `Log_file` again, and the next log message will go to `Log_file`.

   .. cssclass:: highlight
   .. parsed-literal::

       kill -HUP *process_id*

   The same effect could be accomplished by calling :ref:`log.rotate <log-rotate>`.

7. In Terminal #1, put a message "Log Line #3" in the log file.

   .. code-block:: lua

       log.info('Log Line #3')

8. In Terminal #2, use ``less`` to examine files.
   `Log_file.bak` will have the following lines ...

   .. cssclass:: highlight
   .. parsed-literal::

       2015-11-30 15:13:06.373 [27469] main/101/interactive I> Log Line #1`
       2015-11-30 15:14:25.973 [27469] main/101/interactive I> Log Line #2`

   ... and `Log_file` will look like this:

   .. cssclass:: highlight
   .. parsed-literal::

       log file has been reopened
       2015-11-30 15:15:32.629 [27469] main/101/interactive I> Log Line #3