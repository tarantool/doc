.. _box_space-create_index:

===============================================================================
space_object:create_index()
===============================================================================

.. module:: box.space

.. class:: space_object

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
            tarantool> s:create_index('primary', {unique = true, parts = { {field = 1, type = 'unsigned'}, {field = 2, type = 'string'}} })
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
