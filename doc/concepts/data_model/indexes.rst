..  _index-box_index:

Indexes
=======

Read the full information about indexes on page :doc:`Indexes </book/box/indexes>`.

Basics
------

An **index** is a group of key values and pointers.

As with spaces, you should specify the index **name** and let Tarantool
come up with a unique **numeric identifier** ("index id").

An index always has a **type**. The default index type is :ref:`TREE <indexes-tree>`.
TREE indexes are provided by all Tarantool engines, can index unique and
non-unique values, support partial key searches, comparisons, and ordered results.
Additionally, the memtx engine supports :ref:`HASH <indexes-hash>`,
:ref:`RTREE <indexes-rtree>` and :ref:`BITSET <indexes-bitset>` indexes.

An index may be **multi-part**, that is, you can declare that an index key value
is composed of two or more fields in the tuple, in any order.
For example, for an ordinary TREE index, the maximum number of parts is 255.

An index may be **unique**, that is, you can declare that it would be illegal
to have the same key value twice.

The first index defined on a space is called the **primary key index**,
and it must be unique. All other indexes are called **secondary indexes**,
and they may be non-unique.

..  _index-box_indexed-field-types:

Indexed field types
-------------------

Indexes restrict values that Tarantool can store with MsgPack.
This is why, for example, ``'unsigned'`` and ``'integer'`` are different field types,
although in MsgPack they are both stored as integer values.
An ``'unsigned'`` index contains only *non-negative* integer values,
while an ``‘integer’`` index contains *any* integer values.

Here again are the field types described in
:ref:`Field type details <index_box_field_type_details>`, and the index types they can fit in.
The default field type is ``'unsigned'`` and the default index type is TREE.
Although ``'nil'`` is not a legal indexed field type, indexes may contain `nil`
:ref:`as a non-default option <box_space-is_nullable>`.
Full information is in section
:ref:`Details about index field types <details_about_index_field_types>`.

..  container:: table

    ..  list-table::
        :header-rows: 1
        :widths: 34 33 33

        *   -   Field type name string
            -   Field type
            -   Index type
        *   -   ``'boolean'``
            -   :ref:`boolean <index-box_boolean>`
            -   :ref:`boolean <index-box_boolean>`
        *   -   ``'integer'`` (may also be called ``'int'``)
            -   :ref:`integer <index-box_integer>`, which may include unsigned values
            -   TREE or HASH
        *   -   ``'unsigned'`` (may also be called ``'uint'`` or ``'num'``, but ``'num'`` is deprecated)
            -   :ref:`unsigned <index-box_unsigned>`
            -   TREE, BITSET, or HASH
        *   -   ``'double'``
            -   :ref:`double <index-box_double>`
            -   TREE or HASH
        *   -   ``'number'``
            -   :ref:`number <index-box_number>`, which may include
                :ref:`integer <index-box_integer>`, :ref:`double <index-box_double>`,
                or :ref:`decimal <index-box_decimal>` values
            -   TREE or HASH
        *   -   ``'decimal'``
            -   :ref:`decimal <index-box_decimal>`
            -   TREE or HASH
        *   -   ``'string'`` (may also be called ``'str'``)
            -   :ref:`string <index-box_string>`
            -   TREE, BITSET, or HASH
        *   -   ``'varbinary'``
            -   :ref:`varbinary <index-box_bin>`
            -   TREE, HASH, or BITSET (since version 2.7)
        *   -   ``'uuid'``
            -   :ref:`uuid <index-box_uuid>`
            -   TREE or HASH
        *   -   ``datetime``
            -   :ref:`datetime <index-box_datetime>`
            -   TREE
        *   -   ``'array'``
            -   :ref:`array <index-box_array>`
            -   :ref:`RTREE <box_index-rtree>`
        *   -   ``'scalar'``
            -   may include :ref:`nil <index-box_nil>`,
                :ref:`boolean <index-box_boolean>`,
                :ref:`integer <index-box_integer>`,
                :ref:`unsigned <index-box_unsigned>`,
                :ref:`number <index-box_number>`,
                :ref:`decimal <index-box_decimal>`,
                :ref:`string <index-box_string>`,
                :ref:`varbinary <index-box_bin>`,
                or :ref:`uuid <index-box_uuid>` values                                     |
                |br|
                When a scalar field contains values of
                different underlying types, the key order
                is: nils, then booleans, then numbers,
                then strings, then varbinaries, then
                uuids.
            -   TREE or HASH

..  _index-box_sequence:

Sequences
---------

A **sequence** is a generator of ordered integer values.

As with spaces and indexes, you should specify the sequence **name** and let
Tarantool generate a unique numeric identifier (sequence ID).

As well, you can specify several options when creating a new sequence.
The options determine what value will be generated whenever the sequence is used.

..  _index-box_sequence-options:

Options for box.schema.sequence.create()
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

..  container:: table

    ..  list-table::
        :widths: 20 40 15 25
        :header-rows: 1

        *   -   Option name
            -   Type and meaning
            -   Default
            -   Examples
        *   -   ``start``
            -   Integer. The value to generate the first time a sequence is used
            -   1
            -   ``start=0``
        *   -   ``min``
            -   Integer. Values smaller than this cannot be generated
            -   1
            -   ``min=-1000``
        *   -   ``max``
            -   Integer. Values larger than this cannot be generated
            -   9223372036854775807
            -   ``max=0``
        *   -   ``cycle``
            -   Boolean. Whether to start again when values cannot be generated
            -   false
            -   ``cycle=true``
        *   -   ``cache``
            -   Integer. The number of values to store in a cache
            -   0
            -   ``cache=0``
        *   -   ``step``
            -   Integer. What to add to the previous generated value, when generating a new value
            -   1
            -   ``step=-1``
        *   -   ``if_not_exists``
            -   Boolean. If this is true and a sequence with this name exists already,
                ignore other options and use the existing values
            -   ``false``
            -   ``if_not_exists=true``


Once a sequence exists, it can be altered, dropped, reset, forced to generate
the next value, or associated with an index.

For an initial example, we generate a sequence named 'S'.

..  code-block:: tarantoolsession

    tarantool> box.schema.sequence.create('S',{min=5, start=5})
    ---
    - step: 1
      id: 5
      min: 5
      cache: 0
      uid: 1
      max: 9223372036854775807
      cycle: false
      name: S
      start: 5
    ...

The result shows that the new sequence has all default values,
except for the two that were specified, ``min`` and ``start``.

Then we get the next value, with the ``next()`` function.

..  code-block:: tarantoolsession

    tarantool> box.sequence.S:next()
    ---
    - 5
    ...

The result is the same as the start value. If we called ``next()``
again, we would get 6 (because the previous value plus the
step value is 6), and so on.

Then we create a new table and specify that its primary key should be
generated from the sequence.

..  code-block:: tarantoolsession

    tarantool> s=box.schema.space.create('T')
    ---
    ...
    tarantool> s:create_index('I',{sequence='S'})
    ---
    - parts:
      - type: unsigned
        is_nullable: false
        fieldno: 1
      sequence_id: 1
      id: 0
      space_id: 520
      unique: true
      type: TREE
      sequence_fieldno: 1
      name: I
    ...
    ---
    ...

Then we insert a tuple without specifying a value for the primary key.

..  code-block:: tarantoolsession

     tarantool> box.space.T:insert{nil,'other stuff'}
     ---
     - [6, 'other stuff']
     ...

The result is a new tuple where the first field has a value of 6.
This arrangement, where the system automatically generates the
values for a primary key, is sometimes called "auto-incrementing"
or "identity".

For syntax and implementation details, see the reference for
:doc:`box.schema.sequence </reference/reference_lua/box_schema_sequence>`.
