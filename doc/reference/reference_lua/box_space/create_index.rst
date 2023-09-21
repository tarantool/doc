..  _box_space-create_index:

space_object:create_index()
===========================


..  class:: space_object

    ..  method:: create_index(index-name [, index_opts ])

        Create an :ref:`index <index-box_index>`.

        It is mandatory to create an index for a space before trying to insert
        tuples into it or select tuples from it. The first created index
        will be used as the primary-key index, so it must be unique.

        :param space_object space_object: an :ref:`object reference
                                          <app_server-object_reference>`
        :param string index_name: name of index, which should conform to the
                                  :ref:`rules for object names <app_server-names>`
        :param table  index_opts: index options (see :ref:`index_opts <index_opts_object>`)

        :return: index object
        :rtype:  index_object

        **Possible errors:**

        * too many parts
        * index '...' already exists
        * primary key must be unique

        Building or rebuilding a large index will cause occasional
        :ref:`yields <app-cooperative_multitasking>`
        so that other requests will not be blocked.
        If the other requests cause an illegal situation
        such as a duplicate key in a unique index,
        building or rebuilding such index will fail.

        **Example:**

        ..  literalinclude:: /code_snippets/test/indexes/index_select_test.lua
            :language: lua
            :lines: 20-40
            :dedent:



.. _index_opts_object:

index_opts
----------


..  class:: index_opts

    Index options that include the index name, type, identifiers of key fields, and so on.
    These options are passed to the :ref:`space_object.create_index() <box_space-create_index>` method.

    .. NOTE::

        These options are also passed to :doc:`/reference/reference_lua/box_index/alter`.

    ..  _index_opts_type:

    .. data:: type

        The :ref:`index type <index-types>`.

        | Type: string
        | Default: ``TREE``
        | Possible values: ``TREE``, ``HASH``, ``RTREE``, ``BITSET``


    ..  _index_opts_id:

    .. data:: id

        A unique numeric identifier of the index, which is generated automatically.

        | Type: number
        | Default: last index's ID + 1


    ..  _index_opts_unique:

    .. data:: unique

        Specify whether an index may be unique.
        When ``true``, the index cannot contain the same key value twice.

        | Type: boolean
        | Default: ``true``

        **Example:**

        ..  literalinclude:: /code_snippets/test/indexes/index_select_test.lua
            :language: lua
            :lines: 36-37
            :dedent:


    ..  _index_opts_if_not_exists:

    .. data:: if_not_exists

        Specify whether to swallow an error on an attempt to create an index with a duplicated name.

        | Type: boolean
        | Default: ``false``


    ..  _index_opts_parts:

    .. data:: parts

        Specify the index's key parts.

        | Type: a table of :ref:`key_part <key_part_object>` values
        | Default: ``{1, ‘unsigned’}``

        **Example:**

        ..  literalinclude:: /code_snippets/test/indexes/index_select_test.lua
            :language: lua
            :lines: 30-40
            :dedent:

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


    ..  _index_opts_dimension:

    .. data:: dimension

        The RTREE index dimension.

        | Type: number
        | Default: 2


    ..  _index_opts_distance:

    .. data:: distance

        The RTREE index distance type.

        | Type: string
        | Default: ``euclid``
        | Possible values: ``euclid``, ``manhattan``


    ..  _index_opts_sequence:

    .. data:: sequence

        Create a generator for indexes using a sequence object.
        Learn more from :ref:`specifying a sequence in create_index() <box_schema-sequence_create_index>`.

        | Type: string or number


    ..  _index_opts_func:

    .. data:: func

        Specify the identifier of the :ref:`functional index <box_space-index_func>` function.

        | Type: string


    ..  _index_opts_hint:

    .. data:: hint

        **Since:** :doc:`2.6.1 </release/2.6.1>`

        Specify whether hint optimization is enabled for the TREE index:

        *   If ``true``, the index works faster.
        *   If ``false``, the index size is reduced by half.

        | Type: boolean
        | Default: ``true``


    ..  _index_opts_bloom_fpr:

    .. data:: bloom_fpr

        **Vinyl only**

        Specify the bloom filter's false positive rate.

        | Type: number
        | Default: :ref:`vinyl_bloom_fpr <cfg_storage-vinyl_bloom_fpr>`


    ..  _index_opts_page_size:

    .. data:: page_size

        **Vinyl only**

        Specify the size of a page used for read and write disk operations.

        | Type: number
        | Default: :ref:`vinyl_page_size <cfg_storage-vinyl_page_size>`


    ..  _index_opts_range_size:

    .. data:: range_size

        **Vinyl only**

        Specify the default maximum range size (in bytes) for a vinyl index.

        | Type: number
        | Default: :ref:`vinyl_range_size <cfg_storage-vinyl_range_size>`


    ..  _index_opts_run_count_per_level:

    .. data:: run_count_per_level

        **Vinyl only**

        Specify the maximum number of runs per level in the LSM tree.

        | Type: number
        | Default: :ref:`vinyl_run_count_per_level <cfg_storage-vinyl_run_count_per_level>`


    ..  _index_opts_run_size_ratio:

    .. data:: run_size_ratio

        **Vinyl only**

        Specify the ratio between the sizes of different levels in the LSM tree.

        | Type: number
        | Default: :ref:`vinyl_run_size_ratio <cfg_storage-vinyl_run_size_ratio>`





