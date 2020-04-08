.. _box_tuple:

-------------------------------------------------------------------------------
                            Submodule `box.tuple`
-------------------------------------------------------------------------------

.. module:: box.tuple

===============================================================================
                                   Overview
===============================================================================

The ``box.tuple`` submodule provides read-only access for the ``tuple``
userdata type. It allows, for a single :ref:`tuple <index-box_tuple>`: selective
retrieval of the field contents, retrieval of information about size, iteration
over all the fields, and conversion to a `Lua table <https://www.lua.org/pil/2.5.html>`_.

===============================================================================
                                    Index
===============================================================================

Below is a list of all ``box.tuple`` functions.

.. container:: table

    .. rst-class:: left-align-column-1
    .. rst-class:: left-align-column-2

    +--------------------------------------+---------------------------------+
    | Name                                 | Use                             |
    +======================================+=================================+
    | :ref:`box.tuple.new()                | Create a tuple                  |
    | <box_tuple-new>`                     |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`#tuple_object                  | Count tuple fields              |
    | <box_tuple-count_fields>`            |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`tuple_object:bsize()           | Get count of bytes in a tuple   |
    | <box_tuple-bsize>`                   |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`tuple_object[field-number]     | Get a tuple's field by          |
    | <box_tuple-field_number>`            | specifying a number             |
    +--------------------------------------+---------------------------------+
    | :ref:`tuple_object[field-name]       | Get a tuple's field by          |
    | <box_tuple-field_name>`              | specifying a name               |
    +--------------------------------------+---------------------------------+
    | :ref:`tuple_object[field-path]       | Get a tuple's fields or parts   |
    | <box_tuple-field_path>`              | by specifying a path            |
    +--------------------------------------+---------------------------------+
    | :ref:`tuple_object:find()            | Get the number of the first     |
    | <box_tuple-find>`                    | field matching the search value |
    +--------------------------------------+---------------------------------+
    | :ref:`tuple_object:findall()         | Get the number of all fields    |
    | <box_tuple-find>`                    | matching the search value       |
    +--------------------------------------+---------------------------------+
    | :ref:`tuple_object:next()            | Get the next field value from   |
    | <box_tuple-next>`                    | tuple                           |
    +--------------------------------------+---------------------------------+
    | :ref:`tuple_object:ipairs()          | Prepare for iterating           |
    | <box_tuple-pairs>`                   |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`tuple_object:pairs()           | Prepare for iterating           |
    | <box_tuple-pairs>`                   |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`tuple_object:totable()         | Get a tuple's fields as a table |
    | <box_tuple-totable>`                 |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`tuple_object:tomap()           | Get a tuple's fields as a table |
    | <box_tuple-tomap>`                   | along with key:value pairs      |
    +--------------------------------------+---------------------------------+
    | :ref:`tuple_object:transform()       | Remove (and replace) a tuple's  |
    | <box_tuple-transform>`               | fields                          |
    +--------------------------------------+---------------------------------+
    | :ref:`tuple_object:unpack()          | Get a tuple's fields            |
    | <box_tuple-unpack>`                  |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`tuple_object:update()          | Update a tuple                  |
    | <box_tuple-update>`                  |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`tuple_object:upsert()          | Update a tuple ignoring errors  |
    | <box_tuple-upsert>`                  |                                 |
    +--------------------------------------+---------------------------------+

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

    .. _box_tuple-count_fields:

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

    .. _box_tuple-bsize:

    .. method:: bsize()

        If ``t`` is a tuple instance, ``t:bsize()`` will return the number of
        bytes in the tuple. With both the memtx storage engine and the vinyl
        storage engine the default maximum is one megabyte
        (:ref:`memtx_max_tuple_size <cfg_storage-memtx_max_tuple_size>` or
        :ref:`vinyl_max_tuple_size <cfg_storage-vinyl_max_tuple_size>`). Every
        field has one or more "length" bytes preceding the actual contents, so
        ``bsize()`` returns a value which is slightly greater than the sum of
        the lengths of the contents.

        The value does not include the size of "struct tuple" (for the current
        size of this structure look in the
        `tuple.h <https://github.com/tarantool/tarantool/blob/1.10/src/box/tuple.h>`_
        file in Tarantool's source code).

        :return: number of bytes
        :rtype: number

        In the following example, a tuple named ``t`` is created which has
        three fields, and for each field it takes one byte to store the length
        and three bytes to store the contents, and then there is one more byte
        to store a count of the number of fields, so ``bsize()`` returns
        ``3*(1+3)+1``. This is the same as the size of the string that
        :ref:`msgpack.encode({'aaa','bbb','ccc'}) <msgpack-encode>` would return.

        .. code-block:: tarantoolsession

            tarantool> t = box.tuple.new{'aaa', 'bbb', 'ccc'}
            ---
            ...
            tarantool> t:bsize()
            ---
            - 13
            ...

    .. _box_tuple-field_number:

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

    .. _box_tuple-field_name:

    .. operator:: tuple_object[field-name]

        If ``t`` is a tuple instance, ``t['field-name']`` will return the field
        named 'field-name' in the tuple. Fields have names if the tuple has
        been retrieved from a space that has an associated :ref:`format <box_space-format>`.

        :return: field value.
        :rtype:  lua-value

        In the following example, a tuple named ``t`` is returned from ``replace``
        and then the second field in ``t`` named 'field2' is returned.

        .. code-block:: tarantoolsession

            tarantool> format = {}
            ---
            ...
            tarantool> format[1] = {name = 'field1', type = 'unsigned'}
            ---
            ...
            tarantool> format[2] = {name = 'field2', type = 'string'}
            ---
            ...
            tarantool> s = box.schema.space.create('test', {format = format})
            ---
            ...
            tarantool> pk = s:create_index('pk')
            ---
            ...
            tarantool> t = s:replace{1, 'Я'}
            ---
            ...
            tarantool> t['field2']
            ---
            - Я
            ...

    .. _box_tuple-field_path:

    .. operator:: tuple_object[field-path]

        If ``t`` is a tuple instance, ``t['path']`` will return the field
        or subset of fields that are in ``path``. ``path`` must be a well
        formed JSON specification. ``path`` may contain field names if the tuple has
        been retrieved from a space that has an associated :ref:`format <box_space-format>`.

        To prevent ambiguity, Tarantool first tries to interpret the
        request as :ref:`tuple_object[field-number] <box_tuple-field_number>`
        or :ref:`tuple_object[field-name] <box_tuple-field_name>`.
        If and only if that fails, Tarantool tries to interpret the request
        as ``tuple_object[field-path]``.

        The path must be a well formed JSON specification, but it may be
        preceded by '.'. The '.' is a signal that the path acts as a suffix
        for the tuple.

        The advantage of specifying a path is that Tarantool will use it to
        search through a tuple body and get only the tuple part, or parts,
        that are actually necessary.

        In the following example, a tuple named ``t`` is returned from ``replace``
        and then only the relevant part (in this case, matching a name)
        of a relevant field is returned. Namely: the second field, the
        sixth part, the value following 'value='.

        .. code-block:: tarantoolsession

            tarantool> format = {}
            ---
            ...
            tarantool> format[1] = {name = 'field1', type = 'unsigned'}
            ---
            ...
            tarantool> format[2] = {name = 'field2', type = 'array'}
            ---
            ...
            tarantool> format[3] = {name = 'field4', type = 'string' }
            ---
            ...
            tarantool> format[4] = {name = "[2][6]['пw']['Я']", type = 'string'}
            ---
            ...
            tarantool> s = box.schema.space.create('test', {format = format})
            ---
            ...
            tarantool> pk = s:create_index('pk')
            ---
            ...
            tarantool> field2 = {1, 2, 3, "4", {5,6,7}, {пw={Я="п"}, key="V!", value="K!"}}
            ---
            ...
            tarantool> t = s:replace{1, field2, "123456", "Not K!"}
            ---
            ...
            tarantool> t["[2][6]['value']"]
            ---
            - K!
            ...

    .. _box_tuple-find:

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


    .. _box_tuple-next:

    .. method:: next(tuple[, pos])

        An analogue of the Lua ``next()`` function, but for a tuple object.
        When called without arguments, ``tuple:next()`` returns the first field
        from a tuple. Otherwise, it returns the field next to the indicated position.

        However ``tuple:next()`` is not really efficient, and it is better
        to use :ref:`tuple:pairs()/ipairs() <box_tuple-pairs>`.

        :return: field number and field value
        :rtype:  number and field type

        .. code-block:: tarantoolsession

            tarantool> tuple = box.tuple.new({5, 4, 3, 2, 0})
            ---
            ...

            tarantool> tuple:next()
            ---
            - 1
            - 5
            ...

            tarantool> tuple:next(1)
            ---
            - 2
            - 4
            ...

            tarantool> ctx, field = tuple:next()
            ---
            ...

            tarantool> while field do
                     > print(field)
                     > ctx, field = tuple:next(ctx)
                     > end
            5
            4
            3
            2
            0
            ---
            ...


    .. _box_tuple-pairs:

    .. method:: pairs()
                ipairs()

        In Lua, `lua-table-value:pairs() <https://www.lua.org/pil/7.3.html>`_ is a method which returns:
        ``function``, ``lua-table-value``, ``nil``. Tarantool has extended
        this so that ``tuple-value:pairs()`` returns: ``function``,
        ``tuple-value``, ``nil``. It is useful for Lua iterators, because Lua
        iterators traverse a value's components until an end marker is reached.

        ``tuple_object:ipairs()`` is the same as ``pairs()``, because tuple
        fields are always integers.

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

    .. _box_tuple-totable:

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

    .. _box_tuple-tomap:

    .. method:: tomap([options])

        A `Lua table <https://www.lua.org/pil/2.5.html>`_ can have indexed values,
        also called key:value pairs.
        For example, here:

        .. code-block:: lua

            a = {}; a['field1'] = 10; a['field2'] = 20

        ``a`` is a table with "field1: 10" and "field2: 20".

        The :ref:`tuple_object:totable() <box_tuple-totable>`
        function only returns a table containing the values.
        But the ``tuple_object:tomap()`` function returns a table containing
        not only the values, but also the key:value pairs.

        This only works if the tuple comes from a space that has
        been formatted with a :ref:`format clause <box_space-format>`.

        :param table options: the only possible option is ``names_only``.

                              If ``names_only`` is false or omitted (default),
                              then all the fields will appear twice,
                              first with numeric headings and
                              second with name headings.

                              If ``names_only`` is true, then all the
                              fields will appear only once, with
                              name headings.

        :return: field-number:value pair(s) and key:value pair(s) from the tuple
        :rtype:  lua-table

        In the following example, a tuple named ``t1`` is returned
        from a space that has been formatted, then tables named ``t1map1``
        and ``t1map2`` are produced from ``t1``.

        .. code-block:: lua

            format = {{'field1', 'unsigned'}, {'field2', 'unsigned'}}
            s = box.schema.space.create('test', {format = format})
            s:create_index('pk',{parts={1,'unsigned',2,'unsigned'}})
            t1 = s:insert{10, 20}
            t1map = t1:tomap()
            t1map_names_only = t1:tomap({names_only=true})

        ``t1map`` will contain "1: 10", "2: 20", "field1: 10", "field2: 20".

        ``t1map_names_only`` will contain "field1: 10", "field2: 20".

    .. _box_tuple-transform:

    .. method:: transform(start-field-number, fields-to-remove [, field-value, ...])

        If ``t`` is a tuple instance, :samp:`t:transform({start-field-number},{fields-to-remove})`
        will return a tuple where, starting from field ``start-field-number``,
        a number of fields (``fields-to-remove``) are removed. Optionally one
        can add more arguments after ``fields-to-remove`` to indicate new
        values that will replace what was removed.

        If the original tuple comes from a space that has been formatted with a
        :ref:`format clause <box_space-format>`, the formatting will not be
        preserved for the result tuple.

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

    .. _box_tuple-unpack:

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

    .. _box_tuple-update:

    .. method:: update({{operator, field_no, value}, ...})

        Update a tuple.

        This function updates a tuple which is not in a space. Compare the function
        :extsamp:`box.space.{*{space-name}*}:update({*{key}*}, {{{*{format}*}, {*{field_no}*}, {*{value}*}}, ...})`
        which updates a tuple in a space.

        For details: see the description for ``operator``, ``field_no``, and
        ``value`` in the section :ref:`box.space.space-name:update{key, format,
        {field_number, value}...) <box_space-update>`.

        If the original tuple comes from a space that has been formatted with a
        :ref:`format clause <box_space-format>`, the formatting will be
        preserved for the result tuple.

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


    .. _box_tuple-upsert:

    .. method:: upsert({{operator, field_no, value}, ...})

        The same as ``tuple_object:update()``, but ignores errors. In case
        of an error the tuple is left intact, but an error message is
        printed. Only client errors are ignored, such as a bad field type,
        or wrong field index/name. System errors, such as OOM, are not
        ignored and raised just like with a normal ``update()``. Note that
        only bad operations are ignored. All correct operations are
        applied.

        :param string  operator: operation type represented as a string (e.g.
                                 '``=``' for 'assign new value')
        :param number  field_no: the field to which the operation will be applied. The
                                 field number can be negative, meaning the
                                 position from the end of tuple.
                                 (#tuple + negative field number + 1)
        :param lua_value  value: the value which will be applied

        :return: new tuple
        :rtype:  tuple

        See the following example where one operation is applied, and one is not.

        .. code-block:: tarantoolsession

            tarantool> t = box.tuple.new({1, 2, 3})
            tarantool> t2 = t:upsert({{'=', 5, 100}})
            UPSERT operation failed:
            ER_NO_SUCH_FIELD_NO: Field 5 was not found in the tuple
            ---
            ...

            tarantool> t
            ---
            - [1, 2, 3]
            ...

            tarantool> t2
            ---
            - [1, 2, 3]
            ...

            tarantool> t2 = t:upsert({{'=', 5, 100}, {'+', 1, 3}})
            UPSERT operation failed:
            ER_NO_SUCH_FIELD_NO: Field 5 was not found in the tuple
            ---
            ...

            tarantool> t
            ---
            - [1, 2, 3]
            ...

            tarantool> t2
            ---
            - [4, 2, 3]
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
