.. _box_data_model:

================================================================================
Data model
================================================================================

This section describes how Tarantool stores values and what operations with data
it supports.

If you tried to create a database as suggested in our
:ref:`"Getting started" exercises <getting_started>`,
then your test database now looks like this:

.. image:: data_model.png

.. _index-box_space:

--------------------------------------------------------------------------------
Space
--------------------------------------------------------------------------------

A **space** -- 'tester' in our example -- is a container.

When Tarantool is being used to store data, there is always at least one space.
Each space has a unique **name** specified by the user.
Besides, each space has a unique **numeric identifier** which can be specified by
the user, but usually is assigned automatically by Tarantool.
Finally, a space always has an **engine**: *memtx* (default) -- in-memory engine,
fast but limited in size, or *vinyl* -- on-disk engine for huge data sets.

A space is a container for :ref:`tuples <index-box_tuple>`.
To be functional, it needs to have a :ref:`primary index <index-box_index>`.
It can also have secondary indexes.

.. _index-box_tuple:

--------------------------------------------------------------------------------
Tuple
--------------------------------------------------------------------------------

A **tuple** plays the same role as a “row” or a “record”, and the components of
a tuple (which we call “fields”) play the same role as a “row column” or
“record field”, except that:

* fields can be composite structures, such as arrays or maps, and
* fields don't need to have names.

Any given tuple may have any number of fields, and the fields may be of
different :ref:`types <index-box_data-types>`.
The identifier of a field is the field's number, base 1
(in Lua and other 1-based languages) or base 0 (in PHP or C/C++).
For example, ``1`` or ``0`` can be used in some contexts to refer to the first
field of a tuple.

The number of tuples in a space is unlimited.

Tuples in Tarantool are stored as
`MsgPack <https://en.wikipedia.org/wiki/MessagePack>`_ arrays.

When Tarantool returns a tuple value in the console,
by default it uses :ref:`YAML <interactive_console>` format,
for example: ``[3, 'Ace of Base', 1993]``.

.. _index-box_index:

--------------------------------------------------------------------------------
Index
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
**types** (see allowed :ref:`indexed field types <index-box_indexed-field-types>`
below).

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

   tarantool> i = s:create_index('secondary', {type = 'tree', parts = {field = 2, type = 'string'}})

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

Read more about index operations :ref:`below <index-box_index-operations>`.

.. _index-box_data-types:

--------------------------------------------------------------------------------
Data types
--------------------------------------------------------------------------------

Tarantool is both a database and an application server.
Hence a developer often deals with two type sets:
the programming language types (e.g. Lua) and
the types of the Tarantool storage format (MsgPack).

.. _index-box_lua-vs-msgpack:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Lua vs MsgPack
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. container:: table

    .. rst-class:: right-align-column-1
    .. rst-class:: left-align-column-2
    .. rst-class:: left-align-column-3
    .. rst-class:: left-align-column-4

    +-------------------+----------------------+--------------------------------+----------------------------+
    | Scalar / compound | MsgPack |nbsp| type  | Lua type                       | Example value              |
    +===================+======================+================================+============================+
    | scalar            | nil                  | "`nil`_"                       | msgpack.NULL               |
    +-------------------+----------------------+--------------------------------+----------------------------+
    | scalar            | boolean              | "`boolean`_"                   | true                       |
    +-------------------+----------------------+--------------------------------+----------------------------+
    | scalar            | string               | "`string`_"                    | 'A B C'                    |
    +-------------------+----------------------+--------------------------------+----------------------------+
    | scalar            | integer              | "`number`_"                    | 12345                      |
    +-------------------+----------------------+--------------------------------+----------------------------+
    | scalar            | double               | "`number`_"                    | 1.2345                     |
    +-------------------+----------------------+--------------------------------+----------------------------+
    | scalar            | double               | "`cdata`_"                     | 1.2345                     |
    +-------------------+----------------------+--------------------------------+----------------------------+
    | scalar            | bin                  | "`cdata`_"                     | [!!binary 3t7e]            |
    +-------------------+----------------------+--------------------------------+----------------------------+
    | scalar            | decimal              | "`cdata`_"                     | 1.2                        |
    +-------------------+----------------------+--------------------------------+----------------------------+
    | scalar            | uuid                 | "`cdata`_"                     | 12a34b5c-de67-8f90-123g-   |
    |                   |                      |                                | h4567ab8901                |
    +-------------------+----------------------+--------------------------------+----------------------------+
    | scalar            | ext                  | (converted to exact number)    | 1.2                        |
    +-------------------+----------------------+--------------------------------+----------------------------+
    | compound          | map                  | "`table`_" (with string keys)  | {'a': 5, 'b': 6}           |
    +-------------------+----------------------+--------------------------------+----------------------------+
    | compound          | array                | "`table`_" (with integer keys) | [1, 2, 3, 4, 5]            |
    +-------------------+----------------------+--------------------------------+----------------------------+
    | compound          | array                | tuple ("`cdata`_")             | [12345, 'A B C']           |
    +-------------------+----------------------+--------------------------------+----------------------------+

