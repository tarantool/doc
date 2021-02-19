
================================================================================
Indexes
================================================================================

An **index** is special data structure that stores a group of key values and
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

An index definition may include identifiers of tuple fields and their expected
**types**. See allowed indexed field types in section
:ref:`Details about indexed field types <details_about_index_field_types>`.

..  NOTE::

    A recommended design pattern for a data model is to base primary keys on the
    first fields of a tuple, because this speeds up tuple comparison.

Let's look on an example where we first define the primary index (named 'primary')
based on field #1 of each tuple:

..  code-block:: tarantoolsession

    tarantool> i = s:create_index('primary', {type = 'hash', parts = {{field = 1, type = 'unsigned'}}}

The effect is that, for all tuples in space 'tester', field #1 must exist and
must contain an unsigned integer.
The index type is HASH, so values in field #1 must be unique, because keys
in HASH indexes are unique.

After that, let's define a secondary index (named 'secondary') based on field #2
of each tuple:

..  code-block:: tarantoolsession

    tarantool> i = s:create_index('secondary', {type = 'tree', parts = {field = 2, type = 'string'}})

The effect is that, for all tuples in space 'tester', field #2 must exist and
must contain a string.
The index type is TREE, so values in field #2 must not be unique, because keys
in TREE indexes may be non-unique.

Space definitions and index definitions are stored permanently in Tarantool's
system spaces :ref:`_space <box_space-space>` and :ref:`_index <box_space-index>`
(for details, see reference on :ref:`box.space <box_space>` submodule).

..  admonition:: Tip
    :class: fact

    The full information about creating an index is in section
    :doc:`/reference/reference_lua/box_space/create_index`.

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

        *   - multi-part
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

        *   - exclude_null (version 2.8+)
            - \+
            - \-
            - \-
            - \-

        *   - :doc:`iterator types </reference/reference_lua/box_index/pairs>`
            - ALL, EQ, REQ, GT, GE, LT, LE
            - ALL, EQ, GT
            - ALL, EQ, GT, GE, LT, LE, OVERLAPS, NEIGHBOR
            - ALL, EQ, BITS_ALL_SET, BITS_ANY_SET, BITS_ALL_NOT_SET

********************************************************************************
TREE indexes
********************************************************************************

The default index type is 'TREE'.
TREE indexes are provided by memtx and vinyl engines, can index unique and
non-unique values, support partial key searches, comparisons and ordered results.

This is a universal type of indexes, for most cases it will be the best choice.

Additionally, memtx engine supports HASH, RTREE and BITSET indexes.

********************************************************************************
HASH indexes
********************************************************************************

HASH indexes require unique fields and loses to TREE in almost all respects.
So we do not recommend to use it in the applications.
HASH is now present in Tarantool mainly because of backward compatibility.

Here are some tips. Do not use HASH index:

* just if you want to
* if you think that HASH is faster with no performance metering
* if you want to iterate over the data
* for primary key
* as an only index

Use HASH index:

* if it is a secondary key
* if you 100% won't need to make it non-unique
* if you really need that 2-5% performance improvement
* if you have taken measurements on your data and you see this increase in performance
* if you save every byte on tuples (HASH is a little more compact)

********************************************************************************
RTREE indexes
********************************************************************************

RTREE is a multidimensional index supporting up to 32 number of dimensions.
It is used especially for indexing spacial information, such as geographical
objects. In :ref:`this example <box_index-rtree>`
we demonstrate spacial searches via RTREE index.

RTREE index can accept two types of ``distance`` functions:
``euclid`` and ``manhattan``.

**Example:**

..  code-block:: tarantoolsession

    tarantool> box.schema.space.create('rtree_example')
    tarantool> box.space.rtree_example:create_index('primary')
    tarantool> box.space.rtree_example:create_index('rtree',{unique=false,type='RTREE', parts={2,'ARRAY'}})
    tarantool> box.space.rtree_example:insert{1, {3, 5, 9, 10}}
    tarantool> box.space.rtree_example:insert{2, {10, 11}}
    tarantool> box.space.rtree_example.index.rtree:select({4, 7, 5, 9}, {iterator = 'GT'})

The result will be:

..  code-block:: tarantoolsession

    ---
    - - [1, [3, 5, 9, 10]]
    ...

because a rectangle whose corners are at coordinates ``4,7,5,9`` is entirely
within a rectangle whose corners are at coordinates ``3,5,9,10``.

********************************************************************************
BITSET indexes
********************************************************************************

Bitset is a bit mask. You should use it when you need to search by bit masks.
This can be, for example, storing a vector of attributes and search by these attributes.

**Example 1:**

The following script shows creation and search with a BITSET index.
Notice that BITSET cannot be unique, so first a primary-key index is created,
and bit values are entered as hexadecimal literals for easier reading.

..  code-block:: tarantoolsession

    tarantool> s = box.schema.space.create('space_with_bitset')
    tarantool> s:create_index('primary_index', {
             >   parts = {1, 'string'},
             >   unique = true,
             >   type = 'TREE'
             > })
    tarantool> s:create_index('bitset_index', {
             >   parts = {2, 'unsigned'},
             >   unique = false,
             >   type = 'BITSET'
             > })
    tarantool> s:insert{'Tuple with bit value = 01', 0x01}
    tarantool> s:insert{'Tuple with bit value = 10', 0x02}
    tarantool> s:insert{'Tuple with bit value = 11', 0x03}
    tarantool> s.index.bitset_index:select(0x02, {
             >   iterator = box.index.EQ
             > })
    ---
    - - ['Tuple with bit value = 10', 2]
    ...
    tarantool> s.index.bitset_index:select(0x02, {
             >   iterator = box.index.BITS_ANY_SET
             > })
    ---
    - - ['Tuple with bit value = 10', 2]
      - ['Tuple with bit value = 11', 3]
    ...
    tarantool> s.index.bitset_index:select(0x02, {
             >   iterator = box.index.BITS_ALL_SET
             > })
    ---
    - - ['Tuple with bit value = 10', 2]
      - ['Tuple with bit value = 11', 3]
    ...
    tarantool> s.index.bitset_index:select(0x02, {
             >   iterator = box.index.BITS_ALL_NOT_SET
             > })
    ---
    - - ['Tuple with bit value = 01', 1]
    ...

**Example 2:**

..  code-block:: tarantoolsession

    tarantool> box.schema.space.create('bitset_example')
    tarantool> box.space.bitset_example:create_index('primary')
    tarantool> box.space.bitset_example:create_index('bitset',{unique=false,type='BITSET', parts={2,'unsigned'}})
    tarantool> box.space.bitset_example:insert{1,1}
    tarantool> box.space.bitset_example:insert{2,4}
    tarantool> box.space.bitset_example:insert{3,7}
    tarantool> box.space.bitset_example:insert{4,3}
    tarantool> box.space.bitset_example.index.bitset:select(2, {iterator='BITS_ANY_SET'})

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
specific to an index type, for example evaluating Boolean expressions when
traversing BITSET indexes, or going in descending order when traversing TREE indexes.

.. _index-box_index-operations:

--------------------------------------------------------------------------------
Index operations
--------------------------------------------------------------------------------

Index operations are automatic: if a data-manipulation request changes a tuple,
then it also changes the index keys defined for the tuple.

The simple index-creation operation that we've illustrated before is:

.. cssclass:: highlight
.. parsed-literal::

    :samp:`box.space.{space-name}:create_index('{index-name}')`

This creates a unique TREE index on the first field of all tuples
(often called "Field#1"), which is assumed to be numeric.

The simple SELECT request that we've illustrated before is:

.. cssclass:: highlight
.. parsed-literal::

    :extsamp:`box.space.{*{space-name}*}:select({*{value}*})`

This looks for a single tuple via the first index. Since the first index
is always unique, the maximum number of returned tuples will be: one.
You can call ``select()`` without arguments, causing all tuples to be returned.

Let's continue working with the space 'tester' created in the :ref:`"Getting
started" exercises <getting_started_db>` but first modify it:

.. code-block:: tarantoolsession

    tarantool> box.space.tester:format({
             > {name = 'id', type = 'unsigned'},
             > {name = 'band_name', type = 'string'},
             > {name = 'year', type = 'unsigned'},
             > {name = 'rate', type = 'unsigned', is_nullable=true}})
    ---
    ...

Add the rate to the tuple #1 and #2:

.. code-block:: tarantoolsession

    tarantool> box.space.tester:update(1, {{'=', 4, 5}})
    ---
    - [1, 'Roxette', 1986, 5]
    ...
    tarantool> box.space.tester:update(2, {{'=', 4, 4}})
    ---
    - [2, 'Scorpions', 2015, 4]
    ...


And insert another tuple:

.. code-block:: tarantoolsession

    tarantool> box.space.tester:insert({4, 'Roxette', 2016, 3})
    ---
    - [4, 'Roxette', 2016, 3]
    ...

**The existing SELECT variations:**

1. The search can use comparisons other than equality.

.. code-block:: tarantoolsession

    tarantool> box.space.tester:select(1, {iterator = 'GT'})
    ---
    - - [2, 'Scorpions', 2015, 4]
      - [3, 'Ace of Base', 1993]
      - [4, 'Roxette', 2016, 3]
    ...

The :ref:`comparison operators <box_index-iterator-types>` are LT, LE, EQ, REQ, GE, GT
(for "less than", "less than or equal", "equal", "reversed equal",
"greater than or equal", "greater than" respectively).
Comparisons make sense if and only if the index type is ‘TREE'.

This type of search may return more than one tuple; if so, the tuples will be
in descending order by key when the comparison operator is LT or LE or REQ,
otherwise in ascending order.

2. The search can use a secondary index.

For a primary-key search, it is optional to specify an index name.
For a secondary-key search, it is mandatory.

.. code-block:: tarantoolsession

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
    tarantool> box.space.tester.index.secondary:select({1993})
    ---
    - - [3, 'Ace of Base', 1993]
    ...

.. _partial_key_search:

3. The search may be for some key parts starting with the prefix of
   the key. Notice that partial key searches are available only in TREE indexes.

.. code-block:: tarantoolsession

    -- Create an index with three parts
    tarantool> box.space.tester:create_index('tertiary', {parts = {{field = 2, type = 'string'}, {field=3, type='unsigned'}, {field=4, type='unsigned'}}})
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
      name: tertiary
    ...
    -- Make a partial search
    tarantool> box.space.tester.index.tertiary:select({'Scorpions', 2015})
    ---
    - - [2, 'Scorpions', 2015, 4]
    ...

4. The search may be for all fields, using a table for the value:

.. code-block:: tarantoolsession

    tarantool> box.space.tester.index.tertiary:select({'Roxette', 2016, 3})
    ---
    - - [4, 'Roxette', 2016, 3]
    ...

or the search can be for one field, using a table or a scalar:

.. code-block:: tarantoolsession

    tarantool> box.space.tester.index.tertiary:select({'Roxette'})
    ---
    - - [1, 'Roxette', 1986, 5]
      - [4, 'Roxette', 2016, 3]
    ...

..  admonition:: Tip
    :class: fact

    You can add, drop, or alter the definitions at runtime, with some restrictions.
    Read more in section :ref:`index operations <index-box_index-operations>`
    and in reference for :doc:`box.index submodule </reference/reference_lua/box_index>`.