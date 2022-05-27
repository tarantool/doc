
space_object:create_index()
===========================

On this page:

* :ref:`create_index() description <box_space-create_index>`
* :ref:`Details about index field types <details_about_index_field_types>`
* :ref:`Allowing null for an indexed key <box_space-is_nullable>`
* :ref:`Creating an index using field names instead of field numbers <box_space-field_names>`
* :ref:`Creating an index using the path option for map fields (JSON-path indexes) <box_space-path>`
* :ref:`Creating a multikey index using the path option with [*] <box_space-path_multikey>`
* :ref:`Creating a functional index <box_space-index_func>`

..  class:: space_object

    ..  _box_space-create_index:

    ..  method:: create_index(index-name [, options ])

        Create an :ref:`index <index-box_index>`.

        It is mandatory to create an index for a space before trying to insert
        tuples into it, or select tuples from it. The first created index
        will be used as the primary-key index, so it must be unique.

        :param space_object space_object: an :ref:`object reference
                                          <app_server-object_reference>`
        :param string index_name: name of index, which should conform to the
                                  :ref:`rules for object names <app_server-names>`
        :param table     options: see "Options for space_object:create_index()",
                                  below

        :return: index object
        :rtype:  index_object

        **Possible errors:**

        * too many parts;
        * index '...' already exists;
        * primary key must be unique.

        Building or rebuilding a large index will cause occasional
        :ref:`yields <atomic-cooperative_multitasking>`
        so that other requests will not be blocked.
        If the other requests cause an illegal situation
        such as a duplicate key in a unique index,
        building or rebuilding such index will fail.

        ..  _box_space-create_index-options:

        **Options for space_object:create_index()**

        ..  container:: table

            ..  list-table::
                :widths: 25 30 30 15
                :header-rows: 1

                *   -   Name
                    -   Effect
                    -   Type
                    -   Default
                *   -   type
                    -   type of index
                    -   string ('HASH' or 'TREE' or 'BITSET' or 'RTREE').
                        Note that vinyl only supports 'TREE'.
                    -   'TREE'
                *   -   id
                    -   unique identifier
                    -   number
                    -   last index's id + 1
                *   -   unique
                    -   index is unique
                    -   boolean
                    -   true
                *   -   if_not_exists
                    -   no error if duplicate name
                    -   boolean
                    -   false
                *   -   parts
                    -   field numbers + types
                    -   {field_no, 'unsigned' or 'string' or 'integer' or 'number' or 'double' or 
                        'decimal' or 'boolean' or 'varbinary' or 'uuid' or 'array' or 'scalar',
                        and optional collation or is_nullable value or path}
                    -   {1, 'unsigned'}
                *   -   dimension
                    -   affects :ref:`RTREE <box_index-rtree>` only
                    -   number
                    -   2
                *   -   distance
                    -   affects RTREE only
                    -   string ('euclid' or 'manhattan')
                    -   'euclid'
                *   -   bloom_fpr
                    -   affects vinyl only
                    -   number
                    -   vinyl_bloom_fpr
                *   -   page_size
                    -   affects vinyl only
                    -   number
                    -   vinyl_page_size
                *   -   range_size
                    -   affects vinyl only
                    -   number
                    -   vinyl_range_size
                *   -   run_count_per_level
                    -   affects vinyl only
                    -   number
                    -   vinyl_run_count_per_level
                *   -   run_size_ratio
                    -   affects vinyl only
                    -   number
                    -   vinyl_run_size_ratio
                *   -   sequence
                    -   see section regarding
                        :ref:`specifying a sequence in create_index() <box_schema-sequence_create_index>`
                    -   string or number
                    -   not present
                *   -   func
                    -   :ref:`functional index <box_space-index_func>`
                    -   string
                    -   not present
                *   -   hint (since version :doc:`2.6.1 </release/2.6.1>`)
                    -   affects TREE only.
                        ``true`` makes an index work faster, ``false`` -- index size is reduced by half
                    -   boolean
                    -   true

        The options in the above chart are also applicable for
        :doc:`/reference/reference_lua/box_index/alter`.


        **Note on storage engine:** vinyl has extra options which by default are
        based on configuration parameters
        :ref:`vinyl_bloom_fpr <cfg_storage-vinyl_bloom_fpr>`,
        :ref:`vinyl_page_size <cfg_storage-vinyl_page_size>`,
        :ref:`vinyl_range_size <cfg_storage-vinyl_range_size>`,
        :ref:`vinyl_run_count_per_level <cfg_storage-vinyl_run_count_per_level>`, and
        :ref:`vinyl_run_size_ratio <cfg_storage-vinyl_run_size_ratio>`
        -- see the description of those parameters.
        The current values can be seen by selecting from
        :doc:`/reference/reference_lua/box_space/_index`.

        **Example:**

        ..  code-block:: tarantoolsession

            tarantool> my_space = box.schema.space.create('tester')
            ---
            ...
            tarantool> my_space:create_index('primary', {unique = true, parts = {
                     > {field = 1, type = 'unsigned'},
                     > {field = 2, type = 'string'}
                     > }})
            ---
            - unique: true
              parts:
              - type: unsigned
                is_nullable: false
                fieldno: 1
              - type: string
                is_nullable: false
                fieldno: 2
              id: 0
              space_id: 512
              type: TREE
              name: primary
            ...

        ..  _index_parts_declaration_note:

        ..  NOTE::

            **Alternative way to declare index parts**

            Before version :doc:`2.7.1 </release/2.7.1>`,
            if an index consisted of a single part and had some options like
            ``is_nullable`` or ``collation`` and its definition was written as

            ..  code-block:: lua

                my_space:create_index('one_part_idx', {parts = {1, 'unsigned', is_nullable=true}})

            (with the only brackets) then options were ignored by Tarantool.

            Since version :doc:`2.7.1 </release/2.7.1>` it is allowed to omit
            extra braces in an index definition and use both ways:

            ..  code-block:: lua

                -- with extra braces
                my_space:create_index('one_part_idx', {parts = {{1, 'unsigned', is_nullable=true}}})

                -- without extra braces
                my_space:create_index('one_part_idx', {parts = {1, 'unsigned', is_nullable=true}})


