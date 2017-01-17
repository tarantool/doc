.. _errno-module:

-------------------------------------------------------------------------------
                            Module `errno`
-------------------------------------------------------------------------------

.. module:: errno

The ``errno`` module provides a function ``strerror()`` which will return the text of
an operating-system error, and a function ``errno()`` which will return
the last operating-system error, and a `metatable`_
which contains constant error names. Typically the ``errno`` module is used
within a function or within a Lua program, in association with a module whose
functions can return operating-system errors, such as :ref:`fio <fio-module>`.

.. _errno-strerror:

.. function:: strerror([code])

    Return a string, given an error number. The string will contain the
    conventional error message for the current operating system. If ``code`` is
    not supplied, the error message will be for the last
    operating-system-related function, or 0.

    :param integer code: number of an operating-system error

    Return type: string

    The **errno()** function returns an error number for the last
    operating-system-related function, or 0. To invoke it, simply
    say errno(), without the module name.

    Example:

    This function displays the result of a call to :ref:`fio.open() <fio-open>`
    which causes error 2 (``errno.ENOENT``). The display includes the
    error number, the associated error string, and the error name.

    .. code-block:: none

        tarantool> function f()
                 >   local fio = require('fio')
                 >   local errno = require('errno')
                 >   fio.open('no_such_file')
                 >   print('errno() = ' .. errno())
                 >   print('errno.strerror() = ' .. errno.strerror())
                 >   local t = getmetatable(errno).__index
                 >   for k, v in pairs(t) do
                 >     if v == errno() then
                 >       print('errno() constant = ' .. k)
                 >     end
                 >   end
                 > end
        ---
        ...

        tarantool> f()
        errno() = 2
        errno.strerror() = No such file or directory
        errno() constant = ENOENT
        ---
        ...

.. _metatable: https://www.lua.org/pil/13.html

