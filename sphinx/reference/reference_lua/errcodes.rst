.. _error_codes:

-------------------------------------------------------------------------------
Database error codes
-------------------------------------------------------------------------------

In the current version of the binary protocol, error messages, which are normally
more descriptive than error codes, are not present in server responses. The actual
message may contain a file name, a detailed reason or operating system error code.
All such messages, however, are logged in the error log. Below are general
descriptions of some popular codes. A complete list of errors can be found in file
`errcode.h`_ in the source tree.

.. _errcode.h: https://github.com/tarantool/tarantool/blob/1.7/src/box/errcode.h

    .. container:: table

        **List of error codes**

        .. rst-class:: left-align-column-1
        .. rst-class:: left-align-column-2

        +-------------------+--------------------------------------------------------+
        | ER_NONMASTER      | Can't modify data on a replication slave.              |
        +-------------------+--------------------------------------------------------+
        | ER_ILLEGAL_PARAMS | Illegal parameters. Malformed protocol                 |
        |                   | message.                                               |
        +-------------------+--------------------------------------------------------+
        | ER_MEMORY_ISSUE   | Out of memory:                                         |
        |                   | :ref:`slab_alloc_arena <cfg_storage-slab_alloc_arena>` |
        |                   | limit has been reached.                                |
        +-------------------+--------------------------------------------------------+
        | ER_WAL_IO         | Failed to write to disk. May mean: failed              |
        |                   | to record a change in the                              |
        |                   | write-ahead log. Some sort of disk error.              |
        +-------------------+--------------------------------------------------------+
        | ER_KEY_PART_COUNT | Key part count is not the same as                      |
        |                   | index part count                                       |
        +-------------------+--------------------------------------------------------+
        | ER_NO_SUCH_SPACE  | The specified space does not exist.                    |
        |                   |                                                        |
        +-------------------+--------------------------------------------------------+
        | ER_NO_SUCH_INDEX  | The specified index in the specified                   |
        |                   | space does not exist.                                  |
        +-------------------+--------------------------------------------------------+
        | ER_PROC_LUA       | An error occurred inside a Lua procedure.              |
        |                   |                                                        |
        +-------------------+--------------------------------------------------------+
        | ER_FIBER_STACK    | The recursion limit was reached when                   |
        |                   | creating a new fiber. This usually                     |
        |                   | indicates that a stored procedure is                   |
        |                   | recursively invoking itself too often.                 |
        +-------------------+--------------------------------------------------------+
        | ER_UPDATE_FIELD   | An error occurred during update of a                   |
        |                   | field.                                                 |
        +-------------------+--------------------------------------------------------+
        | ER_TUPLE_FOUND    | A duplicate key exists in a unique                     |
        |                   | index.                                                 |
        +-------------------+--------------------------------------------------------+

-------------------------------------------------------------------------------
Handling errors
-------------------------------------------------------------------------------

Here are some procedures that can make Lua functions more
robust when there are errors, particularly database errors.

1. Invoke with pcall.

   Take advantage of Lua's mechanisms for
   `"Error handling and exceptions" <http://www.lua.org/pil/8.4.html>`_,
   particularly ``pcall``. That is, instead of simply invoking with |br|
   :samp:`box.space.{space-name}:{function-name}()` |br|
   say |br|
   :samp:`if pcall(box.space.{space-name}:{function-name}() ...`

   For some Tarantool box functions, pcall also returns error details
   including a file-name and line-number within Tarantool's source code.
   This can be seen by unpacking. For example: |br|
   ``x, y = pcall(function() box.schema.space.create('') end)`` |br|
   ``y:unpack()``

   See the tutorial :ref:`Sum a JSON field for all tuples <c_lua_tutorial-sum_a_json_field>`
   to see how pcall can fit in an application.
   
2. Examine and raise with box.error.

   To make a new error and pass it on, the box.error module
   provides :ref:`box.error(code, errtext [, errtext ...]) <box_error-error>`.

   To find the last error, the box.error module
   provides :ref:`box.error.last() <box_error-last>`.
   (There is also a way to find the text of the last operating-system
   error for certain functions -- :ref:`errno.strerror([code]) <errno-strerror>`.)

3. Log.

   Put messages in a log using the :ref:`log module <log>`.

   And filter messages that are automatically generated, with the
   :ref:`logger <cfg_logging-logger>` configuration parameter.


