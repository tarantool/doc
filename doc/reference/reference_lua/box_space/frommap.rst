.. _box_space-frommap:

===============================================================================
space_object:frommap()
===============================================================================

.. module:: box.space

.. class:: space_object

    .. method:: frommap(map [, option])

        Convert a map to a tuple instance or to a table.
        The map must consist of "field name = value" pairs.
        The field names and the value types must match names and types
        stated previously for the space, via
        :ref:`space_object:format() <box_space-format>`.

        :param space_object space_object: an :ref:`object reference
                                          <app_server-object_reference>`
        :param field-value-pairs map: a series of "field = value" pairs, in any order.
        :param boolean option:  the only legal option is ``{table = true|false}``; |br|
                                if the option is omitted or if ``{table = false}``,
                                then return type will be 'cdata' (i.e. tuple); |br|
                                if ``{table = true}``, then return type will be 'table'.

        :return: a tuple instance or table.
        :rtype:  tuple or table

        **Possible errors:** ``space_object`` does not exist or has no format; "unknown field".

        **Example:**

        .. code-block:: tarantoolsession

            -- Create a format with two fields named 'a' and 'b'.
            -- Create a space with that format.
            -- Create a tuple based on a map consistent with that space.
            -- Create a table based on a map consistent with that space.
            tarantool> format1 = {{name='a',type='unsigned'},{name='b',type='scalar'}}
            ---
            ...
            tarantool> s = box.schema.create_space('test', {format = format1})
            ---
            ...
            tarantool> s:frommap({b = 'x', a = 123456})
            ---
            - [123456, 'x']
            ...
            tarantool> s:frommap({b = 'x', a = 123456}, {table = true})
            ---
            - - 123456
              - x
            ...
