
================================================================================
Indexes
================================================================================

An **index** is a special data structure that stores a group of key values and
pointers. It is used for efficient manipulations with data.

As with spaces, you should specify the index **name**, and let Tarantool
come up with a unique **numeric identifier** ("index id").

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

--------------------------------------------------------------------------------
Creating an index
--------------------------------------------------------------------------------

It is mandatory to create an index for a space before trying to insert
tuples into the space, or select tuples from the space.

The simple :doc:`index-creation </reference/reference_lua/box_space/create_index>`
operation is:

..  cssclass:: highlight
..  parsed-literal::

    :extsamp:`box.space.{**{space-name}**}:create_index('{*{index-name}*}')`

This creates a unique :ref:`TREE <indexes-tree>` index on the first field
of all tuples (often called "Field#1"), which is assumed to be numeric.

A recommended design pattern for a data model is to base primary keys on the
first fields of a tuple. This speeds up tuple comparison due to the specifics of
data storage and the way comparisons are arranged in Tarantool.

The simple :doc:`SELECT </reference/reference_lua/box_index/select>` request is:

..  cssclass:: highlight
..  parsed-literal::

    :extsamp:`box.space.{**{space-name}**}:select({*{value}*})`

This looks for a single tuple via the first index. Since the first index
is always unique, the maximum number of returned tuples will be 1.
You can call ``select()`` without arguments, and it will return all tuples.
Be careful! Using ``select()`` for huge spaces hangs your instance.

An index definition may also include identifiers of tuple fields
and their expected **types**. See allowed indexed field types in section
:ref:`Details about indexed field types <details_about_index_field_types>`:

..  cssclass:: highlight
..  parsed-literal::

    :extsamp:`box.space.{**{space-name}**}:create_index({**{index-name}**}, {type = 'tree', parts = {{field = 1, type = 'unsigned'}}}`

Space definitions and index definitions are stored permanently in Tarantool's
system spaces :ref:`_space <box_space-space>` and :ref:`_index <box_space-index>`.

..  admonition:: Tip
    :class: fact

    See full information about creating indexes, such as
    how to create a multikey index, an index using the ``path`` option, or
    how to create a functional index in our reference for
    :doc:`/reference/reference_lua/box_space/create_index`.

.. _index-box_index-operations:

--------------------------------------------------------------------------------
Index operations
--------------------------------------------------------------------------------

Index operations are automatic: if a data manipulation request changes a tuple,
then it also changes the index keys defined for the tuple.

#.  For further demonstrations let's create a sample space named ``tester`` and
    put it in a variable ``my_space``:

    ..  code-block:: tarantoolsession

        tarantool> my_space = box.schema.space.create('tester')

#.  Format the created space by specifying field names and types:

    ..  code-block:: tarantoolsession

        tarantool> my_space:format({
                 > {name = 'id', type = 'unsigned'},
                 > {name = 'band_name', type = 'string'},
                 > {name = 'year', type = 'unsigned'},
                 > {name = 'rate', type = 'unsigned', is_nullable = true}})

#.  Create the **primary** index (named ``primary``):

    ..  code-block:: tarantoolsession

        tarantool> my_space:create_index('primary', {
                 > type = 'tree',
                 > parts = {'id'}
                 > })

    This is a primary index based on the ``id`` field of each tuple.

#.  Insert some :ref:`tuples <index-box_tuple>` into the space:

    ..  code-block:: tarantoolsession

        tarantool> my_space:insert{1, 'Roxette', 1986, 1}
        tarantool> my_space:insert{2, 'Scorpions', 2015, 4}
        tarantool> my_space:insert{3, 'Ace of Base', 1993}
        tarantool> my_space:insert{4, 'Roxette', 2016, 3}

#.  Create a **secondary index**:

    ..  code-block:: tarantoolsession

        tarantool> box.space.tester:create_index('secondary', {parts = {{field=3, type='unsigned'}}})
        ---
        - unique: true
          parts:
          - type: unsigned
            is_nullable: false
            fieldno: 3
          id: 2
          space_id: 512
          type: TREE
          name: secondary
        ...

#.  Create a **multi-part index** with three parts:

    ..  code-block:: tarantoolsession

        tarantool> box.space.tester:create_index('thrine', {parts = {
                 > {field = 2, type = 'string'},
                 > {field = 3, type = 'unsigned'},
                 > {field = 4, type = 'unsigned'}
                 > }})
        ---
        - unique: true
          parts:
          - type: string
            is_nullable: false
            fieldno: 2
          - type: unsigned
            is_nullable: false
            fieldno: 3
          - type: unsigned
            is_nullable: true
            fieldno: 4
          id: 6
          space_id: 513
          type: TREE
          name: thrine
        ...

**There are the following SELECT variations:**

*   The search can use **comparisons** other than equality:

    ..  code-block:: tarantoolsession

        tarantool> box.space.tester:select(1, {iterator = 'GT'})
        ---
        - - [2, 'Scorpions', 2015, 4]
          - [3, 'Ace of Base', 1993]
          - [4, 'Roxette', 2016, 3]
        ...

    The :ref:`comparison operators <box_index-iterator-types>` are:

    *   ``LT`` for "less than"
    *   ``LE`` for "less than or equal"
    *   ``GT`` for "greater"
    *   ``GE`` for "greater than or equal" .
    *   ``EQ`` for "equal",
    *   ``REQ`` for "reversed equal"

    Value comparisons make sense if and only if the index type is TREE.
    The iterator types for other types of indexes are slightly different and work
    differently. See details in section :ref:`Iterator types <box_index-iterator-types>`.

    Note that we don't use the name of the index, which means we use primary index here.

    This type of search may return more than one tuple. The tuples will be sorted
    in descending order by key if the comparison operator is LT or LE or REQ.
    Otherwise they will be sorted in ascending order.

*   The search can use a **secondary index**.

    For a primary-key search, it is optional to specify an index name as
    was demonstrated above.
    For a secondary-key search, it is mandatory.

    ..  code-block:: tarantoolsession

        tarantool> box.space.tester.index.secondary:select({1993})
        ---
        - - [3, 'Ace of Base', 1993]
        ...

    .. _partial_key_search:

*   **Partial key search:** The search may be for some key parts starting with
    the prefix of the key. Note that partial key searches are available
    only in TREE indexes.

    ..  code-block:: tarantoolsession

        tarantool> box.space.tester.index.thrine:select({'Scorpions', 2015})
        ---
        - - [2, 'Scorpions', 2015, 4]
        ...

*   The search can be for all fields, using a table as the value:

    ..  code-block:: tarantoolsession

        tarantool> box.space.tester.index.thrine:select({'Roxette', 2016, 3})
        ---
        - - [4, 'Roxette', 2016, 3]
        ...

    or the search can be for one field, using a table or a scalar:

    ..  code-block:: tarantoolsession

        tarantool> box.space.tester.index.thrine:select({'Roxette'})
        ---
        - - [1, 'Roxette', 1986, 5]
          - [4, 'Roxette', 2016, 3]
        ...

..  admonition:: Tip
    :class: fact

    You can also add, drop, or alter the definitions at runtime, with some
    restrictions. Read more about index operations in reference for
    :doc:`box.index submodule </reference/reference_lua/box_index>`.

.. _index-types:

--------------------------------------------------------------------------------
Index types
--------------------------------------------------------------------------------

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

********************************************************************************
TREE indexes
********************************************************************************

The default index type is 'TREE'.
TREE indexes are provided by memtx and vinyl engines, can index unique and
non-unique values, support partial key searches, comparisons and ordered results.

This is a universal type of indexes, for most cases it will be the best choice.

Additionally, memtx engine supports HASH, RTREE and BITSET indexes.

.. _indexes-hash:

********************************************************************************
HASH indexes
********************************************************************************

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

********************************************************************************
RTREE indexes
********************************************************************************

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

********************************************************************************
BITSET indexes
********************************************************************************

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