..  _details_about_index_field_types:

..  _box_space-index_field_types:

Details about index field types
-------------------------------

Index field types differ depending on what values are allowed,
and what index types are allowed.

..  container:: table

    ..  list-table::
        :widths: 23 42 20 15
        :header-rows: 1

        *   - Index field type
            - What can be in it
            - Where it is legal
            - Examples

        *   - ``unsigned``
            - unsigned integers between 0 and 18446744073709551615,
              about 18 quintillion. May also be called
              'uint' or 'num', but 'num' is deprecated
            - memtx TREE or HASH indexes;

              vinyl TREE indexes
            - 123456

        *   - ``string``
            - any set of octets, up to the :ref:`maximum length
              <limitations_bytes_in_index_key>`. May also be called 'str'.
              A string may have a :ref:`collation <index-collation>`
            - memtx TREE or HASH or BITSET indexes;

              vinyl TREE indexes
            - 'A B C'

              '\\65 \\66 \\67'

        *   - ``varbinary``
            - any set of octets, up to the :ref:`maximum length
              <limitations_bytes_in_index_key>`. A varbinary byte sequence
              does not have a :ref:`collation <index-collation>`
              because its contents are not UTF-8 characters
            - memtx TREE, HASH or BITSET (since version :doc:`2.7.1 </release/2.7.1>`) indexes;

              vinyl TREE indexes
            - '\\65 \\66 \\67'

        *   - ``integer``
            - integers between -9223372036854775808 and 18446744073709551615.
              May also be called 'int'
            - memtx TREE or HASH indexes;

              vinyl TREE indexes
            - -2^63

        *   - ``number``
            - integers between -9223372036854775808 and 18446744073709551615,
              single-precision floating point numbers, or double-precision
              floating point numbers, or exact numbers
            - memtx TREE or HASH indexes;

              vinyl TREE indexes
            - 1.234

              -44

              1.447e+44

        *   - ``double``
            - double-precision floating point numbers
            - memtx TREE or HASH indexes;

              vinyl TREE indexes
            - 1.234

        *   - ``boolean``
            - true or false
            - memtx TREE or HASH indexes;

              vinyl TREE indexes
            - false

        *   - ``decimal``
            - exact number returned from a function in the
              :ref:`decimal <decimal>` module
            - memtx TREE or HASH indexes;

              vinyl TREE indexes
            - decimal.new(1.2)

        *   - ``uuid`` (since :doc:`2.4.1 </release/2.4.1>`)
            - a 128-bit quantity sequence of lower-case hexadecimal digits,
              representing Universally Unique Identifiers (UUID)
            - memtx TREE or HASH indexes;

              vinyl TREE indexes
            - uuid.fromstr('64d22e4d-ac92-4a23-899a-e59f34af5479')

        *   - ``array``
            - array of numbers
            - memtx :ref:`RTREE <box_index-rtree>` indexes
            - {10, 11}

              {3, 5, 9, 10}

        *   - ``scalar``
            - null (input with ``msgpack.NULL`` or ``yaml.NULL`` or ``json.NULL``),
              booleans (true or false), or
              integers between -9223372036854775808 and 18446744073709551615, or
              single-precision floating point numbers, or
              double-precision floating point numbers, or
              exact numbers, or
              strings, or
              (varbinary) byte arrays, or
              uuids.
              When there is a mix of types, the key order is: null,
              then booleans, then numbers, then strings, then byte arrays,
              then uuids.
            - memtx TREE or HASH indexes;

              vinyl TREE indexes
            - null

              true

              -1

              1.234

              ''

              'ру'


        *   - ``nil``
            - Additionally, `nil` is allowed with any index field type
              if :ref:`is_nullable=true <box_space-is_nullable>` is specified
            -
            -

