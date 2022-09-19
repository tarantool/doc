..  _concepts-data_model_indexes:
..  _index-box_index:

Indexes
=======

Basics
------

An **index** is a special data structure that stores a group of key values and
pointers. It is used for efficient manipulations with data.

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

Indexes have certain limitations. See details on page
:doc:`Limitations </book/box/limitations>`.

To create a generator for indexes, you can use a sequence object.
Learn how to do it in the :ref:`tutorial <index-box_sequence>`.

..  _index-box_indexed-field-types:

Indexed field types
-------------------

Not to be confused with :ref:`index types <index-types>` -- the types of the data structure that is an index.
See more about index types :ref:`below <index-types>`.

Indexes restrict values that Tarantool can store with MsgPack.
This is why, for example, ``'unsigned'`` and ``'integer'`` are different field types,
although in MsgPack they are both stored as integer values.
An ``'unsigned'`` index contains only *non-negative* integer values,
while an ``‘integer’`` index contains *any* integer values.

The default field type is ``'unsigned'`` and the default index type is TREE.
Although ``'nil'`` is not a legal indexed field type, indexes may contain `nil`
:ref:`as a non-default option <box_space-is_nullable>`.

To learn more about field types, check the
:ref:`Field type details <index_box_field_type_details>` section and the more elaborate
:ref:`Details about index field types <details_about_index_field_types>` in the reference.

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

.. _index-types:

Index types
-----------

An index always has a **type**. Different types are intended for different
usage scenarios.

We give an overview of index features in the following table:

..  container:: table

    ..  list-table::
        :header-rows: 1

        *   - Feature
            - TREE
            - HASH
            - RTREE
            - BITSET

        *   - unique
            - \+
            - \+
            - \-
            - \-

        *   - non-unique
            - \+
            - \-
            - \+
            - \+

        *   - :ref:`is_nullable <box_space-is_nullable>`
            - \+
            - \-
            - \-
            - \-

        *   - can be multi-part
            - \+
            - \+
            - \-
            - \-

        *   - :ref:`multikey <box_space-path_multikey>`
            - \+
            - \-
            - \-
            - \-

        *   - :ref:`partial-key search <partial_key_search>`
            - \+
            - \-
            - \-
            - \-

        *   - can be primary key
            - \+
            - \+
            - \-
            - \-

        *   - ``exclude_null`` (version 2.8+)
            - \+
            - \-
            - \-
            - \-

        *   - :doc:`iterator types </reference/reference_lua/box_index/pairs>`
            - ALL, EQ, REQ, GT, GE, LT, LE
            - ALL, EQ, GT
            - ALL, EQ, GT, GE, LT, LE, OVERLAPS, NEIGHBOR
            - ALL, EQ, BITS_ALL_SET, BITS_ANY_SET, BITS_ALL_NOT_SET

.. _indexes-tree:

TREE indexes
~~~~~~~~~~~~

The default index type is 'TREE'.
TREE indexes are provided by memtx and vinyl engines, can index unique and
non-unique values, support partial key searches, comparisons and ordered results.

This is a universal type of indexes, for most cases it will be the best choice.

Additionally, memtx engine supports HASH, RTREE and BITSET indexes.

.. _indexes-hash:

HASH indexes
~~~~~~~~~~~~

HASH indexes require unique fields and loses to TREE in almost all respects.
So we do not recommend to use it in the applications.
HASH is now present in Tarantool mainly because of backward compatibility.

Here are some tips. Do not use HASH index:

*   just if you want to
*   if you think that HASH is faster with no performance metering
*   if you want to iterate over the data
*   for primary key
*   as an only index

Use HASH index:

*   if it is a secondary key
*   if you 100% won't need to make it non-unique
*   if you have taken measurements on your data and you see an accountable
    increase in performance
*   if you save every byte on tuples (HASH is a little more compact)

.. _indexes-rtree:

RTREE indexes
~~~~~~~~~~~~~

RTREE is a multidimensional index supporting up to 20 dimensions.
It is used especially for indexing spatial information, such as geographical
objects. In :ref:`this example <box_index-rtree>` we demonstrate spatial searches
via RTREE index.

RTREE index could not be primary, and could not be unique.
The option list of this type of index may contain ``dimension`` and ``distance`` options.
The ``parts`` definition must contain the one and only part with type ``array``.
RTREE index can accept two types of ``distance`` functions: ``euclid`` and ``manhattan``.

**Example 1:**

