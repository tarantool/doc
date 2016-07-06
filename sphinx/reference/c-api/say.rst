===========================================================
                Logging module
===========================================================

.. cpp:enum:: say_level

    .. cpp:enumerator:: say_level:S_FATAL

        do not use this value directly

    .. cpp:enumerator:: say_level:S_SYSERROR

    .. cpp:enumerator:: say_level:S_ERROR

    .. cpp:enumerator:: say_level:S_CRIT

    .. cpp:enumerator:: say_level:S_WARN

    .. cpp:enumerator:: say_level:S_INFO

    .. cpp:enumerator:: say_level:S_DEBUG

.. c:macro:: say(level, format, ...)

    Format and print a message to Tarantool log file.

    :param int          level: :cpp:enum:`log level <say_level>`
    :param const char* format: ``printf()``-like format string
    :param                ...: format arguments

    See also :manpage:`printf(3)`, :cpp:enum:`say_level`

.. c:macro:: say_error    (format, ...)
             say_crit     (format, ...)
             say_warn     (format, ...)
             say_info     (format, ...)
             say_debug    (format, ...)
             say_syserror (format, ...)

    Format and print a message to Tarantool log file.

    :param const char* format: ``printf()``-like format string
    :param                ...: format arguments

    See also :manpage:`printf(3)`, :cpp:enum:`say_level`

    Example:

    .. code-block:: c

        say_info("Some useful information: %s", status);
