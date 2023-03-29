.. _box_index-select:

===============================================================================
index_object:select()
===============================================================================

..  class:: index_object

    ..  method:: select(search-key, options)

        Search for a tuple or a set of tuples by the current index.
        To search by the primary index in the specified space, use the :ref:`box_space-select` method.

        :param index_object index_object: an :ref:`object reference
                                          <app_server-object_reference>`
        :param scalar/table      key: a value to be matched against the index key, which may be multi-part
        :param table/nil     options: none, any, or all of the following parameters:

                                      * ``iterator`` -- the :ref:`iterator type <box_index-iterator-types>`. The default iterator type is 'EQ'
                                      * ``limit`` -- the maximum number of tuples
                                      * ``offset`` -- the number of tuples to skip
                                        (use this parameter carefully for :ref:`large data sets <offset-warning>`)
                                      * ``options.after`` -- a tuple or a tuple's position, after which ``select`` continues searching
                                      * ``options.fetch_pos`` -- if **true**, the ``select`` method returns the position of the last selected tuple as the second value

        :return:

            This function might return one or two values:

            *   The tuples whose fields are equal to the fields of the passed key.
                If the number of passed fields is less than the
                number of fields in the current key, then only the passed
                fields are compared, so ``select{1,2}`` will match a tuple
                whose primary key is ``{1,2,3}``.
            *   (Optionally) If ``options.fetch_pos`` is set to **true**, returns a base64-encoded string representing
                the position of the last selected tuple as the second value.

        :rtype:  array of tuples

        .. _offset-warning:

        ..  WARNING::

            Use the ``offset`` option carefully for scanning
            large data sets as it linearly increases the number
            of scanned tuples and leads to a full space scan.
            Instead, you can use the ``after`` and ``fetch_pos`` options.


       **Examples:**

        Below are few examples of using ``select`` with different parameters.
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

            -- Select all tuples by the specified secondary index --
            tarantool> bands.index.band:select()
            ---
            - - [3, 'Ace of Base', 1987]
              - [9, 'Led Zeppelin', 1968]
              - [8, 'Nirvana', 1987]
              - [5, 'Pink Floyd', 1965]
              - [10, 'Queen', 1970]
              - [1, 'Roxette', 1986]
              - [2, 'Scorpions', 1965]
              - [4, 'The Beatles', 1960]
              - [7, 'The Doors', 1965]
              - [6, 'The Rolling Stones', 1962]
            ...

            -- Select a tuple by the specified multi-part secondary key --
            tarantool> bands.index.band_year:select{'The Beatles', 1960}
            ---
            - - [4, 'The Beatles', 1960]
            ...

            -- Select maximum 3 tuples with the key value greater than 1965 --
            tarantool> bands.index.year:select({1965}, {iterator='GT', limit = 3})
            ---
            - - [9, 'Led Zeppelin', 1968]
              - [10, 'Queen', 1970]
              - [1, 'Roxette', 1986]
            ...

            -- Select maximum 3 tuples after the specified tuple --
            tarantool> bands.index.primary:select({}, {after = {4, 'The Beatles', 1960}, limit = 3})
            ---
            - - [5, 'Pink Floyd', 1965]
              - [6, 'The Rolling Stones', 1962]
              - [7, 'The Doors', 1965]
            ...

            -- Step 1: select first 3 tuples and fetch a last tuple's position --
            tarantool> result, position = bands.index.primary:select({}, {limit = 3, fetch_pos = true})
            ---
            ...
            -- Step 2: pass the last tuple's position as the 'after' parameter --
            tarantool> bands.index.primary:select({}, {limit = 3, after = position})
            ---
            - - [4, 'The Beatles', 1960]
              - [5, 'Pink Floyd', 1965]
              - [6, 'The Rolling Stones', 1962]
            ...


        ..  _box_index-note:

        ..  NOTE::

            :samp:`box.space.{space-name}.index.{index-name}:select(...)[1]`. can be
            replaced by :samp:`box.space.{space-name}.index.{index-name}:get(...)`.
            That is, ``get`` can be used as a convenient shorthand to get the first
            tuple in the tuple set that would be returned by ``select``. However,
            if there is more than one tuple in the tuple set, then ``get`` throws
            an error.