.. _nil: http://www.lua.org/pil/2.1.html
.. _boolean: http://www.lua.org/pil/2.2.html
.. _string: http://www.lua.org/pil/2.4.html
.. _number: http://www.lua.org/pil/2.3.html
.. _table: http://www.lua.org/pil/2.5.html
.. _cdata: http://luajit.org/ext_ffi.html#call

In Lua, a **nil** type has only one possible value, also called *nil*
(displayed as **null** on Tarantool's command line, since the output is in the
YAML format).
Nils may be compared to values of any types with == (is-equal)
or ~= (is-not-equal), but other operations will not work.
Nils may not be used in Lua tables; the workaround is to use
:ref:`msgpack.NULL <msgpack-null>`

A **boolean** is either ``true`` or ``false``.

.. _index-box_string:

A **string** is a variable-length sequence of bytes, usually represented with
alphanumeric characters inside single quotes. In both Lua and MsgPack, strings
are treated as binary data, with no attempts to determine a string's
character set or to perform any string conversion -- unless there is an optional
:ref:`collation <index-collation>`.
So, usually, string sorting and comparison are done byte-by-byte, without any special
collation rules applied.
(Example: numbers are ordered by their point on the number line, so 2345 is
greater than 500; meanwhile, strings are ordered by the encoding of the first
byte, then the encoding of the second byte, and so on, so '2345' is less than '500'.)

.. _index-box_number:

In Lua, a **number** is double-precision floating-point, but Tarantool
'number' may have both
integer and floating-point values. Tarantool will try to store a Lua number as
floating-point if the value contains a decimal point or is very large
(greater than 100 trillion = 1e14), otherwise Tarantool will store it as an integer.
To ensure that even very large numbers are stored as integers, use the
:ref:`tonumber64 <other-tonumber64>` function, or the LL (Long Long) suffix,
or the ULL (Unsigned Long Long) suffix.
Here are examples of numbers using regular notation, exponential notation,
the ULL suffix and the ``tonumber64`` function:
``-55``, ``-2.7e+20``, ``100000000000000ULL``, ``tonumber64('18446744073709551615')``.

.. _index-box_double:

The Tarantool/SQL **double** field type exists
mainly so that there will be an equivalent to Tarantool/SQL's
:ref:`DOUBLE data type <sql_data_type_double>`.
In MsgPack the storage type is MP_DOUBLE and the size of the encoded value is always 9 bytes.
In Lua, 'double' fields can only contain non-integer numeric values and
cdata values with double floating-point numbers.
To avoid using the wrong kind of values inadvertently, use
``ffi.cast()`` when searching or changing 'double' fields.
For example, instead of
:samp:`{space_object}:insert` :code:`{` :samp:`{value}` :code:`}`
say
``ffi = require('ffi') ...``
:samp:`{space_object}:insert` :code:`({ffi.cast('double',` :samp:`{value}` :code:`)})`.
Example:

.. code-block:: none

    s = box.schema.space.create('s', {format = {{'d', 'double'}}})
    s:create_index('ii')
    s:insert({1.1})
    ffi = require('ffi')
    s:insert({ffi.cast('double', 1)})
    s:insert({ffi.cast('double', tonumber('123'))})
    s:select(1.1)
    s:select({ffi.cast('double', 1)})

Arithmetic with cdata 'double' will not work reliably, so
for Lua it is better to use the 'number' type.
This warning does not apply for Tarantool/SQL because
Tarantool/SQL does
:ref:`implicit casting <sql_data_type_conversion>`.

An **ext** (extension) value is an addition by Tarantool, not part of the
formal MsgPack definition, for storage of decimal values. Values with the
decimal type are not floating-point values although they may contain decimal
points. They are exact.

A **bin** (binary) value is not directly supported by Lua but there is
a Tarantool type ``VARBINARY`` which is encoded as MessagePack binary.
For an (advanced) example showing how to insert VARBINARY into a database,
see the Cookbook Recipe for :ref:`ffi_varbinary_insert <cookbook-ffi_varbinary_insert>`.

