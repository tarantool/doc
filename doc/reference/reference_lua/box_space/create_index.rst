
===============================================================================
space_object:create_index()
===============================================================================

On this page:

* :ref:`create_index() description <box_space-create_index>`
* :ref:`Details about index field types <details_about_index_field_types>`
* :ref:`Index field types to use in space_object:create_index() <box_space-index_field_types>`
* :ref:`Allowing null for an indexed key <box_space-is_nullable>`
* :ref:`Using field names instead of field numbers <box_space-field_names>`
* :ref:`Using the path option for map fields (JSON-indexes) <box_space-path>`
* :ref:`Using the path option with [*] <box_space-path_multikey>`
* :ref:`Making a functional index with space_object:create_index() <box_space-index_func>`

.. class:: space_object

    .. _box_space-create_index:

    .. method:: create_index(index-name [, options ])

        Create an :ref:`index <index-box_index>`.
        It is mandatory to create an index for a space
        before trying to insert tuples into it, or select tuples from it. The
        first created index, which will be used as the primary-key index, must be
        unique.

        :param space_object space_object: an :ref:`object reference
                                          <app_server-object_reference>`
        :param string index_name: name of index, which should conform to the
                                  :ref:`rules for object names <app_server-names>`
        :param table     options: see "Options for space_object:create_index()",
                                  below

        :return: index object
        :rtype:  index_object

        .. _box_space-create_index-options:

        **Options for space_object:create_index()**

        .. container:: table

            .. rst-class:: left-align-column-1
            .. rst-class:: left-align-column-2
            .. rst-class:: left-align-column-3
            .. rst-class:: left-align-column-4

            .. tabularcolumns:: |\Y{0.2}|\Y{0.3}|\Y{0.2}|\Y{0.3}|

            +---------------------+-------------------------------------------------------+----------------------------------+-------------------------------+
            | Name                | Effect                                                | Type                             | Default                       |
            +=====================+=======================================================+==================================+===============================+
            | type                | type of index                                         | string                           | 'TREE'                        |
            |                     |                                                       | ('HASH' or 'TREE' or             |                               |
            |                     |                                                       | 'BITSET' or 'RTREE')             |                               |
            |                     |                                                       | Note re storage engine:          |                               |
            |                     |                                                       | vinyl only supports 'TREE'       |                               |
            +---------------------+-------------------------------------------------------+----------------------------------+-------------------------------+
            | id                  | unique identifier                                     | number                           | last index's id, +1           |
            +---------------------+-------------------------------------------------------+----------------------------------+-------------------------------+
            | unique              | index is unique                                       | boolean                          | ``true``                      |
            +---------------------+-------------------------------------------------------+----------------------------------+-------------------------------+
            | if_not_exists       | no error if duplicate name                            | boolean                          | ``false``                     |
            +---------------------+-------------------------------------------------------+----------------------------------+-------------------------------+
            | parts               | field-numbers  + types                                | {field_no, ``'unsigned'`` or     | ``{1, 'unsigned'}``           |
            |                     |                                                       | ``'string'`` or ``'integer'`` or |                               |
            |                     |                                                       | ``'number'`` or ``'double'`` or  |                               |
            |                     |                                                       | ``'decimal'`` or ``'boolean'``   |                               |
            |                     |                                                       | or ``'varbinary'`` or ``'uuid'`` |                               |
            |                     |                                                       | or ``'array'`` or ``'scalar'``,  |                               |
            |                     |                                                       | and optional collation or        |                               |
            |                     |                                                       | is_nullable value or path}       |                               |
            +---------------------+-------------------------------------------------------+----------------------------------+-------------------------------+
            | dimension           | affects :ref:`RTREE <box_index-rtree>` only           | number                           | 2                             |
            +---------------------+-------------------------------------------------------+----------------------------------+-------------------------------+
            | distance            | affects RTREE only                                    | string ('euclid' or              | 'euclid'                      |
            |                     |                                                       | 'manhattan')                     |                               |
            +---------------------+-------------------------------------------------------+----------------------------------+-------------------------------+
            | bloom_fpr           | affects vinyl only                                    | number                           | ``vinyl_bloom_fpr``           |
            +---------------------+-------------------------------------------------------+----------------------------------+-------------------------------+
            | page_size           | affects vinyl only                                    | number                           | ``vinyl_page_size``           |
            +---------------------+-------------------------------------------------------+----------------------------------+-------------------------------+
            | range_size          | affects vinyl only                                    | number                           | ``vinyl_range_size``          |
            +---------------------+-------------------------------------------------------+----------------------------------+-------------------------------+
            | run_count_per_level | affects vinyl only                                    | number                           | ``vinyl_run_count_per_level`` |
            +---------------------+-------------------------------------------------------+----------------------------------+-------------------------------+
            | run_size_ratio      | affects vinyl only                                    | number                           | ``vinyl_run_size_ratio``      |
            +---------------------+-------------------------------------------------------+----------------------------------+-------------------------------+
            | sequence            | see section regarding                                 | string or number                 | not present                   |
            |                     | :ref:`specifying a sequence in create_index()         |                                  |                               |
            |                     | <box_schema-sequence_create_index>`                   |                                  |                               |
            +---------------------+-------------------------------------------------------+----------------------------------+-------------------------------+
            | func                | :ref:`functional index <box_space-index_func>`        | string                           | not present                   |
            +---------------------+-------------------------------------------------------+----------------------------------+-------------------------------+
            | hint                | affects TREE only. ``true`` makes an index work       | boolean                          | ``true``                      |
            |                     | faster, ``false`` -- an index size is reduced by half |                                  |                               |
            +---------------------+-------------------------------------------------------+----------------------------------+-------------------------------+

            The options in the above chart are also applicable for
            :doc:`/reference/reference_lua/box_index/alter`.


        **Note re storage engine:** vinyl has extra options which by default are
        based on configuration parameters
        :ref:`vinyl_bloom_fpr <cfg_storage-vinyl_bloom_fpr>`,
        :ref:`vinyl_page_size <cfg_storage-vinyl_page_size>`,
        :ref:`vinyl_range_size <cfg_storage-vinyl_range_size>`,
        :ref:`vinyl_run_count_per_level <cfg_storage-vinyl_run_count_per_level>`, and
        :ref:`vinyl_run_size_ratio <cfg_storage-vinyl_run_size_ratio>`
        -- see the description of those parameters.
        The current values can be seen by selecting from
        :doc:`/reference/reference_lua/box_space/_index`.

        Building or rebuilding a large index will cause occasional
        :ref:`yields <atomic-cooperative_multitasking>`
        so that other requests will not be blocked.
        If the other requests cause an illegal situation such as a duplicate key
        in a unique index, the index building or rebuilding will fail.

        **Possible errors:**

        * too many parts;
        * index '...' already exists;
        * primary key must be unique.

        .. code-block:: tarantoolsession

            tarantool> s = box.space.tester
            ---
            ...
            tarantool> s:create_index('primary', {unique = true, parts = { {field = 1, type = 'unsigned'}, {field = 2, type = 'string'}} })
            ---
            ...

    .. _details_about_index_field_types:

    **Details about index field types:**

    The eleven index field types (unsigned | string | integer | number | double |
    boolean | decimal | uuid | varbinary | array | scalar) differ depending on
    what values are allowed, and what index types are allowed.

    * **unsigned**: unsigned integers between 0 and 18446744073709551615,
      about 18 quintillion. May also be called 'uint' or 'num', but 'num'
      is deprecated. Legal in memtx TREE or HASH indexes, and in vinyl TREE
      indexes.
    * **string**: any set of octets, up to the :ref:`maximum length
      <limitations_bytes_in_index_key>`. May also be called 'str'. Legal in
      memtx TREE or HASH or BITSET indexes, and in vinyl TREE indexes.
      A string may have a :ref:`collation <index-collation>`.
    * **integer**: integers between -9223372036854775808 and 18446744073709551615.
      May also be called 'int'. Legal in memtx TREE or HASH indexes, and in
      vinyl TREE indexes.
    * **number**: integers between -9223372036854775808 and 18446744073709551615,
      single-precision floating point numbers, or double-precision floating
      point numbers, or exact numbers. Legal in memtx TREE or HASH indexes, and in vinyl TREE
      indexes.
    * **double**: double-precision floating point numbers.
      Legal in memtx TREE or HASH indexes, and in vinyl TREE indexes.
    * **boolean**: true or false. Legal in memtx TREE or HASH indexes, and in
      vinyl TREE indexes.
    * **decimal**: exact number returned from a function in the
      :ref:`decimal <decimal>` module. Legal in memtx TREE or HASH indexes,
      and in vinyl TREE indexes.
    * **uuid**: stores a 128-bit quantity sequence of lower-case hexadecimal digits,
      representing Universally Unique Identifiers (UUID). Legal in memtx TREE or
      HASH indexes, and in vinyl TREE indexes.
    * **varbinary**: any set of octets, up to the :ref:`maximum length
      <limitations_bytes_in_index_key>`. Legal in memtx TREE or HASH indexes,
      and in vinyl TREE indexes. A varbinary byte sequence does not have a
      :ref:`collation <index-collation>` because its contents are not UTF-8 characters.
    * **array**: array of numbers. Legal in memtx :ref:`RTREE <box_index-rtree>` indexes.
    * **scalar**: null (input with ``msgpack.NULL`` or ``yaml.NULL`` or ``json.NULL``),
      booleans (true or false), or integers between
      -9223372036854775808 and 18446744073709551615, or single-precision
      floating point numbers, or double-precision floating-point numbers, or
      exact numbers, or strings, or (varbinary) byte arrays.
      When there is a mix of types, the key order is: null, then
      booleans, then numbers, then strings, then byte arrays. Legal in memtx TREE or
      HASH indexes, and in vinyl TREE indexes.

    Additionally, `nil` is allowed with any index field type if
    :ref:`is_nullable=true <box_space-is_nullable>` is specified.

    .. _box_space-index_field_types:

    **Index field types to use in space_object:create_index()**

    .. container:: table stackcolumn

        .. rst-class:: left-align-column-1
        .. rst-class:: left-align-column-2
        .. rst-class:: left-align-column-3
        .. rst-class:: left-align-column-4
        .. rst-class:: top-align-column-1

        .. tabularcolumns:: |\Y{0.2}|\Y{0.4}|\Y{0.2}|\Y{0.2}|

        +------------------+---------------------------+---------------------------------------+-----------------------+
        | Index field type | What can be in it         | Where is it legal                     | Examples              |
        +------------------+---------------------------+---------------------------------------+-----------------------+
        | **unsigned**     | integers between 0 and    | memtx TREE or HASH                    | 123456 |br|           |
        |                  | 18446744073709551615      | indexes, |br|                         |                       |
        |                  |                           | vinyl TREE indexes                    |                       |
        +------------------+---------------------------+---------------------------------------+-----------------------+
        |  **string**      | strings -- any set of     | memtx TREE or HASH indexes |br|       | 'A B C' |br|          |
        |                  | octets                    | vinyl TREE indexes                    | '\\65 \\66 \\67'      |
        +------------------+---------------------------+---------------------------------------+-----------------------+
        |  **varbinary**   | byte sequences -- any set | memtx TREE or HASH indexes |br|       | '\\65 \\66 \\67' |br| |
        |                  | of octets                 | vinyl TREE indexes                    |                       |
        +------------------+---------------------------+---------------------------------------+-----------------------+
        |  **integer**     | integers between          | memtx TREE or HASH indexes, |br|      | -2^63 |br|            |
        |                  | -9223372036854775808 and  | vinyl TREE indexes                    |                       |
        |                  | 18446744073709551615      |                                       |                       |
        +------------------+---------------------------+---------------------------------------+-----------------------+
        | **number**       | integers between          | memtx TREE or HASH indexes, |br|      | 1.234 |br|            |
        |                  | -9223372036854775808 and  | vinyl TREE indexes                    | -44 |br|              |
        |                  | 18446744073709551615,     |                                       | 1.447e+44             |
        |                  | single-precision          |                                       |                       |
        |                  | floating point numbers,   |                                       |                       |
        |                  | double-precision          |                                       |                       |
        |                  | floating point numbers,   |                                       |                       |
        |                  | exact (decimal) numbers   |                                       |                       |
        +------------------+---------------------------+---------------------------------------+-----------------------+
        | **double**       | double-precision          | memtx TREE or HASH indexes, |br|      | 1.234                 |
        |                  | floating point numbers    | vinyl TREE indexes                    |                       |
        +------------------+---------------------------+---------------------------------------+-----------------------+
        | **boolean**      | true or false             | memtx TREE or HASH indexes, |br|      | false |br|            |
        |                  |                           | vinyl TREE indexes                    | true                  |
        +------------------+---------------------------+---------------------------------------+-----------------------+
        | **decimal**      | exact numbers returned by | memtx TREE or HASH indexes, |br|      | decimal.new(1.2) |br| |
        |                  | a function in the         | vinyl TREE indexes                    |                       |
        |                  | :ref:`decimal <decimal>`  |                                       |                       |
        |                  | module                    |                                       |                       |
        +------------------+---------------------------+---------------------------------------+-----------------------+
        | **uuid**         | values returned by        | memtx TREE or HASH indexes, |br|      | uuid.fromstr('|br|    |
        |                  | :ref:`uuid.new()          | vinyl TREE indexes                    | 64d22e4d-ac92-4a |br| |
        |                  | <uuid-new>`               |                                       | 23-899a-e59f34af5479')|
        +------------------+---------------------------+---------------------------------------+-----------------------+
        | **array**        | array of integers between | memtx RTREE indexes                   | {10, 11} |br|         |
        |                  | -9223372036854775808 and  |                                       | {3, 5, 9, 10}         |
        |                  | 9223372036854775807       |                                       |                       |
        +------------------+---------------------------+---------------------------------------+-----------------------+
        | **scalar**       | null,                     | memtx TREE or HASH indexes, |br|      | null |br|             |
        |                  | booleans (true or false), | vinyl TREE indexes                    | true |br|             |
        |                  | integers between          |                                       | -1 |br|               |
        |                  | -9223372036854775808 and  |                                       | 1.234 |br|            |
        |                  | 18446744073709551615,     |                                       | '' |br|               |
        |                  | single-precision floating |                                       | 'ру'                  |
        |                  | point numbers,            |                                       |                       |
        |                  | double-precision floating |                                       |                       |
        |                  | point numbers, strings    |                                       |                       |
        +------------------+---------------------------+---------------------------------------+-----------------------+

    .. _box_space-is_nullable:

    **Allowing null for an indexed key:** If the index type is TREE, and the index
    is not the primary index, then the ``parts={...}`` clause may include
    ``is_nullable=true`` or ``is_nullable=false`` (the default). If ``is_nullable`` is
    true, then it is legal to insert ``nil`` or an equivalent such as ``msgpack.NULL``
    (or it is legal to insert nothing at all for trailing nullable fields).
    Within indexes, such "null values" are always treated as equal to other null
    values, and are always treated as less than non-null values.
    Nulls may appear multiple times even in a unique index. Example:

    .. code-block:: lua

        box.space.tester:create_index('I',{unique=true,parts={{field = 2, type = 'number', is_nullable = true}}})

    .. WARNING::

        It is legal to create multiple indexes for the same field with different
        ``is_nullable`` values, or to call :doc:`/reference/reference_lua/box_space/format`
        with a different ``is_nullable`` value from what is used for an index.
        When there is a contradiction, the rule is: null is illegal unless
        ``is_nullable=true`` for every index and for the space format.

    .. _box_space-field_names:

    **Using field names instead of field numbers:** ``create_index()`` can use
    field names and/or field types described by the optional
    :doc:`/reference/reference_lua/box_space/format` clause.
    In the following example, we show ``format()`` for a space that has two columns
    named 'x' and 'y', and then we show five variations of the ``parts={}``
    clause of ``create_index()``,
    first for the 'x' column, second for both the 'x' and 'y' columns.
    The variations include omitting the type, using numbers, and adding extra braces.

    .. code-block:: lua

        box.space.tester:format({{name='x', type='scalar'}, {name='y', type='integer'}})
        box.space.tester:create_index('I2',{parts={{'x', 'scalar'}}})
        box.space.tester:create_index('I3',{parts={{'x','scalar'},{'y','integer'}}})
        box.space.tester:create_index('I4',{parts={{1,'scalar'}}})
        box.space.tester:create_index('I5',{parts={{1,'scalar'},{2,'integer'}}})
        box.space.tester:create_index('I6',{parts={1}})
        box.space.tester:create_index('I7',{parts={1,2}})
        box.space.tester:create_index('I8',{parts={'x'}})
        box.space.tester:create_index('I9',{parts={'x','y'}})
        box.space.tester:create_index('I10',{parts={{'x'}}})
        box.space.tester:create_index('I11',{parts={{'x'},{'y'}}})

    .. _box_space-path:

    **Using the path option for map fields (JSON-indexes):** To create an index
    for a field that is a map (a path string and a scalar value), specify the
    path string during index_create, that is,
    :code:`parts={` :samp:`{field-number},'{data-type}',path = '{path-name}'` :code:`}`.
    The index type must be ``'tree'`` or ``'hash'`` and the field's contents
    must always be maps with the same path.

    .. code-block:: lua

        -- Example 1 -- The simplest use of path:
        -- Result will be - - [{'age': 44}]
        box.schema.space.create('T')
        box.space.T:create_index('I',{parts={{field = 1, type = 'scalar', path = 'age'}}})
        box.space.T:insert{{age=44}}
        box.space.T:select(44)
        -- Example 2 -- path plus format() plus JSON syntax to add clarity
        -- Result will be: - [1, {'FIO': {'surname': 'Xi', 'firstname': 'Ahmed'}}]
        s = box.schema.space.create('T')
        format = {{'id', 'unsigned'}, {'data', 'map'}}
        s:format(format)
        parts = {{'data.FIO["firstname"]', 'str'}, {'data.FIO["surname"]', 'str'}}
        i = s:create_index('info', {parts = parts})
        s:insert({1, {FIO={firstname='Ahmed', surname='Xi'}}})

    **Note re storage engine:** vinyl supports only the TREE index type, and vinyl
    secondary indexes must be created before tuples are inserted.

    .. _box_space-path_multikey:

    **Using the path option with [*]**  The string in a path option can contain '[*]'
    which is called an array index placeholder.
    Indexes defined with this are useful for JSON documents that all have the same structure.
    For example, when creating an index on field#2 for a string document that will start
    with ``{'data': [{'name': '...'}, {'name': '...'}]``, the parts section in the
    create_index request could look like: ``parts = {{field = 2, type = 'str', path = 'data[*].name'}}``.
    Then tuples containing names can be retrieved quickly with ``index_object:select({key-value})``.
    In fact a single field can have multiple keys, as in this example which retrieves the
    same tuple twice because there are two keys 'A' and 'B' which both match the request:

    .. code-block:: lua

        s = box.schema.space.create('json_documents')
        s:create_index('primarykey')
        i = s:create_index('multikey', {parts = {{field = 2, type = 'str', path = 'data[*].name'}}})
        s:insert({1,
                 {data = {{name='A'},
                          {name='B'}},
                  extra_field = 1}})
        i:select({''},{iterator='GE'})

    The result of the select request looks like this:

    .. code-block:: tarantoolsession

        tarantool> i:select({''},{iterator='GE'})
        ---
        - - [1, {'data': [{'name': 'A'}, {'name': 'B'}], 'extra_field': 1}]
        - [1, {'data': [{'name': 'A'}, {'name': 'B'}], 'extra_field': 1}]
        ...

    Some restrictions exist:
    () '[*]' must be alone or must be at the end of a name in the path;
    () '[*]' must not appear twice in the path;
    () if an index has a path with x[*] then no other index can have a path with x.component;
    () '[*]' must not appear in the path of a primary-key ;
    () if an index has ``unique=true`` and has a path with '[*]' then duplicate keys
    from different tuples are disallowed but duplicate keys for the same tuple are allowed;
    () As with :ref:`Using the path option for map fields <box_space-path>`, the field's value
    must have the structure that the path definition implies, or be nil (nil is not indexed).

    .. _box_space-index_func:

    **Making a functional index with space_object:create_index()**

    Functional indexes are indexes that call a user-defined function for forming
    the index key, rather than depending entirely on the Tarantool default formation.
    Functional indexes are useful for condensing or truncating or reversing or
    any other way that users want to customize the index.

    The function definition must expect a tuple (which has the contents of
    fields at the time a data-change request happens) and must return a tuple
    (which has the contents that will actually be put in the index).

    The space must have a memtx engine. |br|
    The function must be :ref:`persistent <box_schema-func_create_with-body>` and deterministic. |br|
    The key parts must not depend on JSON paths. |br|
    The ``create_index`` definition must include specification of all
    key parts, and the function must return a table which has the
    same number of key parts with the same types. |br|
    The function must access key-part values by index, not by field name. |br|
    Functional indexes must not be primary-key indexes. |br|
    Functional indexes cannot be altered and the function cannot
    be changed if it is used for an index, so the only way to change
    them is to drop the index and create it again. |br|
    Only sandboxed functions are suitable for functional indexes.

    **Example:**

    A function could make a key using only the first letter of a string field.

    .. code-block:: lua

        -- Step 1: Make the space.
        -- The space needs a primary-key field, which is not the field that we
        -- will use for the functional index.
        box.schema.space.create('x', {engine = 'memtx'})
        box.space.x:create_index('i',{parts={{field = 1, type = 'string'}}})
        -- Step 2: Make the function.
        -- The function expects a tuple. In this example it will work on tuple[2]
        -- because the key source is field number 2 in what we will insert.
        -- Use string.sub() from the string module to get the first character.
        lua_code = [[function(tuple) return {string.sub(tuple[2],1,1)} end]]
        -- Step 3: Make the function persistent.
        -- Use the box.schema.func.create function for this.
        box.schema.func.create('F',
            {body = lua_code, is_deterministic = true, is_sandboxed = true})
        -- Step 4: Make the functional index.
        -- Specify the fields whose values will be passed to the function.
        -- Specify the function.
        box.space.x:create_index('j',{parts={{field = 1, type = 'string'}},func = 'F'})
        -- Step 5: Test.
        -- Insert a few tuples.
        -- Select using only the first letter, it will work because that is the key
        -- Or, select using the same function as was used for insertion
        box.space.x:insert{'a', 'wombat'}
        box.space.x:insert{'b', 'rabbit'}
        box.space.x.index.j:select('w')
        box.space.x.index.j:select(box.func.F:call({{'x', 'wombat'}}));

    The results of the two ``select`` requests will look like this:

    .. code-block:: tarantoolsession

        tarantool> box.space.x.index.j:select('w')
        ---
        - - ['a', 'wombat']
        ...
        tarantool> box.space.x.index.j:select(box.func.F:call({{'x','wombat'}}));
        ---
        - - ['a', 'wombat']
        ...

    Functions for functional indexes can return multiple keys. |br|
    Such functions are called "multikey" functions. |br|
    The ``box.func.create`` options must include ``opts = {is_multikey = true}``. |br|
    The return value must be a table of tuples. |br|
    If a multikey function returns N tuples, then N keys will be added to the index.

    **Example:**

    .. code-block:: lua

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
                                 opts = {is_multikey = true}})
        idx = s:create_index('addr', {unique = false,
                                      func = 'address',
                                      parts = {{field = 1, type = 'string',
                                              collation = 'unicode_ci'}}})
        s:insert({"James", "SIS Building Lambeth London UK"})
        s:insert({"Sherlock", "221B Baker St Marylebone London NW1 6XE UK"})
        idx:select('Uk')
        -- Both tuples will be returned.
