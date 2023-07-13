.. _box_space-user_defined:

===============================================================================
space_object extensions
===============================================================================

You can extend ``space_object`` with custom functions as follows:

1. Create a Lua function.
2. Add the function name to a predefined global variable ``box.schema.space_mt``, which has the ``table`` type. Adding to ``box.schema.space_mt`` makes the function available for all spaces.
3. Call the function on the ``space_object``: ``space_object:function-name([parameters])``.

Alternatively, you can make a user-defined function available for only one space
by calling ``getmetatable(space_object)`` and then adding the function name to the
meta table.

See also: :doc:`/reference/reference_lua/box_index/user_defined`.

**Example:**

.. code-block:: lua

    -- Visible to any space, no parameters.
    -- After these requests, the value of global_variable will be 6.
    box.schema.space.create('t')
    box.space.t:create_index('i')
    global_variable = 5
    function f(space_arg) global_variable = global_variable + 1 end
    box.schema.space_mt.counter = f
    box.space.t:counter()
