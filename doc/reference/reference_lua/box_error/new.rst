.. _box_error-new:

===============================================================================
box.error.new()
===============================================================================

.. _box_error-new-error-table:

.. function:: box.error.new({ reason = string[, code = number, type = string] })

    Create an error object with the specified parameters.

    :param string reason: an error description
    :param integer  code: (optional) a numeric code for this error
    :param string   type: (optional) an error type

    **Example 1**

    ..  literalinclude:: /code_snippets/test/errors/raise_new_error_table_test.lua
        :language: lua
        :start-after: snippet_start
        :end-before: snippet_end
        :dedent:

    **Example 2: custom type**

    ..  literalinclude:: /code_snippets/test/errors/raise_new_error_table_custom_type_test.lua
        :language: lua
        :start-after: snippet_start
        :end-before: snippet_end
        :dedent:

.. _box_error-new-error-array:

.. function:: box.error.new(type, reason[, ...])

    Create an error object with the specified type and description.

    :param string   type: an error type
    :param string reason: an error description
    :param           ...: description arguments

    **Example**

    ..  literalinclude:: /code_snippets/test/errors/raise_new_error_array_custom_type_test.lua
        :language: lua
        :start-after: snippet_start
        :end-before: snippet_end
        :dedent:

.. _box_error-new-error-predefined:

.. function:: box.error.new(code[, ...])

    Create a predefined :ref:`Tarantool error <error_codes>` specified by its identifier.
    You can see all Tarantool errors in the `errcode.h
    <https://github.com/tarantool/tarantool/blob/master/src/box/errcode.h>`_ file.

    :param number code: a pre-defined error identifier; Lua constants that correspond to those Tarantool errors are defined as members of ``box.error``, for example, ``box.error.NO_SUCH_USER == 45``
    :param         ...: description arguments

    **Example 1: one argument**

    ..  literalinclude:: /code_snippets/test/errors/raise_new_tarantool_error_one_arg_test.lua
        :language: lua
        :start-after: snippet_start
        :end-before: snippet_end
        :dedent:

    **Example 2: two arguments**

    ..  literalinclude:: /code_snippets/test/errors/raise_new_tarantool_error_multiple_arg_test.lua
        :language: lua
        :start-after: snippet_start
        :end-before: snippet_end
        :dedent:
