.. _box_space:

-------------------------------------------------------------------------------
                             Submodule `box.space`
-------------------------------------------------------------------------------

The ``box.space`` submodule has the data-manipulation functions ``select``,
``insert``, ``replace``, ``update``, ``upsert``, ``delete``, ``get``, ``put``.
It also has members, such as id, and whether or not a space is enabled. Submodule
source code is available in file
`src/box/lua/schema.lua <https://github.com/tarantool/tarantool/blob/1.7/src/box/lua/schema.lua>`_.

A list of all ``box.space`` functions follows, then comes a list of all
``box.space`` members.

    **The functions and members of box.space**

    .. container:: table

        .. rst-class:: left-align-column-1
        .. rst-class:: left-align-column-2

        +--------------------------------------+---------------------------------+
        | Name                                 | Use                             |
        +======================================+=================================+
        | :ref:`space_object:create_index()    | Create an index                 |
        | <box_space-create_index>`            |                                 |
        +--------------------------------------+---------------------------------+
        | :ref:`space_object:insert()          | Insert a tuple                  |
        | <box_space-insert>`                  |                                 |
        +--------------------------------------+---------------------------------+
        | :ref:`space_object:select()          | Select one or more tuples       |
        | <box_space-select>`                  |                                 |
        +--------------------------------------+---------------------------------+
        | :ref:`space_object:get()             | Select a tuple                  |
        | <box_space-get>`                     |                                 |
        +--------------------------------------+---------------------------------+
        | :ref:`space_object:drop()            | Destroy a space                 |
        | <box_space-drop>`                    |                                 |
        +--------------------------------------+---------------------------------+
        | :ref:`space_object:rename()          | Rename a space                  |
        | <box_space-rename>`                  |                                 |
        +--------------------------------------+---------------------------------+
        | :ref:`space_object:replace()         | Insert or replace a tuple       |
        | <box_space-replace>`                 |                                 |
        +--------------------------------------+---------------------------------+
        | :ref:`space_object:put()             | Insert or replace a tuple       |
        | <box_space-replace>`                 |                                 |
        +--------------------------------------+---------------------------------+
        | :ref:`space_object:update()          | Update a tuple                  |
        | <box_space-update>`                  |                                 |
        +--------------------------------------+---------------------------------+
        | :ref:`space_object:upsert()          | Update a tuple                  |
        | <box_space-upsert>`                  |                                 |
        +--------------------------------------+---------------------------------+
        | :ref:`space_object:delete()          | Delete a tuple                  |
        | <box_space-delete>`                  |                                 |
        +--------------------------------------+---------------------------------+
        | :ref:`space_object:count()           | Get count of tuples             |
        | <box_space-count>`                   |                                 |
        +--------------------------------------+---------------------------------+
        | :ref:`space_object:len()             | Get count of tuples             |
        | <box_space-len>`                     |                                 |
        +--------------------------------------+---------------------------------+
        | :ref:`space_object:truncate()        | Delete all tuples               |
        | <box_space-truncate>`                |                                 |
        +--------------------------------------+---------------------------------+
        | :ref:`space_object:auto_increment()  | Generate key + Insert a tuple   |
        | <box_space-auto_increment>`          |                                 |
        +--------------------------------------+---------------------------------+
        | :ref:`space_object:pairs()           | Prepare for iterating           |
        | <box_space-pairs>`                   |                                 |
        +--------------------------------------+---------------------------------+
        | :ref:`space_object:on_replace()      | Create a replace trigger        |
        | <box_space-on_replace>`              |                                 |
        +--------------------------------------+---------------------------------+
        | :ref:`space_object:run_triggers()    | Enable/disable a replace        |
        | <box_space-run_triggers>`            | trigger                         |
        +--------------------------------------+---------------------------------+
        | :ref:`space_object.id                | Numeric identifier of space     |
        | <box_space-id>`                      |                                 |
        +--------------------------------------+---------------------------------+
        | :ref:`space_object.enabled           | Flag, true if space is enabled  |
        | <box_space-enabled>`                 |                                 |
        +--------------------------------------+---------------------------------+
        | :ref:`space_object.field_count       | Required number of fields       |
        | <box_space-field_count>`             |                                 |
        +--------------------------------------+---------------------------------+
        | :ref:`space_object.index             | Container of space's indexes    |
        | <box_space-field_count>`             |                                 |
        +--------------------------------------+---------------------------------+
        | :ref:`box.space._schema              | (Metadata) List of schemas      |
        | <box_space-schema>`                  |                                 |
        +--------------------------------------+---------------------------------+
        | :ref:`box.space._space               | (Metadata) List of spaces       |
        | <box_space-space>`                   |                                 |
        +--------------------------------------+---------------------------------+
        | :ref:`box.space._index               | (Metadata) List of indexes      |
        | <box_space-index>`                   |                                 |
        +--------------------------------------+---------------------------------+
        | :ref:`box.space._user                | (Metadata) List of users        |
        | <box_space-user>`                    |                                 |
        +--------------------------------------+---------------------------------+
        | :ref:`box.space._priv                | (Metadata) List of privileges   |
        | <box_space-priv>`                    |                                 |
        +--------------------------------------+---------------------------------+
        | :ref:`box.space._cluster             | (Metadata) List of clusters     |
        | <box_space-cluster>`                 |                                 |
        +--------------------------------------+---------------------------------+
        | :ref:`box.space._func                | (Metadata) List of function     |
        | <box_space-func>`                    | tuples                          |
        +--------------------------------------+---------------------------------+

.. module:: box.space

.. class:: space_object

    .. _box_space-create_index:

    .. method:: create_index(index-name [, options ])

        Create an index. It is mandatory to create an index for a space
        before trying to insert tuples into it, or select tuples from it. The
        first created index, which will be used as the primary-key index, must be
        unique.

        :param space_object space_object: an :ref:`object reference
                                          <app_server-object_reference>`
        :param string index_name: name of index, which should not be a number
                                  and should not contain special characters
        :param table     options:

        :return: index object
        :rtype:  index_object

        .. container:: table

            Options for ``space_object:create_index``:

            .. rst-class:: left-align-column-1
            .. rst-class:: left-align-column-2
            .. rst-class:: left-align-column-3
            .. rst-class:: left-align-column-4

            +---------------+--------------------+-----------------------------+---------------------+
            | Name          | Effect             | Type                        | Default             |
            +===============+====================+=============================+=====================+
            | type          | type of index      | string                      | 'TREE'              |
            |               |                    | ('HASH' or 'TREE' or        |                     |
            |               |                    | 'BITSET' or 'RTREE')        |                     |
            +---------------+--------------------+-----------------------------+---------------------+
            | id            | unique identifier  | number                      | last index's id, +1 |
            +---------------+--------------------+-----------------------------+---------------------+
            | unique        | index is unique    | boolean                     | ``true``            |
            +---------------+--------------------+-----------------------------+---------------------+
            | if_not_exists | no error if        | boolean                     | ``false``           |
            |               | duplicate name     |                             |                     |
            +---------------+--------------------+-----------------------------+---------------------+
            | parts         | field-numbers  +   | {field_no, 'unsigned' or    | ``{1, 'unsigned'}`` |
            |               | types              | 'string' or 'integer' or    |                     |
            |               |                    | 'number' or 'array' or      |                     |
            |               |                    | 'scalar'}                   |                     |
            +---------------+--------------------+-----------------------------+---------------------+
            | dimension     | affects RTREE only | number                      | 2                   |
            +---------------+--------------------+-----------------------------+---------------------+
            | distance      | affects RTREE only | string ('euclid' or         | 'euclid'            |
            |               |                    | 'manhattan')                |                     |
            +---------------+--------------------+-----------------------------+---------------------+

        **Possible errors:** too many parts. Index '...' already exists. Primary key must be unique.

        .. NOTE::

            | Note re storage engine:
            | vinyl supports only the TREE index type, and vinyl secondary
              indexes must be created before tuples are inserted.

        .. code-block:: tarantoolsession

            tarantool> s = box.space.space55
            ---
            ...
            tarantool> s:create_index('primary', {unique = true, parts = {1, 'unsigned', 2, 'string'}})
            ---
            ...

    .. _details_about_index_field_types:

    Details about index field types:

    The six index field types (unsigned | string | integer | number |
    array | scalar) differ depending on what values are allowed, and
    what index types are allowed.

    * **unsigned**: unsigned integers between 0 and 18446744073709551615,
      about 18 quintillion. May also be called 'uint' or 'num', but 'num'
      is deprecated. Legal in memtx TREE or HASH indexes, and in vinyl TREE
      indexes.
    * **string**: any set of octets, up to the :ref:`maximum length
      <limitations_bytes_in_index_key>`. May also be called 'str'. Legal in
      memtx TREE or HASH or BITSET indexes, and in vinyl TREE indexes.
    * **integer**: integers between -9223372036854775808 and 18446744073709551615.
      May also be called 'int'. Legal in memtx TREE or HASH indexes, and in
      vinyl TREE indexes.
    * **number**: integers between -9223372036854775808 and 18446744073709551615,
      single-precision floating point numbers, or double-precision floating
      point numbers. Legal in memtx TREE or HASH indexes, and in vinyl TREE
      indexes.
    * **array**: array of integers between -9223372036854775808 and
      9223372036854775807. Legal in memtx RTREE indexes.
    * **scalar**: booleans (true or false), or integers between
      -9223372036854775808 and 18446744073709551615, or single-precision
      floating point numbers, or double-precison floating-point numbers, or
      strings. When there is a mix of types, the key order is: booleans, then
      numbers, then strings. Legal in memtx TREE or HASH indexes, and in vinyl
      TREE indexes.

    .. container:: table

        **Index field types to use in create_index**

        .. rst-class:: left-align-column-1
        .. rst-class:: left-align-column-2
        .. rst-class:: left-align-column-3
        .. rst-class:: left-align-column-4
        .. rst-class:: top-align-column-1

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

    .. _box_space-insert:

    .. method:: insert(tuple)

        Insert a tuple into a space.

        :param space_object space_object: an :ref:`object reference
                                          <app_server-object_reference>`
        :param tuple/table         tuple: tuple to be inserted.

        :return: the inserted tuple
        :rtype:  tuple

        **Possible errors:** If a tuple with the same unique-key value already
        exists, returns :errcode:`ER_TUPLE_FOUND`.

        **Example:**

        .. code-block:: tarantoolsession

            tarantool> box.space.tester:insert{5000,'tuple number five thousand'}
            ---
            - [5000, 'tuple number five thousand']
            ...

    .. _box_space-select:

    .. method:: select([key])

        Search for a tuple or a set of tuples in the given space.

        :param space_object space_object: an :ref:`object reference
                                          <app_server-object_reference>`
        :param scalar/table          key: value to be matched against the index
                                          key, which may be multi-part.

        :return: the tuples whose primary-key fields are equal to the fields of
                 the passed key. If the number of passed fields is less than the
                 number of fields in the primary key, then only the passed
                 fields are compared, so ``select{1,2}`` will match a tuple
                 whose primary key is ``{1,2,3}``.
        :rtype:  array of tuples

        **Possible errors:** No such space; wrong type.

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

        For examples of complex ``select`` requests, where one can specify which
        index to search and what condition to use (for example "greater than"
        instead of "equal to") and how many tuples to return, see the later
        section :ref:`index_object:select <box_index-select>`.

    .. _box_space-get:

    .. method:: get(key)

        Search for a tuple in the given space.

        :param space_object space_object: an :ref:`object reference
                                          <app_server-object_reference>`
        :param scalar/table          key: value to be matched against the index
                                          key, which may be multi-part.

        :return: the tuple whose index key matches ``key``, or ``nil``.
        :rtype:  tuple

        **Possible errors:** If space_object does not exist.

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

    .. _box_space-drop:

    .. method:: drop()

        Drop a space.

        :param space_object space_object: an :ref:`object reference
                                          <app_server-object_reference>`

        :return: nil

        **Possible errors:** If ``space_object`` does not exist.

        **Complexity factors:** Index size, Index type,
        Number of indexes accessed, WAL settings.

        **Example:**

        .. code-block:: lua

            box.space.space_that_does_not_exist:drop()

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

        **Possible errors:** If a different tuple with the same unique-key
        value already exists, returns :errcode:`ER_TUPLE_FOUND`. (This
        will only happen if there is a unique secondary index.)

        **Complexity factors:** Index size, Index type,
        Number of indexes accessed, WAL settings.

        **Example:**

        .. code-block:: lua

            box.space.tester:replace{5000, 'tuple number five thousand'}

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
        ``field[2]``` before we subtract ``3`` from it, and that's why the
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

    .. _box_space-upsert:

    .. method:: upsert(tuple_value, {{operator, field_no, value}, ...}, )

        Update or insert a tuple.

        If there is an existing tuple which matches the key fields of ``tuple_value``, then the
        request has the same effect as :ref:`space_object:update() <box_space-update>` and the
        ``{{operator, field_no, value}, ...}`` parameter is used.
        If there is no existing tuple which matches the key fields of ``tuple_value``, then the
        request has the same effect as :ref:`space_object:insert() <box_space-insert>` and the
        ``{tuple_value}`` parameter is used. However, unlike ``insert`` or
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

        **Possible errors:** it is illegal to modify a primary-key field. It is
        illegal to use upsert with a space that has a unique secondary index.

        **Complexity factors:** Index size, Index type, number of indexes
        accessed, WAL settings.

        **Example:**

        .. code-block:: lua

            box.space.tester:upsert({12,'c'}, {{'=', 3, 'a'}, {'=', 4, 'b'}})

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

        .. NOTE::

            | Note re storage engine:
            | vinyl will return ``nil``, rather than the deleted tuple.

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

    .. data:: index

        A container for all defined indexes. There is a Lua object of type
        :ref:`box.index <box_index>` with methods to search tuples and iterate over them in
        predefined order.

        :rtype: table

        **Example:**

        .. code-block:: lua

            tarantool> #box.space.tester.index
            ---
            - 1
            ...
            tarantool> box.space.tester.index.primary.type
            ---
            - TREE
            ...

    .. _box_space-count:

    .. method:: count([key], [iterator])

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

    .. _box_space-len:

    .. method:: len()

        :param space_object space_object: an :ref:`object reference
                                          <app_server-object_reference>`

        :return: Number of tuples in the space.

        **Example:**

        .. code-block:: tarantoolsession

            tarantool> box.space.tester:len()
            ---
            - 2
            ...

        .. NOTE::

            | Note re storage engine:
            | vinyl does not support ``len()``.  One possible workaround is to
              say ``#select(...)``.

    .. _box_space-truncate:

    .. method:: truncate()

        Deletes all tuples.

        :param space_object space_object: an :ref:`object reference
                                          <app_server-object_reference>`

        **Complexity factors:** Index size, Index type, Number of tuples accessed.

        :return: nil

        .. NOTE::

            Note that ``truncate`` must be called only by the user who created
            the space OR under a `setuid` function created by that user. Read
            more about `setuid` functions in reference on
            :ref:`box.schema.func.create() <box_schema-func_create>`.

        **Example:**

        .. code-block:: tarantoolsession

            tarantool> box.space.tester:truncate()
            ---
            ...
            tarantool> box.space.tester:len()
            ---
            - 0
            ...

    .. _box_space-auto_increment:

    .. method:: auto_increment(tuple)

        Insert a new tuple using an auto-increment primary key. The space
        specified by space_object must have an ``unsigned`` or ``integer`` or
        ``numeric`` primary key index of type ``TREE``. The primary-key field
        will be incremented before the insert.

        :param space_object space_object: an :ref:`object reference
                                          <app_server-object_reference>`
        :param table/tuple         tuple: tuple's fields, other than the
                                          primary-key field

        :return: the inserted tuple.
        :rtype:  tuple

        **Complexity factors:** Index size, Index type,
        Number of indexes accessed, WAL settings.

        **Possible errors:** index has wrong type or primary-key indexed field is not a number.

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

        **Possible errors:** No such space; wrong type.

        **Complexity factors:** Index size, Index type.

        For examples of complex ``pairs`` requests, where one can specify which
        index to search and what condition to use (for example "greater than"
        instead of "equal to"), see the later section :ref:`index_object:pairs
        <box_index-index_pairs>`.

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

    .. _box_space-on_replace:

    .. method:: on_replace(trigger-function [, old-trigger-function])

        Create a "replace trigger". The ``trigger-function`` will be executed
        whenever a ``replace()`` or ``insert()`` or ``update()`` or ``upsert()``
        or ``delete()`` happens to a tuple in ``<space-name>``.

        :param function     trigger-function: function which will become the
                                              trigger function
        :param function old-trigger-function: existing trigger function which
                                              will be replaced by
                                              trigger-function
        :return: nil or function list

        If the parameters are (nil, old-trigger-function-name), then the old
        trigger is deleted.

        **Example #1:**

        .. code-block:: tarantoolsession

            tarantool> function f ()
                     >   x = x + 1
                     > end
            tarantool> box.space.X:on_replace(f)

        The ``trigger-function`` can have two parameters: old tuple, new tuple.
        For example, the following code causes nil to be printed when the insert
        request is processed, and causes [1, 'Hi'] to be printed when the delete
        request is processed:

        .. code-block:: lua

            box.schema.space.create('space_1')
            box.space.space_1:create_index('space_1_index',{})
            function on_replace_function (old, new) print(old) end
            box.space.space_1:on_replace(on_replace_function)
            box.space.space_1:insert{1,'Hi'}
            box.space.space_1:delete{1}

        **Example #2:**

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

    .. _box_space-run_triggers:

    .. method:: run_triggers(true|false)

        At the time that a trigger is defined, it is automatically enabled -
        that is, it will be executed. Replace triggers can be disabled with
        :samp:`box.space.{space-name}:run_triggers(false)` and re-enabled with
        :samp:`box.space.{space-name}:run_triggers(true)`.

        :return: nil

        **Example #1:**

        The following series of requests will associate an existing function named F
        with an existing space named T, associate the function a second time with the
        same space (so it will be called twice), disable all triggers of T, and delete
        each trigger by replacing with ``nil``.

        .. code-block:: tarantoolsession

            tarantool> box.space.T:on_replace(F)
            tarantool> box.space.T:on_replace(F)
            tarantool> box.space.T:run_triggers(false)
            tarantool> box.space.T:on_replace(nil, F)
            tarantool> box.space.T:on_replace(nil, F)

        **Example #2:**

        The following series of requests will create a space, create an index, create
        a function which increments a counter, create a trigger, do two inserts, drop
        the space, and display the counter value -- which is 2, because the function
        is executed once after each insert.

        .. code-block:: tarantoolsession

            tarantool> s = box.schema.space.create('space53')
            tarantool> s:create_index('primary', {parts = {1, 'unsigned'}})
            tarantool> function replace_trigger()
                     >  replace_counter = replace_counter + 1
                     > end
            tarantool> s:on_replace(replace_trigger)
            tarantool> replace_counter = 0
            tarantool> t = s:insert{1, 'First replace'}
            tarantool> t = s:insert{2, 'Second replace'}
            tarantool> s:drop()
            tarantool> replace_counter

.. _box_space-schema:

.. data:: _schema

    ``_schema`` is a system space.

    The single tuple in this space contains the following fields:
    * ``version``,
    * ``major-version-number``,
    * ``minor-version-number``.

    **Example:**

    The following function will display all fields in all tuples of ``_schema``:

    .. code-block:: lua

        function example()
          local ta = {}
          local i, line
          for k, v in box.space._schema:pairs() do
            i = 1
            line = ''
            while i <= #v do
              line = line .. v[i] .. ' '
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
        - - 'cluster 1ec4e1f8-8f1b-4304-bb22-6c47ce0cf9c6 '
          - 'max_id 520 '
          - 'version 1 7 0 '
        ...

.. _box_space-space:

.. data:: _space

    ``_space`` is a system space.

    Tuples in this space contain the following fields:

    * ``id``,
    * ``owner`` (= id of user who owns the space),
    * ``name``, ``engine``, ``field_count``,
    * ``flags`` (e.g. temporary), ``format``.

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
    ``box.schema.space.create()`` with a ``format`` clause. Then it retrieves
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

.. _box_space-index:

.. data:: _index

    ``_index`` is a system space.

    Tuples in this space contain the following fields:
    * ``id`` (= id of space),
    * ``iid`` (= index number within space),
    * ``name``,
    * ``type``,
    * ``opts`` (e.g. unique option), [``tuple-field-no``, ``tuple-field-type`` ...].

    The following function will display all fields in all tuples of ``_index``:
    (notice that the fifth field gets special treatment as a map value and
    the sixth or later fields get special treatment as arrays):

    .. code-block:: lua

        function example()
          local ta = {}
          local i, line, value
          for k, v in box.space._index:pairs() do
            i = 1
            line = ''
             while v[i] ~= nil do
              if i < 5 then
                value = v[i]
                end
              if i == 5 then
                if v[i].unique == true then
                  value = 'true'
                  end
                end
              if i > 5 then
                value = v[i][1][1] .. ' ' .. v[i][1][2]
                end
              line = line .. value .. ' '
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
        - - '272 0 primary tree true 0 str '
          - '280 0 primary tree true 0 num '
          - '280 1 owner tree tree 1 num '
          - '280 2 name tree true 2 str '
          - '281 0 primary tree true 0 num '
          - '281 1 owner tree tree 1 num '
          - '281 2 name tree true 2 str '
          - '288 0 primary tree true 0 num '
          - '288 2 name tree true 0 num '
          - '289 0 primary tree true 0 num '
          - '289 2 name tree true 0 num '
          - '296 0 primary tree true 0 num '
          - '296 1 owner tree tree 1 num '
          - '296 2 name tree true 2 str '
          - '297 0 primary tree true 0 num '
          - '297 1 owner tree tree 1 num '
          - '297 2 name tree true 2 str '
          - '304 0 primary tree true 0 num '
          - '304 1 owner tree tree 1 num '
          - '304 2 name tree true 2 str '
          - '305 0 primary tree true 0 num '
          - '305 1 owner tree tree 1 num '
          - '305 2 name tree true 2 str '
          - '312 0 primary tree true 1 num '
          - '312 1 owner tree tree 0 num '
          - '312 2 object tree tree 2 str '
          - '313 0 primary tree true 1 num '
          - '313 1 owner tree tree 0 num '
          - '313 2 object tree tree 2 str '
          - '320 0 primary tree true 0 num '
          - '320 1 uuid tree true 1 str '
          - '512 0 primary tree true 0 num '
          - '513 0 primary tree true 0 num '
          - '516 0 primary tree true 0 STR '
        ...

.. _box_space-user:

.. data:: _user

    ``_user`` is a system space where usernames and password hashes are stored.

    Tuples in this space contain the following fields:

    * the numeric id of the tuple ("id"),
    * the numeric id of the tuple’s creator,
    * the name,
    * the type: 'user' or 'role',
    * optional password.

    There are four special tuples in the ``_user`` space: 'guest', 'admin',
    'public' and 'replication'.

    .. container:: table

        .. rst-class:: left-align-column-1
        .. rst-class:: right-align-column-2
        .. rst-class:: left-align-column-3
        .. rst-class:: left-align-column-4

        +-------------+----+------+---------------------------------------------------------+
        | Name        | ID | Type | Description                                             |
        +=============+====+======+=========================================================+
        | guest       | 0  | user | Default user when connecting remotely.                  |
        |             |    |      | Usually an untrusted user with few privileges.          |
        +-------------+----+------+---------------------------------------------------------+
        | admin       | 1  | user | Default user when using Tarantool as a console.         |
        |             |    |      | Usually an administrative user with all privileges.     |
        +-------------+----+------+---------------------------------------------------------+
        | public      | 2  | role | Pre-defined :ref:`role <authentication-roles>`,         |
        |             |    |      | automatically assigned to new users when they are       |
        |             |    |      | created with                                            |
        |             |    |      | ``box.schema.user.create(user-name)``.                  |
        |             |    |      | Therefore, a convenient way to grant 'read' on space    |
        |             |    |      | 't' to every user that will ever exist is with          |
        |             |    |      | ``box.schema.role.grant('public','read','space','t')``. |
        +-------------+----+------+---------------------------------------------------------+
        | replication | 3  | role | Pre-defined :ref:`role <authentication-roles>`,         |
        |             |    |      | assigned by the 'admin' user to users who need to use   |
        |             |    |      | :ref:`replication <index-box_replication>` features.    |
        +-------------+----+------+---------------------------------------------------------+

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

.. _box_space-priv:

.. data:: _priv

    ``_priv`` is a system space where :ref:`privileges <authentication-owners_privileges>`
    are stored.

    Tuples in this space contain the following fields:

    * the numeric id of the user who gave the privilege ("grantor_id"),
    * the numeric id of the user who received the privilege ("grantee_id"),
    * the type of object: 'space', 'function' or 'universe',
    * the numeric id of the object,
    * the type of operation: "read" = 1, "write" = 2, "execute" = 4, or
      a combination such as "read,write,execute".

    You can:

    * Grant a privilege with :ref:`box.schema.user.grant() <box_schema-user_grant>`.
    * Revoke a privilege with :ref:`box.schema.user.revoke() <box_schema-user_revoke>`.

    .. NOTE::

       * Generally, privileges are granted or revoked by the owner of the object
         (the user who created it), or by the 'admin' user.

       * Before dropping any objects or users, make sure that all their associated
         privileges have been revoked.

       * Only the 'admin' user can grant privileges for the 'universe'.

       * Except the 'admin' user, only the creator of a space can drop, alter, or
         truncate the space.

       * Except the 'admin' user, only the creator of a user can change a different
         user’s password.

.. _box_space-cluster:

.. data:: _cluster

    ``_cluster`` is a system space
    for support of the :ref:`replication feature <index-box_replication>`.

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
    function tuples so that their names can be used within grant/revoke
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

=============================================================================
          Example: use box.space functions to read _space tuples
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
          Example: use box.space functions to organize a _space tuple
===========================================================================

The objective is to display field names and field types of a system space --
using metadata to find metadata.

To begin: how can one select the _space tuple that describes _space?

A simple way is to look at the constants in box.schema,
which tell us that there is an item named SPACE_ID == 288,
so these statements will retrieve the correct tuple:

| ``box.space._space:select{ 288 }``
| or
| ``box.space._space:select{ box.schema.SPACE_ID }``

Another way is to look at the tuples in box.space._index,
which tell us that there is a secondary index named 'name' for space
number 288, so this statement also will retrieve the correct tuple:

``box.space._space.index.name:select{ '_space' }``

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