..  _box_space-is_nullable:

Allowing null for an indexed key
--------------------------------

is_nullable parts option
~~~~~~~~~~~~~~~~~~~~~~~~

If the index type is TREE, and the index is not the primary index,
then the ``parts={...}`` clause may include ``is_nullable=true`` or
``is_nullable=false`` (the default).

If ``is_nullable`` is true, then it is legal to insert ``nil`` or an equivalent
such as ``msgpack.NULL``.
It is also legal to insert nothing at all when using trailing nullable fields.
Within indexes, such null values are always treated as equal to other null
values, and are always treated as less than non-null values.
Nulls may appear multiple times even in a unique index. Example:

..  code-block:: lua

        box.space.tester:create_index('I', {unique = true, parts = {{field = 2, type = 'number', is_nullable = true}}})

..  WARNING::

    It is legal to create multiple indexes for the same field with different
    ``is_nullable`` values, or to call :doc:`/reference/reference_lua/box_space/format`
    with a different ``is_nullable`` value from what is used for an index.
    When there is a contradiction, the rule is: null is illegal unless
    ``is_nullable=true`` for every index and for the space format.

exclude_null parts option
~~~~~~~~~~~~~~~~~~~~~~~~~

Since version 2.8.2 an index part definition may include option ``exclude_null``,
which allows an index to skip tuples with null at this part.

By default, the option is set to ``false``. When ``exclude_null`` is turned on,
the ``is_nullable=true`` option will be set automatically.
It can't be used for the primary key. This option can be changed dynamically:
in this case the index is rebuilt.

Such indexes do not store filtered tuples at all, so indexing can be done faster.

``exclude_null`` and ``is_nullable`` are connected, so this table describes
the result of combining them:

..  container:: table stackcolumn

    ..  rst-class:: left-align-column-1
    ..  rst-class:: left-align-column-2

    ..  list-table::

        *   - **exclude_null/is_nullable**
            - **false**
            - **true**

        *   - **false**
            - ok
            - ok

        *   - **true**
            - not allowed
            - ok


..  _box_space-field_names:

Creating an index using field names instead of field numbers
------------------------------------------------------------

``create_index()`` can use field names and/or field types described by the optional
:doc:`/reference/reference_lua/box_space/format` clause.

In the following example, we show ``format()`` for a space that has two columns
named 'x' and 'y', and then we show five variations of the ``parts={}``
clause of ``create_index()``,
first for the 'x' column, second for both the 'x' and 'y' columns.
The variations include omitting the type, using numbers, and adding extra braces.

..  code-block:: lua

    box.space.tester:format({{name = 'x', type = 'scalar'}, {name = 'y', type = 'integer'}})

    box.space.tester:create_index('I2', {parts = {{'x', 'scalar'}}})
    box.space.tester:create_index('I3', {parts = {{'x', 'scalar'}, {'y', 'integer'}}})

    box.space.tester:create_index('I4', {parts = {{1, 'scalar'}}})
    box.space.tester:create_index('I5', {parts = {{1, 'scalar'}, {2, 'integer'}}})

    box.space.tester:create_index('I6', {parts = {1}})
    box.space.tester:create_index('I7', {parts = {1, 2}})

    box.space.tester:create_index('I8', {parts = {'x'}})
    box.space.tester:create_index('I9', {parts = {'x', 'y'}})

    box.space.tester:create_index('I10', {parts = {{'x'}}})
    box.space.tester:create_index('I11', {parts = {{'x'}, {'y'}}})

