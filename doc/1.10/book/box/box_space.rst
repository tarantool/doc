.. _box_space:

-------------------------------------------------------------------------------
                             Submodule `box.space`
-------------------------------------------------------------------------------

===============================================================================
                                   Overview
===============================================================================

The ``box.space`` submodule has the data-manipulation functions ``select``,
``insert``, ``replace``, ``update``, ``upsert``, ``delete``, ``get``, ``put``.
It also has members, such as id, and whether or not a space is enabled. Submodule
source code is available in file
`src/box/lua/schema.lua <https://github.com/tarantool/tarantool/blob/1.7/src/box/lua/schema.lua>`_.

===============================================================================
                                    Index
===============================================================================

Below is a list of all ``box.space`` functions and members.

.. container:: table

    .. rst-class:: left-align-column-1
    .. rst-class:: left-align-column-2

    +--------------------------------------+---------------------------------+
    | Name                                 | Use                             |
    +======================================+=================================+
    | :ref:`space_object:auto_increment()  | Generate key + Insert a tuple   |
    | <box_space-auto_increment>`          |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`space_object:bsize()           | Get count of bytes              |
    | <box_space-bsize>`                   |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`space_object:count()           | Get count of tuples             |
    | <box_space-count>`                   |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`space_object:create_index()    | Create an index                 |
    | <box_space-create_index>`            |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`space_object:delete()          | Delete a tuple                  |
    | <box_space-delete>`                  |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`space_object:drop()            | Destroy a space                 |
    | <box_space-drop>`                    |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`space_object:format()          | Declare field names and types   |
    | <box_space-format>`                  |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`space_object:frommap()         | Convert from map to tuple or    |
    | <box_space-frommap>`                 | table                           |
    +--------------------------------------+---------------------------------+
    | :ref:`space_object:get()             | Select a tuple                  |
    | <box_space-get>`                     |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`space_object:insert()          | Insert a tuple                  |
    | <box_space-insert>`                  |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`space_object:len()             | Get count of tuples             |
    | <box_space-len>`                     |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`space_object:on_replace()      | Create a replace trigger        |
    | <box_space-on_replace>`              | with a function that cannot     |
    |                                      | change the tuple                |
    +--------------------------------------+---------------------------------+
    | :ref:`space_object:before_replace()  | Create a replace trigger        |
    | <box_space-before_replace>`          | with a function that can        |
    |                                      | change the tuple                |
    +--------------------------------------+---------------------------------+
    | :ref:`space_object:pairs()           | Prepare for iterating           |
    | <box_space-pairs>`                   |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`space_object:put()             | Insert or replace a tuple       |
    | <box_space-replace>`                 |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`space_object:rename()          | Rename a space                  |
    | <box_space-rename>`                  |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`space_object:replace()         | Insert or replace a tuple       |
    | <box_space-replace>`                 |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`space_object:run_triggers()    | Enable/disable a replace        |
    | <box_space-run_triggers>`            | trigger                         |
    +--------------------------------------+---------------------------------+
    | :ref:`space_object:select()          | Select one or more tuples       |
    | <box_space-select>`                  |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`space_object:truncate()        | Delete all tuples               |
    | <box_space-truncate>`                |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`space_object:update()          | Update a tuple                  |
    | <box_space-update>`                  |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`space_object:upsert()          | Update a tuple                  |
    | <box_space-upsert>`                  |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`space_object:user_defined()    | Any function / method that any  |
    | <box_space-user_defined>`            | user wants to add               |
    +--------------------------------------+---------------------------------+
    | :ref:`space_object.enabled           | Flag, true if space is enabled  |
    | <box_space-enabled>`                 |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`space_object.field_count       | Required number of fields       |
    | <box_space-field_count>`             |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`space_object.id                | Numeric identifier of space     |
    | <box_space-id>`                      |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`space_object.index             | Container of space's indexes    |
    | <box_space-space_index>`             |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`box.space._cluster             | (Metadata) List of replica sets |
    | <box_space-cluster>`                 |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`box.space._func                | (Metadata) List of function     |
    | <box_space-func>`                    | tuples                          |
    +--------------------------------------+---------------------------------+
    | :ref:`box.space._index               | (Metadata) List of indexes      |
    | <box_space-index>`                   |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`box.space._vindex              | (Metadata) List of indexes      |
    | <box_space-vindex>`                  | accessible for the current user |
    +--------------------------------------+---------------------------------+
    | :ref:`box.space._priv                | (Metadata) List of privileges   |
    | <box_space-priv>`                    |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`box.space._vpriv               | (Metadata) List of privileges   |
    | <box_space-vpriv>`                   | accessible for the current user |
    +--------------------------------------+---------------------------------+
    | :ref:`box.space._schema              | (Metadata) List of schemas      |
    | <box_space-schema>`                  |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`box.space._sequence            | (Metadata) List of sequences    |
    | <box_space-sequence>`                |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`box.space._sequence_data       | (Metadata) List of sequences    |
    | <box_space-sequence_data>`           |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`box.space._space               | (Metadata) List of spaces       |
    | <box_space-space>`                   |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`box.space._vspace              | (Metadata) List of spaces       |
    | <box_space-vspace>`                  | accessible for the current user |
    +--------------------------------------+---------------------------------+
    | :ref:`box.space._user                | (Metadata) List of users        |
    | <box_space-user>`                    |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`box.space._vuser               | (Metadata) List of users        |
    | <box_space-vuser>`                   | accessible for the current user |
    +--------------------------------------+---------------------------------+

.. module:: box.space

.. class:: space_object

    .. _box_space-auto_increment:

    .. method:: auto_increment(tuple)

        Insert a new tuple using an auto-increment primary key. The space
        specified by space_object must have an
        :ref:`'unsigned' or 'integer' or 'number' <index-box_indexed-field-types>`
        primary key index of type ``TREE``. The primary-key field
        will be incremented before the insert.

        Since version 1.7.5 this method is deprecated – it is better to use a
        :ref:`sequence <index-box_sequence>`.

        :param space_object space_object: an :ref:`object reference
                                          <app_server-object_reference>`
        :param table/tuple         tuple: tuple's fields, other than the
                                          primary-key field

        :return: the inserted tuple.
        :rtype:  tuple

        **Complexity factors:** Index size, Index type,
        Number of indexes accessed, :ref:`WAL settings <cfg_binary_logging_snapshots-rows_per_wal>`.

        **Possible errors:**

        * index has wrong type;
        * primary-key indexed field is not a number.

        **Example:**

        .. code-block:: tarantoolsession

            tarantool> box.space.tester:auto_increment{'Fld#1', 'Fld#2'}
            ---
            - [1, 'Fld#1', 'Fld#2']
            ...
            tarantool> box.space.tester:auto_increment{'Fld#3'}
            ---
            - [2, 'Fld#3']
            ...

    .. _box_space-bsize:

    .. method:: bsize()

        :param space_object space_object: an :ref:`object reference
                                          <app_server-object_reference>`

        :return: Number of bytes in the space. This number, which is stored
                 in Tarantool's internal memory, represents the total number
                 of bytes in all tuples, not including index keys.
                 For a measure of index size,
                 see :ref:`index_object:bsize() <box_index-bsize>`.

        **Example:**

        .. code-block:: tarantoolsession

            tarantool> box.space.tester:bsize()
            ---
            - 22
            ...

    .. _box_space-count:

    .. method:: count([key], [iterator])

        Return the number of tuples.
        If compared with :ref:`len() <box_space-len>`, this method works
        slower because ``count()`` scans the entire space to count the
        tuples.

        :param space_object space_object: an :ref:`object reference
                                          <app_server-object_reference>`
        :param scalar/table key: primary-key field values, must be passed as a
                                 Lua table if key is multi-part
        :param iterator: comparison method

        :return: Number of tuples.

        **Example:**

        .. code-block:: tarantoolsession

            tarantool> box.space.tester:count(2, {iterator='GE'})
            ---
            - 1
            ...

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
            | parts               | field-numbers  + types                                | {field_no, 'unsigned' or         | ``{1, 'unsigned'}``           |
            |                     |                                                       | 'string' or 'integer' or         |                               |
            |                     |                                                       | 'number' or 'boolean' or         |                               |
            |                     |                                                       | 'array' or 'scalar',             |                               |
            |                     |                                                       | and optional collation,          |                               |
            |                     |                                                       | and optional is_nullable value}  |                               |
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

        The options in the above chart are also applicable for :ref:`index_object:alter() <box_index-alter>`.

        **Note re storage engine:** vinyl has extra options which by default are
        based on configuration parameters
        :ref:`vinyl_bloom_fpr <cfg_storage-vinyl_bloom_fpr>`,
        :ref:`vinyl_page_size <cfg_storage-vinyl_page_size>`,
        :ref:`vinyl_range_size <cfg_storage-vinyl_range_size>`,
        :ref:`vinyl_run_count_per_level <cfg_storage-vinyl_run_count_per_level>`, and
        :ref:`vinyl_run_size_ratio <cfg_storage-vinyl_run_size_ratio>`
        -- see the description of those parameters.
        The current values can be seen by selecting from
        :ref:`box.space._index <box_space-index>`.

        **Possible errors:**

        * too many parts;
        * index '...' already exists;
        * primary key must be unique.

        .. code-block:: tarantoolsession

            tarantool> s = box.space.tester
            ---
            ...
            tarantool> s:create_index('primary', {unique = true, parts = {1, 'unsigned', 2, 'string'}})
            ---
            ...

    .. _details_about_index_field_types:

    **Details about index field types:**

    The seven index field types (unsigned | string | integer | number |
    boolean | array | scalar) differ depending on what values are allowed, and
    what index types are allowed.

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
      point numbers. Legal in memtx TREE or HASH indexes, and in vinyl TREE
      indexes.
    * **boolean**: true or false. Legal in memtx TREE or HASH indexes, and in
      vinyl TREE indexes.
    * **array**: array of numbers. Legal in memtx :ref:`RTREE <box_index-rtree>` indexes.
    * **scalar**: booleans (true or false), or integers between
      -9223372036854775808 and 18446744073709551615, or single-precision
      floating point numbers, or double-precison floating-point numbers, or
      strings. When there is a mix of types, the key order is:
      booleans, then numbers, then strings. Legal in memtx TREE or
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

        +------------------+---------------------------+---------------------------------------+-------------------+
        | Index field type | What can be in it         | Where is it legal                     | Examples          |
        +------------------+---------------------------+---------------------------------------+-------------------+
        | **unsigned**     | integers between 0 and    | memtx TREE or HASH                    | 123456 |br|       |
        |                  | 18446744073709551615      | indexes, |br|                         |                   |
        |                  |                           | vinyl TREE indexes                    |                   |
        +------------------+---------------------------+---------------------------------------+-------------------+
        |  **string**      | strings -- any set of     | memtx TREE or HASH indexes |br|       | 'A B C' |br|      |
        |                  | octets                    | vinyl TREE indexes                    | '\\65 \\66 \\67'  |
        +------------------+---------------------------+---------------------------------------+-------------------+
        |  **integer**     | integers between          | memtx TREE or HASH indexes, |br|      | -2^63 |br|        |
        |                  | -9223372036854775808 and  | vinyl TREE indexes                    |                   |
        |                  | 18446744073709551615      |                                       |                   |
        +------------------+---------------------------+---------------------------------------+-------------------+
        | **number**       | integers between          | memtx TREE or HASH indexes, |br|      | 1.234 |br|        |
        |                  | -9223372036854775808 and  | vinyl TREE indexes                    | -44 |br|          |
        |                  | 18446744073709551615,     |                                       | 1.447e+44         |
        |                  | single-precision          |                                       |                   |
        |                  | floating point numbers,   |                                       |                   |
        |                  | double-precision          |                                       |                   |
        |                  | floating point numbers    |                                       |                   |
        +------------------+---------------------------+---------------------------------------+-------------------+
        | **boolean**      | true or false             | memtx TREE or HASH indexes, |br|      | false |br|        |
        |                  |                           | vinyl TREE indexes                    | true              |
        +------------------+---------------------------+---------------------------------------+-------------------+
        | **array**        | array of integers between | memtx RTREE indexes                   | {10, 11} |br|     |
        |                  | -9223372036854775808 and  |                                       | {3, 5, 9, 10}     |
        |                  | 9223372036854775807       |                                       |                   |
        +------------------+---------------------------+---------------------------------------+-------------------+
        | **scalar**       | booleans (true or false), | memtx TREE or HASH indexes, |br|      | true |br|         |
        |                  | integers between          | vinyl TREE indexes                    | -1 |br|           |
        |                  | -9223372036854775808 and  |                                       | 1.234 |br|        |
        |                  | 18446744073709551615,     |                                       | '' |br|           |
        |                  | single-precision floating |                                       | 'ру'              |
        |                  | point numbers,            |                                       |                   |
        |                  | double-precision floating |                                       |                   |
        |                  | point numbers, strings    |                                       |                   |
        +------------------+---------------------------+---------------------------------------+-------------------+

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

        box.space.tester:create_index('I',{unique=true,parts={{2,'number',is_nullable=true}}})

    .. WARNING::

        It is legal to create multiple indexes for the same field with different
        ``is_nullable`` values, or to call :ref:`space_object:format() <box_space-format>`
        with a different ``is_nullable`` value from what is used for an index.
        When there is a contradiction, the rule is: null is illegal unless
        ``is_nullable=true`` for every index and for the space format.

    .. _box_space-field_names:

    **Using field names instead of field numbers:** ``create_index()`` can use
    field names and/or field types described by the optional
    :ref:`space_object:format() <box_space-format>` clause.
    In the following example, we show ``format()`` for a space that has two columns
    named 'x' and 'y', and then we show five variations of the ``parts={}``
    clause of ``create_index()``,
    first for the 'x' column, second for both the 'x' and 'y' columns.
    The variations include omitting the type, using numbers, and adding extra braces.

    .. code-block:: lua

        box.space.tester:format({{name='x', type='scalar'}, {name='y', type='integer'}})
        box.space.tester:create_index('I2',{parts={{'x','scalar'}}})
        box.space.tester:create_index('I3',{parts={{'x','scalar'},{'y','integer'}}})
        box.space.tester:create_index('I4',{parts={1,'scalar'}})
        box.space.tester:create_index('I5',{parts={1,'scalar',2,'integer'}})
        box.space.tester:create_index('I6',{parts={1}})
        box.space.tester:create_index('I7',{parts={1,2}})
        box.space.tester:create_index('I8',{parts={'x'}})
        box.space.tester:create_index('I9',{parts={'x','y'}})
        box.space.tester:create_index('I10',{parts={{'x'}}})
        box.space.tester:create_index('I11',{parts={{'x'},{'y'}}})

    **Note re storage engine:** vinyl supports only the TREE index type, and vinyl
    secondary indexes must be created before tuples are inserted.

    .. _box_space-delete:

    .. method:: delete(key)

        Delete a tuple identified by a primary key.

        :param space_object space_object: an :ref:`object reference
                                          <app_server-object_reference>`
        :param scalar/table key: primary-key field values, must be passed as a
                                 Lua table if key is multi-part

        :return: the deleted tuple
        :rtype:  tuple

        **Complexity factors:** Index size, Index type

        **Note re storage engine:**
        vinyl will return ``nil``, rather than the deleted tuple.

        **Example:**

        .. code-block:: tarantoolsession

            tarantool> box.space.tester:delete(1)
            ---
            - [1, 'My first tuple']
            ...
            tarantool> box.space.tester:delete(1)
            ---
            ...
            tarantool> box.space.tester:delete('a')
            ---
            - error: 'Supplied key type of part 0 does not match index part type:
              expected unsigned'
            ...

        For more usage scenarios and typical errors see
        :ref:`Example: using data operations <box_space-operations-detailed-examples>`
        further in this section.

    .. _box_space-drop:

    .. method:: drop()

        Drop a space.

        :param space_object space_object: an :ref:`object reference
                                          <app_server-object_reference>`

        :return: nil

        **Possible errors:** ``space_object`` does not exist.

        **Complexity factors:** Index size, Index type,
        Number of indexes accessed, WAL settings.

        **Example:**

        .. code-block:: lua

            box.space.space_that_does_not_exist:drop()

    .. _box_space-format:

    .. method:: format([format-clause])

        Declare field names and :ref:`types <index-box_data-types>`.

        :param space_object space_object: an :ref:`object reference
                                          <app_server-object_reference>`
        :param table format-clause: a list of field names and types

        :return: nil, unless format-clause is omitted

        **Possible errors:**

        * ``space_object`` does not exist;
        * field names are duplicated;
        * type is not legal.

        Ordinarily Tarantool allows unnamed untyped fields.
        But with ``format`` users can, for example, document
        that the Nth field is the surname field and must contain strings.
        It is also possible to specify a format clause in
        :ref:`box.schema.space.create() <box_schema-space_create>`.

        The format clause contains, for each field, a definition within braces:
        ``{name='...',type='...'[,is_nullable=...]}``, where:

        * the ``name`` value may be any string, provided that two fields do not
          have the same name;
        * the ``type`` value may be any of those allowed for
          :ref:`indexed fields <index-box_indexed-field-types>`:
          unsigned | string | integer | number | boolean | array | scalar
          (the same as the requirement in
          :ref:`"Options for space_object:create_index" <box_space-create_index-options>`);
        * the optional ``is_nullable`` value may be either ``true`` or ``false``
          (the same as the requirement in
          :ref:`"Options for space_object:create_index" <box_space-create_index-options>`).
          See also the warning notice in section
          :ref:`Allowing null for an indexed key <box_space-is_nullable>`.

        It is not legal for tuples to contain values that have the wrong type;
        for example after ``box.space.tester:format({{' ',type='number'}})`` the request
        ``box.space.tester:insert{'string-which-is-not-a-number'}`` will cause an error.

        It is not legal for tuples to contain null values if ``is_nullable=false``, which is the default;
        for example after ``box.space.tester:format({{' ',type='number',is_nullable=false}})`` the request
        ``box.space.tester:insert{nil,2}`` will cause an error.

        It is legal for tuples to have more fields than are described by a format
        clause. The way to constrain the number of fields is to specify a space's
        :ref:`field_count <box_space-field_count>` member.

        It is legal for tuples to have fewer fields than are described by a format
        clause, if the omitted trailing fields are described with ``is_nullable=true``;
        for example after ``box.space.tester:format({{'a',type='number'},{'b',type='number',is_nullable=true}})`` the request
        ``box.space.tester:insert{2}`` will not cause a format-related error.

        It is legal to use ``format`` on a space that already has a format,
        thus replacing any previous definitions,
        provided that there is no conflict with existing data or index definitions.

        It is legal to use ``format`` to change the ``is_nullable`` flag;
        for example after ``box.space.tester:format({{' ',type='scalar',is_nullable=false}})``
        the request ``box.space.tester:format({{' ',type='scalar',is_nullable=true}})``
        will not cause an error -- and will not cause rebuilding of the space.
        But going the other way and changing ``is_nullable`` from ``true``
        to ``false`` might cause rebuilding and might cause an error if there
        are existing tuples with nulls.

        **Example:**

        .. code-block:: lua

            box.space.tester:format({{name='surname',type='string'},{name='IDX',type='array'}})
            box.space.tester:format({{name='surname',type='string',is_nullable=true}})


        There are legal variations of the format clause:

        * omitting both 'name=' and 'type=',
        * omitting 'type=' alone, and
        * adding extra braces.

        The following examples show all the variations,
        first for one field named 'x', second for two fields named 'x' and 'y'.

        .. code-block:: lua

            box.space.tester:format({{'x'}})
            box.space.tester:format({{'x'},{'y'}})
            box.space.tester:format({{name='x',type='scalar'}})
            box.space.tester:format({{name='x',type='scalar'},{name='y',type='unsigned'}})
            box.space.tester:format({{name='x'}})
            box.space.tester:format({{name='x'},{name='y'}})
            box.space.tester:format({{'x',type='scalar'}})
            box.space.tester:format({{'x',type='scalar'},{'y',type='unsigned'}})
            box.space.tester:format({{'x','scalar'}})
            box.space.tester:format({{'x','scalar'},{'y','unsigned'}})

        The following example shows how to create a space, format it with all
        possible types, and insert into it.

        .. code-block:: tarantoolsession

            tarantool> box.schema.space.create('t')
            --- ...
            tarantool> box.space.t:format({{name='1',type='any'},
                     >                     {name='2',type='unsigned'},
                     >                     {name='3',type='string'},
                     >                     {name='4',type='number'},
                     >                     {name='5',type='integer'},
                     >                     {name='6',type='boolean'},
                     >                     {name='7',type='scalar'},
                     >                     {name='8',type='array'},
                     >                     {name='9',type='map'}})
            --- ...
            tarantool> box.space.t:create_index('i',{parts={2,'unsigned'}})
            --- ...
            tarantool> box.space.t:insert{{'a'},      -- any
                     >                    1,          -- unsigned
                     >                    'W?',       -- string
                     >                    5.5,        -- number
                     >                    -0,         -- integer
                     >                    true,       -- boolean
                     >                    true,       -- scalar
                     >                    {{'a'}},    -- array
                     >                    {val=1}}    -- map
            ---
            - [['a'], 1, 'W?', 5.5, 0, true, true, [['a']], {'val': 1}]
            ...

        Names specified with the format clause can be used in
        :ref:`space_object:get() <box_space-get>` and in
        :ref:`space_object:create_index() <box_space-create_index>` and in
        :ref:`tuple_object[field-name] <box_tuple-field_name>` and in
        :ref:`tuple_object[field-path] <box_tuple-field_path>`.

        If the format clause is omitted, then the returned value is the
        table that was used in a previous :samp:`{space_object}:format({format-clause})`
        invocation. For example, after ``box.space.tester:format({{'x','scalar'}})``,
        ``box.space.tester:format()`` will return ``[{'name': 'x', 'type': 'scalar'}]``.

        **Note re storage engine:** vinyl supports formatting of non-empty
        spaces. Primary index definition cannot be formatted.

    .. _box_space-frommap:

    .. method:: frommap(map [, option])

        Convert a map to a tuple instance or to a table.
        The map must consist of "field name = value" pairs.
        The field names and the value types must match names and types
        stated previously for the space, via
        :ref:`space_object:format() <box_space-format>`.

        :param space_object space_object: an :ref:`object reference
                                          <app_server-object_reference>`
        :param field-value-pairs map: a series of "field = value" pairs, in any order.
        :param boolean option:  the only legal option is ``{table = true|false}``; |br|
                                if the option is omitted or if ``{table = false}``,
                                then return type will be 'cdata' (i.e. tuple); |br|
                                if ``{table = true}``, then return type will be 'table'.

        :return: a tuple instance or table.
        :rtype:  tuple or table

        **Possible errors:** ``space_object`` does not exist or has no format; "unknown field".

        **Example:**

        .. code-block:: none

            -- Create a format with two fields named 'a' and 'b'.
            -- Create a space with that format.
            -- Create a tuple based on a map consistent with that space.
            -- Create a table based on a map consistent with that space.
            tarantool> format1 = {{name='a',type='unsigned'},{name='b',type='scalar'}}
            ---
            ...
            tarantool> s = box.schema.create_space('test', {format = format1})
            ---
            ...
            tarantool> s:frommap({b = 'x', a = 123456})
            ---
            - [123456, 'x']
            ...
            tarantool> s:frommap({b = 'x', a = 123456}, {table = true})
            ---
            - - 123456
              - x
            ...

    .. _box_space-get:

    .. method:: get(key)

        Search for a tuple in the given space.

        :param space_object space_object: an :ref:`object reference
                                          <app_server-object_reference>`
        :param scalar/table          key: value to be matched against the index
                                          key, which may be multi-part.

        :return: the tuple whose index key matches ``key``, or ``nil``.
        :rtype:  tuple

        **Possible errors:** ``space_object`` does not exist.

        **Complexity factors:** Index size, Index type, Number of indexes
        accessed, WAL settings.

        The ``box.space...select`` function returns a set of tuples as a Lua
        table; the ``box.space...get`` function returns at most a single tuple.
        And it is possible to get the first tuple in a space by appending
        ``[1]``. Therefore ``box.space.tester:get{1}`` has the same effect as
        ``box.space.tester:select{1}[1]``, if exactly one tuple is found.

        **Example:**

        .. code-block:: lua

            box.space.tester:get{1}

        **Using field names instead of field numbers:** `get()` can use field names
        described by the optional :ref:`space_object:format() <box_space-format>` clause.
        This is similar to a standard Lua feature, where a component can be referenced
        by its name instead of its number.
        For example, we can format the `tester` space
        with a field named `x` and use the name `x` in the index definition:

        .. code-block:: lua

            box.space.tester:format({{name='x',type='scalar'}})
            box.space.tester:create_index('I',{parts={'x'}})

        Then, if ``get`` or ``select`` retrieve a single tuple,
        we can reference the field 'x' in the tuple by its name:

        .. code-block:: lua

            box.space.tester:get{1}['x']
            box.space.tester:select{1}[1]['x']

    .. _box_space-insert:

    .. method:: insert(tuple)

        Insert a tuple into a space.

        :param space_object space_object: an :ref:`object reference
                                          <app_server-object_reference>`
        :param tuple/table         tuple: tuple to be inserted.

        :return: the inserted tuple
        :rtype:  tuple

        **Possible errors:** :errcode:`ER_TUPLE_FOUND` if a tuple with the same unique-key value already
        exists.

        **Example:**

        .. code-block:: tarantoolsession

            tarantool> box.space.tester:insert{5000,'tuple number five thousand'}
            ---
            - [5000, 'tuple number five thousand']
            ...

        For more usage scenarios and typical errors see
        :ref:`Example: using data operations <box_space-operations-detailed-examples>`
        further in this section.

    .. _box_space-len:

    .. method:: len()

        Return the number of tuples in the space.
        If compared with :ref:`count() <box_space-count>`, this method works
        faster because ``len()`` does not scan the entire space to count the
        tuples.

        :param space_object space_object: an :ref:`object reference
                                          <app_server-object_reference>`

        :return: Number of tuples in the space.

        **Example:**

        .. code-block:: tarantoolsession

            tarantool> box.space.tester:len()
            ---
            - 2
            ...

        **Note re storage engine:** vinyl supports ``len()`` but the result may be approximate.
        If an exact result is necessary then use :ref:`count() <box_space-count>`
        or :ref:`pairs():length() <box_space-pairs>`.

    .. _box_space-on_replace:

    .. method:: on_replace([trigger-function [, old-trigger-function]])

        Create a "replace :ref:`trigger <triggers>`".
        The ``trigger-function`` will be executed
        whenever a ``replace()`` or ``insert()`` or ``update()`` or ``upsert()``
        or ``delete()`` happens to a tuple in ``<space-name>``.

        :param function     trigger-function: function which will become the
                                              trigger function; see Example #2
                                              below for details about
                                              trigger function parameters
        :param function old-trigger-function: existing trigger function which
                                              will be replaced by
                                              ``trigger-function``
        :return: nil or function pointer

        If the parameters are (nil, old-trigger-function), then the old
        trigger is deleted.

        If both parameters are omitted, then the response is a list of existing
        trigger functions.

        If it is necessary to know whether the trigger activation
        happened due to replication or on a specific connection type,
        the function can refer to :ref:`box.session.type() <box_session-type>`.

        Details about trigger characteristics are in the
        :ref:`triggers <triggers-box_triggers>` section.

        See also :ref:`space_object:before_replace() <box_space-before_replace>`.

        **Example #1:**

        .. code-block:: tarantoolsession

            tarantool> function f ()
                     >   x = x + 1
                     > end
            tarantool> box.space.X:on_replace(f)

        **Example #2:**

        The ``trigger-function`` can have up to four parameters:

        * (tuple) old value which has the contents before the request started,
        * (tuple) new value which has the contents after the request ended,
        * (string) space name,
        * (string) type of request which is 'INSERT', 'DELETE', 'UPDATE', or 'REPLACE'.

        For example, the following code causes nil and 'INSERT' to be printed when the insert
        request is processed, and causes [1, 'Hi'] and 'DELETE' to be printed when the delete
        request is processed:

        .. code-block:: lua

            box.schema.space.create('space_1')
            box.space.space_1:create_index('space_1_index',{})
            function on_replace_function (old, new, s, op) print(old) print(op) end
            box.space.space_1:on_replace(on_replace_function)
            box.space.space_1:insert{1,'Hi'}
            box.space.space_1:delete{1}

        **Example #3:**

        The following series of requests will create a space, create an index,
        create a function which increments a counter, create a trigger, do two
        inserts, drop the space, and display the counter value - which is 2,
        because the function is executed once after each insert.

        .. code-block:: tarantoolsession

            tarantool> s = box.schema.space.create('space53')
            tarantool> s:create_index('primary', {parts = {1, 'unsigned'}})
            tarantool> function replace_trigger()
                     >   replace_counter = replace_counter + 1
                     > end
            tarantool> s:on_replace(replace_trigger)
            tarantool> replace_counter = 0
            tarantool> t = s:insert{1, 'First replace'}
            tarantool> t = s:insert{2, 'Second replace'}
            tarantool> s:drop()
            tarantool> replace_counter

    .. _box_space-before_replace:

    .. method:: before_replace([trigger-function [, old-trigger-function]])

        Create a "replace :ref:`trigger <triggers>`".
        The ``trigger-function`` will be executed
        whenever a ``replace()`` or ``insert()`` or ``update()`` or ``upsert()``
        or ``delete()`` happens to a tuple in ``<space-name>``.

        :param function     trigger-function: function which will become the
                                              trigger function; for the trigger
                                              function's optional parameters see
                                              the description of
                                              :ref:`on_replace <box_space-on_replace>`.
        :param function old-trigger-function: existing trigger function which
                                              will be replaced by
                                              ``trigger-function``
        :return: nil or function pointer

        If the parameters are ``(nil, old-trigger-function)``, then the old
        trigger is deleted.

        If both parameters are omitted, then the response is a list of existing trigger functions.

        If it is necessary to know whether the trigger activation
        happened due to replication or on a specific connection type,
        the function can refer to :ref:`box.session.type() <box_session-type>`.

        Details about trigger characteristics are in the
        :ref:`triggers <triggers-box_triggers>` section.

        See also :ref:`space_object:on_replace() <box_space-on_replace>`.

        Administrators can make replace triggers with ``on_replace()``,
        or make triggers with ``before_replace()``.
        If they make both types, then all ``before_replace`` triggers
        are executed before all ``on_replace`` triggers.
        The functions for both ``on_replace`` and ``before_replace``
        triggers can make changes to the database, but only the
        functions for ``before_replace`` triggers can change the
        tuple that is being replaced.

        Since a ``before_replace`` trigger function has the extra
        capability of making a change to the old tuple, it also can have
        extra overhead, to fetch the old tuple before making the
        change. Therefore an ``on_replace`` trigger is better if
        there is no need to change the old tuple. However, this
        only applies for the memtx engine -- for the vinyl engine,
        the fetch will happen for either kind of trigger.
        (With memtx the tuple data is stored along with the
        index key so no extra search is necessary;
        with vinyl that is not the case so the extra search
        is necessary.)

        Where the extra capability is not needed,
        ``on_replace`` should be used instead of ``before_replace``.
        Usually ``before_replace`` is used only for certain
        replication scenarios -- it is useful for conflict resolution.

        The value that a ``before_replace`` trigger function can return
        affects what will happen after the return. Specifically:

        * if there is no return value, then execution proceeds,
          inserting|replacing the new value;
        * if the value is nil, then the tuple will be deleted;
        * if the value is the same as the old parameter, then no
          `on_replace`` function will be called and the data
          change will be skipped
        * if the value is the same as the new parameter, then it's as if
          the ``before_replace`` function wasn't called;
        * if the value is something else, then execution proceeds,
          inserting|replacing the new value.

        However, if a trigger function returns an old tuple, or if a
        trigger function calls :ref:`run_triggers(false) <box_space-run_triggers>`,
        that will not affect other triggers that are activated for the same
        insert|update|replace request.

        **Example:**

        The following are ``before_replace`` functions that have no return
        value, or that return nil, or the same as the old parameter, or the
        same as the new parameter, or something else.

        .. code-block:: lua

            function f1 (old, new) return end
            function f2 (old, new) return nil end
            function f3 (old, new) return old end
            function f4 (old, new) return new end
            function f5 (old, new) return box.tuple.new({new[1],'b'}) end

    .. _box_space-pairs:

    .. method:: pairs([key [, iterator]])

        Search for a tuple or a set of tuples in the given space, and allow
        iterating over one tuple at a time.

        :param space_object space_object: an :ref:`object reference
                                          <app_server-object_reference>`
        :param scalar/table key: value to be matched against the index key,
                                 which may be multi-part
        :param         iterator: see :ref:`index_object:pairs
                                 <box_index-index_pairs>`

        :return: `iterator <https://www.lua.org/pil/7.1.html>`_ which can be
                 used in a for/end loop or with `totable()
                 <https://rtsisyk.github.io/luafun/reducing.html#fun.totable>`_

        **Possible errors:**

        * no such space;
        * wrong type.

        **Complexity factors:** Index size, Index type.

        For examples of complex ``pairs`` requests, where one can specify which
        index to search and what condition to use (for example "greater than"
        instead of "equal to"), see the later section :ref:`index_object:pairs
        <box_index-index_pairs>`.

        For information about iterators' internal structures see the
        `"Lua Functional library" <https://luafun.github.io/index.html>`_
        documentation.

        **Example:**

        .. code-block:: tarantoolsession

            tarantool> s = box.schema.space.create('space33')
            ---
            ...
            tarantool> -- index 'X' has default parts {1, 'unsigned'}
            tarantool> s:create_index('X', {})
            ---
            ...
            tarantool> s:insert{0, 'Hello my '}, s:insert{1, 'Lua world'}
            ---
            - [0, 'Hello my ']
            - [1, 'Lua world']
            ...
            tarantool> tmp = ''
            ---
            ...
            tarantool> for k, v in s:pairs() do
                     >   tmp = tmp .. v[2]
                     > end
            ---
            ...
            tarantool> tmp
            ---
            - Hello my Lua world
            ...

    .. _box_space-rename:

    .. method:: rename(space-name)

        Rename a space.

        :param space_object space_object: an :ref:`object reference
                                          <app_server-object_reference>`
        :param string space-name: new name for space

        :return: nil

        **Possible errors:** ``space_object`` does not exist.

        **Example:**

        .. code-block:: tarantoolsession

            tarantool> box.space.space55:rename('space56')
            ---
            ...
            tarantool> box.space.space56:rename('space55')
            ---
            ...

    .. _box_space-replace:

    .. method:: replace(tuple)
                put(tuple)

        Insert a tuple into a space. If a tuple with the same primary key already
        exists, ``box.space...:replace()`` replaces the existing tuple with a new
        one. The syntax variants ``box.space...:replace()`` and
        ``box.space...:put()`` have the same effect; the latter is sometimes used
        to show that the effect is the converse of ``box.space...:get()``.

        :param space_object space_object: an :ref:`object reference
                                          <app_server-object_reference>`
        :param table/tuple tuple: tuple to be inserted

        :return: the inserted tuple.
        :rtype:  tuple

        **Possible errors:** :errcode:`ER_TUPLE_FOUND` if a different tuple with the same unique-key
        value already exists. (This
        will only happen if there is a unique secondary index.)

        **Complexity factors:** Index size, Index type,
        Number of indexes accessed, WAL settings.

        **Example:**

        .. code-block:: lua

            box.space.tester:replace{5000, 'tuple number five thousand'}

        For more usage scenarios and typical errors see
        :ref:`Example: using data operations <box_space-operations-detailed-examples>`
        further in this section.

    .. _box_space-run_triggers:

    .. method:: run_triggers(true|false)

        At the time that a :ref:`trigger <triggers>` is defined, it is automatically enabled -
        that is, it will be executed. :ref:`Replace <box_space-on_replace>` triggers can be disabled with
        :samp:`box.space.{space-name}:run_triggers(false)` and re-enabled with
        :samp:`box.space.{space-name}:run_triggers(true)`.

        :return: nil

        **Example:**

        The following series of requests will associate an existing function named `F`
        with an existing space named `T`, associate the function a second time with the
        same space (so it will be called twice), disable all triggers of `T`, and delete
        each trigger by replacing with ``nil``.

        .. code-block:: tarantoolsession

            tarantool> box.space.T:on_replace(F)
            tarantool> box.space.T:on_replace(F)
            tarantool> box.space.T:run_triggers(false)
            tarantool> box.space.T:on_replace(nil, F)
            tarantool> box.space.T:on_replace(nil, F)

    .. _box_space-select:

    .. method:: select([key [,, options]])

        Search for a tuple or a set of tuples in the given space.

        :param space_object space_object: an :ref:`object reference
                                          <app_server-object_reference>`
        :param scalar/table          key: value to be matched against the index
                                          key, which may be multi-part.
        :param table/nil         options: none, any or all of the same options that
                                          :ref:`index_object:select <box_index-select>`
                                          allows:

                                          * ``options.iterator`` (:ref:`type of iterator <box_index-iterator-types>`)
                                          * ``options.limit`` (maximum number of tuples)
                                          * ``options.offset`` (number of tuples to skip)

        :return: the tuples whose primary-key fields are equal to the fields of
                 the passed key. If the number of passed fields is less than the
                 number of fields in the primary key, then only the passed
                 fields are compared, so ``select{1,2}`` will match a tuple
                 whose primary key is ``{1,2,3}``.
        :rtype:  array of tuples

        A ``select`` request can also be done with a specific index and index
        options, which are the subject of :ref:`index_object:select <box_index-select>`.

        **Possible errors:**

        * no such space;
        * wrong type.

        **Complexity factors:** Index size, Index type.

        **Example:**

        .. code-block:: tarantoolsession

            tarantool> s = box.schema.space.create('tmp', {temporary=true})
            ---
            ...
            tarantool> s:create_index('primary',{parts = {1,'unsigned', 2, 'string'}})
            ---
            ...
            tarantool> s:insert{1,'A'}
            ---
            - [1, 'A']
            ...
            tarantool> s:insert{1,'B'}
            ---
            - [1, 'B']
            ...
            tarantool> s:insert{1,'C'}
            ---
            - [1, 'C']
            ...
            tarantool> s:insert{2,'D'}
            ---
            - [2, 'D']
            ...
            tarantool> -- must equal both primary-key fields
            tarantool> s:select{1,'B'}
            ---
            - - [1, 'B']
            ...
            tarantool> -- must equal only one primary-key field
            tarantool> s:select{1}
            ---
            - - [1, 'A']
              - [1, 'B']
              - [1, 'C']
            ...
            tarantool> -- must equal 0 fields, so returns all tuples
            tarantool> s:select{}
            ---
            - - [1, 'A']
              - [1, 'B']
              - [1, 'C']
              - [2, 'D']
            ...
            tarantool> -- the first field must be greater than 0, and
            tarantool> -- skip the first tuple, and return up to
            tarantool> -- 2 tuples. This example's options all
            tarantool> -- depend on index characteristics so see
            tarantool> -- more explanation in index_object:select().
            tarantool> s:select({0},{iterator='GT',offset=1,limit=2})
            ---
            - - [1, 'B']
              - [1, 'C']
            ...

        As the last request in the above example shows:
        to make complex ``select`` requests, where you can specify which
        index to search and what condition to use (for example "greater than"
        instead of "equal to") and how many tuples to return, it will be
        necessary to become familiar with :ref:`index_object:select <box_index-select>`.

        For more usage scenarios and typical errors see
        :ref:`Example: using data operations <box_space-operations-detailed-examples>`
        further in this section.

    .. _box_space-truncate:

    .. method:: truncate()

        Deletes all tuples.

        :param space_object space_object: an :ref:`object reference
                                          <app_server-object_reference>`

        **Complexity factors:** Index size, Index type, Number of tuples accessed.

        :return: nil

        The ``truncate`` method can only be called by the user who created
        the space, or from within a ``setuid`` function created by the user
        who created the space.
        Read more about `setuid` functions in the reference for
        :ref:`box.schema.func.create() <box_schema-func_create>`.

        The ``truncate`` method cannot be called from within a transaction.

        **Example:**

        .. code-block:: tarantoolsession

            tarantool> box.space.tester:truncate()
            ---
            ...
            tarantool> box.space.tester:len()
            ---
            - 0
            ...

    .. _box_space-update:

    .. method:: update(key, {{operator, field_no, value}, ...})

        Update a tuple.

        The ``update`` function supports operations on fields — assignment,
        arithmetic (if the field is numeric), cutting and pasting
        fragments of a field, deleting or inserting a field. Multiple
        operations can be combined in a single update request, and in this
        case they are performed atomically and sequentially. Each operation
        requires specification of a field number. When multiple operations
        are present, the field number for each operation is assumed to be
        relative to the most recent state of the tuple, that is, as if all
        previous operations in a multi-operation update have already been
        applied. In other words, it is always safe to merge multiple ``update``
        invocations into a single invocation, with no change in semantics.

        Possible operators are:

            * ``+`` for addition (values must be numeric)
            * ``-`` for subtraction (values must be numeric)
            * ``&`` for bitwise AND (values must be unsigned numeric)
            * ``|`` for bitwise OR (values must be unsigned numeric)
            * ``^`` for bitwise :abbr:`XOR(exclusive OR)` (values must be
              unsigned numeric)
            * ``:`` for string splice
            * ``!`` for insertion
            * ``#`` for deletion
            * ``=`` for assignment

        For ``!`` and ``=`` operations the field number can be ``-1``, meaning
        the last field in the tuple.

        :param space_object space_object: an :ref:`object reference
                                          <app_server-object_reference>`
        :param scalar/table key: primary-key field values, must be passed as a
                                 Lua table if key is multi-part
        :param string  operator: operation type represented in string
        :param number  field_no: what field the operation will apply to. The
                                 field number can be negative, meaning the
                                 position from the end of tuple.
                                 (#tuple + negative field number + 1)
        :param lua_value  value: what value will be applied

        :return: the updated tuple.
        :rtype:  tuple

        **Possible errors:** it is illegal to modify a primary-key field.

        **Complexity factors:** Index size, Index type, number of indexes
        accessed, WAL settings.

        Thus, in the instruction:

        .. code-block:: lua

            s:update(44, {{'+', 1, 55 }, {'=', 3, 'x'}})

        the primary-key value is ``44``, the operators are ``'+'`` and ``'='``
        meaning *add a value to a field and then assign a value to a field*, the
        first affected field is field ``1`` and the value which will be added to
        it is ``55``, the second affected field is field ``3`` and the value
        which will be assigned to it is ``'x'``.

        **Example:**

        Assume that initially there is a space named ``tester`` with a
        primary-key index whose type is ``unsigned``. There is one tuple, with
        ``field[1]`` = ``999`` and ``field[2]`` = ``'A'``.

        In the update: |br|
        ``box.space.tester:update(999, {{'=', 2, 'B'}})`` |br|
        The first argument is ``tester``, that is, the affected space is ``tester``.
        The second argument is ``999``, that is, the affected tuple is identified by
        primary key value = 999.
        The third argument is ``=``, that is, there is one operation —
        *assignment to a field*.
        The fourth argument is ``2``, that is, the affected field is ``field[2]``.
        The fifth argument is ``'B'``, that is, ``field[2]`` contents change to ``'B'``.
        Therefore, after this update, ``field[1]`` = ``999`` and ``field[2]`` = ``'B'``.

        In the update: |br|
        ``box.space.tester:update({999}, {{'=', 2, 'B'}})`` |br|
        the arguments are the same, except that the key is passed as a Lua table
        (inside braces). This is unnecessary when the primary key has only one
        field, but would be necessary if the primary key had more than one field.
        Therefore, after this update, ``field[1]`` = ``999`` and ``field[2]`` = ``'B'`` (no change).

        In the update: |br|
        ``box.space.tester:update({999}, {{'=', 3, 1}})`` |br|
        the arguments are the same, except that the fourth argument is ``3``,
        that is, the affected field is ``field[3]``. It is okay that, until now,
        ``field[3]`` has not existed. It gets added. Therefore, after this update,
        ``field[1]`` = ``999``, ``field[2]`` = ``'B'``, ``field[3]`` = ``1``.

        In the update: |br|
        ``box.space.tester:update({999}, {{'+', 3, 1}})`` |br|
        the arguments are the same, except that the third argument is ``'+'``,
        that is, the operation is addition rather than assignment. Since
        ``field[3]`` previously contained ``1``, this means we're adding ``1``
        to ``1``. Therefore, after this update, ``field[1]`` = ``999``,
        ``field[2]`` = ``'B'``, ``field[3]`` = ``2``.

        In the update: |br|
        ``box.space.tester:update({999}, {{'|', 3, 1}, {'=', 2, 'C'}})`` |br|
        the idea is to modify two fields at once. The formats are ``'|'`` and
        ``=``, that is, there are two operations, OR and assignment. The fourth
        and fifth arguments mean that ``field[3]`` gets OR'ed with ``1``. The
        seventh and eighth arguments mean that ``field[2]`` gets assigned ``'C'``.
        Therefore, after this update, ``field[1]`` = ``999``, ``field[2]`` = ``'C'``,
        ``field[3]`` = ``3``.

        In the update: |br|
        ``box.space.tester:update({999}, {{'#', 2, 1}, {'-', 2, 3}})`` |br|
        The idea is to delete ``field[2]``, then subtract ``3`` from ``field[3]``.
        But after the delete, there is a renumbering, so ``field[3]`` becomes
        ``field[2]`` before we subtract ``3`` from it, and that's why the
        seventh argument is ``2``, not ``3``. Therefore, after this update,
        ``field[1]`` = ``999``, ``field[2]`` = ``0``.

        In the update: |br|
        ``box.space.tester:update({999}, {{'=', 2, 'XYZ'}})`` |br|
        we're making a long string so that splice will work in the next example.
        Therefore, after this update, ``field[1]`` = ``999``, ``field[2]`` = ``'XYZ'``.

        In the update: |br|
        ``box.space.tester:update({999}, {{':', 2, 2, 1, '!!'}})`` |br|
        The third argument is ``':'``, that is, this is the example of splice.
        The fourth argument is ``2`` because the change will occur in ``field[2]``.
        The fifth argument is 2 because deletion will begin with the second byte.
        The sixth argument is 1 because the number of bytes to delete is 1.
        The seventh argument is ``'!!'``, because ``'!!'`` is to be added at this position.
        Therefore, after this update, ``field[1]`` = ``999``, ``field[2]`` = ``'X!!Z'``.

        For more usage scenarios and typical errors see
        :ref:`Example: using data operations <box_space-operations-detailed-examples>`
        further in this section.

    .. _box_space-upsert:

    .. method:: upsert({tuple}, {{operator, field_no, value}, ...}, )

        Update or insert a tuple.

        If there is an existing tuple which matches the key fields of ``tuple``, then the
        request has the same effect as :ref:`space_object:update() <box_space-update>` and the
        ``{{operator, field_no, value}, ...}`` parameter is used.
        If there is no existing tuple which matches the key fields of ``tuple``, then the
        request has the same effect as :ref:`space_object:insert() <box_space-insert>` and the
        ``{tuple}`` parameter is used. However, unlike ``insert`` or
        ``update``, ``upsert`` will not read a tuple and perform
        error checks before returning -- this is a design feature which
        enhances throughput but requires more caution on the part of the user.

        :param space_object space_object: an :ref:`object reference
                                          <app_server-object_reference>`
        :param table/tuple tuple: default tuple to be inserted, if analogue
                                  isn't found
        :param string   operator: operation type represented in string
        :param number   field_no: what field the operation will apply to. The
                                  field number can be negative, meaning the
                                  position from the end of tuple.
                                  (#tuple + negative field number + 1)
        :param lua_value   value: what value will be applied

        :return: null

        **Possible errors:**

        * It is illegal to modify a primary-key field.
        * It is illegal to use upsert with a space that has a unique secondary
          index.

        **Complexity factors:** Index size, Index type, number of indexes
        accessed, WAL settings.

        **Example:**

        .. code-block:: lua

            box.space.tester:upsert({12,'c'}, {{'=', 3, 'a'}, {'=', 4, 'b'}})

        For more usage scenarios and typical errors see
        :ref:`Example: using data operations <box_space-operations-detailed-examples>`
        further in this section.

    .. _box_space-user_defined:

    .. method:: user_defined()

        Users can define any functions they want, and associate them with spaces:
        in effect they can make their own space methods.
        They do this by:

        (1) creating a Lua function,
        (2) adding the function name to a predefined global variable which has
            type = table, and
        (3) invoking the function any time thereafter, as long as the server
            is up, by saying ``space_object:function-name([parameters])``.

        The predefined global variable is ``box.schema.space_mt``.
        Adding to ``box.schema.space_mt`` makes the method available for all spaces.

        Alternatively, user-defined methods can be made available for only one space,
        by calling ``getmetatable(space_object)`` and then adding the function name to the
        meta table. See also the example for
        :ref:`index_object:user_defined() <box_index-user_defined>`.

        :param index_object index_object: an :ref:`object reference
                                          <app_server-object_reference>`.
        :param any-type any-name: whatever the user defines

        **Example:**

        .. code-block:: lua

            -- Visible to any space, no parameters.
            -- After these requests, the value of global_variable will be 6.
            box.schema.space.create('t')
            box.space.t:create_index('i')
            global_variable = 5
            function f(space_arg) global_variable = global_variable + 1 end
            box.schema.space_mt.counter = f
            box.space.t:counter()

    .. _box_space-enabled:

    .. data:: enabled

        Whether or not this space is enabled.
        The value is ``false`` if the space has no index.

    .. _box_space-field_count:

    .. data:: field_count

        The required field count for all tuples in this space. The field_count
        can be set initially with:

        .. cssclass:: highlight
        .. parsed-literal::

            box.schema.space.create(..., {
                ... ,
                field_count = *field_count_value* ,
                ...
            })

        The default value is ``0``, which means there is no required field count.

        **Example:**

        .. code-block:: tarantoolsession

            tarantool> box.space.tester.field_count
            ---
            - 0
            ...

    .. _box_space-id:

    .. data:: id

        Ordinal space number. Spaces can be referenced by either name or
        number. Thus, if space ``tester`` has ``id = 800``, then
        ``box.space.tester:insert{0}`` and ``box.space[800]:insert{0}``
        are equivalent requests.

        **Example:**

        .. code-block:: tarantoolsession

            tarantool> box.space.tester.id
            ---
            - 512
            ...

.. _box_space-space_index:

.. data:: index

    A container for all defined indexes. There is a Lua object of type
    :ref:`box.index <box_index>` with methods to search tuples and iterate
    over them in predefined order.

    To reset, use :ref:`box.stat.reset() <box_introspection-box_stat_reset>`.

    :rtype: table

    **Example:**

    .. code-block:: tarantoolsession

        # checking the number of indexes for space 'tester'
        tarantool> local counter=0; for i=0,#box.space.tester.index do
          if box.space.tester.index[i]~=nil then counter=counter+1 end
          end; print(counter)
        1
        ---
        ...
        # checking the type of index 'primary'
        tarantool> box.space.tester.index.primary.type
        ---
        - TREE
        ...

.. _box_space-cluster:

.. data:: _cluster

    ``_cluster`` is a system space
    for support of the :ref:`replication feature <replication>`.

.. _box_space-func:

.. data:: _func

   ``_func`` is a system space with function tuples made by
   :ref:`box.schema.func.create() <box_schema-func_create>`.

   Tuples in this space contain the following fields:

   * the numeric function id, a number,
   * the function name,
   * flag,
   * a language name (optional): 'LUA' (default) or 'C'.

   The ``_func`` space does not include the function’s body.
   You continue to create Lua functions in the usual way, by saying
   ``function function_name () ... end``, without adding anything
   in the ``_func`` space. The ``_func`` space only exists for storing
   function tuples so that their names can be used within
   :ref:`grant/revoke <authentication-owners_privileges>`
   functions.

   You can:

   * Create a ``_func`` tuple with
     :ref:`box.schema.func.create() <box_schema-func_create>`,
   * Drop a ``_func`` tuple with
     :ref:`box.schema.func.drop() <box_schema-func_drop>`,
   * Check whether a ``_func`` tuple exists with
     :ref:`box.schema.func.exists() <box_schema-func_exists>`.

   **Example:**

   In the following example, we create a function named ‘f7’, put it into
   Tarantool's ``_func`` space and grant 'execute' privilege for this function
   to 'guest' user.

   .. code-block:: tarantoolsession

      tarantool> function f7()
               >  box.session.uid()
               > end
      ---
      ...
      tarantool> box.schema.func.create('f7')
      ---
      ...
      tarantool> box.schema.user.grant('guest', 'execute', 'function', 'f7')
      ---
      ...
      tarantool> box.schema.user.revoke('guest', 'execute', 'function', 'f7')
      ---
      ...

.. _box_space-index:

.. data:: _index

    ``_index`` is a system space.

    Tuples in this space contain the following fields:

    * ``id`` (= id of space),
    * ``iid`` (= index number within space),
    * ``name``,
    * ``type``,
    * ``opts`` (e.g. unique option), [``tuple-field-no``, ``tuple-field-type`` ...].

    Here is what ``_index`` contains in a typical installation:

    .. code-block:: tarantoolsession

       tarantool> box.space._index:select{}
       ---
       - - [272, 0, 'primary', 'tree', {'unique': true}, [[0, 'string']]]
         - [280, 0, 'primary', 'tree', {'unique': true}, [[0, 'unsigned']]]
         - [280, 1, 'owner', 'tree', {'unique': false}, [[1, 'unsigned']]]
         - [280, 2, 'name', 'tree', {'unique': true}, [[2, 'string']]]
         - [281, 0, 'primary', 'tree', {'unique': true}, [[0, 'unsigned']]]
         - [281, 1, 'owner', 'tree', {'unique': false}, [[1, 'unsigned']]]
         - [281, 2, 'name', 'tree', {'unique': true}, [[2, 'string']]]
         - [288, 0, 'primary', 'tree', {'unique': true}, [[0, 'unsigned'], [1, 'unsigned']]]
         - [288, 2, 'name', 'tree', {'unique': true}, [[0, 'unsigned'], [2, 'string']]]
         - [289, 0, 'primary', 'tree', {'unique': true}, [[0, 'unsigned'], [1, 'unsigned']]]
         - [289, 2, 'name', 'tree', {'unique': true}, [[0, 'unsigned'], [2, 'string']]]
         - [296, 0, 'primary', 'tree', {'unique': true}, [[0, 'unsigned']]]
         - [296, 1, 'owner', 'tree', {'unique': false}, [[1, 'unsigned']]]
         - [296, 2, 'name', 'tree', {'unique': true}, [[2, 'string']]]
       ---
       ...

.. _box_space-vindex:

.. data:: _vindex

    ``_vindex`` is a system space that represents a virtual view. The structure
    of its tuples is identical to that of :ref:`_index <box_space-index>`, but
    permissions for certain tuples are limited in accordance with user privileges.
    ``_vindex`` contains only those tuples that are accessible to the current user.
    See :ref:`Access control <authentication>` for details about user privileges.

    If the user has the full set of privileges (like 'admin'), the contents
    of ``_vindex`` match the contents of ``_index``. If the user has limited
    access, ``_vindex`` contains only tuples accessible to this user.

    .. NOTE::

       * ``_vindex`` is a system view, so it allows only read requests.

       * While the ``_index`` space requires proper access privileges, any user
         can always read from ``_vindex``.

.. _box_space-priv:

.. data:: _priv

    ``_priv`` is a system space where
    :ref:`privileges <authentication-owners_privileges>` are stored.

    Tuples in this space contain the following fields:

    * the numeric id of the user who gave the privilege ("grantor_id"),
    * the numeric id of the user who received the privilege ("grantee_id"),
    * the type of object: 'space', 'function', 'sequence' or 'universe',
    * the numeric id of the object,
    * the type of operation: "read" = 1, "write" = 2, "execute" = 4,
      "create" = 32, "drop" = 64, "alter" = 128, or
      a combination such as "read,write,execute".

    You can:

    * Grant a privilege with :ref:`box.schema.user.grant() <box_schema-user_grant>`.
    * Revoke a privilege with :ref:`box.schema.user.revoke() <box_schema-user_revoke>`.

    .. NOTE::

       * Generally, privileges are granted or revoked by the owner of the object
         (the user who created it), or by the 'admin' user.

       * Before dropping any objects or users, make sure that all their associated
         privileges have been revoked.

       * Only the :ref:`'admin' user <authentication-owners_privileges>`
         can grant privileges for the 'universe'.

       * Only the 'admin' user or the creator of a space can drop, alter, or
         truncate the space.

       * Only the 'admin' user or the creator of a user can change a different
         user’s password.

.. _box_space-vpriv:

.. data:: _vpriv

    ``_vpriv`` is a system space that represents a virtual view. The structure
    of its tuples is identical to that of :ref:`_priv <box_space-priv>`, but
    permissions for certain tuples are limited in accordance with user privileges.
    ``_vpriv`` contains only those tuples that are accessible to the current user.
    See :ref:`Access control <authentication>` for details about user privileges.

    If the user has the full set of privileges (like 'admin'), the contents
    of ``_vpriv`` match the contents of ``_priv``. If the user has limited
    access, ``_vpriv`` contains only tuples accessible to this user.

    .. NOTE::

       * ``_vpriv`` is a system view, so it allows only read requests.

       * While the ``_priv`` space requires proper access privileges, any user
         can always read from ``_vpriv``.

.. _box_space-schema:

.. data:: _schema

    ``_schema`` is a system space.

    This space contains the following tuples:

    * ``version`` tuple with version information for this Tarantool instance,
    * ``cluster`` tuple with the instance's replica set ID,
    * ``max_id`` tuple with the maximal space ID,
    * ``once...`` tuples that correspond to specific
      :ref:`box.once() <box-once>` blocks from the instance's
      :ref:`initialization file <index-init_label>`.
      The first field in these tuples contains the ``key`` value from the
      corresponding ``box.once()`` block prefixed with 'once' (e.g. `oncehello`),
      so you can easily find a tuple that corresponds to a specific
      ``box.once()`` block.

    **Example:**

    Here is what ``_schema`` contains in a typical installation (notice the
    tuples for two ``box.once()`` blocks, ``'oncebye'`` and ``'oncehello'``):

    .. code-block:: tarantoolsession

       tarantool> box.space._schema:select{}
       ---
       - - ['cluster', 'b4e15788-d962-4442-892e-d6c1dd5d13f2']
         - ['max_id', 512]
         - ['oncebye']
         - ['oncehello']
         - ['version', 1, 7, 2]

.. _box_space-sequence:

.. data:: _sequence

    ``_sequence`` is a system space
    for support of the :ref:`sequence feature <index-box_sequence>`.
    It contains persistent information that was established by
    :ref:`box.schema.sequence.create() <box_schema-sequence_create>` or
    :ref:`box.schema.sequence.alter() <box_schema-sequence_alter>`.

.. _box_space-sequence_data:

.. data:: _sequence_data

    ``_sequence_data`` is a system space
    for support of the :ref:`sequence feature <index-box_sequence>`.

    Each tuple in ``_sequence_data`` contains two fields:

    * the id of the sequence, and
    * the last value that the sequence generator returned
      (non-persistent information).

.. _box_space-space:

.. data:: _space

    ``_space`` is a system space.

    Tuples in this space contain the following fields:

    * ``id``,
    * ``owner`` (= id of user who owns the space),
    * ``name``, ``engine``, ``field_count``,
    * ``flags`` (e.g. temporary),
    * ``format`` (as made by a :ref:`format clause <box_space-format>`).

    These fields are established by :ref:`space.create()
    <box_schema-space_create>`.

    **Example #1:**

    The following function will display all simple fields in all tuples of
    ``_space``.

    .. code-block:: lua

        function example()
          local ta = {}
          local i, line
          for k, v in box.space._space:pairs() do
            i = 1
            line = ''
            while i <= #v do
              if type(v[i]) ~= 'table' then
                line = line .. v[i] .. ' '
              end
            i = i + 1
            end
            table.insert(ta, line)
          end
          return ta
        end

    Here is what ``example()`` returns in a typical installation:

    .. code-block:: tarantoolsession

        tarantool> example()
        ---
        - - '272 1 _schema memtx 0  '
          - '280 1 _space memtx 0  '
          - '281 1 _vspace sysview 0  '
          - '288 1 _index memtx 0  '
          - '296 1 _func memtx 0  '
          - '304 1 _user memtx 0  '
          - '305 1 _vuser sysview 0  '
          - '312 1 _priv memtx 0  '
          - '313 1 _vpriv sysview 0  '
          - '320 1 _cluster memtx 0  '
          - '512 1 tester memtx 0  '
          - '513 1 origin vinyl 0  '
          - '514 1 archive memtx 0  '
        ...

    **Example #2:**

    The following requests will create a space using
    ``box.schema.space.create()`` with a :ref:`format clause <box_space-format>`, then retrieve
    the ``_space`` tuple for the new space. This illustrates the typical use of
    the ``format`` clause, it shows the recommended names and data types for the
    fields.

    .. code-block:: tarantoolsession

        tarantool> box.schema.space.create('TM', {
                 >   id = 12345,
                 >   format = {
                 >     [1] = {["name"] = "field_1"},
                 >     [2] = {["type"] = "unsigned"}
                 >   }
                 > })
        ---
        - index: []
          on_replace: 'function: 0x41c67338'
          temporary: false
          id: 12345
          engine: memtx
          enabled: false
          name: TM
          field_count: 0
        - created
        ...
        tarantool> box.space._space:select(12345)
        ---
        - - [12345, 1, 'TM', 'memtx', 0, {}, [{'name': 'field_1'}, {'type': 'unsigned'}]]
        ...

.. _box_space-vspace:

.. data:: _vspace

    ``_vspace`` is a system space that represents a virtual view. The structure
    of its tuples is identical to that of :ref:`_space <box_space-space>`, but
    permissions for certain tuples are limited in accordance with user privileges.
    ``_vspace`` contains only those tuples that are accessible to the current user.
    See :ref:`Access control <authentication>` for details about user privileges.

    If the user has the full set of privileges (like 'admin'), the contents
    of ``_vspace`` match the contents of ``_space``. If the user has limited
    access, ``_vspace`` contains only tuples accessible to this user.

    .. NOTE::

       * ``_vspace`` is a system view, so it allows only read requests.

       * While the ``_space`` space requires proper access privileges, any user
         can always read from ``_vspace``.

.. _box_space-user:

.. data:: _user

    ``_user`` is a system space where user-names and password hashes are stored.

    Tuples in this space contain the following fields:

    * the numeric id of the tuple ("id"),
    * the numeric id of the tuple’s creator,
    * the name,
    * the type: 'user' or 'role',
    * optional password.

    There are five special tuples in the ``_user`` space: 'guest', 'admin',
    'public', 'replication', and 'super'.

    .. container:: table

        .. rst-class:: left-align-column-1
        .. rst-class:: right-align-column-2
        .. rst-class:: left-align-column-3
        .. rst-class:: left-align-column-4

        .. tabularcolumns:: |\Y{0.2}|\Y{0.1}|\Y{0.1}|\Y{0.6}|

        +-------------+----+------+----------------------------------------------------------------+
        | Name        | ID | Type | Description                                                    |
        +=============+====+======+================================================================+
        | guest       | 0  | user | Default user when connecting remotely.                         |
        |             |    |      | Usually an untrusted user with few privileges.                 |
        +-------------+----+------+----------------------------------------------------------------+
        | admin       | 1  | user | Default user when using Tarantool as a console.                |
        |             |    |      | Usually an                                                     |
        |             |    |      | :ref:`administrative user <authentication-owners_privileges>`  |
        |             |    |      | with all privileges.                                           |
        +-------------+----+------+----------------------------------------------------------------+
        | public      | 2  | role | Pre-defined :ref:`role <authentication-roles>`,                |
        |             |    |      | automatically granted to new users when they are               |
        |             |    |      | created with                                                   |
        |             |    |      | ``box.schema.user.create(user-name)``.                         |
        |             |    |      | Therefore a convenient way to grant 'read' on space            |
        |             |    |      | 't' to every user that will ever exist is with                 |
        |             |    |      | ``box.schema.role.grant('public','read','space','t')``.        |
        +-------------+----+------+----------------------------------------------------------------+
        | replication | 3  | role | Pre-defined :ref:`role <authentication-roles>`,                |
        |             |    |      | which the 'admin' user can grant to users who need to use      |
        |             |    |      | :ref:`replication <replication>` features.                     |
        +-------------+----+------+----------------------------------------------------------------+
        | super       | 31 | role | Pre-defined :ref:`role <authentication-roles>`,                |
        |             |    |      | which the 'admin' user can grant to users who need all         |
        |             |    |      | privileges on all objects.                                     |
        |             |    |      | The 'super' role has these privileges on                       |
        |             |    |      | 'universe':                                                    |
        |             |    |      | read, write, execute, create, drop, alter.                     |
        +-------------+----+------+----------------------------------------------------------------+

    To select a tuple from the ``_user`` space, use ``box.space._user:select()``.
    For example, here is what happens with a select for user id = 0, which is
    the 'guest' user, which by default has no password:

    .. code-block:: tarantoolsession

        tarantool> box.space._user:select{0}
        ---
        - - [0, 1, 'guest', 'user']
        ...

    .. WARNING::

       To change tuples in the ``_user`` space, do not use ordinary ``box.space``
       functions for insert or update or delete. The ``_user`` space is special,
       so there are special functions which have appropriate error checking.

    To create a new user, use :ref:`box.schema.user.create() <box_schema-user_create>`:

    .. cssclass:: highlight
    .. parsed-literal::

        box.schema.user.create(*user-name*)
        box.schema.user.create(*user-name*, {if_not_exists = true})
        box.schema.user.create(*user-name*, {password = *password*})

    To change the user's password, use :ref:`box.schema.user.password() <box_schema-user_password>`:

    .. cssclass:: highlight
    .. parsed-literal::

        -- To change the current user's password
        box.schema.user.passwd(*password*)

        -- To change a different user's password
        -- (usually only 'admin' can do it)
        box.schema.user.passwd(*user-name*, *password*)

    To drop a user, use :ref:`box.schema.user.drop() <box_schema-user_drop>`:

    .. cssclass:: highlight
    .. parsed-literal::

        box.schema.user.drop(*user-name*)

    To check whether a user exists, use :ref:`box.schema.user.exists() <box_schema-user_exists>`,
    which returns ``true`` or ``false``:

    .. cssclass:: highlight
    .. parsed-literal::

        box.schema.user.exists(*user-name*)

    To find what privileges a user has, use :ref:`box.schema.user.info() <box_schema-user_info>`:

    .. cssclass:: highlight
    .. parsed-literal::

        box.schema.user.info(*user-name*)

    .. NOTE::

        The maximum number of users is 32.

    **Example:**

    Here is a session which creates a new user with a strong password, selects a
    tuple in the ``_user`` space, and then drops the user.

    .. code-block:: tarantoolsession

        tarantool> box.schema.user.create('JeanMartin', {password = 'Iwtso_6_os$$'})
        ---
        ...
        tarantool> box.space._user.index.name:select{'JeanMartin'}
        ---
        - - [17, 1, 'JeanMartin', 'user', {'chap-sha1': 't3xjUpQdrt857O+YRvGbMY5py8Q='}]
        ...
        tarantool> box.schema.user.drop('JeanMartin')
        ---
        ...

=============================================================================
Example: using box.space functions to read _space tuples
=============================================================================

This function will illustrate how to look at all the spaces, and for each
display: approximately how many tuples it contains, and the first field of
its first tuple. The function uses Tarantool ``box.space`` functions ``len()``
and ``pairs()``. The iteration through the spaces is coded as a scan of the
``_space`` system space, which contains metadata. The third field in
``_space`` contains the space name, so the key instruction
``space_name = v[3]`` means ``space_name`` is the ``space_name`` field in
the tuple of ``_space`` that we've just fetched with ``pairs()``. The function
returns a table:

.. code-block:: lua

    function example()
      local tuple_count, space_name, line
      local ta = {}
      for k, v in box.space._space:pairs() do
        space_name = v[3]
        if box.space[space_name].index[0] ~= nil then
          tuple_count = '1 or more'
        else
          tuple_count = '0'
        end
        line = space_name .. ' tuple_count =' .. tuple_count
        if tuple_count == '1 or more' then
          for k1, v1 in box.space[space_name]:pairs() do
            line = line .. '. first field in first tuple = ' .. v1[1]
            break
          end
        end
        table.insert(ta, line)
      end
      return ta
    end

And here is what happens when one invokes the function:

.. code-block:: tarantoolsession

    tarantool> example()
    ---
    - - _schema tuple_count =1 or more. first field in first tuple = cluster
      - _space tuple_count =1 or more. first field in first tuple = 272
      - _vspace tuple_count =1 or more. first field in first tuple = 272
      - _index tuple_count =1 or more. first field in first tuple = 272
      - _vindex tuple_count =1 or more. first field in first tuple = 272
      - _func tuple_count =1 or more. first field in first tuple = 1
      - _vfunc tuple_count =1 or more. first field in first tuple = 1
      - _user tuple_count =1 or more. first field in first tuple = 0
      - _vuser tuple_count =1 or more. first field in first tuple = 0
      - _priv tuple_count =1 or more. first field in first tuple = 1
      - _vpriv tuple_count =1 or more. first field in first tuple = 1
      - _cluster tuple_count =1 or more. first field in first tuple = 1
    ...

===========================================================================
Example: using box.space functions to organize a _space tuple
===========================================================================

The objective is to display field names and field types of a system space --
using metadata to find metadata.

To begin: how can one select the ``_space`` tuple that describes ``_space``?

A simple way is to look at the constants in ``box.schema``,
which tell us that there is an item named SPACE_ID == 288,
so these statements will retrieve the correct tuple:

.. code-block:: lua

    box.space._space:select{ 288 }
    -- or --
    box.space._space:select{ box.schema.SPACE_ID }

Another way is to look at the tuples in ``box.space._index``,
which tell us that there is a secondary index named 'name' for space
number 288, so this statement also will retrieve the correct tuple:

.. code-block:: lua

    box.space._space.index.name:select{ '_space' }

However, the retrieved tuple is not easy to read:

.. code-block:: tarantoolsession

    tarantool> box.space._space.index.name:select{'_space'}
    ---
    - - [280, 1, '_space', 'memtx', 0, {}, [{'name': 'id', 'type': 'num'}, {'name': 'owner',
            'type': 'num'}, {'name': 'name', 'type': 'str'}, {'name': 'engine', 'type': 'str'},
          {'name': 'field_count', 'type': 'num'}, {'name': 'flags', 'type': 'str'}, {
            'name': 'format', 'type': '*'}]]
    ...

It looks disorganized because field number 7 has been formatted with recommended
names and data types. How can one get those specific sub-fields? Since it's
visible that field number 7 is an array of maps, this `for` loop will do the
organizing:

.. code-block:: tarantoolsession

    tarantool> do
             >   local tuple_of_space = box.space._space.index.name:get{'_space'}
             >   for _, field in ipairs(tuple_of_space[7]) do
             >     print(field.name .. ', ' .. field.type)
             >   end
             > end
    id, num
    owner, num
    name, str
    engine, str
    field_count, num
    flags, str
    format, *
    ---
    ...

.. _box_space-vuser:

.. data:: _vuser

    ``_vuser`` is a system space that represents a virtual view. The structure
    of its tuples is identical to that of :ref:`_user <box_space-user>`, but
    permissions for certain tuples are limited in accordance with user privileges.
    ``_vuser`` contains only those tuples that are accessible to the current user.
    See :ref:`Access control <authentication>` for details about user privileges.

    If the user has the full set of privileges (like 'admin'), the contents
    of ``_vuser`` match the contents of ``_user``. If the user has limited
    access, ``_vuser`` contains only tuples accessible to this user.

    To see how ``_vuser`` works,
    :ref:`connect to a Tarantool database remotely <connecting-remotely>`
    via ``tarantoolctl`` and select all tuples from the ``_user``
    space, both when the 'guest' user *is* and *is not* allowed to read from the
    database.

    First, start Tarantool and grant the 'guest' user with read, write and execute
    privileges:

    .. code-block:: tarantoolsession

        tarantool> box.cfg{listen = 3301}
        ---
        ...
        tarantool> box.schema.user.grant('guest', 'read,write,execute', 'universe')
        ---
        ...

    Switch to the other terminal, connect to the Tarantool instance and select all
    tuples from the ``_user`` space:

    .. code-block:: tarantoolsession

        $ tarantoolctl connect 3301
        localhost:3301> box.space._user:select{}
        ---
        - - [0, 1, 'guest', 'user', {}]
          - [1, 1, 'admin', 'user', {}]
          - [2, 1, 'public', 'role', {}]
          - [3, 1, 'replication', 'role', {}]
          - [31, 1, 'super', 'role', {}]
        ...

    This result contains the same set of users as if you made the request from your
    Tarantool instance as 'admin'.

    Switch to the first terminal and revoke the read privileges from the 'guest' user:

    .. code-block:: tarantoolsession

        tarantool> box.schema.user.revoke('guest', 'read', 'universe')
        ---
        ...

    Switch to the other terminal, stop the session (to stop ``tarantoolctl``, type Ctrl+C
    or Ctrl+D) and repeat the ``box.space._user:select{}`` request. The access is
    denied:

    .. code-block:: tarantoolsession

        $ tarantoolctl connect 3301
        localhost:3301> box.space._user:select{}
        ---
        - error: Read access to space '_user' is denied for user 'guest'
        ...

    However, if you select from ``_vuser`` instead, the users' data available for the
    'guest' user is displayed:

    .. code-block:: tarantoolsession

        localhost:3301> box.space._vuser:select{}
        ---
        - - [0, 1, 'guest', 'user', {}]
        ...

    .. NOTE::

        * ``_vuser`` is a system view, so it allows only read requests.
        * While the ``_user`` space requires proper access privileges, any user
          can always read from ``_vuser``.

.. _box_space-operations-detailed-examples:

===============================================================================
Example: using data operations
===============================================================================

This example demonstrates all legal scenarios -- as well as typical errors --
for each :ref:`data operation <index-box_data-operations>` in Tarantool:
:ref:`INSERT <box_space-operations-insert>`,
:ref:`DELETE <box_space-operations-delete>`,
:ref:`UPDATE <box_space-operations-update>`,
:ref:`UPSERT <box_space-operations-upsert>`,
:ref:`REPLACE <box_space-operations-replace>`, and
:ref:`SELECT <box_space-operations-select>`.

.. code-block:: lua

    -- Bootstrap the database --
    box.cfg{}
    format = {}
    format[1] = {'field1', 'unsigned'}
    format[2] = {'field2', 'unsigned'}
    format[3] = {'field3', 'unsigned'}
    s = box.schema.create_space('test', {format = format})
    -- Create a primary index --
    pk = s:create_index('pk', {parts = {{'field1'}}})
    -- Create a unique secondary index --
    sk_uniq = s:create_index('sk_uniq', {parts = {{'field2'}}})
    -- Create a non-unique secondary index --
    sk_non_uniq = s:create_index('sk_non_uniq', {parts = {{'field3'}}, unique = false})

.. _box_space-operations-insert:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
INSERT
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

``insert`` accepts a well-formatted tuple and checks all keys for duplicates.

.. code-block:: tarantoolsession

    tarantool> -- Unique indexes: ok --
    tarantool> s:insert({1, 1, 1})
    ---
    - [1, 1, 1]
    ...
    tarantool> -- Conflicting primary key: error --
    tarantool> s:insert({1, 1, 1})
    ---
    - error: Duplicate key exists in unique index 'pk' in space 'test'
    ...
    tarantool> -- Conflicting unique secondary key: error --
    tarantool> s:insert({2, 1, 1})
    ---
    - error: Duplicate key exists in unique index 'sk_uniq' in space 'test'
    ...
    tarantool> -- Key {1} exists in sk_non_uniq index, but it is not unique: ok --
    tarantool> s:insert({2, 2, 1})
    ---
    - [2, 2, 1]
    ...
    tarantool> s:truncate()
    ---
    ...

.. _box_space-operations-delete:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
DELETE
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

``delete`` accepts a full key of any unique index.

``space:delete`` is an alias for "delete by primary key".

.. code-block:: tarantoolsession

    tarantool> -- Insert some test data --
    tarantool> s:insert{3, 4, 5}
    ---
    - [3, 4, 5]
    ...
    tarantool> s:insert{6, 7, 8}
    ---
    - [6, 7, 8]
    ...
    tarantool> s:insert{9, 10, 11}
    ---
    - [9, 10, 11]
    ...
    tarantool> s:insert{12, 13, 14}
    ---
    - [12, 13, 14]
    ...
    tarantool> -- Nothing done here: no {4} key in pk index --
    tarantool> s:delete{4}
    ---
    ...
    tarantool> s:select{}
    ---
    - - [3, 4, 5]
      - [6, 7, 8]
      - [9, 10, 11]
      - [12, 13, 14]
    ...
    tarantool> -- Delete by a primary key: ok --
    tarantool> s:delete{3}
    ---
    - [3, 4, 5]
    ...
    tarantool> s:select{}
    ---
    - - [6, 7, 8]
      - [9, 10, 11]
      - [12, 13, 14]
    ...
    tarantool> -- Explicitly delete by a primary key: ok --
    tarantool> s.index.pk:delete{6}
    ---
    - [6, 7, 8]
    ...
    tarantool> s:select{}
    ---
    - - [9, 10, 11]
      - [12, 13, 14]
    ...
    tarantool> -- Delete by a unique secondary key: ok --
    s.index.sk_uniq:delete{10}
    ---
    - [9, 10, 11]
    ...
    s:select{}
    ---
    - - [12, 13, 14]
    ...
    tarantool> -- Delete by a non-unique secondary index: error --
    tarantool> s.index.sk_non_uniq:delete{14}
    ---
    - error: Get() doesn't support partial keys and non-unique indexes
    ...
    tarantool> s:select{}
    ---
    - - [12, 13, 14]
    ...
    tarantool> s:truncate()
    ---
    ...

The key must be full: ``delete`` cannot work with partial keys.

.. code-block:: tarantoolsession

    tarantool> s2 = box.schema.create_space('test2')
    ---
    ...
    tarantool> pk2 = s2:create_index('pk2', {parts = {{1, 'unsigned'}, {2, 'unsigned'}}})
    ---
    ...
    tarantool> s2:insert{1, 1}
    ---
    - [1, 1]
    ...
    tarantool> -- Delete by a partial key: error --
    tarantool> s2:delete{1}
    ---
    - error: Invalid key part count in an exact match (expected 2, got 1)
    ...
    tarantool> -- Delete by a full key: ok --
    tarantool> s2:delete{1, 1}
    ---
    - [1, 1]
    ...
    tarantool> s2:select{}
    ---
    - []
    ...
    tarantool> s2:drop()
    ---
    ...

.. _box_space-operations-update:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
UPDATE
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Similarly to ``delete``, ``update`` accepts a full key of any unique index,
and also the operations to execute.

``space:update`` is an alias for "update by primary key".

.. code-block:: tarantoolsession

    tarantool> -- Insert some test data --
    tarantool> s:insert{3, 4, 5}
    ---
    - [3, 4, 5]
    ...
    tarantool> s:insert{6, 7, 8}
    ---
    - [6, 7, 8]
    ...
    tarantool> s:insert{9, 10, 11}
    ---
    - [9, 10, 11]
    ...
    tarantool> s:insert{12, 13, 14}
    ---
    - [12, 13, 14]
    ...
    tarantool> -- Nothing done here: no {4} key in pk index --
    s:update({4}, {{'=', 2, 400}})
    ---
    ...
    tarantool> s:select{}
    ---
    - - [3, 4, 5]
      - [6, 7, 8]
      - [9, 10, 11]
      - [12, 13, 14]
    ...
    tarantool> -- Update by a primary key: ok --
    tarantool> s:update({3}, {{'=', 2, 400}})
    ---
    - [3, 400, 5]
    ...
    tarantool> s:select{}
    ---
    - - [3, 400, 5]
      - [6, 7, 8]
      - [9, 10, 11]
      - [12, 13, 14]
    ...
    tarantool> -- Explicitly update by a primary key: ok --
    tarantool> s.index.pk:update({6}, {{'=', 2, 700}})
    ---
    - [6, 700, 8]
    ...
    tarantool> s:select{}
    ---
    - - [3, 400, 5]
      - [6, 700, 8]
      - [9, 10, 11]
      - [12, 13, 14]
    ...
    tarantool> -- Update by a unique secondary key: ok --
    tarantool> s.index.sk_uniq:update({10}, {{'=', 2, 1000}})
    ---
    - [9, 1000, 11]
    ...
    tarantool> s:select{}
    ---
    - - [3, 400, 5]
      - [6, 700, 8]
      - [9, 1000, 11]
      - [12, 13, 14]
    ...
    tarantool> -- Update by a non-unique secondary key: error --
    tarantool> s.index.sk_non_uniq:update({14}, {{'=', 2, 1300}})
    ---
    - error: Get() doesn't support partial keys and non-unique indexes
    ...
    tarantool> s:select{}
    ---
    - - [3, 400, 5]
      - [6, 700, 8]
      - [9, 1000, 11]
      - [12, 13, 14]
    ...
    tarantool> s:truncate()
    ---
    ...

.. _box_space-operations-upsert:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
UPSERT
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

``upsert`` accepts a well-formatted tuple and update operations.

If an old tuple is found by the primary key of the specified tuple,
then the update operations are applied to the old tuple,
and the new tuple is ignored.

If no old tuple is found, then the new tuple is inserted, and the
update operations are **ignored**.

Indexes have no ``upsert`` method - this is a method of a space.

.. code-block:: tarantoolsession

    tarantool> s.index.pk.upsert == nil
    ---
    - true
    ...
    tarantool> s.index.sk_uniq.upsert == nil
    ---
    - true
    ...
    tarantool> s.upsert ~= nil
    ---
    - true
    ...
    tarantool> -- As the first argument, upsert accepts --
    tarantool> -- a well-formatted tuple, NOT a key! --
    tarantool> s:insert{1, 2, 3}
    ---
    - [1, 2, 3]
    ...
    tarantool> s:upsert({1}, {{'=', 2, 200}})
    ---
    - error: Tuple field count 1 is less than required by space format or defined indexes
        (expected at least 3)
    ...
    tarantool> s:select{}
    ---
    - - [1, 2, 3]
    ...
    tarantool> s:delete{1}
    ---
    - [1, 2, 3]
    ...

``upsert`` turns into ``insert`` when no old tuple is found by the primary key.

.. code-block:: tarantoolsession

    tarantool> s:upsert({1, 2, 3}, {{'=', 2, 200}})
    ---
    ...
    tarantool> -- As you can see, {1, 2, 3} were inserted, --
    tarantool> -- and the update operations were not applied. --
    s:select{}
    ---
    - - [1, 2, 3]
    ...
    tarantool> -- Performing another upsert with the same primary key, --
    tarantool> -- but different values in the other fields. --
    s:upsert({1, 20, 30}, {{'=', 2, 200}})
    ---
    ...
    tarantool> -- The old tuple was found by the primary key {1} --
    tarantool> -- and update operations were applied. --
    tarantool> -- The new tuple was ignored. --
    tarantool> s:select{}
    ---
    - - [1, 200, 3]
    ...

``upsert`` searches for an old tuple by the primary index,
NOT by a secondary index. This can lead to a duplication error
if the new tuple ruins the uniqueness of a secondary index.

.. code-block:: tarantoolsession

    tarantool> s:upsert({2, 200, 3}, {{'=', 3, 300}})
    ---
    - error: Duplicate key exists in unique index 'sk_uniq' in space 'test'
    ...
    s:select{}
    ---
    - - [1, 200, 3]
    ...
    tarantool> -- But this works, when uniqueness is preserved. --
    tarantool> s:upsert({2, 0, 0}, {{'=', 3, 300}})
    ---
    ...
    tarantool> s:select{}
    ---
    - - [1, 200, 3]
      - [2, 0, 0]
    ...
    tarantool> s:truncate()
    ---
    ...

.. _box_space-operations-replace:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
REPLACE
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

``replace`` accepts a well-formatted tuple and searches for an old tuple
by the primary key of the new tuple.

If the old tuple is found, then it is deleted, and the new tuple is inserted.

If the old tuple was not found, then just the new tuple is inserted.

.. code-block:: tarantoolsession

    tarantool> s:replace{1, 2, 3}
    ---
    - [1, 2, 3]
    ...
    tarantool> s:select{}
    ---
    - - [1, 2, 3]
    ...
    tarantool> s:replace{1, 3, 4}
    ---
    - [1, 3, 4]
    ...
    tarantool> s:select{}
    ---
    - - [1, 3, 4]
    ...
    tarantool> s:truncate()
    ---
    ...

``replace`` can ruin unique constraints, like ``upsert`` does.

.. code-block:: tarantoolsession

    tarantool> s:insert{1, 1, 1}
    ---
    - [1, 1, 1]
    ...
    tarantool> s:insert{2, 2, 2}
    ---
    - [2, 2, 2]
    ...
    tarantool> -- This replace fails, because if the new tuple {1, 2, 0} replaces --
    tarantool> -- the old tuple by the primary key from 'pk' index {1, 1, 1}, --
    tarantool> -- this results in a duplicate unique secondary key in 'sk_uniq' index: --
    tarantool> -- key {2} is used both in the new tuple and in {2, 2, 2}. --
    tarantool> s:replace{1, 2, 0}
    ---
    - error: Duplicate key exists in unique index 'sk_uniq' in space 'test'
    ...
    tarantool> s:truncate()
    ---
    ...

.. _box_space-operations-select:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
SELECT
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

``select`` works with any indexes (primary/secondary) and with any keys
(unique/non-unique, full/partial).

If a key is partial, then ``select`` searches by all keys, where the prefix
matches the specified key part.

.. code-block:: tarantoolsession

    tarantool> s:insert{1, 2, 3}
    ---
    - [1, 2, 3]
    ...
    tarantool> s:insert{4, 5, 6}
    ---
    - [4, 5, 6]
    ...
    tarantool> s:insert{7, 8, 9}
    ---
    - [7, 8, 9]
    ...
    tarantool> s:insert{10, 11, 9}
    ---
    - [10, 11, 9]
    ...
    tarantool> s:select{1}
    ---
    - - [1, 2, 3]
    ...
    tarantool> s:select{}
    ---
    - - [1, 2, 3]
      - [4, 5, 6]
      - [7, 8, 9]
      - [10, 11, 9]
    ...
    tarantool> s.index.pk:select{4}
    ---
    - - [4, 5, 6]
    ...
    tarantool> s.index.sk_uniq:select{8}
    ---
    - - [7, 8, 9]
    ...
    tarantool> s.index.sk_non_uniq:select{9}
    ---
    - - [7, 8, 9]
      - [10, 11, 9]
    ...

