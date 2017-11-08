.. _box_tuple:

-------------------------------------------------------------------------------
                            Submodule `box.tuple`
-------------------------------------------------------------------------------

.. module:: box.tuple

The ``box.tuple`` submodule provides read-only access for the ``tuple``
userdata type. It allows, for a single :ref:`tuple <index-box_tuple>`: selective retrieval of the field
contents, retrieval of information about size, iteration over all the fields,
and conversion to a `Lua table <https://www.lua.org/pil/2.5.html>`_.


.. _box_tuple-new:

.. function:: new(value)

    Construct a new tuple from either a scalar or a Lua table. Alternatively,
    one can get new tuples from tarantool's :ref:`select <box_space-select>`
    or :ref:`insert <box_space-insert>` or :ref:`replace <box_space-replace>`
    or :ref:`update <box_space-update>` requests,
    which can be regarded as statements that do
    ``new()`` implicitly.

    :param lua-value value: the value that will become the tuple contents.

    :return: a new tuple
    :rtype:  tuple

    In the following example, ``x`` will be a new table object containing one
    tuple and ``t`` will be a new tuple object. Saying ``t`` returns the
    entire tuple ``t``.

    **Example:**

    .. code-block:: tarantoolsession

        tarantool> x = box.space.tester:insert{
                 >   33,
                 >   tonumber('1'),
                 >   tonumber64('2')
                 > }:totable()
        ---
        ...
        tarantool> t = box.tuple.new{'abc', 'def', 'ghi', 'abc'}
        ---
        ...
        tarantool> t
        ---
        - ['abc', 'def', 'ghi', 'abc']
        ...

