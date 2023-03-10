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
The ``log`` module allows you to configure logging in you application and
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
    | :ref:`log.logger_pid()               | Get the PID of a logger         |
    | <log-logger_pid>`                    |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`log.rotate()                   | Rotate a log file               |
    | <log-rotate>`                        |                                 |
    +--------------------------------------+---------------------------------+

.. _log-cfg:

.. function:: log.cfg({})

    Allows you to configure logging options.
    The following options are available:

    * ``level``: Specifies the level of detail the log has.

      See also: :ref:`log_level <cfg_logging-log_level>`.

    * ``log``: Specifies where to to send the log's output, for example,
      to a file, pipe, or system logger.

      See also: :ref:`log <cfg_logging-log>`

    * ``nonblock``: If **true**, Tarantool does not block during logging when the system
      is not ready for writing, and drops the message instead.

      See also: :ref:`log_nonblock <cfg_logging-log_nonblock>`

    * ``format``: Specifies the log format: 'plain' or 'json'.
      See also: :ref:`log_format <cfg_logging-log_format>`

    The example below shows how to set the log level to 'debug' and how to send the resulting log
    to the 'tarantool.log' file:

    .. code-block:: lua

        log = require('log')
        log.cfg{ level='debug', log='tarantool.log'}


.. _log-ug_message:

.. function:: error(message)
              warn(message)
              info(message)
              verbose(message)
              debug(message)

    Logs a message with the specified logging level.
    You can learn more about the available levels from the
    :ref:`log_level <cfg_logging-log_level>` property description.

    The example below shows how to log a message with the ``info`` level:

    .. code-block:: lua

        log = require('log')
        log.info('Hello, world!')

    :param any message:    A log message.

                           * A message can be a string.

                           * A messages may contain C-style format specifiers ``%d`` or
                           ``%s``. Example:

                           .. code-block:: lua

                               box.cfg{}
                               log = require('log')
                               log.info('Info %s', box.info.version)

                           * A message may be other scalar data types,
                           or even tables. Example:

                           .. code-block:: lua

                               box.cfg{}
                               log = require('log')
                               log.error({500,'Internal error'})

    :return: nil

    The actual output will be a line in the log, containing:

    * the current timestamp,
    * a module name,
    * 'E', 'W', 'I', 'V' or 'D' depending on ``log_level_function_name``, and
    * ``message``.

    Output will not occur if ``log_level_function_name``
    is for a type greater than :ref:`log_level
    <cfg_logging-log_level>`.

.. _log-logger_pid:

.. function:: logger_pid()

    :return: Returns a PID of a logger.

.. _log-rotate:

.. function:: rotate()

    Rotates the log.

    :return: nil
