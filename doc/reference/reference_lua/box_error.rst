..  _box-error-submodule:

Submodule box.error
===================

The ``box.error`` submodule can be used to work with errors in your application.
For example, you can get the information about the last error raised by Tarantool or
raise custom errors manually.

The difference between raising an error using ``box.error``
and a Lua's built-in `error <https://www.lua.org/pil/8.3.html>`_ function
is that when the error reaches the client, its error code is preserved.
In contrast, a Lua error would always be presented to the client as
:errcode:`ER_PROC_LUA`.

.. NOTE::

    To learn how to handle errors in your application, see the :ref:`Handling errors <error_handling>` section.


.. _box_error_create_error:

Creating an error
-----------------

You can create an error object using the :ref:`box.error.new() <box_error-new>` function.
The created object can be passed to :ref:`box.error() <box_error-error>` to raise the error.
You can also raise the error using :ref:`error_object:raise() <box_error-raise>`.

The example below shows how to create and raise the error with the specified code and reason.

..  literalinclude:: /code_snippets/test/errors/raise_new_error_table_test.lua
    :language: lua
    :start-after: snippet_start
    :end-before: snippet_end
    :dedent:

``box.error.new()`` provides different overloads for creating an error object with different parameters.
These overloads are similar to the ``box.error()`` overloads described in the :ref:`next section <box_error_raise_error>`.


.. _box_error_raise_error:

Raising an error
----------------

To raise an error, call the :ref:`box.error() <box_error-error>` function.
This function can accept the specified error parameters or an error object :ref:`created using box.error.new() <box_error_create_error>`.
In both cases, you can use ``box.error()`` to raise the following error types:

*  A custom error with the specified reason, code, and type.
*  A predefined Tarantool error.


.. _box_error_raise_custom_error:

Custom error
~~~~~~~~~~~~

The following ``box.error()`` overloads are available for raising a custom error:

*  :ref:`box.error({ reason = string[, code = number, type = string] }) <box_error-error-table>` accepts a Lua table containing the error reason, code, and type.
*  :ref:`box.error(type, reason[, args]) <box_error-error-array>` accepts the error type, its reason, and optional arguments passed to a reason's string.

.. NOTE::

    The same overloads are available for :ref:`box.error.new() <box_error-new>`.


.. _box_error_raise_custom_table_error:

box.error({ reason = string[, ...] })
*************************************

In the example below, ``box.error()`` accepts a Lua table with the specified error code and reason:

..  literalinclude:: /code_snippets/test/errors/raise_error_table_test.lua
    :language: lua
    :start-after: snippet_start
    :end-before: snippet_end
    :dedent:

The next example shows how to specify a custom error type:

..  literalinclude:: /code_snippets/test/errors/raise_error_table_custom_type_test.lua
    :language: lua
    :start-after: snippet_start
    :end-before: snippet_end
    :dedent:

When a custom type is specified, it is returned in the :ref:`error_object.type <box_error-type>` attribute.
When it is not specified, ``error_object.type`` returns one of the built-in errors, such as
``ClientError`` or ``OutOfMemory``.

.. _box_error_raise_custom_array_error:

box.error(type, reason[, ...])
******************************

This example shows how to raise an error with the type and reason specified in the ``box.error()`` arguments:

..  literalinclude:: /code_snippets/test/errors/raise_error_array_custom_type_test.lua
    :language: lua
    :start-after: snippet_start
    :end-before: snippet_end
    :dedent:

You can also use a format string to compose an error reason:

..  literalinclude:: /code_snippets/test/errors/raise_error_array_custom_type_args_test.lua
    :language: lua
    :start-after: snippet_start
    :end-before: snippet_end
    :dedent:



.. _box_error_raise_tarantool_error:

Tarantool error
~~~~~~~~~~~~~~~

The :ref:`box.error(code[, ...]) <box_error-error-predefined>` overload raises a predefined
:ref:`Tarantool error <error_codes>` specified by its identifier.
The error code defines the error message format and the number of required arguments.
In the example below, no arguments are passed for the ``box.error.READONLY`` error code:

..  literalinclude:: /code_snippets/test/errors/raise_tarantool_error_no_arg_test.lua
    :language: lua
    :start-after: snippet_start
    :end-before: snippet_end
    :dedent:

For the ``box.error.NO_SUCH_USER`` error code, you need to pass one argument:

..  literalinclude:: /code_snippets/test/errors/raise_tarantool_error_one_arg_test.lua
    :language: lua
    :start-after: snippet_start
    :end-before: snippet_end
    :dedent:

``box.error.CREATE_SPACE`` requires two arguments:

..  literalinclude:: /code_snippets/test/errors/raise_tarantool_error_multiple_arg_test.lua
    :language: lua
    :start-after: snippet_start
    :end-before: snippet_end
    :dedent:


.. _box_error_get_last_error:

Getting the last error
----------------------

To get the last raised error, call :ref:`box.error.last() <box_error-last>`:

..  literalinclude:: /code_snippets/test/errors/unpack_clear_error_test.lua
    :language: lua
    :start-after: Get the last error: start
    :end-before: Get the last error: end
    :dedent:

.. _box_error_get_error_details:

Obtaining error details
-----------------------

To get error details, call the :ref:`error_object.unpack() <box_error-unpack>`.
Error details may include an error code, type, message, and trace.

..  literalinclude:: /code_snippets/test/errors/unpack_clear_error_test.lua
    :language: lua
    :start-after: Get error details: start
    :end-before: Get error details: end
    :dedent:

.. _box_error_set_last_error:

Setting the last error
----------------------

You can set the last error explicitly by calling :ref:`box.error.set() <box_error-set>`:

..  literalinclude:: /code_snippets/test/errors/set_error_test.lua
    :language: lua
    :start-after: snippet_start
    :end-before: snippet_end
    :dedent:

.. _box_error_error_lists:

Error lists
-----------

:ref:`error_object <box_error-error_object>` provides the API for organizing errors into lists.
To set and get the previous error, use the :ref:`error_object:set_prev() <box_error-set_prev>` method and :ref:`error_object.prev <box_error-prev>` attribute.

..  literalinclude:: /code_snippets/test/errors/error_list_test.lua
    :language: lua
    :start-after: snippet_start
    :end-before: snippet_end
    :dedent:

Cycles are not allowed for error lists:

.. code-block:: lua

    storage_server_error:set_prev(base_server_error)
    --[[
    ---
    - error: 'builtin/error.lua:120: Cycles are not allowed'
    ...
    --]]

Setting the previous error does not erase its own previous members:

.. code-block:: Lua

    -- e1 -> e2 -> e3 -> e4
    e1:set_prev(e2)
    e2:set_prev(e3)
    e3:set_prev(e4)
    e2:set_prev(e5)
    -- Now there are two lists: e1 -> e2 -> e5 and e3 -> e4

IPROTO also supports stacked diagnostics.
See details in :ref:`MessagePack extensions -- The ERROR type <msgpack_ext-error>`.

.. _box_error_clear_errors:

Clearing errors
---------------

To clear the errors, call :ref:`box.error.clear() <box_error-clear>`.

..  literalinclude:: /code_snippets/test/errors/unpack_clear_error_test.lua
    :language: lua
    :start-after: Clear the errors: start
    :end-before: Clear the errors: end
    :dedent:



.. _box-error-submodule-api-reference:

API Reference
-------------

Below is a list of ``box.error`` functions and related objects.

.. container:: table

    ..  rst-class:: left-align-column-1
    ..  rst-class:: left-align-column-2

    ..  list-table::
        :widths: 25 75
        :header-rows: 1

        *   - Name
            - Use

        *   - :doc:`./box_error/error`
            - Raise the last error or the error defined by the specified parameters

        *   - :doc:`./box_error/last`
            - Get the last raised error

        *   - :doc:`./box_error/clear`
            - Clear the errors

        *   - :doc:`./box_error/new`
            - Create the error but do not raise it

        *   - :doc:`./box_error/set`
            - Set the specified error as the last system error explicitly

        *   - :doc:`./box_error/error_object`
            - An object that defines an error


..  toctree::
    :hidden:

    box_error/error
    box_error/last
    box_error/clear
    box_error/new
    box_error/set
    box_error/error_object