Lua **tables** with string keys are stored as MsgPack maps;
Lua tables with integer keys starting with 1 -- as MsgPack arrays.
Nils may not be used in Lua tables; the workaround is to use
:ref:`msgpack.NULL <msgpack-null>`

A **tuple** is a light reference to a MsgPack array stored in the database.
It is a special type (cdata) to avoid conversion to a Lua table on retrieval.
A few functions may return tables with multiple tuples. For more tuple examples,
see :ref:`box.tuple <box_tuple>`.

.. NOTE::

   Tarantool uses the MsgPack format for database storage, which is variable-length.
   So, for example, the smallest number requires only one byte, but the largest number
   requires nine bytes.

Examples of insert requests with different data types:

.. code-block:: tarantoolsession

    tarantool> box.space.K:insert{1,nil,true,'A B C',12345,1.2345}
    ---
    - [1, null, true, 'A B C', 12345, 1.2345]
    ...
    tarantool> box.space.K:insert{2,{['a']=5,['b']=6}}
    ---
    - [2, {'a': 5, 'b': 6}]
    ...
    tarantool> box.space.K:insert{3,{1,2,3,4,5}}
    ---
    - [3, [1, 2, 3, 4, 5]]
    ...

.. _index-box_indexed-field-types:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Indexed field types
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Indexes restrict values which Tarantool's MsgPack may contain. This is why,
for example, 'unsigned' is a separate **indexed field type**, compared to ‘integer’
data type in MsgPack: they both store ‘integer’ values, but an 'unsigned' index
contains only *non-negative* integer values and an ‘integer’ index contains *all*
integer values.

Here is how Tarantool indexed field types correspond to MsgPack data types.

