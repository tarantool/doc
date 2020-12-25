.. _box_space-user_defined:

===============================================================================
space_object:user_defined()
===============================================================================

.. module:: box.space

.. class:: space_object

    .. method:: user_defined()

        Users can define any functions they want, and associate them with spaces:
        in effect they can make their own space methods.
        They do this by:

        (1) creating a Lua function,
        (2) adding the function name to a predefined global variable which has
            type = table, and
        (3) invoking the function any time thereafter, as long as the server
            is up, by saying ``space_object:function-name([parameters])``.

        The predefined global variable is ``box.schema.space_mt``.
        Adding to ``box.schema.space_mt`` makes the method available for all spaces.

        Alternatively, user-defined methods can be made available for only one space,
        by calling ``getmetatable(space_object)`` and then adding the function name to the
        meta table. See also the example for
        :ref:`index_object:user_defined() <box_index-user_defined>`.

        :param index_object index_object: an :ref:`object reference
                                          <app_server-object_reference>`.
        :param any-type any-name: whatever the user defines

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
