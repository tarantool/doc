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
    The following logging options are available:

    * ``level``: Specifies the level of detail the log has.
      This property has the same effect as :ref:`log_level <cfg_logging-log_level>`.

    * ``log``: Specifies where to to send the log's output, for example,
      to a file, pipe, or system logger.

      See also: :ref:`log <cfg_logging-log>`

    * ``nonblock``: If **true**, Tarantool does not block during logging when the system
      is not ready for writing, and drops the message instead.

      See also: :ref:`log_nonblock <cfg_logging-log_nonblock>`

    * ``format``: Specifies the log format: 'plain' or 'json'.

      See also: :ref:`log_format <cfg_logging-log_format>`

    The example below shows how set the log level to 'debug' and how to send the resulting log
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

    Output a user-generated message to the :ref:`log file <cfg_logging-log>`,
    given log_level_function_name = ``error`` or ``warn`` or ``info`` or
    ``verbose`` or ``debug``.

    As explained in the description of the configuration setting for
    :ref:`log_level <cfg_logging-log_level>`, there are seven levels of detail:

    * 1 – ``SYSERROR``
    * 2 – ``ERROR`` -- this corresponds to ``log.error(...)``
    * 3 – ``CRITICAL``
    * 4 – ``WARNING``  -- this corresponds to ``log.warn(...)``
    * 5 – ``INFO`` -- this corresponds to ``log.info(...)``
    * 6 – ``VERBOSE``  -- this corresponds to ``log.verbose(...)``
    * 7 – ``DEBUG`` -- this corresponds to ``log.debug(...)``

    For example, if ``box.cfg.log_level`` is currently 5 (the default value),
    then ``log.error(...)``, ``log.warn(...)`` and ``log.info(...)`` messages
    will go to the log file. However, ``log.verbose(...)`` and
    ``log.debug(...)`` messages will not go to the log file, because they
    correspond to higher levels of detail.

    :param any message:    Usually a string.

                           Messages may contain C-style format specifiers %d or
                           %s, so :samp:`log.error('...%d...%s', {x}, {y})`
                           will work if ``x`` is a number and ``y`` is a string.

                           Less commonly, messages may be other scalar data types,
                           or even tables. So :code:`log.error({'x',18.7,true})`
                           will work.

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

    :return: PID of a logger

.. _log-rotate:

.. function:: rotate()

    Rotate the log.

    :return: nil

=================================================
                     Example
=================================================

.. code-block:: tarantoolsession

    $ tarantool
    tarantool> box.cfg{log_level=3, log='tarantool.txt'}
    tarantool> log = require('log')
    tarantool> log.error('Error')
    tarantool> log.info('Info %s', box.info.version)
    tarantool> os.exit()

.. code-block:: console

    $ less tarantool.txt
    2017-09-20 ... [68617] main/101/interactive C> version 1.7.5-31-ge939c6ea6
    2017-09-20 ... [68617] main/101/interactive C> log level 3
    2017-09-20 ... [68617] main/101/interactive [C]:-1 E> Error

The 'Error' line is visible in ``tarantool.txt`` preceded by the letter E.

The 'Info' line is not present because the ``log_level`` is 3.
