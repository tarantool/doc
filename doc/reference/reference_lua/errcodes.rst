.. _error_codes:

Database error codes
====================

The table below lists some popular errors that can be raised by Tarantool in case of various issues.
You can find a complete list of errors in the
`errcode.h <https://github.com/tarantool/tarantool/blob/master/src/box/errcode.h>`_ file.

..  NOTE::

    The :ref:`box.error <box-error-submodule>` module provides the ability to get the information about the last error raised by Tarantool or raise custom errors manually.

.. container:: table

    ..  rst-class:: left-align-column-1
    ..  rst-class:: left-align-column-2

    ..  list-table::
        :widths: 25 35 40
        :header-rows: 1

        *   - Code
            - box.error value
            - Description

        *   - ER_NONMASTER
            - box.error.NONMASTER
            - (In replication) A server instance cannot modify data unless it is a master.

        *   - ER_ILLEGAL_PARAMS
            - box.error.ILLEGAL_PARAMS
            - Illegal parameters. Malformed protocol message.

        *   - ER_MEMORY_ISSUE
            - box.error.MEMORY_ISSUE
            - Out of memory: :ref:`memtx_memory <cfg_storage-memtx_memory>` limit has been reached.

        *   - ER_WAL_IO
            - box.error.WAL_IO
            - Failed to write to disk. May mean: failed  to record a change in the write-ahead log.

        *   - ER_READONLY
            - box.error.READONLY
            - Can't modify data on a read-only instance.

        *   - ER_KEY_PART_COUNT
            - box.error.KEY_PART_COUNT
            - Key part count is not the same as index part count.

        *   - ER_NO_SUCH_SPACE
            - box.error.NO_SUCH_SPACE
            - The specified space does not exist.

        *   - ER_NO_SUCH_INDEX
            - box.error.NO_SUCH_INDEX
            - The specified index in the specified space does not exist.

        *   - ER_PROC_LUA
            - box.error.PROC_LUA
            - An error occurred inside a Lua procedure.

        *   - ER_FIBER_STACK
            - box.error.FIBER_STACK
            - The recursion limit was reached when creating a new fiber. This usually indicates that a stored procedure is recursively invoking itself too often.

        *   - ER_UPDATE_FIELD
            - box.error.UPDATE_FIELD
            - An error occurred during update of a field.

        *   - ER_TUPLE_FOUND
            - box.error.TUPLE_FOUND
            - A duplicate key exists in a unique index.



.. _error_handling:

Handling errors
---------------

Here are some procedures that can make Lua functions more robust when there are
errors, particularly database errors.

1.  Invoke a function using ``pcall``.

    Take advantage of Lua's mechanisms for `Error handling and exceptions <https://www.lua.org/pil/8.4.html>`_, particularly ``pcall``.
    That is, instead of invoking with ...

    .. code-block:: lua

        box.space.{space-name}:{function-name}()

    ... call the function as follows:

    .. code-block:: lua

        if pcall(box.space.{space-name}.{function-name}, box.space.{space-name}) ...

    For some Tarantool box functions, ``pcall`` also returns error details,
    including a file-name and line-number within Tarantool's source code.
    This can be seen by unpacking, for example:

    .. code-block:: lua

        status, error = pcall(function() box.schema.space.create('') end)
        error:unpack()

    See the tutorial :ref:`Sum a JSON field for all tuples <c_lua_tutorial-sum_a_json_field>`
    to see how ``pcall`` can fit in an application.

2.  Examine errors and raise new errors using ``box.error``.

    To make a new error and pass it on, the ``box.error`` module provides
    :doc:`box.error() </reference/reference_lua/box_error/error>`.

    To find the last error, the ``box.error`` submodule provides
    :doc:`/reference/reference_lua/box_error/last`.
    There is also a way to find
    the text of the last operating-system error for certain functions --
    :ref:`errno.strerror([code]) <errno-strerror>`.

3.  Log.

    Put messages in a log using the :ref:`log module <log-module>`.

    Filter automatically generated messages using the
    :ref:`log <cfg_logging-log>` configuration parameter.


Generally, for Tarantool built-in functions which are designed to return objects:
the result is an object, or nil, or `a Lua error <https://www.lua.org/pil/8.3.html>`_.
For example consider the :ref:`fio_read.lua <cookbook-fio_read>` program in a cookbook:

.. code-block:: lua

    #!/usr/bin/env tarantool

    local fio = require('fio')
    local errno = require('errno')
    local f = fio.open('/tmp/xxxx.txt', {'O_RDONLY' })
    if not f then
        error("Failed to open file: "..errno.strerror())
    end
    local data = f:read(4096)
    f:close()
    print(data)

After a function call that might fail, like ``fio.open()`` above,
it is common to see syntax like ``if not f then ...``
or ``if f == nil then ...``, which check
for common failures. But if there had been a syntax
error, for example fio.opex instead of fio.open, then
there would have been a Lua error and f would not have
been changed. If checking for such an obvious error
had been a concern, the programmer would probably have
used ``pcall()``.

All functions in Tarantool modules should work this way,
unless the manual explicitly says otherwise.