.. class:: tuple_object

    .. operator:: #tuple_object

        The ``#`` operator in Lua means "return count of components". So,
        if ``t`` is a tuple instance, ``#t`` will return the number of fields.

        :rtype: number

        In the following example, a tuple named ``t`` is created and then the
        number of fields in ``t`` is returned.

        .. code-block:: tarantoolsession

            tarantool> t = box.tuple.new{'Fld#1', 'Fld#2', 'Fld#3', 'Fld#4'}
            ---
            ...
            tarantool> #t
            ---
            - 4
            ...

    .. method:: bsize()

        If ``t`` is a tuple instance, ``t:bsize()`` will return the number of
        bytes in the tuple. With both the memtx storage engine and the vinyl
        storage engine the default maximum is one megabyte
        (:ref:`memtx_max_tuple_size <cfg_storage-memtx_max_tuple_size>` or
        :ref:`vinyl_max_tuple_size <cfg_storage-vinyl_max_tuple_size>`). Every
        field has one or more "length" bytes preceding the actual contents, so
        ``bsize()`` returns a value which is slightly greater than the sum of
        the lengths of the contents.

        :return: number of bytes
        :rtype: number

        In the following example, a tuple named ``t`` is created which has
        three fields, and for each field it takes one byte to store the length
        and three bytes to store the contents, and a bit for overhead, so
        ``bsize()`` returns ``3*(1+3)+1``.

        .. code-block:: tarantoolsession

            tarantool> t = box.tuple.new{'aaa', 'bbb', 'ccc'}
            ---
            ...
            tarantool> t:bsize()
            ---
            - 13
            ...

    .. operator:: tuple_object[field-number]

        If ``t`` is a tuple instance, ``t[field-number]`` will return the field
        numbered field-number in the tuple. The first field is ``t[1]``.

        :return: field value.
        :rtype:  lua-value

        In the following example, a tuple named ``t`` is created and then the
        second field in ``t`` is returned.

        .. code-block:: tarantoolsession

            tarantool> t = box.tuple.new{'Fld#1', 'Fld#2', 'Fld#3', 'Fld#4'}
            ---
            ...
            tarantool> t[2]
            ---
            - Fld#2
            ...

    .. method:: find([field-number, ] search-value)
                findall([field-number, ] search-value)

        If ``t`` is a tuple instance, ``t:find(search-value)`` will return the
        number of the first field in ``t`` that matches the search value,
        and ``t:findall(search-value [, search-value ...])`` will return numbers
        of all fields in ``t`` that match the search value. Optionally one can
        put a numeric argument ``field-number`` before the search-value to
        indicate “start searching at field number ``field-number``.”

        :return: the number of the field in the tuple.
        :rtype:  number

        In the following example, a tuple named ``t`` is created and then: the
        number of the first field in ``t`` which matches 'a' is returned, then
        the numbers of all the fields in ``t`` which match 'a' are returned,
        then the numbers of all the fields in t which match 'a' and are at or
        after the second field are returned.

        .. code-block:: tarantoolsession

            tarantool> t = box.tuple.new{'a', 'b', 'c', 'a'}
            ---
            ...
            tarantool> t:find('a')
            ---
            - 1
            ...
            tarantool> t:findall('a')
            ---
            - 1
            - 4
            ...
            tarantool> t:findall(2, 'a')
            ---
            - 4
            ...

    .. method:: transform(start-field-number, fields-to-remove [, field-value, ...])

        If ``t`` is a tuple instance, :samp:`t:transform({start-field-number},{fields-to-remove})`
        will return a tuple where, starting from field ``start-field-number``,
        a number of fields (``fields-to-remove``) are removed. Optionally one
        can add more arguments after ``fields-to-remove`` to indicate new
        values that will replace what was removed.

        :param integer start-field-number: base 1, may be negative
        :param integer   fields-to-remove:
        :param lua-value   field-value(s):
        :return: tuple
        :rtype:  tuple

        In the following example, a tuple named ``t`` is created and then,
        starting from the second field, two fields are removed but one new
        one is added, then the result is returned.

        .. code-block:: tarantoolsession

            tarantool> t = box.tuple.new{'Fld#1', 'Fld#2', 'Fld#3', 'Fld#4', 'Fld#5'}
            ---
            ...
            tarantool> t:transform(2, 2, 'x')
            ---
            - ['Fld#1', 'x', 'Fld#4', 'Fld#5']
            ...

    .. method:: unpack([start-field-number [, end-field-number]])

        If ``t`` is a tuple instance, ``t:unpack()`` will return all fields,
        ``t:unpack(1)`` will return all fields starting with field number 1,
        ``t:unpack(1,5)`` will return all fields between field number 1 and field number 5.

        :return: field(s) from the tuple.
        :rtype:  lua-value(s)

        In the following example, a tuple named ``t`` is created and then all
        its fields are selected, then the result is returned.

        .. code-block:: tarantoolsession

            tarantool> t = box.tuple.new{'Fld#1', 'Fld#2', 'Fld#3', 'Fld#4', 'Fld#5'}
            ---
            ...
            tarantool> t:unpack()
            ---
            - Fld#1
            - Fld#2
            - Fld#3
            - Fld#4
            - Fld#5
            ...

    .. method:: totable([start-field-number [, end-field-number]])

        If ``t`` is a tuple instance, ``t:totable()`` will return all fields,
        ``t:totable(1)`` will return all fields starting with field number 1,
        ``t:totable(1,5)`` will return all fields between field number 1 and field number 5.
        It is preferable to use ``t:totable()`` rather than ``t:unpack()``.

        :return: field(s) from the tuple
        :rtype:  lua-table

        In the following example, a tuple named ``t`` is created, then all
        its fields are selected, then the result is returned.

        .. code-block:: tarantoolsession

            tarantool> t = box.tuple.new{'Fld#1', 'Fld#2', 'Fld#3', 'Fld#4', 'Fld#5'}
            ---
            ...
            tarantool> t:totable()
            ---
            - ['Fld#1', 'Fld#2', 'Fld#3', 'Fld#4', 'Fld#5']
            ...


    .. method:: pairs()

        In Lua, `lua-table-value:pairs() <https://www.lua.org/pil/7.3.html>`_ is a method which returns:
        ``function``, ``lua-table-value``, ``nil``. Tarantool has extended
        this so that ``tuple-value:pairs()`` returns: ``function``,
        ``tuple-value``, ``nil``. It is useful for Lua iterators, because Lua
        iterators traverse a value's components until an end marker is reached.

        :return: function, tuple-value, nil
        :rtype:  function, lua-value, nil

        In the following example, a tuple named ``t`` is created and then all
        its fields are selected using a Lua for-end loop.

        .. code-block:: tarantoolsession

            tarantool> t = box.tuple.new{'Fld#1', 'Fld#2', 'Fld#3', 'Fld#4', 'Fld#5'}
            ---
            ...
            tarantool> tmp = ''
            ---
            ...
            tarantool> for k, v in t:pairs() do
                     >   tmp = tmp .. v
                     > end
            ---
            ...
            tarantool> tmp
            ---
            - Fld#1Fld#2Fld#3Fld#4Fld#5
            ...

    .. method:: update({{operator, field_no, value}, ...})

        Update a tuple.

        This function updates a tuple which is not in a space. Compare the function
        :extsamp:`box.space.{*{space-name}*}:update({*{key}*}, {{{*{format}*}, {*{field_no}*}, {*{value}*}}, ...})`
        which updates a tuple in a space.

        For details: see the description for ``operator``, ``field_no``, and
        ``value`` in the section :ref:`box.space.space-name:update{key, format,
        {field_number, value}...) <box_space-update>`.

        :param string  operator: operation type represented in string (e.g.
                                 '``=``' for 'assign new value')
        :param number  field_no: what field the operation will apply to. The
                                 field number can be negative, meaning the
                                 position from the end of tuple.
                                 (#tuple + negative field number + 1)
        :param lua_value  value: what value will be applied

        :return: new tuple
        :rtype:  tuple

        In the following example, a tuple named ``t`` is created and then its
        second field is updated to equal 'B'.

        .. code-block:: tarantoolsession

            tarantool> t = box.tuple.new{'Fld#1', 'Fld#2', 'Fld#3', 'Fld#4', 'Fld#5'}
            ---
            ...
            tarantool> t:update({{'=', 2, 'B'}})
            ---
            - ['Fld#1', 'B', 'Fld#3', 'Fld#4', 'Fld#5']
            ...

===========================================================
                        Example
===========================================================

This function will illustrate how to convert tuples to/from Lua tables and lists
of scalars:

.. code-block:: lua

    tuple = box.tuple.new({scalar1, scalar2, ... scalar_n}) -- scalars to tuple
    lua_table = {tuple:unpack()}                            -- tuple to Lua table
    lua_table = tuple:totable()                             -- tuple to Lua table
    scalar1, scalar2, ... scalar_n = tuple:unpack()         -- tuple to scalars
    tuple = box.tuple.new(lua_table)                        -- Lua table to tuple

Then it will find the field that contains 'b', remove that field from the tuple,
and display how many bytes remain in the tuple. The function uses Tarantool
``box.tuple`` functions ``new()``, ``unpack()``, ``find()``, ``transform()``,
``bsize()``.

.. code-block:: lua

    function example()
      local tuple1, tuple2, lua_table_1, scalar1, scalar2, scalar3, field_number
      local luatable1 = {}
      tuple1 = box.tuple.new({'a', 'b', 'c'})
      luatable1 = tuple1:totable()
      scalar1, scalar2, scalar3 = tuple1:unpack()
      tuple2 = box.tuple.new(luatable1[1],luatable1[2],luatable1[3])
      field_number = tuple2:find('b')
      tuple2 = tuple2:transform(field_number, 1)
      return 'tuple2 = ' , tuple2 , ' # of bytes = ' , tuple2:bsize()
    end

... And here is what happens when one invokes the function:

.. code-block:: tarantoolsession

    tarantool> example()
    ---
    - tuple2 =
    - ['a', 'c']
    - ' # of bytes = '
    - 5
    ...
