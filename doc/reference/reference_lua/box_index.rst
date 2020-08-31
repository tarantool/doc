.. _box_index:

-------------------------------------------------------------------------------
                            Submodule `box.index`
-------------------------------------------------------------------------------

===============================================================================
                                   Overview
===============================================================================

The ``box.index`` submodule provides read-only access for index definitions and
index keys. Indexes are contained in :samp:`box.space.{space-name}.index` array
within each space object. They provide an API for ordered iteration over tuples.
This API is a direct binding to corresponding methods of index objects of type
``box.index`` in the storage engine.

===============================================================================
                                    Index
===============================================================================

Below is a list of all ``box.index`` functions and members.

.. container:: table

    .. rst-class:: left-align-column-1
    .. rst-class:: left-align-column-2

    +--------------------------------------+---------------------------------+
    | Name                                 | Use                             |
    +======================================+=================================+
    | :ref:`index_object.unique            | Flag, true if an index is       |
    | <box_index-unique>`                  | unique                          |
    +--------------------------------------+---------------------------------+
    | :ref:`index_object.type              | Index type                      |
    | <box_index-type>`                    |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`index_object.parts             | Array of index key fields       |
    | <box_index-parts>`                   |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`index_object:pairs()           | Prepare for iterating           |
    | <box_index-index_pairs>`             |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`index_object:select()          | Select one or more tuples       |
    | <box_index-select>`                  | via index                       |
    +--------------------------------------+---------------------------------+
    | :ref:`index_object:get()             | Select a tuple via index        |
    | <box_index-get>`                     |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`index_object:min()             | Find the minimum value in index |
    | <box_index-min>`                     |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`index_object:max()             | Find the maximum value in index |
    | <box_index-max>`                     |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`index_object:random()          | Find a random value in index    |
    | <box_index-random>`                  |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`index_object:count()           | Count tuples matching key value |
    | <box_index-count>`                   |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`index_object:update()          | Update a tuple                  |
    | <box_index-update>`                  |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`index_object:delete()          | Delete a tuple by key           |
    | <box_index-delete>`                  |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`index_object:alter()           | Alter an index                  |
    | <box_index-alter>`                   |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`index_object:drop()            | Drop an index                   |
    | <box_index-drop>`                    |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`index_object:rename()          | Rename an index                 |
    | <box_index-rename>`                  |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`index_object:bsize()           | Get count of bytes for an index |
    | <box_index-bsize>`                   |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`index_object:stat()            | Get statistics for an index     |
    | <box_index-stat>`                    |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`index_object:compact()         | Remove unused index space       |
    | <box_index-compact>`                 |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`index_object:user_defined()    | Any function / method that any  |
    | <box_index-user_defined>`            | user wants to add               |
    +--------------------------------------+---------------------------------+


.. module:: box.index

.. class:: index_object

    .. _box_index-unique:

    .. data:: unique

        True if the index is unique, false if the index is not unique.

        :rtype: boolean

    .. _box_index-type:

    .. data:: type

        Index type, 'TREE' or 'HASH' or 'BITSET' or 'RTREE'.

    .. _box_index-parts:

    .. data:: parts

        An array describing the index fields. To learn more about the index field
        types, refer to :ref:`this table <box_space-index_field_types>`.

        :rtype: table

        **Example:**

        .. code-block:: tarantoolsession

            tarantool> box.space.tester.index.primary
            ---
            - unique: true
              parts:
              - type: unsigned
                is_nullable: false
                fieldno: 1
              id: 0
              space_id: 513
              name: primary
              type: TREE
            ...

    .. _box_index-index_pairs:

    .. method:: pairs([key [,{iterator = iterator-type}]])

        Search for a tuple or a set of tuples via the given index,
        and allow iterating over one tuple at a time.

        The :samp:`{key}` parameter specifies what must match within the index.

        .. NOTE::

            :samp:`{key}` is only used to find the first match. Do not assume
            all matched tuples will contain the key.

        The :samp:`{iterator}` parameter specifies the rule for matching and
        ordering. Different index types support different iterators. For
        example, a TREE index maintains a strict order of keys and can return
        all tuples in ascending or descending order, starting from the specified
        key. Other index types, however, do not support ordering.

        To understand consistency of tuples returned by an iterator, it's
        essential to know the principles of the Tarantool transaction processing
        subsystem. An iterator in Tarantool does not own a consistent read view.
        Instead, each procedure is granted exclusive access to all tuples and
        spaces until there is a "context switch": which may happen due to
        :ref:`the implicit yield rules <atomic-implicit-yields>`, or by an
        explicit call to :ref:`fiber.yield <fiber-yield>`. When the execution
        flow returns to the yielded procedure, the data set could have changed
        significantly. Iteration, resumed after a yield point, does not preserve
        the read view, but continues with the new content of the database. The
        tutorial :ref:`Indexed pattern search
        <c_lua_tutorial-indexed_pattern_search>` shows one way that iterators
        and yields can be used together.

        For information about iterators' internal structures see the
        `"Lua Functional library" <https://luafun.github.io/index.html>`_
        documentation.

        :param index_object index_object: an :ref:`object reference
                                          <app_server-object_reference>`.
        :param scalar/table key: value to be matched against the index key,
                                 which may be multi-part
        :param iterator: as defined in tables below. The default iterator type
                         is 'EQ'


        :return: `iterator <https://www.lua.org/pil/7.1.html>`_ which can be
                 used in a for/end loop or with `totable()
                 <https://luafun.github.io/reducing.html#fun.totable>`_

        **Possible errors:**

        * no such space; wrong type;
        * selected iteration type is not supported for the index type;
        * key is not supported for the iteration type.

        **Complexity factors:** Index size, Index type; Number of tuples
        accessed.

        A search-key-value can be a number (for example ``1234``), a string
        (for example ``'abcd'``), or a table of numbers and strings (for example
        ``{1234, 'abcd'}``). Each part of a key will be compared to each part of
        an index key.

        The returned tuples will be in order by index key value, or by the hash of
        the index key value if index type = 'hash'. If the index is non-unique, then
        duplicates will be secondarily in order by primary key value. The order
        will be reversed if the iterator type is 'LT' or 'LE' or 'REQ'.

        .. _box_index-iterator-types:

        **Iterator types for TREE indexes**

        .. container:: table

            .. rst-class:: left-align-column-1
            .. rst-class:: left-align-column-2
            .. rst-class:: left-align-column-3

            .. tabularcolumns:: |\Y{0.2}|\Y{0.2}|\Y{0.6}|

            +---------------+-----------+---------------------------------------------+
            | Iterator type | Arguments | Description                                 |
            +===============+===========+=============================================+
            | box.index.EQ  | search    | The comparison operator is '==' (equal to). |
            | or 'EQ'       | value     | If an index key is equal to a search value, |
            |               |           | it matches.                                 |
            |               |           | Tuples are returned in ascending order by   |
            |               |           | index key. This is the default.             |
            +---------------+-----------+---------------------------------------------+
            | box.index.REQ | search    | Matching is the same as for                 |
            | or 'REQ'      | value     | ``box.index.EQ``.                           |
            |               |           | Tuples are returned in descending order by  |
            |               |           | index key.                                  |
            +---------------+-----------+---------------------------------------------+
            | box.index.GT  | search    | The comparison operator is '>' (greater     |
            | or 'GT'       | value     | than).                                      |
            |               |           | If an index key is greater than a search    |
            |               |           | value, it matches.                          |
            |               |           | Tuples are returned in ascending order by   |
            |               |           | index key.                                  |
            +---------------+-----------+---------------------------------------------+
            | box.index.GE  | search    | The comparison operator is '>=' (greater    |
            | or 'GE'       | value     | than or equal to).                          |
            |               |           | If an index key is greater than or equal to |
            |               |           | a search value, it matches.                 |
            |               |           | Tuples are returned in ascending order by   |
            |               |           | index key.                                  |
            +---------------+-----------+---------------------------------------------+
            | box.index.ALL | search    | Same as box.index.GE.                       |
            | or 'ALL'      | value     |                                             |
            |               |           |                                             |
            +---------------+-----------+---------------------------------------------+
            | box.index.LT  | search    | The comparison operator is '<' (less than). |
            | or 'LT'       | value     | If an index key is less than a search       |
            |               |           | value, it matches.                          |
            |               |           | Tuples are returned in descending order by  |
            |               |           | index key.                                  |
            +---------------+-----------+---------------------------------------------+
            | box.index.LE  | search    | The comparison operator is '<=' (less than  |
            | or 'LE'       | value     | or equal to).                               |
            |               |           | If an index key is less than or equal to a  |
            |               |           | search value, it matches.                   |
            |               |           | Tuples are returned in descending order by  |
            |               |           | index key.                                  |
            +---------------+-----------+---------------------------------------------+

            Informally, we can state that searches with TREE indexes are
            generally what users will find is intuitive, provided that there
            are no nils and no missing parts. Formally, the logic is as follows.
            A search key has zero or more parts, for example {}, {1,2,3},{1,nil,3}.
            An index key has one or more parts, for example {1}, {1,2,3},{1,2,3}.
            A search key may contain nil (but not msgpack.NULL, which is the wrong type).
            An index key may not contain nil or msgpack.NULL, although a later version
            of Tarantool will have different rules --  the behavior of searches with nil is subject to change.
            Possible iterators are LT, LE, EQ, REQ, GE, GT.
            A search key is said to "match" an index key if the following
            statements, which are pseudocode for the comparison operation,
            return TRUE.

            .. cssclass:: highlight
            .. parsed-literal::

                If (number-of-search-key-parts > number-of-index-key-parts) return ERROR
                If (number-of-search-key-parts == 0) return TRUE
                for (i = 1; ; ++i)
                {
                  if (i > number-of-search-key-parts) OR (search-key-part[i] is nil)
                  {
                    if (iterator is LT or GT) return FALSE
                    return TRUE
                  }
                  if (type of search-key-part[i] is not compatible with type of index-key-part[i])
                  {
                    return ERROR
                  }
                  if (search-key-part[i] == index-key-part[i])
                  {
                    continue
                  }
                  if (search-key-part[i] > index-key-part[i])
                  {
                    if (iterator is EQ or REQ or LE or LT) return FALSE
                    return TRUE
                  }
                  if (search-key-part[i] < index-key-part[i])
                  {
                    if (iterator is EQ or REQ or GE or GT) return FALSE
                    return TRUE
                  }
                }

            **Iterator types for HASH indexes**

            .. rst-class:: left-align-column-1
            .. rst-class:: left-align-column-2
            .. rst-class:: left-align-column-3

            .. tabularcolumns:: |\Y{0.2}|\Y{0.2}|\Y{0.6}|

            +---------------+-----------+------------------------------------------------+
            | Type          | Arguments | Description                                    |
            +===============+===========+================================================+
            | box.index.ALL | none      | All index keys match.                          |
            |               |           | Tuples are returned in ascending order by      |
            |               |           | hash of index key, which will appear to be     |
            |               |           | random.                                        |
            +---------------+-----------+------------------------------------------------+
            | box.index.EQ  | search    | The comparison operator is '==' (equal to).    |
            | or 'EQ'       | value     | If an index key is equal to a search value,    |
            |               |           | it matches.                                    |
            |               |           | The number of returned tuples will be 0 or 1.  |
            |               |           | This is the default.                           |
            +---------------+-----------+------------------------------------------------+
            | box.index.GT  | search    | The comparison operator is '>' (greater than). |
            | or 'GT'       | value     | If a hash of an index key is greater than a    |
            |               |           | hash of a search value, it matches.            |
            |               |           | Tuples are returned in ascending order by hash |
            |               |           | of index key, which will appear to be random.  |
            |               |           | Provided that the space is not being updated,  |
            |               |           | one can retrieve all the tuples in a space,    |
            |               |           | N tuples at a time, by using                   |
            |               |           | {iterator='GT', limit=N}                       |
            |               |           | in each search, and using the last returned    |
            |               |           | value from the previous result as the start    |
            |               |           | search value for the next search.              |
            +---------------+-----------+------------------------------------------------+

            **Iterator types for BITSET indexes**

            .. rst-class:: left-align-column-1
            .. rst-class:: left-align-column-2
            .. rst-class:: left-align-column-3

            .. tabularcolumns:: |\Y{0.4}|\Y{0.2}|\Y{0.4}|

            +----------------------------+-----------+----------------------------------------------+
            | Type                       | Arguments | Description                                  |
            +============================+===========+==============================================+
            | box.index.ALL              | none      | All index keys match.                        |
            | or 'ALL'                   |           | Tuples are returned in their order within    |
            |                            |           | the space.                                   |
            +----------------------------+-----------+----------------------------------------------+
            | box.index.EQ               | bitset    | If an index key is equal to a bitset value,  |
            | or 'EQ'                    | value     | it matches.                                  |
            |                            |           | Tuples are returned in their order within    |
            |                            |           | the space. This is the default.              |
            +----------------------------+-----------+----------------------------------------------+
            | box.index.BITS_ALL_SET     | bitset    | If all of the bits which are 1 in the bitset |
            |                            | value     | value are 1 in the index key, it matches.    |
            |                            |           | Tuples are returned in their order within    |
            |                            |           | the space.                                   |
            +----------------------------+-----------+----------------------------------------------+
            | box.index.BITS_ANY_SET     | bitset    | If any of the bits which are 1 in the bitset |
            |                            | value     | value are 1 in the index key, it matches.    |
            |                            |           | Tuples are returned in their order within    |
            |                            |           | the space.                                   |
            +----------------------------+-----------+----------------------------------------------+
            | box.index.BITS_ALL_NOT_SET | bitset    | If all of the bits which are 1 in the bitset |
            |                            | value     | value are 0 in the index key, it matches.    |
            |                            |           | Tuples are returned in their order within    |
            |                            |           | the space.                                   |
            +----------------------------+-----------+----------------------------------------------+

            .. _rtree-iterator:

            **Iterator types for RTREE indexes**

            .. rst-class:: left-align-column-1
            .. rst-class:: left-align-column-2
            .. rst-class:: left-align-column-3

            .. tabularcolumns:: |\Y{0.3}|\Y{0.2}|\Y{0.5}|

            .. csv-table::
                :file: box_index_rtree.csv
                :class: longtable
                :header-rows: 1
                :delim: 0x3B

        **First example of index pairs():**

        Default 'TREE' Index and ``pairs()`` function:

        .. code-block:: tarantoolsession

            tarantool> s = box.schema.space.create('space17')
            ---
            ...
            tarantool> s:create_index('primary', {
                     >   parts = {1, 'string', 2, 'string'}
                     > })
            ---
            ...
            tarantool> s:insert{'C', 'C'}
            ---
            - ['C', 'C']
            ...
            tarantool> s:insert{'B', 'A'}
            ---
            - ['B', 'A']
            ...
            tarantool> s:insert{'C', '!'}
            ---
            - ['C', '!']
            ...
            tarantool> s:insert{'A', 'C'}
            ---
            - ['A', 'C']
            ...
            tarantool> function example()
                     >   for _, tuple in
                     >     s.index.primary:pairs(nil, {
                     >         iterator = box.index.ALL}) do
                     >       print(tuple)
                     >   end
                     > end
            ---
            ...
            tarantool> example()
            ['A', 'C']
            ['B', 'A']
            ['C', '!']
            ['C', 'C']
            ---
            ...
            tarantool> s:drop()
            ---
            ...

        **Second example of index pairs():**

        This Lua code finds all the tuples whose primary key values begin with 'XY'.
        The assumptions include that there is a one-part primary-key
        TREE index on the first field, which must be a string. The iterator loop ensures
        that the search will return tuples where the first value
        is greater than or equal to 'XY'. The conditional statement
        within the loop ensures that the looping will stop when the
        first two letters are not 'XY'.

        .. code-block:: lua

            for _, tuple in
            box.space.t.index.primary:pairs("XY",{iterator = "GE"}) do
              if (string.sub(tuple[1], 1, 2) ~= "XY") then break end
              print(tuple)
            end

        **Third example of index pairs():**

        This Lua code finds all the tuples whose primary key values are
        greater than or equal to 1000, and less than or equal to 1999
        (this type of request is sometimes called a "range search" or a "between search").
        The assumptions include that there is a one-part primary-key
        TREE index on the first field, which must be a :ref:`number <index-box_number>`. The iterator loop ensures
        that the search will return tuples where the first value
        is greater than or equal to 1000. The conditional statement
        within the loop ensures that the looping will stop when the
        first value is greater than 1999.

        .. code-block:: lua

            for _, tuple in
            box.space.t2.index.primary:pairs(1000,{iterator = "GE"}) do
              if (tuple[1] > 1999) then break end
              print(tuple)
            end

    .. _box_index-select:

    .. method:: select(search-key, options)

        This is an alternative to :ref:`box.space...select() <box_space-select>`
        which goes via a particular index and can make use of additional
        parameters that specify the iterator type, and the limit (that is, the
        maximum number of tuples to return) and the offset (that is, which
        tuple to start with in the list).

        :param index_object index_object: an :ref:`object reference
                                          <app_server-object_reference>`.
        :param scalar/table      key: values to be matched against the index key
        :param table/nil     options: none, any, or all of the following parameters:

                                      * ``iterator`` -- type of iterator
                                      * ``limit`` -- maximum number of tuples
                                      * ``offset`` -- start tuple number

        :return: the tuple or tuples that match the field values.
        :rtype:  array of tuples

        **Example:**

        .. code-block:: tarantoolsession

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

        .. code-block:: yaml

            ---
            - - [2, 'Y', 'Row with field[2]=Y']
              - [3, 'Z', 'Row with field[2]=Z']
            ...

        .. NOTE::

            The arguments are optional. If you call
            :samp:`box.space.{space-name}:select{}`, then every key in the index
            is considered to be a match, regardless of the iterator type. Therefore,
            for the example above, ``box.space.tester:select{}`` will select every
            tuple in the ``tester`` space via the first (primary-key) index.

        .. NOTE::

            :samp:`index.{index-name}` is optional. If it is omitted, then the assumed
            index is the first (primary-key) index. Therefore, for the example
            above, ``box.space.tester:select({1}, {iterator = 'GT'})`` would have
            returned the same two rows, via the 'primary' index.

        .. NOTE::

            :samp:`iterator = {iterator-type}` is optional. If it is omitted, then
            ``iterator = 'EQ'`` is assumed.

        .. _box_index-note:

        .. NOTE::

            :samp:`box.space.{space-name}.index.{index-name}:select(...)[1]`. can be
            replaced by :samp:`box.space.{space-name}.index.{index-name}:get(...)`.
            That is, ``get`` can be used as a convenient shorthand to get the first
            tuple in the tuple set that would be returned by ``select``. However,
            if there is more than one tuple in the tuple set, then ``get`` throws
            an error.


        **Example with BITSET index:**

        The following script shows creation and search with a BITSET index.
        Notice: BITSET cannot be unique, so first a primary-key index is created.
        Notice: bit values are entered as hexadecimal literals for easier reading.

        .. code-block:: tarantoolsession

            tarantool> s = box.schema.space.create('space_with_bitset')
            tarantool> s:create_index('primary_index', {
                     >   parts = {1, 'string'},
                     >   unique = true,
                     >   type = 'TREE'
                     > })
            tarantool> s:create_index('bitset_index', {
                     >   parts = {2, 'unsigned'},
                     >   unique = false,
                     >   type = 'BITSET'
                     > })
            tarantool> s:insert{'Tuple with bit value = 01', 0x01}
            tarantool> s:insert{'Tuple with bit value = 10', 0x02}
            tarantool> s:insert{'Tuple with bit value = 11', 0x03}
            tarantool> s.index.bitset_index:select(0x02, {
                     >   iterator = box.index.EQ
                     > })
            ---
            - - ['Tuple with bit value = 10', 2]
            ...
            tarantool> s.index.bitset_index:select(0x02, {
                     >   iterator = box.index.BITS_ANY_SET
                     > })
            ---
            - - ['Tuple with bit value = 10', 2]
              - ['Tuple with bit value = 11', 3]
            ...
            tarantool> s.index.bitset_index:select(0x02, {
                     >   iterator = box.index.BITS_ALL_SET
                     > })
            ---
            - - ['Tuple with bit value = 10', 2]
              - ['Tuple with bit value = 11', 3]
            ...
            tarantool> s.index.bitset_index:select(0x02, {
                     >   iterator = box.index.BITS_ALL_NOT_SET
                     > })
            ---
            - - ['Tuple with bit value = 01', 1]
            ...

    .. _box_index-get:

    .. method:: get(key)

        Search for a tuple via the given index, as described :ref:`earlier <box_index-note>`.

        :param index_object index_object: an :ref:`object reference
                                          <app_server-object_reference>`.
        :param scalar/table      key: values to be matched against the index key

        :return: the tuple whose index-key fields are equal to the passed key values.
        :rtype:  tuple

        **Possible errors:**

        * no such index;
        * wrong type;
        * more than one tuple matches.

        **Complexity factors:** Index size, Index type.
        See also :ref:`space_object:get() <box_space-get>`.

        **Example:**

        .. code-block:: tarantoolsession

            tarantool> box.space.tester.index.primary:get(2)
            ---
            - [2, 'Music']
            ...

    .. _box_index-min:

    .. method:: min([key])

        Find the minimum value in the specified index.

        :param index_object index_object: an :ref:`object reference
                                          <app_server-object_reference>`.
        :param scalar/table      key: values to be matched against the index key

        :return: the tuple for the first key in the index. If optional
                 ``key`` value is supplied, returns the first key which
                 is greater than or equal to ``key`` value.
                 In a future version of Tarantool, index:min(``key`` value) will return nothing
                 if ``key`` value is not equal to a value in the index.
        :rtype:  tuple

        **Possible errors:** index is not of type 'TREE'.

        **Complexity factors:** Index size, Index type.

        **Example:**

        .. code-block:: tarantoolsession

            tarantool> box.space.tester.index.primary:min()
            ---
            - ['Alpha!', 55, 'This is the first tuple!']
            ...

    .. _box_index-max:

    .. method:: max([key])

        Find the maximum value in the specified index.

        :param index_object index_object: an :ref:`object reference
                                          <app_server-object_reference>`.
        :param scalar/table      key: values to be matched against the index key

        :return: the tuple for the last key in the index. If optional ``key`` value
                 is supplied, returns the last key which is less than or equal to
                 ``key`` value.
                 In a future version of Tarantool, index:max(``key`` value) will return nothing
                 if ``key`` value is not equal to a value in the index.
        :rtype:  tuple

        **Possible errors:** index is not of type 'TREE'.

        **Complexity factors:** Index size, Index type.

        **Example:**

        .. code-block:: tarantoolsession

            tarantool> box.space.tester.index.primary:max()
            ---
            - ['Gamma!', 55, 'This is the third tuple!']
            ...

    .. _box_index-random:

    .. method:: random(seed)

        Find a random value in the specified index. This method is useful when
        it's important to get insight into data distribution in an index without
        having to iterate over the entire data set.


        :param index_object index_object: an :ref:`object reference
                                          <app_server-object_reference>`.
        :param number seed: an arbitrary non-negative integer

        :return: the tuple for the random key in the index.
        :rtype:  tuple

        **Complexity factors:** Index size, Index type.

        **Note re storage engine:** vinyl does not support ``random()``.

        **Example:**

        .. code-block:: tarantoolsession

            tarantool> box.space.tester.index.secondary:random(1)
            ---
            - ['Beta!', 66, 'This is the second tuple!']
            ...

    .. _box_index-count:

    .. method:: count([key], [iterator])

        Iterate over an index, counting the number of
        tuples which match the key-value.

        :param index_object index_object: an :ref:`object reference
                                          <app_server-object_reference>`.
        :param scalar/table key: values to be matched against the index key
        :param         iterator: comparison method

        :return: the number of matching tuples.
        :rtype:  number

        **Example:**

        .. code-block:: tarantoolsession

            tarantool> box.space.tester.index.primary:count(999)
            ---
            - 0
            ...
            tarantool> box.space.tester.index.primary:count('Alpha!', { iterator = 'LE' })
            ---
            - 1
            ...

    .. _box_index-update:

    .. method:: update(key, {{operator, field_no, value}, ...})

        Update a tuple.

        Same as :ref:`box.space...update() <box_space-update>`,
        but key is searched in this index instead of primary key.
        This index ought to be unique.

        :param index_object index_object: an :ref:`object reference
                                          <app_server-object_reference>`.
        :param scalar/table key: values to be matched against the index key
        :param string  operator: operation type represented in string
        :param number  field_no: what field the operation will apply to. The
                                 field number can be negative, meaning the
                                 position from the end of tuple.
                                 (#tuple + negative field number + 1)
        :param lua_value  value: what value will be applied

        :return: * the updated tuple
                 * nil if the key is not found
        :rtype:  tuple or nil

    .. _box_index-delete:

    .. method:: delete(key)

        Delete a tuple identified by a key.

        Same as :ref:`box.space...delete() <box_space-delete>`, but key is
        searched in this index instead of in the primary-key index. This index
        ought to be unique.

        :param index_object index_object: an :ref:`object reference
                                          <app_server-object_reference>`.
        :param scalar/table key: values to be matched against the index key

        :return: the deleted tuple.
        :rtype:  tuple

        **Note re storage engine:**
        vinyl will return `nil`, rather than the deleted tuple.

    .. _box_index-alter:

    .. method:: alter({options})

        Alter an index.
        It is legal in some circumstances to change one or more of the
        index characteristics, for example its type, its sequence options,
        its parts, and whether it is unique. Usually this causes rebuilding
        of the space,  except for the simple case where a part's ``is_nullable``
        flag is changed from ``false`` to ``true``.

        :param index_object index_object: an :ref:`object reference
                                          <app_server-object_reference>`.
        :param table options: options list, same as the options list for
                              ``create_index``, see the chart named
                              :ref:`Options for space_object:create_index() <box_space-create_index>`.

        :return: nil

        **Possible errors:**

        * index does not exist,
        * the primary-key index cannot be changed to ``{unique = false}``.

        **Note re storage engine:** vinyl does not support ``alter()``
        of a primary-key index unless the space is empty.

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

    .. _box_index-drop:

    .. method:: drop()

        Drop an index. Dropping a primary-key index has
        a side effect: all tuples are deleted.

        :param index_object index_object: an :ref:`object reference
                                          <app_server-object_reference>`.

        :return: nil.

        **Possible errors:**

        * index does not exist,
        * a primary-key index cannot be dropped while a secondary-key index
          exists.

        **Example:**

        .. code-block:: tarantoolsession

            tarantool> box.space.space55.index.primary:drop()
            ---
            ...

    .. _box_index-rename:

    .. method:: rename(index-name)

        Rename an index.

        :param index_object index_object: an :ref:`object reference
                                          <app_server-object_reference>`.
        :param string index-name: new name for index

        :return: nil

        **Possible errors:** index_object does not exist.

        **Example:**

        .. code-block:: tarantoolsession

            tarantool> box.space.space55.index.primary:rename('secondary')
            ---
            ...

        **Complexity factors:** Index size, Index type, Number of tuples accessed.

    .. _box_index-bsize:

    .. method:: bsize()

        Return the total number of bytes taken by the index.

        :param index_object index_object: an :ref:`object reference
                                          <app_server-object_reference>`.

        :return: number of bytes
        :rtype: number

    .. _box_index-stat:

    .. method:: stat()

        Return statistics about actions taken that affect the index.

        This is for use with the vinyl engine.

        Some detail items in the output from ``index_object:stat()`` are:

        * ``index_object:stat().latency`` -- timings subdivided by percentages;
        * ``index_object:stat().bytes`` -- the number of bytes total;
        * ``index_object:stat().disk.rows`` -- the approximate number of tuples in each range;
        * ``index_object:stat().disk.statement`` -- counts of inserts|updates|upserts|deletes;
        * ``index_object:stat().disk.compaction`` -- counts of compactions and their amounts;
        * ``index_object:stat().disk.dump`` -- counts of dumps and their amounts;
        * ``index_object:stat().disk.iterator.bloom`` -- counts of bloom filter hits|misses;
        * ``index_object:stat().disk.pages`` -- the size in pages;
        * ``index_object:stat().disk.last_level`` -- size of data in the last LSM tree level;
        * ``index_object:stat().cache.evict`` -- number of evictions from the cache;
        * ``index_object:stat().range_size`` -- maximum number of bytes in a range;
        * ``index_object:stat().dumps_per_compaction`` -- average number of dumps required to trigger major compaction in any range of the LSM tree.

        Summary index statistics are also available via
        :ref:`box.stat.vinyl() <box_introspection-box_stat_vinyl_details>`.

        :param index_object index_object: an :ref:`object reference
                                          <app_server-object_reference>`.

        :return: statistics
        :rtype: table

    .. _box_index-compact:

    .. method:: compact()

        Remove unused index space. For the memtx storage engine this
        method does nothing; ``index_object:compact()`` is only for the
        vinyl storage engine. For example, with vinyl, if a tuple is
        deleted, the space is not immediately reclaimed. There is a
        scheduler for reclaiming space automatically based on factors
        such as lsm shape and amplification as discussed in the section
        :ref:`Storing data with vinyl <engines-vinyl>`,
        so calling ``index_object:compact()`` manually is not always necessary.

        :return: nil (Tarantool returns without waiting for compaction to complete)


    .. _box_index-user_defined:

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

=================================================================
              Example showing use of the box functions
=================================================================

This example will work with the sandbox configuration described in the preface.
That is, there is a space named tester with a numeric primary key. The example
function will:

* select a tuple whose key value is 1000;
* raise an error if the tuple already exists and already has 3 fields;
* Insert or replace the tuple with:
    * field[1] = 1000
    * field[2] = a uuid
    * field[3] = number of seconds since 1970-01-01;
* Get field[3] from what was replaced;
* Format the value from field[3] as yyyy-mm-dd hh:mm:ss.ffff;
* Return the formatted value.

The function uses Tarantool box functions
:ref:`box.space...select <box_space-select>`,
:ref:`box.space...replace <box_space-replace>`, :ref:`fiber.time <fiber-time>`,
:ref:`uuid.str <uuid-str>`. The function uses
Lua functions `os.date()`_ and `string.sub()`_.

.. _os.date(): http://www.lua.org/pil/22.1.html
.. _string.sub(): http://www.lua.org/pil/20.html

.. code-block:: lua

    function example()
      local a, b, c, table_of_selected_tuples, d
      local replaced_tuple, time_field
      local formatted_time_field
      local fiber = require('fiber')
      table_of_selected_tuples = box.space.tester:select{1000}
      if table_of_selected_tuples ~= nil then
        if table_of_selected_tuples[1] ~= nil then
          if #table_of_selected_tuples[1] == 3 then
            box.error({code=1, reason='This tuple already has 3 fields'})
          end
        end
      end
      replaced_tuple = box.space.tester:replace
        {1000,  require('uuid').str(), tostring(fiber.time())}
      time_field = tonumber(replaced_tuple[3])
      formatted_time_field = os.date("%Y-%m-%d %H:%M:%S", time_field)
      c = time_field % 1
      d = string.sub(c, 3, 6)
      formatted_time_field = formatted_time_field .. '.' .. d
      return formatted_time_field
    end

... And here is what happens when one invokes the function:

.. code-block:: tarantoolsession

    tarantool> box.space.tester:delete(1000)
    ---
    - [1000, '264ee2da03634f24972be76c43808254', '1391037015.6809']
    ...
    tarantool> example(1000)
    ---
    - 2014-01-29 16:11:51.1582
    ...
    tarantool> example(1000)
    ---
    - error: 'This tuple already has 3 fields'
    ...

=================================================================
              Example showing a user-defined iterator
=================================================================

Here is an example that shows how to build one's own iterator. The
``paged_iter`` function is an "iterator function", which will only be understood
by programmers who have read the Lua manual section `Iterators and Closures
<https://www.lua.org/pil/7.1.html>`_. It does paginated retrievals, that is, it
returns 10 tuples at a time from a table named "t", whose primary key was
defined with ``create_index('primary',{parts={1,'string'}})``.

.. code-block:: lua

    function paged_iter(search_key, tuples_per_page)
      local iterator_string = "GE"
      return function ()
      local page = box.space.t.index[0]:select(search_key,
        {iterator = iterator_string, limit=tuples_per_page})
      if #page == 0 then return nil end
      search_key = page[#page][1]
      iterator_string = "GT"
      return page
      end
    end

Programmers who use ``paged_iter`` do not need to know why it works, they only
need to know that, if they call it within a loop, they will get 10 tuples at a
time until there are no more tuples.

In this example the tuples are merely
printed, a page at a time. But it should be simple to change the functionality,
for example by yielding after each retrieval, or by breaking when the tuples
fail to match some additional criteria.

.. code-block:: lua

    for page in paged_iter("X", 10) do
      print("New Page. Number Of Tuples = " .. #page)
      for i = 1, #page, 1 do
        print(page[i])
      end
    end

.. _box_index-rtree:

=============================================================================
         Submodule `box.index` with index type = RTREE for spatial searches
=============================================================================

The :ref:`box.index <box_index>` submodule may be used for spatial searches if
the index type is RTREE. There are operations for searching *rectangles*
(geometric objects with 4 corners and 4 sides) and *boxes* (geometric objects
with more than 4 corners and more than 4 sides, sometimes called
hyperrectangles). This manual uses the term *rectangle-or-box* for the whole
class of objects that includes both rectangles and boxes. Only rectangles will
be illustrated.

Rectangles are described according to their X-axis (horizontal axis) and Y-axis
(vertical axis) coordinates in a grid of arbitrary size. Here is a picture of
four rectangles on a grid with 11 horizontal points and 11 vertical points:

.. code-block:: none

               X AXIS
               1   2   3   4   5   6   7   8   9   10  11
            1
            2  #-------+                                           <-Rectangle#1
    Y AXIS  3  |       |
            4  +-------#
            5          #-----------------------+                   <-Rectangle#2
            6          |                       |
            7          |   #---+               |                   <-Rectangle#3
            8          |   |   |               |
            9          |   +---#               |
            10         +-----------------------#
            11                                     #               <-Rectangle#4

The rectangles are defined according to this scheme: {X-axis coordinate of top
left, Y-axis coordinate of top left, X-axis coordinate of bottom right, Y-axis
coordinate of bottom right} -- or more succinctly: {x1,y1,x2,y2}. So in the
picture ... Rectangle#1 starts at position 1 on the X axis and position 2 on
the Y axis, and ends at position 3 on the X axis and position 4 on the Y axis,
so its coordinates are {1,2,3,4}. Rectangle#2's coordinates are {3,5,9,10}.
Rectangle#3's coordinates are {4,7,5,9}. And finally Rectangle#4's coordinates
are {10,11,10,11}. Rectangle#4 is actually a "point" since it has zero width
and zero height, so it could have been described with only two digits: {10,11}.

Some relationships between the rectangles are: "Rectangle#1's nearest neighbor
is Rectangle#2", and "Rectangle#3 is entirely inside Rectangle#2".

Now let us create a space and add an RTREE index.

.. code-block:: tarantoolsession

    tarantool> s = box.schema.space.create('rectangles')
    tarantool> i = s:create_index('primary', {
             >   type = 'HASH',
             >   parts = {1, 'unsigned'}
             > })
    tarantool> r = s:create_index('rtree', {
             >   type = 'RTREE',
             >   unique = false,
             >   parts = {2, 'ARRAY'}
             > })

Field#1 doesn't matter, we just make it because we need a primary-key index.
(RTREE indexes cannot be unique and therefore cannot be primary-key indexes.)
The second field must be an "array", which means its values must represent
{x,y} points or {x1,y1,x2,y2} rectangles. Now let us populate the table by
inserting two tuples, containing the coordinates of Rectangle#2 and Rectangle#4.

.. code-block:: tarantoolsession

    tarantool> s:insert{1, {3, 5, 9, 10}}
    tarantool> s:insert{2, {10, 11}}

And now, following the description of `RTREE iterator types`_, we can search the
rectangles with these requests:

.. _RTREE iterator types: rtree-iterator_

.. code-block:: tarantoolsession

    tarantool> r:select({10, 11, 10, 11}, {iterator = 'EQ'})
    ---
    - - [2, [10, 11]]
    ...
    tarantool> r:select({4, 7, 5, 9}, {iterator = 'GT'})
    ---
    - - [1, [3, 5, 9, 10]]
    ...
    tarantool> r:select({1, 2, 3, 4}, {iterator = 'NEIGHBOR'})
    ---
    - - [1, [3, 5, 9, 10]]
      - [2, [10, 11]]
    ...

Request#1 returns 1 tuple because the point {10,11} is the same as the rectangle
{10,11,10,11} ("Rectangle#4" in the picture). Request#2 returns 1 tuple because
the rectangle {4,7,5,9}, which was "Rectangle#3" in the picture, is entirely
within{3,5,9,10} which was Rectangle#2. Request#3 returns 2 tuples, because the
NEIGHBOR iterator always returns all tuples, and the first returned tuple will
be {3,5,9,10} ("Rectangle#2" in the picture) because it is the closest neighbor
of {1,2,3,4} ("Rectangle#1" in the picture).

Now let us create a space and index for cuboids, which are rectangle-or-boxes
that have 6 corners and 6 sides.

.. code-block:: tarantoolsession

    tarantool> s = box.schema.space.create('R')
    tarantool> i = s:create_index('primary', {parts = {1, 'unsigned'}})
    tarantool> r = s:create_index('S', {
             >   type = 'RTREE',
             >   unique = false,
             >   dimension = 3,
             >   parts = {2, 'ARRAY'}
             > })

The additional option here is ``dimension=3``. The default dimension is 2, which
is why it didn't need to be specified for the examples of rectangle. The maximum
dimension is 20. Now for insertions and selections there will usually be 6
coordinates. For example:

.. code-block:: tarantoolsession

    tarantool> s:insert{1, {0, 3, 0, 3, 0, 3}}
    tarantool> r:select({1, 2, 1, 2, 1, 2}, {iterator = box.index.GT})

Now let us create a space and index for Manhattan-style spatial objects, which
are rectangle-or-boxes that have a different way to calculate neighbors.

.. code-block:: tarantoolsession

    tarantool> s = box.schema.space.create('R')
    tarantool> i = s:create_index('primary', {parts = {1, 'unsigned'}})
    tarantool> r = s:create_index('S', {
             >   type = 'RTREE',
             >   unique = false,
             >   distance = 'manhattan',
             >   parts = {2, 'ARRAY'}
             > })

The additional option here is ``distance='manhattan'``. The default distance
calculator is 'euclid', which is the straightforward as-the-crow-flies method.
The optional distance calculator is 'manhattan', which can be a more appropriate
method if one is following the lines of a grid rather than traveling in a
straight line.

.. code-block:: tarantoolsession

    tarantool> s:insert{1, {0, 3, 0, 3}}
    tarantool> r:select({1, 2, 1, 2}, {iterator = box.index.NEIGHBOR})


More examples of spatial searching are online in the file `R tree index quick
start and usage`_.

.. _R tree index quick start and usage: https://github.com/tarantool/tarantool/wiki/R-tree-index-quick-start-and-usage