..  _box_space-path:

Creating an index using the path option for map fields (JSON-path indexes)
--------------------------------------------------------------------------

To create an index for a field that is a map (a path string and a scalar value),
specify the path string during index creation, like this:

..  cssclass:: highlight
..  parsed-literal::

    :extsamp:`parts = {{*{field-number}*}, {*{'data-type'}*}, path = {*{'path-name'}*}}`

The index type must be TREE or HASH and the contents of the field
must always be maps with the same path.

**Example 1 -- The simplest use of path:**

..  code-block:: tarantoolsession

    tarantool> box.schema.space.create('T')
    tarantool> box.space.T:create_index('I',{parts = {{field = 1, type = 'scalar', path = 'age'}}})
    tarantool> box.space.T:insert({{age = 44}})
    tarantool> box.space.T:select(44)
    ---
    - [{'age': 44}]

**Example 2 -- path plus format() plus JSON syntax to add clarity:**

..  code-block:: lua

    tarantool> my_space = box.schema.space.create('T')
    tarantool> format = {{'id', 'unsigned'}, {'data', 'map'}}
    tarantool> my_space:format(format)
    tarantool> parts = {{'data.FIO["firstname"]', 'str'}, {'data.FIO["surname"]', 'str'}}
    tarantool> my_index = my_space:create_index('info', {parts = parts})
    tarantool> my_space:insert({1, {FIO = {firstname = 'Ahmed', surname = 'Xi'}}})
    ---
    - [1, {'FIO': {'surname': 'Xi', 'firstname': 'Ahmed'}}]

**Note re storage engine:** vinyl supports only the TREE index type, and vinyl
secondary indexes must be created before tuples are inserted.

..  _box_space-path_multikey:

Creating a multikey index using the path option with [*]
--------------------------------------------------------

The string in a path option can contain ``[*]`` which is called
**an array index placeholder**. Indexes defined with this are useful
for JSON documents that all have the same structure.

