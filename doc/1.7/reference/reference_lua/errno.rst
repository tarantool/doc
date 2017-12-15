.. _errno-module:

-------------------------------------------------------------------------------
                            Module `errno`
-------------------------------------------------------------------------------

.. module:: errno

===============================================================================
                                   Overview
===============================================================================

The ``errno`` module is typically used
within a function or within a Lua program, in association with a module whose
functions can return operating-system errors, such as :ref:`fio <fio-module>`.

===============================================================================
                                    Index
===============================================================================

Below is a list of all ``errno`` functions.

.. container:: table

    .. rst-class:: left-align-column-1
    .. rst-class:: left-align-column-2

    +--------------------------------------+---------------------------------+
    | Name                                 | Use                             |
    +======================================+=================================+
    | :ref:`errno()                        | Get an error number for the     |
    | <errno-errno>`                       | last OS-related function        |
    +--------------------------------------+---------------------------------+
    | :ref:`errno.strerror()               | Get an error message for the    |
    | <errno-strerror>`                    | corresponding error number      |
    +--------------------------------------+---------------------------------+

.. _errno-errno:

.. operator:: errno()

    Return an error number for the last operating-system-related function, or 0.
    To invoke it, simply say ``errno()``, without the module name.

    :rtype: integer

.. _errno-strerror:

.. function:: strerror([code])

    Return a string, given an error number. The string will contain the
    text of the conventional error message for the current operating system.
    If ``code`` is not supplied, the error message will be for the last
    operating-system-related function, or 0.

    :param integer code: number of an operating-system error

    :rtype: string

**Example:**

This function displays the result of a call to :ref:`fio.open() <fio-open>`
which causes error 2 (``errno.ENOENT``). The display includes the
error number, the associated error string, and the error name.

.. code-block:: tarantoolsession

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

To see all possible error names stored in the ``errno`` metatable, say
``getmetatable(errno)`` (output abridged):

.. code-block:: tarantoolsession

   tarantool> getmetatable(errno)
   ---
   - __newindex: 'function: 0x41666a38'
     __call: 'function: 0x41666890'
     __index:
     ENOLINK: 67
     EMSGSIZE: 90
     EOVERFLOW: 75
     ENOTCONN: 107
     EFAULT: 14
     EOPNOTSUPP: 95
     EEXIST: 17
     ENOSR: 63
     ENOTSOCK: 88
     EDESTADDRREQ: 89
     <...>
   ...

