..  _key_def-module:

-------------------------------------------------------------------------------
                            Module key_def
-------------------------------------------------------------------------------

..  module:: key_def

The `key_def` module has a function for defining the field numbers and types of a tuple.
The definition is usually used with an index definition
to extract or compare the index key values.

..  _key_def-new:

..  function:: new(parts)

    Create a new key_def instance.

    :param table parts: field numbers and types.
                        There must be at least one part.
                        Every part must contain the attributes ``type`` and ``fieldno``/``field``.
                        Other attributes are optional.

    :returns: :ref:`a key_def object <key_def-object>`

    The parts table has components which are the same as
    the ``parts`` option in
    :ref:`Options for space_object:create_index() <box_space-create_index-options>`.

    ``fieldno`` (integer), for example, ``fieldno = 1``.
    It is legal to use ``field`` instead of ``fieldno``.

    ``type`` (string), for example, ``type = 'string'``.

    Other components are optional.

    Example: ``key_def.new({{type = 'unsigned', fieldno = 1}})``

    Example: ``key_def.new({{type = 'string', collation = 'unicode', field = 2}})``


..  _key_def-object:

..  class:: key_def_object

    A key_def object is an object returned by :ref:`key_def.new() <key_def-new>`.
    It has methods
    :ref:`extract_key() <key_def-extract_key>`,
    :ref:`compare() <key_def-compare>`,
    :ref:`compare_with_key() <key_def-compare_with_key>`,
    :ref:`merge() <key_def-merge>`,
    :ref:`totable() <key_def-totable>`.

    ..  _key_def-extract_key:

    ..  method:: extract_key(tuple)

        Return a tuple containing only the fields of the ``key_def`` object.

        :param table tuple: tuple or Lua table with field contents

        :return: the fields defined for the ``key_def`` object

        **Example #1:**

        ..  code-block:: tarantoolsession

            -- Suppose an item has five fields
            -- 1, 99.5, 'X', nil, 99.5
            -- and the fields that we care about are
            -- #3 (a string) and #1 (an integer).
            -- We can define those fields with k = key_def.new
            -- and extract the values with k:extract_key.

            tarantool> key_def = require('key_def')
            ---
            ...

            tarantool> k = key_def.new({{type = 'string', fieldno = 3},
            >                           {type = 'unsigned', fieldno = 1}})
            ---
            ...

            tarantool> k:extract_key({1, 99.5, 'X', nil, 99.5})
            ---
            - ['X', 1]
            ...

        **Example #2**

        ..  code-block:: lua

            -- Now suppose the item is a tuple in a space with
            -- an index on field #3 plus field #1.
            -- We can use key_def.new with the index definition
            -- instead of filling it out (Example #1).
            -- The result will be the same.
            key_def = require('key_def')
            box.schema.space.create('T')
            i = box.space.T:create_index('I', {parts={3, 'string', 1, 'unsigned'}})
            box.space.T:insert{1, 99.5, 'X', nil, 99.5}
            k = key_def.new(i.parts)
            k:extract_key(box.space.T:get({'X', 1}))

        **Example #3**

        ..  code-block:: lua

            -- Iterate through the tuples in a secondary non-unique index
            -- extracting the tuples' primary-key values, so they could be deleted
            -- using a unique index. This code should be a part of a Lua function.
            local key_def_lib = require('key_def')
            local s = box.schema.space.create('test')
            local pk = s:create_index('pk')
            local sk = s:create_index('test', {unique = false, parts = {
                {2, 'number', path = 'a'}, {2, 'number', path = 'b'}}})
            s:insert{1, {a = 1, b = 1}}
            s:insert{2, {a = 1, b = 2}}
            local key_def = key_def_lib.new(pk.parts)
            for _, tuple in sk:pairs({1})) do
                local key = key_def:extract_key(tuple)
                pk:delete(key)
            end

    ..  _key_def-compare:

    ..  method:: compare(tuple_1, tuple_2)

        Compare the key fields of ``tuple_1`` with the key fields of ``tuple_2``.
        It is a tuple-by-tuple comparison so users do not have to
        write code that compares one field at a time.
        Each field's type and collation will be taken into account.
        In effect it is a comparison of ``extract_key(tuple_1)`` with ``extract_key(tuple_2)``.

        :param table tuple1: tuple or Lua table with field contents
        :param table tuple2: tuple or Lua table with field contents

        :return: > 0 if tuple_1 key fields > tuple_2 key fields,
                 = 0 if tuple_1 key fields = tuple_2 key fields,
                 < 0 if tuple_1 key fields < tuple_2 key fields

        **Example:**

        ..  code-block:: lua

            -- This will return 0
            key_def = require('key_def')
            k = key_def.new({{type = 'string', fieldno = 3, collation = 'unicode_ci'},
                             {type = 'unsigned', fieldno = 1}})
            k:compare({1, 99.5, 'X', nil, 99.5}, {1, 99.5, 'x', nil, 99.5})

    ..  _key_def-compare_with_key:

    ..  method:: compare_with_key(tuple_1, tuple_2)

        Compare the key fields of ``tuple_1`` with all the fields of ``tuple_2``.
        This is the same as :ref:`key_def_object:compare() <key_def-compare>`
        except that ``tuple_2`` contains only the key fields.
        In effect it is a comparison of ``extract_key(tuple_1)`` with ``tuple_2``.

        :param table tuple1: tuple or Lua table with field contents
        :param table tuple2: tuple or Lua table with field contents

        :return: > 0 if tuple_1 key fields > tuple_2 fields,
                 = 0 if tuple_1 key fields = tuple_2 fields,
                 < 0 if tuple_1 key fields < tuple_2 fields

        **Example:**

        ..  code-block:: lua

            -- Returns 0
            key_def = require('key_def')
            k = key_def.new({{type = 'string', fieldno = 3, collation = 'unicode_ci'},
                             {type = 'unsigned', fieldno = 1}})
            k:compare_with_key({1, 99.5, 'X', nil, 99.5}, {'x', 1})

    ..  _key_def-merge:

    ..  method:: merge (other_key_def_object)

        Combine the main ``key_def_object`` with ``other_key_def_object``.
        The return value is a new ``key_def_object`` containing all the fields of
        the main ``key_def_object``, then all the fields of ``other_key_def_object`` which
        are not in the main ``key_def_object``.

        :param key_def_object other_key_def_object: definition of fields to add

        :return: key_def_object

        **Example:**

        ..  code-block:: lua

            -- Returns a key definition with fieldno = 3 and fieldno = 1.
            key_def = require('key_def')
            k = key_def.new({{type = 'string', fieldno = 3}})
            k2= key_def.new({{type = 'unsigned', fieldno = 1},
                             {type = 'string', fieldno = 3}})
            k:merge(k2)

    ..  _key_def-totable:

    ..  method:: totable()

        Returns a table containing the fields of the ``key_def_object``.
        This is the reverse of ``key_def.new()``:

        *  ``key_def.new()`` takes a table and returns a ``key_def`` object,
        *  ``key_def_object:totable()`` takes a ``key_def`` object and returns a table.

        This is useful for input to ``_serialize`` methods.

        :return: table

        **Example:**

        ..  code-block:: lua

            -- Returns a table with type = 'string', fieldno = 3
            key_def = require('key_def')
            k = key_def.new({{type = 'string', fieldno = 3}})
            k:totable()
