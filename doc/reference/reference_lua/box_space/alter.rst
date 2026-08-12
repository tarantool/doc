.. _box_space-alter:

===============================================================================
space_object:alter()
===============================================================================

.. class:: space_object

    .. method:: alter(options)

        Since version :doc:`2.5.2 </release/2.5.2>`.
        Alter an existing space. This method changes certain space parameters.

        ..  WARNING::

            Option 1 alter Warning:

            The ``space_object:alter()`` operation involves full space traversal. Full traversal
            is the process of processing every node or element in the space structure exactly once
            in a systematic manner.

            Full traversal may lead to replication lag for both synchronous and asynchronous replication
            and make writes with synchronous replication unavailable for the whole duration of operation
            when initiated at the following conditions:

            - initiated on a space with over 10000 tuples AND
            - when the node is under any load (when it processes user requests/performs business operations).

            To avoid issues:

            - initiate the ``space_object:alter()`` operation on spaces that do not exceed 10000 tuples OR 
            - initiate the ``space_object:alter()`` operation when the node is not under any load.

            Safe exceptions for the ``space_object:alter()`` operation are:

            - changing indexed field type to a more generic one («unsigned» to «number», «decimal» to «scalar»); 
            - turning a unique index into a non-unique one; 
            - changing some of the index parameters which do not require a rebuild (changing page_size of a vinyl space index).

            In future releases, the ``space_object:alter()`` operation will be deprecated.

            Option 2 alter Warning:

            The ``space_object:alter()`` operation involve full space traversal and introduce replication lag for both
            synchronous and asynchronous replication and make writes with synchronous replication unavailable for the
            whole duration of operation when initiated at certain conditions.

            The issues occur when the ``space_object:alter()`` operation is initiated at the following conditions:

            - initiated on a space with over 10000 tuples AND
            - when the node is under any load (when it processes user requests/performs business operations).

            To avoid issues:

            - initiate the ``space_object:alter()`` operation on spaces that do not exceed 10000 tuples OR 
            - initiate the ``space_object:alter()`` operation when the node is not under any load.

            Safe exceptions for the ``space_object:alter()`` operation are:

            - changing indexed field type to a more generic one («unsigned» to «number», «decimal» to «scalar»); 
            - turning a unique index into a non-unique one; 
            - changing some of the index parameters which do not require a rebuild (changing page_size of a vinyl space index).

            In future releases, the ``space_object:alter()`` operation will be deprecated.

        :param table options: the space options such as ``field_count``, ``user``,
                              ``format``, ``name``, and other. The full list of
                              these options with descriptions parameters is provided in
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
