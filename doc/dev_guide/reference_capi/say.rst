===========================================================
                Module `say` (logging)
===========================================================

.. _c_api-say-say_level:

.. cpp:enum:: say_level

    .. cpp:enumerator:: ::S_FATAL

        do not use this value directly

    .. cpp:enumerator:: ::S_SYSERROR

    .. cpp:enumerator:: ::S_ERROR

    .. cpp:enumerator:: ::S_CRIT

    .. cpp:enumerator:: ::S_WARN

    .. cpp:enumerator:: ::S_INFO

    .. cpp:enumerator:: ::S_VERBOSE

    .. cpp:enumerator:: ::S_DEBUG

.. c:macro:: say(level, format, ...)

    Format and print a message to Tarantool log file.

    :param int          level: :ref:`log level <c_api-say-say_level>`
    :param const char* format: ``printf()``-like format string
    :param                ...: format arguments

    See also :manpage:`printf(3)`, :ref:`say_level<c_api-say-say_level>`

.. c:macro:: say_error    (format, ...)
             say_crit     (format, ...)
             say_warn     (format, ...)
             say_info     (format, ...)
             say_verbose  (format, ...)
             say_debug    (format, ...)
             say_syserror (format, ...)

    Format and print a message to Tarantool log file.

    :param const char* format: ``printf()``-like format string
    :param                ...: format arguments

    See also :manpage:`printf(3)`, :ref:`say_level<c_api-say-say_level>`

    **Example:**

    .. code-block:: c

        say_info("Some useful information: %s", status);