..  code-block:: lua

    my_space = box.schema.create_space("tester")
    my_space:format({ { type = 'number', name = 'id' }, { type = 'array', name = 'content' } })
    hash_index = my_space:create_index('primary', { type = 'tree', parts = {'id'} })
    rtree_index = my_space:create_index('spatial', { type = 'RTREE', unique = false, parts = {'content'} })

Corresponding tuple field thus must be an array of 2 or 4 numbers.
2 numbers mean a point {x, y};
4 numbers mean a rectangle {x1, y1, x2, y2},
where (x1, y1) and (x2, y2) - diagonal point of the rectangle.

..  code-block:: lua

    my_space:insert{1, {1, 1}}
    my_space:insert{2, {2, 2, 3, 3}}

Selection results depend on a chosen iterator.
The default EQ iterator searches for an exact rectangle,
a point is treated as zero width and height rectangle:

..  code-block:: tarantoolsession

    tarantool> rtree_index:select{1, 1}
    ---
    - - [1, [1, 1]]
    ...

    tarantool> rtree_index:select{1, 1, 1, 1}
    ---
    - - [1, [1, 1]]
    ...

    tarantool> rtree_index:select{2, 2}
    ---
    - []
    ...

    tarantool> rtree_index:select{2, 2, 3, 3}
    ---
    - - [2, [2, 2, 3, 3]]
    ...

Iterator ALL, which is the default when no key is specified,
selects all tuples in arbitrary order:

..  code-block:: tarantoolsession

    tarantool> rtree_index:select{}
    ---
    - - [1, [1, 1]]
      - [2, [2, 2, 3, 3]]
    ...

Iterator LE (less or equal) searches for tuples with their rectangles
within a specified rectangle:

..  code-block:: tarantoolsession

    tarantool> rtree_index:select({1, 1, 2, 2}, {iterator='le'})
    ---
    - - [1, [1, 1]]
    ...

Iterator LT (less than, or strictly less) searches for tuples
with their rectangles strictly within a specified rectangle:

..  code-block:: tarantoolsession

    tarantool> rtree_index:select({0, 0, 3, 3}, {iterator = 'lt'})
    ---
    - - [1, [1, 1]]
    ...

Iterator GE searches for tuples with a specified rectangle within their rectangles:

..  code-block:: tarantoolsession

    tarantool> rtree_index:select({1, 1}, {iterator = 'ge'})
    ---
    - - [1, [1, 1]]
    ...

Iterator GT searches for tuples with a specified rectangle strictly within their rectangles:

..  code-block:: tarantoolsession

    tarantool> rtree_index:select({2.1, 2.1, 2.9, 2.9}, {iterator = 'gt'})
    ---
    - []
    ...

Iterator OVERLAPS searches for tuples with their rectangles overlapping specified rectangle:

..  code-block:: tarantoolsession

    tarantool> rtree_index:select({0, 0, 10, 2}, {iterator='overlaps'})
    ---
    - - [1, [1, 1]]
      - [2, [2, 2, 3, 3]]
    ...

Iterator NEIGHBOR searches for all tuples and orders them by distance to the specified point:

..  code-block:: tarantoolsession

    tarantool> for i=1,10 do
             >    for j=1,10 do
             >        my_space:insert{i*10+j, {i, j, i+1, j+1}}
             >    end
             > end
    ---
    ...

    tarantool> rtree_index:select({1, 1}, {iterator = 'neighbor', limit = 5})
    ---
    - - [11, [1, 1, 2, 2]]
      - [12, [1, 2, 2, 3]]
      - [21, [2, 1, 3, 2]]
      - [22, [2, 2, 3, 3]]
      - [31, [3, 1, 4, 2]]
    ...

**Example 2:**

3D, 4D and more dimensional RTREE indexes work in the same way as 2D except
that user must specify more coordinates in requests.
Here's short example of using 4D tree:

..  code-block:: tarantoolsession

    tarantool> my_space = box.schema.create_space("tester")
    tarantool> my_space:format{ { type = 'number', name = 'id' }, { type = 'array', name = 'content' } }
    tarantool> primary_index = my_space:create_index('primary', { type = 'TREE', parts = {'id'} })
    tarantool> rtree_index = my_space:create_index('spatial', { type = 'RTREE', unique = false, dimension = 4, parts = {'content'} })
    tarantool> my_space:insert{1, {1, 2, 3, 4}} -- insert 4D point
    tarantool> my_space:insert{2, {1, 1, 1, 1, 2, 2, 2, 2}} -- insert 4D box

    tarantool> rtree_index:select{1, 2, 3, 4} -- find exact point
    ---
    - - [1, [1, 2, 3, 4]]
    ...

    tarantool> rtree_index:select({0, 0, 0, 0, 3, 3, 3, 3}, {iterator = 'LE'}) -- select from 4D box
    ---
    - - [2, [1, 1, 1, 1, 2, 2, 2, 2]]
    ...

    tarantool> rtree_index:select({0, 0, 0, 0}, {iterator = 'neighbor'}) -- select neighbours
    ---
    - - [2, [1, 1, 1, 1, 2, 2, 2, 2]]
      - [1, [1, 2, 3, 4]]
    ...

..  NOTE::

    Keep in mind that select NEIGHBOR iterator with unset limits extracts
    the entire space in order of increasing distance. And there can be
    tons of data, and this can affect the performance.

    And another frequent mistake is to specify iterator type without quotes,
    in such way: ``rtree_index:select(rect, {iterator = LE})``.
    This leads to silent EQ select, because ``LE`` is undefined variable and
    treated as nil, so iterator is unset and default used.

.. _indexes-bitset:

BITSET indexes
~~~~~~~~~~~~~~

Bitset is a bit mask. You should use it when you need to search by bit masks.
This can be, for example, storing a vector of attributes and searching by these
attributes.

**Example 1:**

The following script shows creating and searching with a BITSET index.
Notice that BITSET cannot be unique, so first a primary-key index is created,
and bit values are entered as hexadecimal literals for easier reading.

..  code-block:: tarantoolsession

    tarantool> my_space = box.schema.space.create('space_with_bitset')
    tarantool> my_space:create_index('primary_index', {
             >   parts = {1, 'string'},
             >   unique = true,
             >   type = 'TREE'
             > })
    tarantool> my_space:create_index('bitset_index', {
             >   parts = {2, 'unsigned'},
             >   unique = false,
             >   type = 'BITSET'
             > })
    tarantool> my_space:insert{'Tuple with bit value = 01', 0x01}
    tarantool> my_space:insert{'Tuple with bit value = 10', 0x02}
    tarantool> my_space:insert{'Tuple with bit value = 11', 0x03}
    tarantool> my_space.index.bitset_index:select(0x02, {
             >   iterator = box.index.EQ
             > })
    ---
    - - ['Tuple with bit value = 10', 2]
    ...
    tarantool> my_space.index.bitset_index:select(0x02, {
             >   iterator = box.index.BITS_ANY_SET
             > })
    ---
    - - ['Tuple with bit value = 10', 2]
      - ['Tuple with bit value = 11', 3]
    ...
    tarantool> my_space.index.bitset_index:select(0x02, {
             >   iterator = box.index.BITS_ALL_SET
             > })
    ---
    - - ['Tuple with bit value = 10', 2]
      - ['Tuple with bit value = 11', 3]
    ...
    tarantool> my_space.index.bitset_index:select(0x02, {
             >   iterator = box.index.BITS_ALL_NOT_SET
             > })
    ---
    - - ['Tuple with bit value = 01', 1]
    ...

**Example 2:**

..  code-block:: tarantoolsession

    tarantool> box.schema.space.create('bitset_example')
    tarantool> box.space.bitset_example:create_index('primary')
    tarantool> box.space.bitset_example:create_index('bitset',{unique = false, type = 'BITSET', parts = {2,'unsigned'}})
    tarantool> box.space.bitset_example:insert{1,1}
    tarantool> box.space.bitset_example:insert{2,4}
    tarantool> box.space.bitset_example:insert{3,7}
    tarantool> box.space.bitset_example:insert{4,3}
    tarantool> box.space.bitset_example.index.bitset:select(2, {iterator = 'BITS_ANY_SET'})

The result will be:

..  code-block:: tarantoolsession

    ---
    - - [3, 7]
      - [4, 3]
    ...

because (7 AND 2) is not equal to 0, and (3 AND 2) is not equal to 0.

Additionally, there exist
:doc:`index iterator operations </reference/reference_lua/box_index/pairs>`.
They can only be used with code in Lua and C/C++. Index iterators are for
traversing indexes one key at a time, taking advantage of features that are
specific to an index type.
For example, they can be used for evaluating Boolean expressions when
traversing BITSET indexes, or for going in descending order when traversing TREE
indexes.