For example, when creating an index on field#2 for a string document
that will start with ``{'data': [{'name': '...'}, {'name': '...'}]``,
the parts section in the ``create_index`` request could look like:

..  code-block:: lua

    parts = {{field = 2, type = 'str', path = 'data[*].name'}}

Then tuples containing names can be retrieved quickly with
``index_object:select({key-value})``.

In fact a single field can have multiple keys, as in this example
which retrieves the same tuple twice because there are two keys 'A' and 'B'
which both match the request:

..  code-block:: lua

    my_space = box.schema.space.create('json_documents')
    my_space:create_index('primary')
    multikey_index = my_space:create_index('multikey', {parts = {{field = 2, type = 'str', path = 'data[*].name'}}})
    my_space:insert({1,
             {data = {{name = 'A'},
                      {name = 'B'}},
              extra_field = 1}})
    multikey_index:select({''}, {iterator = 'GE'})

The result of the select request looks like this:

..  code-block:: tarantoolsession

    tarantool> multikey_index:select({''},{iterator='GE'})
    ---
    - - [1, {'data': [{'name': 'A'}, {'name': 'B'}], 'extra_field': 1}]
    - [1, {'data': [{'name': 'A'}, {'name': 'B'}], 'extra_field': 1}]
    ...

Some restrictions exist:

*   ``[*]`` must be alone or must be at the end of a name in the path
*   ``[*]`` must not appear twice in the path
*   if an index has a path with ``x[*]`` then no other index can have a path with
    x.component
*   ``[*]`` must not appear in the path of a primary-key
*   if an index has ``unique=true`` and has a path with ``[*]``
    then duplicate keys from different tuples are disallowed but duplicate keys
    for the same tuple are allowed
*   the field's value must have the same structure as in the path definition,
    or be nil (nil is not indexed)

..  _box_space-index_func:

Creating a functional index
---------------------------

Functional indexes are indexes that call a user-defined function for forming
the index key, rather than depending entirely on the Tarantool default formation.
Functional indexes are useful for condensing or truncating or reversing or
any other way that users want to customize the index.

There are several recommendations on building functional indexes:

*   The function definition must expect a tuple, which has the contents of
    fields at the time a data-change request happens, and must return a tuple,
    which has the contents that will actually be put in the index.

*   The ``create_index`` definition must include specification of all key parts,
    and the custom function must return a table which has the same number of key
    parts with the same types.

*   The space must have a memtx engine.

*   The function must be persistent and deterministic
    (see :ref:`Creating a function with body <box_schema-func_create_with-body>`).

*   The key parts must not depend on JSON paths.

*   The function must access key-part values by index, not by field name.

*   Functional indexes must not be primary-key indexes.

*   Functional indexes cannot be altered and the function cannot be changed if
    it is used for an index, so the only way to change them is to drop the index
    and create it again.

*   Only :ref:`sandboxed <box_schema-func_create_with-body>` functions
    are suitable for functional indexes.

**Example:**

A function could make a key using only the first letter of a string field.

#.  Make a space. The space needs a primary-key field, which is not
    the field that we will use for the functional index:

    ..  code-block:: lua

        box.schema.space.create('tester', {engine = 'memtx'})
        box.space.tester:create_index('i',{parts={{field = 1, type = 'string'}}})

#.  Make a function. The function expects a tuple. In this example it will
    work on tuple[2] because the key source is field number 2 in what we will
    insert. Use ``string.sub()`` from the ``string`` module to get the first character:

    ..  code-block:: lua

        lua_code = [[function(tuple) return {string.sub(tuple[2],1,1)} end]]

#.  Make the function persistent using the ``box.schema.func.create`` function:

    ..  code-block:: lua

        box.schema.func.create('my_func',
            {body = lua_code, is_deterministic = true, is_sandboxed = true})

#.  Make a functional index. Specify the fields whose values will be passed
    to the function. Specify the function:

    ..  code-block:: lua

        box.space.tester:create_index('func_idx',{parts={{field = 1, type = 'string'}},func = 'my_func'})

#.  Test. Insert a few tuples. Select using only the first letter, it will work
    because that is the key. Or, select using the same function as was used for
    insertion:

    ..  code-block:: lua

        box.space.tester:insert({'a', 'wombat'})
        box.space.tester:insert({'b', 'rabbit'})
        box.space.tester.index.func_idx:select('w')
        box.space.tester.index.func_idx:select(box.func.my_func:call({{'tester', 'wombat'}}));

    The results of the two ``select`` requests will look like this:

    ..  code-block:: tarantoolsession

        tarantool> box.space.tester.index.func_idx:select('w')
        ---
        - - ['a', 'wombat']
        ...
        tarantool> box.space.tester.index.func_idx:select(box.func.my_func:call({{'tester','wombat'}}));
        ---
        - - ['a', 'wombat']
        ...

Here is the full code of the example:

..  code-block:: lua

    box.schema.space.create('tester', {engine = 'memtx'})
    box.space.tester:create_index('i',{parts={{field = 1, type = 'string'}}})
    lua_code = [[function(tuple) return {string.sub(tuple[2],1,1)} end]]
    box.schema.func.create('my_func',
        {body = lua_code, is_deterministic = true, is_sandboxed = true})
    box.space.tester:create_index('func_idx',{parts={{field = 1, type = 'string'}},func = 'my_func'})
    box.space.tester:insert({'a', 'wombat'})
    box.space.tester:insert({'b', 'rabbit'})
    box.space.tester.index.func_idx:select('w')
    box.space.tester.index.func_idx:select(box.func.my_func:call({{'tester', 'wombat'}}));

..  _box_space-index_func_multikey:

Functions for functional indexes can return **multiple keys**. Such functions are
called "multikey" functions.

To create a multikey function, the options of ``box.schema.func.create()`` must include ``is_multikey = true``.
The return value must be a table of tuples. If a multikey function returns
N tuples, then N keys will be added to the index.

**Example:**

..  code-block:: lua

    s = box.schema.space.create('withdata')
    s:format({{name = 'name', type = 'string'},
              {name = 'address', type = 'string'}})
    pk = s:create_index('name', {parts = {{field = 1, type = 'string'}}})
    lua_code = [[function(tuple)
                   local address = string.split(tuple[2])
                   local ret = {}
                   for _, v in pairs(address) do
                     table.insert(ret, {utf8.upper(v)})
                   end
                   return ret
                 end]]
    box.schema.func.create('address',
                            {body = lua_code,
                             is_deterministic = true,
                             is_sandboxed = true,
                             is_multikey = true})
    idx = s:create_index('addr', {unique = false,
                                  func = 'address',
                                  parts = {{field = 1, type = 'string',
                                          collation = 'unicode_ci'}}})
    s:insert({"James", "SIS Building Lambeth London UK"})
    s:insert({"Sherlock", "221B Baker St Marylebone London NW1 6XE UK"})
    idx:select('Uk')
    -- Both tuples will be returned.
