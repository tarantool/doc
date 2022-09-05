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

To create a generator for indexes, you can use a sequence object.
Learn how to do it in the :ref:`tutorial <index-box_sequence>`.
