===========================================================
                        Module `coio`
===========================================================

.. cpp:enum:: COIO_EVENT

    .. cpp:enumerator:: ::COIO_READ

        READ event

    .. cpp:enumerator:: ::COIO_WRITE

        WRITE event

.. c:function:: int coio_wait(int fd, int event, double timeout)

    Wait until READ or WRITE event on socket (``fd``). Yields.

    :param int         fd: non-blocking socket file description
    :param int      event: requested events to wait. Combination of
                           ``COIO_READ | COIO_WRITE`` bit flags.
    :param double timeout: timeout in seconds.

    :return: 0 - timeout
    :return: >0 - returned events. Combination of ``TNT_IO_READ | TNT_IO_WRITE`` bit flags.

.. c:function:: ssize_t coio_call(ssize_t (*func)(va_list), ...)

    Create new eio task with specified function and arguments. Yield and wait
    until the task is complete or a timeout occurs.

    This function doesn't throw exceptions to avoid double error checking: in
    most cases it's also necessary to check the return value of the called
    function and perform necessary actions. If func sets errno, the errno is
    preserved across the call.

    :return: -1 and ``errno`` = ENOMEM if failed to create a task
    :return: the function return (``errno`` is preserved).

    **Example:**

    .. code-block:: c

        static ssize_t openfile_cb(va_list ap)
        {
                const char* filename = va_arg(ap);
                int flags = va_arg(ap);
                return open(filename, flags);
        }

        if (coio_call(openfile_cb, 0.10, "/tmp/file", 0) == -1)
            // handle errors.
        ...


.. c:function:: int coio_getaddrinfo(const char *host, const char *port, const struct addrinfo *hints, struct addrinfo **res, double timeout)

    Fiber-friendly version of :manpage:`getaddrinfo(3)`.

