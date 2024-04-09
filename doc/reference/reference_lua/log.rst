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

    *   ``level``: Specify the level of detail the log has.

        The example below shows how to set the log level to ``verbose``:

        ..  literalinclude:: /code_snippets/test/logging/log_test.lua
            :language: lua
            :start-at: local log = require
            :end-at: log.cfg
            :dedent:

        See also: :ref:`log.level <configuration_reference_log_level>`.

    *   ``log``: Specify where to send the log's output, for example, to a file, pipe, or system logger.

        **Example 1: sending the log to the tarantool.log file**

        .. code-block:: lua

            log.cfg { log = 'tarantool.log' }

        **Example 2: sending the log to a pipe**

        .. code-block:: lua

            log.cfg { log = '| cronolog tarantool.log' }

        **Example 3: sending the log to syslog**

        .. code-block:: lua

            log.cfg { log = 'syslog:server=unix:/dev/log' }

        See also: :ref:`log.to <configuration_reference_log_to>`.

    *   ``nonblock``: If **true**, Tarantool does not block during logging when the system
        is not ready for writing, and drops the message instead.

        See also: :ref:`log.nonblock <configuration_reference_log_nonblock>`.

    *   ``format``: Specify the log format: 'plain' or 'json'.

        See also: :ref:`log.format <configuration_reference_log_format>`.

    *   ``modules``: Configure the specified log levels for different modules.

        See also: :ref:`log.modules <configuration_reference_log_modules>`.


.. _log-ug_message:

.. function:: error(message)
              warn(message)
              info(message)
              verbose(message)
              debug(message)

    Log a message with the specified logging level.
    You can learn more about the available levels from the
    :ref:`log.level <configuration_reference_log_level>` option description.

    **Example**

    The example below shows how to log a message with the ``warn`` level:

    ..  literalinclude:: /code_snippets/test/logging/log_test.lua
        :language: lua
        :start-at: log.warn
        :end-at: log.warn
        :dedent:

    :param any message:    A log message.

                           * A message can be a string.

                           * A message may contain C-style format specifiers ``%d`` or ``%s``. Example:

                             ..  literalinclude:: /code_snippets/test/logging/log_test.lua
                                 :language: lua
                                 :start-at: log.info
                                 :end-at: log.info
                                 :dedent:

                           * A message may be a scalar data type or a table. Example:

                             ..  literalinclude:: /code_snippets/test/logging/log_test.lua
                                 :language: lua
                                 :start-at: log.error
                                 :end-at: log.error
                                 :dedent:

    :return: nil

    The actual output will be a line in the log, containing:

    * the current timestamp
    * a module name
    * 'E', 'W', 'I', 'V' or 'D' depending on the called function
    * ``message``

    Note that the message will not be logged if the severity level corresponding to
    the called function is less than :ref:`log.level <configuration_reference_log_level>`.

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
    You can configure a specific log level for a new logger using the :ref:`log.modules <configuration_reference_log_modules>` configuration property.

    :param string name: a logger name
    :return: a logger instance

    **Example**

    This example shows how to set the ``verbose`` level for ``module1`` and the ``error`` level for ``module2`` in a configuration file:

    ..  literalinclude:: /code_snippets/snippets/config/instances.enabled/log_new_modules/config.yaml
        :language: yaml
        :start-at: log:
        :end-at: app.lua
        :dedent:

    To create the ``module1`` and ``module2`` loggers in your application (``app.lua``), call the ``new()`` function:

    ..  literalinclude:: /code_snippets/snippets/config/instances.enabled/log_new_modules/app.lua
        :language: lua
        :start-at: Creates new loggers
        :end-at: module2_log = require
        :dedent:

    Then, you can call functions corresponding to different logging levels to make sure
    that events with severities above or equal to the given levels are shown:

    ..  literalinclude:: /code_snippets/snippets/config/instances.enabled/log_new_modules/app.lua
        :language: lua
        :start-after: module2_log = require
        :dedent:

    At the same time, the events with severities below the specified levels are swallowed.

    Example on GitHub: `log_new_modules <https://github.com/tarantool/doc/tree/latest/doc/code_snippets/snippets/config/instances.enabled/log_new_modules>`_.
