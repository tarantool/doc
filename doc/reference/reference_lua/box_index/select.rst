.. _box_index-select:

===============================================================================
index_object:select()
===============================================================================

..  class:: index_object

    ..  method:: select(search-key, options)

        This is an alternative to :ref:`box.space...select() <box_space-select>`
        which goes via a particular index and can make use of additional
        parameters that specify the iterator type, and the limit, and the offset.

        :param index_object index_object: an :ref:`object reference
                                          <app_server-object_reference>`.
        :param scalar/table      key: values to be matched against the index key
        :param table/nil     options: none, any, or all of the following parameters:

                                      * ``iterator`` -- the :ref:`type of iterator <box_index-iterator-types>`
                                      * ``limit`` -- the maximum number of tuples
                                      * ``offset`` -- the number of tuples to skip
                                        (do not use it. See
                                        :ref:`warning <offset-warning>`)


        :return: the tuple or tuples that match the field values.
        :rtype:  array of tuples

        .. _offset-warning:

        ..  WARNING::

            We do not recommend using the ``offset`` option for scanning
            large values because it linearly increases the number
            of scanned tuples and leads to the full scan of the space.

            For unique indexes, you can build cursors with
            :doc:`pairs() </reference/reference_lua/box_index/pairs>`:

            ..  code-block:: lua

                index_obj:pairs(key, {iterator = 'GT'})

        **Example:**

        ..  code-block:: tarantoolsession

            -- Create a space named tester.
            tarantool> sp = box.schema.space.create('tester')
            -- Create a unique index 'primary'
            -- which won't be needed for this example.
            tarantool> sp:create_index('primary', {parts = {1, 'unsigned' }})
            -- Create a non-unique index 'secondary'
            -- with an index on the second field.
            tarantool> sp:create_index('secondary', {
                     >   type = 'tree',
                     >   unique = false,
                     >   parts = {2, 'string'}
                     > })
            -- Insert three tuples, values in field[2]
            -- equal to 'X', 'Y', and 'Z'.
            tarantool> sp:insert{1, 'X', 'Row with field[2]=X'}
            tarantool> sp:insert{2, 'Y', 'Row with field[2]=Y'}
            tarantool> sp:insert{3, 'Z', 'Row with field[2]=Z'}
            -- Select all tuples where the secondary index
            -- keys are greater than 'X'.
            tarantool> sp.index.secondary:select({'X'}, {
                     >   iterator = 'GT',
                     >   limit = 1000
                     > })

        The result will be a table of tuple and will look like this:

        ..  code-block:: yaml

            ---
            - - [2, 'Y', 'Row with field[2]=Y']
              - [3, 'Z', 'Row with field[2]=Z']
            ...

        ..  NOTE::

            The arguments are optional. If you call
            :samp:`box.space.{space-name}:select{}`, then every key in the index
            is considered to be a match, regardless of the iterator type. Therefore,
            for the example above, ``box.space.tester:select{}`` will select every
            tuple in the ``tester`` space via the first (primary-key) index.

        ..  NOTE::

            :samp:`index.{index-name}` is optional. If it is omitted, then the assumed
            index is the first (primary-key) index. Therefore, for the example
            above, ``box.space.tester:select({1}, {iterator = 'GT'})`` would have
            returned the same two rows, via the 'primary' index.

        ..  NOTE::

            :samp:`iterator = {iterator-type}` is optional. If it is omitted, then
            ``iterator = 'EQ'`` is assumed.

        ..  _box_index-note:

        ..  NOTE::

            :samp:`box.space.{space-name}.index.{index-name}:select(...)[1]`. can be
            replaced by :samp:`box.space.{space-name}.index.{index-name}:get(...)`.
            That is, ``get`` can be used as a convenient shorthand to get the first
            tuple in the tuple set that would be returned by ``select``. However,
            if there is more than one tuple in the tuple set, then ``get`` throws
            an error.
