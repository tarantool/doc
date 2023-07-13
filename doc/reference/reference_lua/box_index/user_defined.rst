.. _box_index-user_defined:

===============================================================================
index_object extensions
===============================================================================

You can extend ``index_object`` with custom functions as follows:

1. Create a Lua function.
2. Add the function name to a predefined global variable, which has the ``table`` type.
3. Call the function on the ``index_object``: ``index_object:function-name([parameters])``.

There are three predefined global variables:

* Adding to ``box_schema.index_mt`` makes the function available for all indexes.
* Adding to ``box_schema.memtx_index_mt`` makes the function available for all memtx indexes.
* Adding to ``box_schema.vinyl_index_mt`` makes the function available for all vinyl indexes.

Alternatively, you can make a user-defined function available for only one index
by calling ``getmetatable(index_object)`` and then adding the function name to the
meta table.


**Example 1:**

The example below shows how to extend all memtx indexes with the custom function:

..  literalinclude:: /code_snippets/test/indexes/index_custom_function_test.lua
    :language: lua
    :lines: 21-35
    :dedent:

**Example 2:**

The example below shows how to extend the specified index with the custom function with parameters:

..  literalinclude:: /code_snippets/test/indexes/index_custom_function_test.lua
    :language: lua
    :lines: 38-54
    :dedent:
