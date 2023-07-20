.. _log-module:

-------------------------------------------------------------------------------
                                   Module log
-------------------------------------------------------------------------------

.. module:: log

===============================================================================
                                   Overview
===============================================================================

Tarantool provides a set of :ref:`options <cfg_logging>` used to configure logging
in various ways: you can set a level of logging, specify where to send the log's output,
configure a log format, and so on.
The ``log`` module allows you to configure logging in your application and
provides additional capabilities, for example, logging custom messages and
rotating log files.

===============================================================================
                                    Index
===============================================================================

Below is a list of all ``log`` functions.

.. container:: table

    .. rst-class:: left-align-column-1
    .. rst-class:: left-align-column-2

    +--------------------------------------+---------------------------------+
    | Name                                 | Use                             |
    +======================================+=================================+
    | :ref:`log.cfg({})                    | Configure a logger              |
    | <log-cfg>`                           |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`log.error()                    |                                 |
    | <log-ug_message>` |br|               |                                 |
    | :ref:`log.warn()                     |                                 |
    | <log-ug_message>` |br|               |                                 |
    | :ref:`log.info()                     | Log a message with the          |
    | <log-ug_message>` |br|               | specified level                 |
    | :ref:`log.verbose()                  |                                 |
    | <log-ug_message>` |br|               |                                 |
    | :ref:`log.debug()                    |                                 |
    | <log-ug_message>`                    |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`log.pid()                      | Get the PID of a logger         |
    | <log-pid>`                           |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`log.rotate()                   | Rotate a log file               |
    | <log-rotate>`                        |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`log.new()                      | Create a new logger with        |
    | <log-new>`                           | the specified name              |
    +--------------------------------------+---------------------------------+

.. _log-cfg:

.. function:: log.cfg({})

    Configure logging options.
    The following options are available:

    * ``level``: Specifies the level of detail the log has.

      Learn more: :ref:`log_level <cfg_logging-log_level>`.

    * ``log``: Specifies where to send the log's output, for example,
      to a file, pipe, or system logger.

      Learn more: :ref:`log <cfg_logging-log>`.

    * ``nonblock``: If **true**, Tarantool does not block during logging when the system
      is not ready for writing, and drops the message instead.

      Learn more: :ref:`log_nonblock <cfg_logging-log_nonblock>`.

    * ``format``: Specifies the log format: 'plain' or 'json'.

      Learn more: :ref:`log_format <cfg_logging-log_format>`.

    * ``modules``: Configures the specified log levels for different modules.

      Learn more: :ref:`log_modules <cfg_logging-log_modules>`.

    The example below shows how to set the log level to 'debug' and how to send the resulting log
    to the 'tarantool.log' file:

    .. code-block:: lua

        log = require('log')
        log.cfg{ level='debug', log='tarantool.log'}

    .. NOTE::

        Note that calling ``log.cfg()`` before ``box.cfg()`` takes into account
        logging options specified using :ref:`environment variables <box-cfg-params-env>`,
        such as ``TT_LOG`` and ``TT_LOG_LEVEL``.

.. _log-ug_message:

.. function:: error(message)
              warn(message)
              info(message)
              verbose(message)
              debug(message)

    Log a message with the specified logging level.
    You can learn more about the available levels from the
    :ref:`log_level <cfg_logging-log_level>` property description.

    The example below shows how to log a message with the ``info`` level:

    ..  literalinclude:: /code_snippets/test/logging/log_test.lua
        :language: lua
        :lines: 13-21
        :dedent:

    :param any message:    A log message.

                           * A message can be a string.

                           * A message may contain C-style format specifiers ``%d`` or ``%s``. Example:

                             .. code-block:: lua

                                 box.cfg{}
                                 log = require('log')
                                 log.info('Info %s', box.info.version)

                           * A message may be a scalar data type or a table. Example:

                             .. code-block:: lua

                                 log = require('log')
                                 log.error({500,'Internal error'})

    :return: nil

    The actual output will be a line in the log, containing:

    * the current timestamp
    * a module name
    * 'E', 'W', 'I', 'V' or 'D' depending on the called function
    * ``message``

    Note that the message will not be logged if the severity level corresponding to
    the called function is less than :ref:`log_level <cfg_logging-log_level>`.

.. _log-pid:

.. function:: pid()

    :return: A PID of a logger. You can use this PID to send a signal to a log rotation program, so it can rotate logs.

.. _log-rotate:

.. function:: rotate()

    Rotate the log.
    For example, you need to call this function to continue logging after a log rotation program
    renames or moves a file with the latest logs.

    :return: nil

.. _log-new:

.. function:: new(name)

    **Since:** :doc:`2.11.0 </release/2.11.0>`

    Create a new logger with the specified name.
    You can configure a specific log level for a new logger using the :ref:`log_modules <cfg_logging-log_modules>` configuration property.

    :param string name: a logger name
    :return: a logger instance

    **Example:**

    The code snippet below shows how to set the ``verbose`` level for ``module1`` and the ``error`` level for ``module2``:

    ..  literalinclude:: /code_snippets/test/logging/log_new_modules_test.lua
        :language: lua
        :lines: 9-13
        :dedent:

    To create the ``module1`` and ``module2`` loggers, call the ``new()`` function:

    ..  literalinclude:: /code_snippets/test/logging/log_new_modules_test.lua
        :language: lua
        :lines: 17-19
        :dedent:

    Then, you can call functions corresponding to different logging levels to make sure
    that events with severities above or equal to the given levels are shown:

    ..  literalinclude:: /code_snippets/test/logging/log_new_modules_test.lua
        :language: lua
        :lines: 21-41
        :dedent:

    At the same time, the events with severities below the specified levels are swallowed.
