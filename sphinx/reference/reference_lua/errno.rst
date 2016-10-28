.. _errno-module:

-------------------------------------------------------------------------------
                            Module `errno`
-------------------------------------------------------------------------------

.. module:: errno

The ``errno`` module has a function ``strerror()``
which will return the text of an operating-system
error, given its error number.
Typically this module is used within a function
or within a Lua program, in association with a
module whose functions can return operating-system errors,
such as :ref:`fio <fio-module>`.

.. _errno-strerror:

.. function:: strerror([code])

    Return a string, given an error number.
    The string will contain the conventional error message
    for the current operating system.
    If ``code`` is not supplied, the error message will be
    for the last operating-system-related function, or 0.

    :param integer       code: number of an operating-system error

    Return type: string

    Example:

    This function displays the result of a call to
    :ref:`fio.open() <fio-open>` which causes error 2 (errno.ENOENT).

    .. code-block:: none

        tarantool> function f()
                 >   local fio = require('fio')
                 >   local errno = require('errno')
                 >   fio.open('no_such_file')
                 >   print(errno.strerror())
                 > end
        ---
        ...

        tarantool> f()
        No such file or directory
        ---
        ...