.. _key_part_object:

key_part
--------

..  class:: key_part

    A descriptor of a single part in a multipart key.
    A table of parts is passed to the :ref:`index_opts.parts <index_opts_parts>` option.

    ..  _key_part_field:

    .. data:: field

        Specify the field number or name.

        .. NOTE::

            To create a key part by a field name, you need to specify :ref:`space_object:format() <box_space-format>` first.

        | Type: string or number

        **Examples:** :ref:`Creating an index using field names and numbers <box_space-field_names>`


    ..  _key_part_field_type:

    .. data:: type

        Specify the field type.
        If the field type is specified in :ref:`space_object:format() <box_space-format>`,
        ``key_part.type`` inherits this value.

        | Type: string
        | Default: ``scalar``
        | Possible values: listed in :ref:`Indexed field types <index-box_indexed-field-types>`


    ..  _key_part_collation:

    .. data:: collation

        Specify the :ref:`collation <index-collation>` used to compare field values.
        If the field collation is specified in :ref:`space_object:format() <box_space-format>`,
        ``key_part.collation`` inherits this value.

        | Type: string
        | Possible values: listed in the :ref:`box.space._collation <box_space-collation>` system space

        **Example:**

        ..  literalinclude:: /code_snippets/test/indexes/create_index_key_parts_test.lua
            :language: lua
            :lines: 20-41
            :dedent:

    ..  _key_part_is_nullable:

    .. data:: is_nullable

        Specify whether ``nil`` (or its equivalent such as ``msgpack.NULL``) can be used as a field value.
        If the ``is_nullable`` option is specified in :ref:`space_object:format() <box_space-format>`,
        ``key_part.is_nullable`` inherits this value.

        You can set this option to ``true`` if:

        *   the index type is TREE
        *   the index is not the primary index

        It is also legal to insert nothing at all when using trailing nullable fields.
        Within indexes, such null values are always treated as equal to other null
        values and are always treated as less than non-null values.
        Nulls may appear multiple times even in a unique index.

        | Type: boolean
        | Default: false


        **Example:**

        ..  code-block:: lua

                box.space.tester:create_index('I', {unique = true, parts = {{field = 2, type = 'number', is_nullable = true}}})

        ..  WARNING::

            It is legal to create multiple indexes for the same field with different
            ``is_nullable`` values or to call :doc:`/reference/reference_lua/box_space/format`
            with a different ``is_nullable`` value from what is used for an index.
            When there is a contradiction, the rule is: null is illegal unless
            ``is_nullable=true`` for every index and for the space format.


    ..  _key_part_exclude_null:

    .. data:: exclude_null

        **Since:** :doc:`2.8.2 </release/2.8.2>`

        Specify whether an index can skip tuples with null at this key part.
        You can set this option to ``true`` if:

        *   the index type is TREE
        *   the index is not the primary index

        If ``exclude_null`` is set to ``true``, ``is_nullable`` is set to ``true`` automatically.
        Note that this option can be changed dynamically.
        In this case, the index is rebuilt.

        Such indexes do not store filtered tuples at all, so indexing can be done faster.

        | Type: boolean
        | Default: false



    ..  _key_part_path:

    .. data:: path

        Specify the path string for a map field.

        | Type: string

        See the examples below:

        *   :ref:`Creating an index using the path option for map fields <box_space-path>`
        *   :ref:`Creating a multikey index using the path option with [*] <box_space-path_multikey>`






















.. _create_index_examples:

Examples
--------

..  _box_space-field_names:

Creating an index using field names and numbers
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


``create_index()`` can use field names or field numbers to define key parts.


**Example 1 (field names):**

To create a key part by a field name, you need to specify :ref:`space_object:format() <box_space-format>` first.

..  literalinclude:: /code_snippets/test/indexes/index_select_test.lua
    :language: lua
    :lines: 30-40
    :dedent:

**Example 2 (field numbers):**

..  literalinclude:: /code_snippets/test/indexes/create_index_field_number_test.lua
    :language: lua
    :lines: 30-40
    :dedent:



