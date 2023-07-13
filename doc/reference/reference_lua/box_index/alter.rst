.. _box_index-alter:

===============================================================================
index_object:alter()
===============================================================================

.. class:: index_object

    .. method:: alter({options})

        Alter an index.
        It is legal in some circumstances to change one or more of the
        index characteristics, for example its type, its sequence options,
        its parts, and whether it is unique. Usually this causes rebuilding
        of the space,  except for the simple case where a part's ``is_nullable``
        flag is changed from ``false`` to ``true``.

        :param index_object index_object: an :ref:`object reference
                                          <app_server-object_reference>`.
        :param table options: index options (see :ref:`index_opts <index_opts_object>`)

        :return: nil

        **Possible errors:**

        * index does not exist
        * the primary-key index cannot be changed to ``{unique = false}``

        .. NOTE::

            Vinyl does not support ``alter()`` of a primary-key index unless the space is empty.

        **Example 1:**

        You can add and remove fields that make up a primary index:

        .. code-block:: tarantoolsession

            tarantool> s = box.schema.create_space('test')
            ---
            ...
            tarantool> i = s:create_index('i', {parts = {{field = 1, type = 'unsigned'}}})
            ---
            ...
            tarantool> s:insert({1, 2})
            ---
            - [1, 2]
            ...
            tarantool> i:select()
            ---
            - - [1, 2]
            ...
            tarantool> i:alter({parts = {{field = 1, type = 'unsigned'}, {field = 2, type = 'unsigned'}}})
            ---
            ...
            tarantool> s:insert({1, 't'})
            ---
            - error: 'Tuple field 2 type does not match one required by operation: expected unsigned'
            ...

        **Example 2:**

        You can change index options for both memtx and vinyl spaces:

        .. code-block:: tarantoolsession

            tarantool> box.space.space55.index.primary:alter({type = 'HASH'})
            ---
            ...

            tarantool> box.space.vinyl_space.index.i:alter({page_size=4096})
            ---
            ...
