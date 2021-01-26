.. _box_space-alter:

===============================================================================
space_object:alter()
===============================================================================

.. class:: space_object

    .. method:: alter(options)

        Since version 2.5.2.
        Alter an existing space. This method changes certain space parameters.

        :param table options: ``field_count``, ``user``,
                              ``format``, ``temporary``, ``is_sync``, and ``name``
                              -- the meaning of these parameters is the same as in
                              :doc:`/reference/reference_lua/box_schema/space_create`

        :return: nothing in case of success; an error when fails

        **Example:**

        .. code-block:: tarantoolsession

            tarantool> s = box.schema.create_space('tester')
            ---
            ...
            tarantool> format = {{name = 'field1', type = 'unsigned'}}
            ---
            ...
            tarantool> s:alter({name = 'tester1', format = format})
            ---
            ...
            tarantool> s.name
            ---
            - tester1
            ...
            tarantool> s:format()
            ---
            - [{'name': 'field1', 'type': 'unsigned'}]
            ...