..  _box_space-path:

Creating an index using the path option for map fields (JSON-path indexes)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

To create an index for a field that is a map (a path string and a scalar value),
specify the path string during index creation, like this:

..  cssclass:: highlight
..  parsed-literal::

    :extsamp:`parts = {{*{field-number}*}, {*{'data-type'}*}, path = {*{'path-name'}*}}`

The index type must be TREE or HASH and the contents of the field
must always be maps with the same path.

**Example 1 -- The simplest use of path:**

..  literalinclude:: /code_snippets/test/indexes/create_index_json_path_test.lua
    :language: lua
    :lines: 20-25
    :dedent:

**Example 2 -- path plus format() plus JSON syntax to add clarity:**

..  literalinclude:: /code_snippets/test/indexes/create_index_json_path_test.lua
    :language: lua
    :lines: 27-32
    :dedent:



..  _box_space-path_multikey:

Creating a multikey index using the path option with [*]
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

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

A single field can have multiple keys, as in this example
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

The following restrictions exist:

*   ``[*]`` must be alone or must be at the end of a name in the path.
*   ``[*]`` must not appear twice in the path.
*   If an index has a path with ``x[*]``, then no other index can have a path with
    x.component.
*   ``[*]`` must not appear in the path of a primary key.
*   If an index has ``unique=true`` and has a path with ``[*]``,
    then duplicate keys from different tuples are disallowed, but duplicate keys
    for the same tuple are allowed.
*   The field's value must have the same structure as in the path definition,
    or be nil (nil is not indexed).
*   In a space with multikey indexes, any tuple cannot contain
    :ref:`more than ~8,000 elements <limitations_fields_in_tuple_multikey_index>` indexed that way.

..  _box_space-index_func:

Creating a functional index
~~~~~~~~~~~~~~~~~~~~~~~~~~~

Functional indexes are indexes that call a user-defined function for forming
the index key, rather than depending entirely on the Tarantool default formation.
Functional indexes are useful for condensing or truncating or reversing or
any other way that users want to customize the index.

There are several recommendations for building functional indexes:

*   The function definition must expect a tuple, which has the contents of
    fields at the time a data-change request happens, and must return a tuple,
    which has the contents that will be put in the index.

*   The ``create_index`` definition must include the specification of all key parts,
    and the custom function must return a table that has the same number of key
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

#.  Create a space. The space needs a primary-key field, which is not
    the field that we will use for the functional index:

    ..  literalinclude:: /code_snippets/test/indexes/create_index_func_test.lua
        :language: lua
        :lines: 20-21
        :dedent:


#.  Create a function. The function expects a tuple. In this example, it will
    work on tuple[2] because the key source is field number 2 in what we will
    insert. Use ``string.sub()`` from the ``string`` module to get the first character:

    ..  literalinclude:: /code_snippets/test/indexes/create_index_func_test.lua
        :language: lua
        :lines: 22
        :dedent:

#.  Make the function persistent using the ``box.schema.func.create`` function:

    ..  literalinclude:: /code_snippets/test/indexes/create_index_func_test.lua
        :language: lua
        :lines: 23-24
        :dedent:

#.  Create a functional index. Specify the fields whose values will be passed
    to the function. Specify the function:

    ..  literalinclude:: /code_snippets/test/indexes/create_index_func_test.lua
        :language: lua
        :lines: 25-26
        :dedent:

#.  Insert a few tuples. Select using only the first letter, it will work
    because that is the key. Or, select using the same function as was used for
    insertion:

    ..  literalinclude:: /code_snippets/test/indexes/create_index_func_test.lua
        :language: lua
        :lines: 27-30
        :dedent:


    The results of the two ``select`` requests will look like this:

    ..  code-block:: tarantoolsession

        tarantool> box.space.tester.index.func_index:select('w')
        ---
        - - ['a', 'wombat']
        ...
        tarantool> box.space.tester.index.func_index:select(box.func.my_func:call({{'tester','wombat'}}));
        ---
        - - ['a', 'wombat']
        ...

Here is the full code of the example:

    ..  literalinclude:: /code_snippets/test/indexes/create_index_func_test.lua
        :language: lua
        :lines: 20-30
        :dedent:


..  _box_space-index_func_multikey:

Functions for functional indexes can return **multiple keys**. Such functions are
called "multikey" functions.

To create a multikey function, the options of ``box.schema.func.create()`` must include ``is_multikey = true``.
The return value must be a table of tuples. If a multikey function returns
N tuples, then N keys will be added to the index.

**Example:**

    ..  literalinclude:: /code_snippets/test/indexes/create_index_func_multikey_test.lua
        :language: lua
        :lines: 20-43
        :dedent:
