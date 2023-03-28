.. _box_index-pairs:
.. _box_index-index_pairs:

===============================================================================
index_object:pairs()
===============================================================================

.. class:: index_object

    .. method:: pairs([key [,{iterator = iterator-type}]])

        Search for a tuple or a set of tuples via the given index,
        and allow iterating over one tuple at a time.
        To search by the primary index in the specified space, use the :ref:`box_space-pairs` method.

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
        :ref:`the implicit yield rules <app-implicit-yields>`, or by an
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
                                          <app_server-object_reference>`
        :param scalar/table key: value to be matched against the index key,
                                 which may be multi-part
        :param iterator: as defined in tables below. The default iterator type
                         is 'EQ'
        :param after: a tuple, after which ``pairs`` continues searching


        :return: the `iterator <https://www.lua.org/pil/7.1.html>`_, which can be
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


        **Examples:**

        Below are few examples of using ``pairs`` with different parameters.
        To try out these examples, you need to bootstrap a Tarantool instance
        as described in :ref:`Using data operations <box_space-operations-detailed-examples>`.



        ..  code-block:: tarantoolsession

            -- Insert test data --
            tarantool> bands:insert{1, 'Roxette', 1986}
                       bands:insert{2, 'Scorpions', 1965}
                       bands:insert{3, 'Ace of Base', 1987}
                       bands:insert{4, 'The Beatles', 1960}
                       bands:insert{5, 'Pink Floyd', 1965}
                       bands:insert{6, 'The Rolling Stones', 1962}
                       bands:insert{7, 'The Doors', 1965}
                       bands:insert{8, 'Nirvana', 1987}
                       bands:insert{9, 'Led Zeppelin', 1968}
                       bands:insert{10, 'Queen', 1970}
            ---
            ...

            -- Select all tuples by the primary index --
            tarantool> for _, tuple in bands.index.primary:pairs() do
                           print(tuple)
                       end
            [1, 'Roxette', 1986]
            [2, 'Scorpions', 1965]
            [3, 'Ace of Base', 1987]
            [4, 'The Beatles', 1960]
            [5, 'Pink Floyd', 1965]
            [6, 'The Rolling Stones', 1962]
            [7, 'The Doors', 1965]
            [8, 'Nirvana', 1987]
            [9, 'Led Zeppelin', 1968]
            [10, 'Queen', 1970]
            ---
            ...

            -- Select all tuples whose secondary key values start with the specified string --
            tarantool> for _, tuple in bands.index.band:pairs("The", {iterator = "GE"}) do
                         if (string.sub(tuple[2], 1, 3) ~= "The") then break end
                         print(tuple)
                       end
            [4, 'The Beatles', 1960]
            [7, 'The Doors', 1965]
            [6, 'The Rolling Stones', 1962]
            ---
            ...

            -- Select all tuples whose secondary key values are between 1965 and 1970 --
            tarantool> for _, tuple in bands.index.year:pairs(1965, {iterator = "GE"}) do
                         if (tuple[3] > 1970) then break end
                         print(tuple)
                       end
            [2, 'Scorpions', 1965]
            [5, 'Pink Floyd', 1965]
            [7, 'The Doors', 1965]
            [9, 'Led Zeppelin', 1968]
            [10, 'Queen', 1970]
            ---
            ...

            -- Select all tuples after the specified tuple --
            tarantool> for _, tuple in bands.index.primary:pairs({}, {after={7, 'The Doors', 1965}}) do
                           print(tuple)
                       end
            [8, 'Nirvana', 1987]
            [9, 'Led Zeppelin', 1968]
            [10, 'Queen', 1970]
            ---
            ...