.. container:: table

    .. rst-class:: left-align-column-1
    .. rst-class:: left-align-column-2
    .. rst-class:: left-align-column-3
    .. rst-class:: left-align-column-4
    .. rst-class:: top-align-column-1

    .. tabularcolumns:: |\Y{0.2}|\Y{0.4}|\Y{0.2}|\Y{0.2}|

    +----------------------------+-----------------------------------+----------------------+--------------------+
    | Indexed field type         | MsgPack data type |br|            | Index type           | Examples           |
    |                            | (and possible values)             |                      |                    |
    +============================+===================================+======================+====================+
    | **unsigned**               | **integer**                       | TREE, BITSET or HASH | 123456             |
    | (may also be called ‘uint’ | (integer between 0 and            |                      |                    |
    | or ‘num’, but ‘num’ is     | 18446744073709551615, i.e.        |                      |                    |
    | deprecated)                | about 18 quintillion)             |                      |                    |
    +----------------------------+-----------------------------------+----------------------+--------------------+
    | **integer**                | **integer**                       | TREE or HASH         | -2^63              |
    | (may also be called ‘int’) | (integer between                  |                      |                    |
    |                            | -9223372036854775808 and          |                      |                    |
    |                            | 18446744073709551615)             |                      |                    |
    +----------------------------+-----------------------------------+----------------------+--------------------+
    | **number**                 | **integer**                       | TREE or HASH         | 1.234              |
    |                            | (integer between                  |                      |                    |
    |                            | -9223372036854775808 and          |                      | -44                |
    |                            | 18446744073709551615)             |                      |                    |
    |                            |                                   |                      | 1.447e+44          |
    |                            | **double**                        |                      |                    |
    |                            | (single-precision floating        |                      |                    |
    |                            | point number or double-precision  |                      |                    |
    |                            | floating point number)            |                      |                    |
    +----------------------------+-----------------------------------+----------------------+--------------------+
    | **double**                 | **double**                        | TREE or HASH         | 1.234              |
    +----------------------------+-----------------------------------+----------------------+--------------------+
    | **string**                 | **string**                        | TREE, BITSET or HASH | ‘A B C’            |
    | (may also be called ‘str’) | (any set of octets,               |                      |                    |
    |                            | up to the maximum length)         |                      | ‘\\65 \\66 \\67’   |
    +----------------------------+-----------------------------------+----------------------+--------------------+
    | **varbinary**              | **bin**                           | TREE or HASH         | ‘\\65 \\66 \\67’   |
    |                            | (any set of octets,               |                      |                    |
    |                            | up to the maximum length)         |                      |                    |
    +----------------------------+-----------------------------------+----------------------+--------------------+
    | **boolean**                | **bool**                          | TREE or HASH         | true               |
    |                            | (true or false)                   |                      |                    |
    +----------------------------+-----------------------------------+----------------------+--------------------+
    | **decimal**                | **ext**                           | TREE or HASH         | 1.2                |
    |                            | (extension)                       |                      |                    |
    +----------------------------+-----------------------------------+----------------------+--------------------+
    | **uuid**                   | **ext**                           | TREE or HASH         | 64d22e4d-ac92-|br| |
    |                            | (extension)                       |                      | 4a23-899a-|br|     |
    |                            |                                   |                      | e5934af5479        |
    +----------------------------+-----------------------------------+----------------------+--------------------+
    | **array**                  | **array**                         | RTREE                | {10, 11}           |
    |                            | (list of numbers representing     |                      |                    |
    |                            | points in a geometric figure)     |                      | {3, 5, 9, 10}      |
    |                            |                                   |                      |                    |
    +----------------------------+-----------------------------------+----------------------+--------------------+
    | **scalar**                 | **null**                          | TREE or HASH         | msgpack.NULL       |
    |                            |                                   |                      |                    |
    |                            | **bool**                          |                      | true               |
    |                            | (true or false)                   |                      |                    |
    |                            |                                   |                      | -1                 |
    |                            | **integer**                       |                      |                    |
    |                            | (integer between                  |                      | 1.234              |
    |                            | -9223372036854775808 and          |                      |                    |
    |                            | 18446744073709551615)             |                      | ‘’                 |
    |                            |                                   |                      |                    |
    |                            | **double**                        |                      | ‘ру’               |
    |                            | (single-precision floating        |                      |                    |
    |                            | point number or double-precision  |                      |                    |
    |                            | floating point number)            |                      |                    |
    |                            |                                   |                      |                    |
    |                            | **decimal**                       |                      |                    |
    |                            | (value returned by a function in  |                      |                    |
    |                            | the :ref:`decimal <decimal>`      |                      |                    |
    |                            | module                            |                      |                    |
    |                            |                                   |                      |                    |
    |                            | **string** (any set of octets)    |                      |                    |
    |                            |                                   |                      |                    |
    |                            | **varbinary** (any set of octets) |                      |                    |
    |                            |                                   |                      |                    |
    |                            | Note: When there is a mix of      |                      |                    |
    |                            | types, the key order is: null,    |                      |                    |
    |                            | then booleans, then numbers,      |                      |                    |
    |                            | then strings, then varbinary.     |                      |                    |
    +----------------------------+-----------------------------------+----------------------+--------------------+

.. _index-collation:

--------------------------------------------------------------------------------
Collations
--------------------------------------------------------------------------------

By default, when Tarantool compares strings, it uses what we call a
**"binary" collation**. The only consideration here is the numeric value
of each byte in the string. Therefore, if the string is encoded
with ASCII or UTF-8, then ``'A' < 'B' < 'a'``, because the encoding of 'A'
(what used to be called the "ASCII value") is 65, the encoding of
'B' is 66, and the encoding of 'a' is 98. Binary collation is best
if you prefer fast deterministic simple maintenance and searching
with Tarantool indexes.

But if you want the ordering that you see in phone books and dictionaries,
then you need Tarantool's optional collations, such as ``unicode`` and
``unicode_ci``, which allow for ``'a' < 'A' < 'B'`` and ``'a' = 'A' < 'B'``
respectively.

**The unicode and unicode_ci optional collations** use the ordering according to the
`Default Unicode Collation Element Table (DUCET) <http://unicode.org/reports/tr10/#Default_Unicode_Collation_Element_Table>`_
and the rules described in
`Unicode® Technical Standard #10 Unicode Collation Algorithm (UTS #10 UCA) <http://unicode.org/reports/tr10>`_.
The only difference between the two collations is about
`weights <https://unicode.org/reports/tr10/#Weight_Level_Defn>`_:

* ``unicode`` collation observes L1 and L2 and L3 weights (strength = 'tertiary'),
* ``unicode_ci`` collation observes only L1 weights (strength = 'primary'), so for example 'a' = 'A' = 'á' = 'Á'.

As an example, take some Russian words:

.. code-block:: text

    'ЕЛЕ'
    'елейный'
    'ёлка'
    'еловый'
    'елозить'
    'Ёлочка'
    'ёлочный'
    'ЕЛь'
    'ель'

...and show the difference in ordering and selecting by index:

* with ``unicode`` collation:

  .. code-block:: tarantoolsession

      tarantool> box.space.T:create_index('I', {parts = {{field = 1, type = 'str', collation='unicode'}}})
      ...
      tarantool> box.space.T.index.I:select()
      ---
      - - ['ЕЛЕ']
        - ['елейный']
        - ['ёлка']
        - ['еловый']
        - ['елозить']
        - ['Ёлочка']
        - ['ёлочный']
        - ['ель']
        - ['ЕЛь']
      ...
      tarantool> box.space.T.index.I:select{'ЁлКа'}
      ---
      - []
      ...

* with ``unicode_ci`` collation:

  .. code-block:: tarantoolsession

      tarantool> box.space.T:create_index('I', {parts = {{field = 1, type ='str', collation='unicode_ci'}}})
      ...
      tarantool> box.space.S.index.I:select()
      ---
      - - ['ЕЛЕ']
        - ['елейный']
        - ['ёлка']
        - ['еловый']
        - ['елозить']
        - ['Ёлочка']
        - ['ёлочный']
        - ['ЕЛь']
      ...
      tarantool> box.space.S.index.I:select{'ЁлКа'}
      ---
      - - ['ёлка']
      ...


In all, collation involves much more than these simple examples of
upper case / lower case and accented / unaccented equivalence in alphabets.
We also consider variations of the same character, non-alphabetic writing systems,
and special rules that apply for combinations of characters.

For English: use "unicode" and "unicode_ci".
For Russian: use "unicode" and "unicode_ci" (although a few Russians might
prefer the Kyrgyz collation which says Cyrillic letters 'Е' and 'Ё' are the
same with level-1 weights).
For Dutch, German (dictionary), French, Indonesian, Irish,
Italian, Lingala, Malay, Portuguese, Southern Soho, Xhosa, or Zulu:
"unicode" and "unicode_ci" will do.

**The tailored optional collations**: For other languages, Tarantool supplies tailored collations for every
modern language that has more than a million native speakers, and
for specialized situations such as the difference between dictionary
order and telephone book order.
To see a complete list say ``box.space._collation:select()``.
The tailored collation names have the form
unicode_[language code]_[strength] where language code is a standard
2-character or 3-character language abbreviation, and strength is s1
for "primary strength" (level-1 weights), s2 for "secondary", s3 for "tertiary".
Tarantool uses the same language codes as the ones in the "list of tailorable locales" on man pages of
`Ubuntu <http://manpages.ubuntu.com/manpages/bionic/man3/Unicode::Collate::Locale.3perl.html>`_ and
`Fedora <http://www.polarhome.com/service/man/?qf=Unicode%3A%3ACollate%3A%3ALocale&af=0&tf=2&of=Fedora>`_.
Charts explaining the precise differences from DUCET order are
in the
`Common Language Data Repository <https://unicode.org/cldr/charts/30/collation>`_.

.. _index-box_sequence:

--------------------------------------------------------------------------------
Sequences
--------------------------------------------------------------------------------

A **sequence** is a generator of ordered integer values.

As with spaces and indexes, you should specify the sequence **name**, and let
Tarantool come up with a unique **numeric identifier** ("sequence id").

As well, you can specify several options when creating a new sequence.
The options determine what value will be generated whenever the sequence is used.

.. _index-box_sequence-options:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Options for ``box.schema.sequence.create()``
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. container:: table

    .. rst-class:: left-align-column-1
    .. rst-class:: left-align-column-2
    .. rst-class:: left-align-column-3
    .. rst-class:: left-align-column-4
    .. rst-class:: top-align-column-1

    .. tabularcolumns:: |\Y{0.2}|\Y{0.4}|\Y{0.2}|\Y{0.2}|

    +----------------------------+----------------------------------+----------------------+--------------------+
    | Option name                | Type and meaning                 | Default              | Examples           |
    +============================+==================================+======================+====================+
    | **start**                  | Integer. The value to generate   | 1                    | start=0            |
    |                            | the first time a sequence is     |                      |                    |
    |                            | used                             |                      |                    |
    +----------------------------+----------------------------------+----------------------+--------------------+
    | **min**                    | Integer. Values smaller than     | 1                    | min=-1000          |
    |                            | this cannot be generated         |                      |                    |
    +----------------------------+----------------------------------+----------------------+--------------------+
    | **max**                    | Integer. Values larger than      | 9223372036854775807  | max=0              |
    |                            | this cannot be generated         |                      |                    |
    +----------------------------+----------------------------------+----------------------+--------------------+
    | **cycle**                  | Boolean. Whether to start again  | false                | cycle=true         |
    |                            | when values cannot be generated  |                      |                    |
    +----------------------------+----------------------------------+----------------------+--------------------+
    | **cache**                  | Integer. The number of values    | 0                    | cache=0            |
    |                            | to store in a cache              |                      |                    |
    +----------------------------+----------------------------------+----------------------+--------------------+
    | **step**                   | Integer. What to add to the      | 1                    | step=-1            |
    |                            | previous generated value, when   |                      |                    |
    |                            | generating a new value           |                      |                    |
    +----------------------------+----------------------------------+----------------------+--------------------+
    | **if_not_exists**          | Boolean. If this is true and     | false                | if_not_exists=true |
    |                            | a sequence with this name exists |                      |                    |
    |                            | already, ignore other options    |                      |                    |
    |                            | and use the existing values      |                      |                    |
    +----------------------------+----------------------------------+----------------------+--------------------+

Once a sequence exists, it can be altered, dropped, reset, forced to generate
the next value, or associated with an index.

For an initial example, we generate a sequence named 'S'.

.. code-block:: tarantoolsession

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

.. code-block:: tarantoolsession

    tarantool> box.sequence.S:next()
    ---
    - 5
    ...

The result is the same as the start value. If we called ``next()``
again, we would get 6 (because the previous value plus the
step value is 6), and so on.

Then we create a new table, and say that its primary key may be
generated from the sequence.

.. code-block:: tarantoolsession

    tarantool> s=box.schema.space.create('T');s:create_index('I',{sequence='S'})
    ---
    ...

Then we insert a tuple, without specifying a value for the primary key.

.. code-block:: tarantoolsession

    tarantool> box.space.T:insert{nil,'other stuff'}
    ---
    - [6, 'other stuff']
    ...

The result is a new tuple where the first field has a value of 6.
This arrangement, where the system automatically generates the
values for a primary key, is sometimes called "auto-incrementing"
or "identity".

For syntax and implementation details, see the reference for
:ref:`box.schema.sequence <box_schema-sequence>`.

.. _index-box_persistence:

--------------------------------------------------------------------------------
Persistence
--------------------------------------------------------------------------------

In Tarantool, updates to the database are recorded in the so-called
:ref:`write ahead log (WAL) <internals-wal>` files. This ensures data persistence.
When a power outage occurs or the Tarantool instance is killed incidentally,
the in-memory database is lost. In this situation, WAL files are used
to restore the data. Namely, Tarantool reads the WAL files and redoes
the requests (this is called the "recovery process"). You can change
the timing of the WAL writer, or turn it off, by setting
:ref:`wal_mode <cfg_binary_logging_snapshots-wal_mode>`.

Tarantool also maintains a set of :ref:`snapshot files <internals-snapshot>`.
These files contain an on-disk copy of the entire data set for a given moment.
Instead of reading every WAL file since the databases were created, the recovery
process can load the latest snapshot file and then read only those WAL files
that were produced after the snapshot file was made. After checkpointing, old
WAL files can be removed to free up space.

To force immediate creation of a snapshot file, you can use Tarantool's
:ref:`box.snapshot() <box-snapshot>` request. To enable automatic creation
of snapshot files, you can use Tarantool's
:ref:`checkpoint daemon <book_cfg_checkpoint_daemon>`. The checkpoint
daemon sets intervals for forced checkpoints. It makes sure that the states
of both memtx and vinyl storage engines are synchronized and saved to disk,
and automatically removes old WAL files.

Snapshot files can be created even if there is no WAL file.

.. NOTE::

     The memtx engine makes only regular checkpoints with the interval set in
     :ref:`checkpoint daemon <book_cfg_checkpoint_daemon>` configuration.

     The vinyl engine runs checkpointing in the background at all times.

See the :ref:`Internals <internals-data_persistence>` section for more details
about the WAL writer and the recovery process.

.. _index-box_operations:

--------------------------------------------------------------------------------
Operations
--------------------------------------------------------------------------------

.. _index-box_data-operations:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Data operations
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The basic data operations supported in Tarantool are:

* five data-manipulation operations (INSERT, UPDATE, UPSERT, DELETE, REPLACE), and
* one data-retrieval operation (SELECT).

All of them are implemented as functions in :ref:`box.space <box_space>` submodule.

**Examples:**

* :ref:`INSERT <box_space-insert>`: Add a new tuple to space 'tester'.

  The first field, field[1], will be 999 (MsgPack type is `integer`).

  The second field, field[2], will be 'Taranto' (MsgPack type is `string`).

  .. code-block:: tarantoolsession

      tarantool> box.space.tester:insert{999, 'Taranto'}

* :ref:`UPDATE <box_space-update>`: Update the tuple, changing field field[2].

  The clause "{999}", which has the value to look up in the index of the tuple's
  primary-key field, is mandatory, because ``update()`` requests must always have
  a clause that specifies a unique key, which in this case is field[1].

  The clause "{{'=', 2, 'Tarantino'}}" specifies that assignment will happen to
  field[2] with the new value.

  .. code-block:: tarantoolsession

      tarantool> box.space.tester:update({999}, {{'=', 2, 'Tarantino'}})

* :ref:`UPSERT <box_space-upsert>`: Upsert the tuple, changing field field[2]
  again.

  The syntax of ``upsert()`` is similar to the syntax of ``update()``. However,
  the execution logic of these two requests is different.
  UPSERT is either UPDATE or INSERT, depending on the database's state.
  Also, UPSERT execution is postponed until after transaction commit, so, unlike
  ``update()``, ``upsert()`` doesn't return data back.

  .. code-block:: tarantoolsession

      tarantool> box.space.tester:upsert({999, 'Taranted'}, {{'=', 2, 'Tarantism'}})

* :ref:`REPLACE <box_space-replace>`: Replace the tuple, adding a new field.

  This is also possible with the ``update()`` request, but the ``update()``
  request is usually more complicated.

  .. code-block:: tarantoolsession

      tarantool> box.space.tester:replace{999, 'Tarantella', 'Tarantula'}

* :ref:`SELECT <box_space-select>`: Retrieve the tuple.

  The clause "{999}" is still mandatory, although it does not have to mention
  the primary key.

  .. code-block:: tarantoolsession

      tarantool> box.space.tester:select{999}

* :ref:`DELETE <box_space-delete>`: Delete the tuple.

  In this example, we identify the primary-key field.

  .. code-block:: tarantoolsession

      tarantool> box.space.tester:delete{999}

Summarizing the examples:

* Functions ``insert`` and ``replace`` accept a tuple
  (where a primary key comes as part of the tuple).
* Function ``upsert`` accepts a tuple
  (where a primary key comes as part of the tuple),
  and also the update operations to execute.
* Function ``delete`` accepts a full key of any unique index
  (primary or secondary).
* Function ``update`` accepts a full key of any unique index
  (primary or secondary),
  and also the operations to execute.
* Function ``select`` accepts any key: primary/secondary, unique/non-unique,
  full/partial.

See reference on ``box.space`` for more
:ref:`details on using data operations <box_space-operations-detailed-examples>`.

.. NOTE::

   Besides Lua, you can use
   :ref:`Perl, PHP, Python or other programming language connectors <index-box_connectors>`.
   The client server protocol is open and documented.
   See this :ref:`annotated BNF <box_protocol-iproto_protocol>`.

.. _index-box_index-operations:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Index operations
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

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

The following SELECT variations exist:

1. The search can use comparisons other than equality.

   .. cssclass:: highlight
   .. parsed-literal::

       :extsamp:`box.space.{*{space-name}*}:select(value, {iterator = 'GT'})`

   The :ref:`comparison operators <box_index-iterator-types>` are LT, LE, EQ, REQ, GE, GT
   (for "less than", "less than or equal", "equal", "reversed equal",
   "greater than or equal", "greater than" respectively).
   Comparisons make sense if and only if the index type is ‘TREE'.

   This type of search may return more than one tuple; if so, the tuples will be
   in descending order by key when the comparison operator is LT or LE or REQ,
   otherwise in ascending order.

2. The search can use a secondary index.

   .. cssclass:: highlight
   .. parsed-literal::

       :extsamp:`box.space.{*{space-name}*}.index.{*{index-name}*}:select(value)`

   For a primary-key search, it is optional to specify an index name.
   For a secondary-key search, it is mandatory.

3. The search may be for some or all key parts.

   .. cssclass:: highlight
   .. parsed-literal::

        -- Suppose an index has two parts
        :samp:`tarantool> box.space.{space-name}.index.{index-name}.parts`
        ---
        - - type: unsigned
            fieldno: 1
          - type: string
            fieldno: 2
        ...
        -- Suppose the space has three tuples
        :samp:`box.space.{space-name}:select()`
        ---
        - - [1, 'A']
          - [1, 'B']
          - [2, '']
        ...

4. The search may be for all fields, using a table for the value:

   .. cssclass:: highlight
   .. parsed-literal::

       :extsamp:`box.space.{*{space-name}*}:select({1, 'A'})`

   or the search can be for one field, using a table or a scalar:

   .. cssclass:: highlight
   .. parsed-literal::

       :samp:`box.space.{space-name}:select(1)`

   In the second case, the result will be two tuples:
   ``{1, 'A'}`` and ``{1, 'B'}``.

   You can specify even zero fields, causing all three tuples to be
   returned. (Notice that partial key searches are available only in TREE indexes.)

**Examples**

* BITSET example:

   .. code-block:: tarantoolsession

      tarantool> box.schema.space.create('bitset_example')
      tarantool> box.space.bitset_example:create_index('primary')
      tarantool> box.space.bitset_example:create_index('bitset',{unique=false,type='BITSET', parts={field = 2, type = 'unsigned'}})
      tarantool> box.space.bitset_example:insert{1,1}
      tarantool> box.space.bitset_example:insert{2,4}
      tarantool> box.space.bitset_example:insert{3,7}
      tarantool> box.space.bitset_example:insert{4,3}
      tarantool> box.space.bitset_example.index.bitset:select(2, {iterator='BITS_ANY_SET'})

   The result will be:

   .. code-block:: tarantoolsession

      ---
      - - [3, 7]
        - [4, 3]
      ...

   because (7 AND 2) is not equal to 0, and (3 AND 2) is not equal to 0.

* RTREE example:

   .. code-block:: tarantoolsession

      tarantool> box.schema.space.create('rtree_example')
      tarantool> box.space.rtree_example:create_index('primary')
      tarantool> box.space.rtree_example:create_index('rtree',{unique=false,type='RTREE', parts={field = 2, type = 'ARRAY'}})
      tarantool> box.space.rtree_example:insert{1, {3, 5, 9, 10}}
      tarantool> box.space.rtree_example:insert{2, {10, 11}}
      tarantool> box.space.rtree_example.index.rtree:select({4, 7, 5, 9}, {iterator = 'GT'})

   The result will be:

   .. code-block:: tarantoolsession

      ---
      - - [1, [3, 5, 9, 10]]
      ...

   because a rectangle whose corners are at coordinates ``4,7,5,9`` is entirely
   within a rectangle whose corners are at coordinates ``3,5,9,10``.

Additionally, there exist :ref:`index iterator operations <box_index-index_pairs>`.
They can only be used with code in Lua and C/C++. Index iterators are for
traversing indexes one key at a time, taking advantage of features that are
specific to an index type, for example evaluating Boolean expressions when
traversing BITSET indexes, or going in descending order when traversing TREE indexes.

See also other index operations like :ref:`alter() <box_index-alter>`
(modify index) and :ref:`drop() <box_index-drop>` (delete index) in reference
for :ref:`box.index <box_index>` submodule.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Complexity factors
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

In reference for :ref:`box.space <box_space>` and :ref:`box.index <box_index>`
submodules, there are notes about which complexity factors might affect the
resource usage of each function.

.. container:: table

    .. rst-class:: left-align-column-1
    .. rst-class:: left-align-column-2

    .. tabularcolumns:: |\Y{0.2}|\Y{0.8}|

    +-------------------+----------------------------------------------------------+
    | Complexity        | Effect                                                   |
    | factor            |                                                          |
    +===================+==========================================================+
    | Index size        | The number of index keys is the same as the number       |
    |                   | of tuples in the data set. For a TREE index, if          |
    |                   | there are more keys, then the lookup time will be        |
    |                   | greater, although of course the effect is not            |
    |                   | linear. For a HASH index, if there are more keys,        |
    |                   | then there is more RAM used, but the number of           |
    |                   | low-level steps tends to remain constant.                |
    +-------------------+----------------------------------------------------------+
    | Index type        | Typically, a HASH index is faster than a TREE index      |
    |                   | if the number of tuples in the space is greater          |
    |                   | than one.                                                |
    +-------------------+----------------------------------------------------------+
    | Number of indexes | Ordinarily, only one index is accessed to retrieve       |
    | accessed          | one tuple. But to update the tuple, there must be N      |
    |                   | accesses if the space has N different indexes.           |
    |                   |                                                          |
    |                   | Note re storage engine: Vinyl optimizes away such        |
    |                   | accesses if secondary index fields are unchanged by      |
    |                   | the update. So, this complexity factor applies only to   |
    |                   | memtx, since it always makes a full-tuple copy on every  |
    |                   | update.                                                  |
    +-------------------+----------------------------------------------------------+
    | Number of tuples  | A few requests, for example SELECT, can retrieve         |
    | accessed          | multiple tuples. This factor is usually less             |
    |                   | important than the others.                               |
    +-------------------+----------------------------------------------------------+
    | WAL settings      | The important setting for the write-ahead log is         |
    |                   | :ref:`wal_mode <cfg_binary_logging_snapshots-wal_mode>`. |
    |                   | If the setting causes no writing or                      |
    |                   | delayed writing, this factor is unimportant. If the      |
    |                   | setting causes every data-change request to wait         |
    |                   | for writing to finish on a slow device, this factor      |
    |                   | is more important than all the others.                   |
    +-------------------+----------------------------------------------------------+
