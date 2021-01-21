.. _box_index-user_defined:

===============================================================================
index_object:user_defined()
===============================================================================

.. module:: box.index

.. class:: index_object

    .. method:: user_defined()

        Users can define any functions they want, and associate them with indexes:
        in effect they can make their own index methods.
        They do this by:

        (1) creating a Lua function,
        (2) adding the function name to a predefined global variable which has
            type = table, and
        (3) invoking the function any time thereafter, as long as the server
            is up, by saying ``index_object:function-name([parameters])``.

        There are three predefined global variables:

        * Adding to ``box_schema.index_mt`` makes the method available for all indexes.
        * Adding to ``box_schema.memtx_index_mt`` makes the method available for all memtx indexes.
        * Adding to ``box_schema.vinyl_index_mt`` makes the method available for all vinyl indexes.

        Alternatively, user-defined methods can be made available for only one index,
        by calling ``getmetatable(index_object)`` and then adding the function name to the
        meta table.

        :param index_object index_object: an :ref:`object reference
                                          <app_server-object_reference>`.
        :param any-type any-name: whatever the user defines

        **Example:**

        .. code-block:: lua

            -- Visible to any index of a memtx space, no parameters.
            -- After these requests, the value of global_variable will be 6.
            box.schema.space.create('t', {engine='memtx'})
            box.space.t:create_index('i')
            global_variable = 5
            function f() global_variable = global_variable + 1 end
            box.schema.memtx_index_mt.counter = f
            box.space.t.index.i:counter()

        **Example:**

        .. code-block:: lua

            -- Visible to index box.space.t.index.i only, 1 parameter.
            -- After these requests, the value of X will be 1005.
            box.schema.space.create('t', {engine='memtx', id = 1000})
            box.space.t:create_index('i')
            X = 0
            i = box.space.t.index.i
            function f(i_arg, param) X = X + param + i_arg.space_id end
            box.schema.memtx_index_mt.counter = f
            meta = getmetatable(i)
            meta.counter = f
            i:counter(5)
