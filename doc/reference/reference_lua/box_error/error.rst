.. _box_error-error:

box.error()
===========

.. _box_error-error-no-arg:

.. function:: box.error()

    Raise the last error.

    **See also:** :ref:`box.error.last() <box_error-last>`

.. _box_error-error-object:

.. function:: box.error(error_object)

    Raise the error defined by :ref:`error_object <box_error-error_object>`.

    :param error_object error_object: an error object

    **Example**

    ..  literalinclude:: /code_snippets/test/errors/raise_new_error_table_test.lua
        :language: lua
        :start-after: snippet_start
        :end-before: snippet_end
        :dedent:

.. _box_error-error-table:

.. function:: box.error({ reason = string[, code = number, type = string] })

    Raise the error defined by the specified parameters.

    :param string reason: an error description
    :param integer  code: (optional) a numeric code for this error
    :param string   type: (optional) an error type

    **Example 1**

    ..  literalinclude:: /code_snippets/test/errors/raise_error_table_test.lua
        :language: lua
        :start-after: snippet_start
        :end-before: snippet_end
        :dedent:

    **Example 2: custom type**

    ..  literalinclude:: /code_snippets/test/errors/raise_error_table_custom_type_test.lua
        :language: lua
        :start-after: snippet_start
        :end-before: snippet_end
        :dedent:

.. _box_error-error-array:

.. function:: box.error(type, reason[, ...])

    Raise the error defined by the specified type and description.

    :param string   type: an error type
    :param string reason: an error description
    :param           ...: description arguments

    **Example 1: without arguments**

    ..  literalinclude:: /code_snippets/test/errors/raise_error_array_custom_type_test.lua
        :language: lua
        :start-after: snippet_start
        :end-before: snippet_end
        :dedent:

    **Example 2: with arguments**

    ..  literalinclude:: /code_snippets/test/errors/raise_error_array_custom_type_args_test.lua
        :language: lua
        :start-after: snippet_start
        :end-before: snippet_end
        :dedent:

.. _box_error-error-predefined:

.. function:: box.error(code[, ...])

    Raise a predefined :ref:`Tarantool error <error_codes>` specified by its identifier.
    You can see all Tarantool errors in the `errcode.h
    <https://github.com/tarantool/tarantool/blob/master/src/box/errcode.h>`_ file.

    :param number code: a pre-defined error identifier; Lua constants that correspond to those Tarantool errors are defined as members of ``box.error``, for example, ``box.error.NO_SUCH_USER == 45``
    :param         ...: description arguments

    **Example 1: no arguments**

    ..  literalinclude:: /code_snippets/test/errors/raise_tarantool_error_no_arg_test.lua
        :language: lua
        :start-after: snippet_start
        :end-before: snippet_end
        :dedent:

    **Example 2: one argument**

    ..  literalinclude:: /code_snippets/test/errors/raise_tarantool_error_one_arg_test.lua
        :language: lua
        :start-after: snippet_start
        :end-before: snippet_end
        :dedent:

    **Example 3: two arguments**

    ..  literalinclude:: /code_snippets/test/errors/raise_tarantool_error_multiple_arg_test.lua
        :language: lua
        :start-after: snippet_start
        :end-before: snippet_end
        :dedent:
