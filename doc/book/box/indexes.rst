.. _index-box_index:

--------------------------------------------------------------------------------
Indexes
--------------------------------------------------------------------------------

An **index** is a group of key values and pointers.

As with spaces, you should specify the index **name**, and let Tarantool
come up with a unique **numeric identifier** ("index id").

An index always has a **type**. The default index type is 'TREE'.
TREE indexes are provided by all Tarantool engines, can index unique and
non-unique values, support partial key searches, comparisons and ordered results.
Additionally, memtx engine supports HASH, RTREE and BITSET indexes.

An index may be **multi-part**, that is, you can declare that an index key value
is composed of two or more fields in the tuple, in any order.
For example, for an ordinary TREE index, the maximum number of parts is 255.

An index may be **unique**, that is, you can declare that it would be illegal
to have the same key value twice.

The first index defined on a space is called the **primary key index**,
and it must be unique. All other indexes are called **secondary indexes**,
and they may be non-unique.

An index definition may include identifiers of tuple fields and their expected
**types**. See allowed indexed field types
:ref:`here <index-box_indexed-field-types>`.

.. NOTE::

  A recommended design pattern for a data model is to base primary keys on the
  first fields of a tuple, because this speeds up tuple comparison.

In our example, we first defined the primary index (named 'primary') based on
field #1 of each tuple:

.. code-block:: tarantoolsession

   tarantool> i = s:create_index('primary', {type = 'hash', parts = {{field = 1, type = 'unsigned'}}}

The effect is that, for all tuples in space 'tester', field #1 must exist and
must contain an unsigned integer.
The index type is 'hash', so values in field #1 must be unique, because keys
in HASH indexes are unique.

After that, we defined a secondary index (named 'secondary') based on field #2
of each tuple:

.. code-block:: tarantoolsession

   tarantool> i = s:create_index('secondary', {type = 'tree', parts = {2, 'string'}})

The effect is that, for all tuples in space 'tester', field #2 must exist and
must contain a string.
The index type is 'tree', so values in field #2 must not be unique, because keys
in TREE indexes may be non-unique.

.. NOTE::

  Space definitions and index definitions are stored permanently in Tarantool's
  system spaces :ref:`_space <box_space-space>` and :ref:`_index <box_space-index>`
  (for details, see reference on :ref:`box.space <box_space>` submodule).

  You can add, drop, or alter the definitions at runtime, with some restrictions.
  See syntax details in reference on :ref:`box <box-module>` module.

Read more about index operations :ref:`here <index-box_index-operations>`.
