..  _how-to-db-indexes:

Using indexes
=============    

Creating an index
-----------------

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
:ref:`Details about indexed field types <index-box_indexed-field-types>`:

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

..  _index-box_index-operations:

Index operations
----------------

Index operations are automatic: if a data manipulation request changes a tuple,
then it also changes the index keys defined for the tuple.

#.  Create a sample space named ``bands``:

    ..  literalinclude:: /code_snippets/test/indexes/index_select_test.lua
        :language: lua
        :lines: 21
        :dedent:

#.  Format the created space by specifying field names and types:

    ..  literalinclude:: /code_snippets/test/indexes/index_select_test.lua
        :language: lua
        :lines: 24-28
        :dedent:

#.  Create the **primary** index (named ``primary``):

    ..  literalinclude:: /code_snippets/test/indexes/index_select_test.lua
        :language: lua
        :lines: 31
        :dedent:

    This index is based on the ``id`` field of each tuple.

#.  Insert some :ref:`tuples <index-box_tuple>` into the space:

    ..  literalinclude:: /code_snippets/test/indexes/index_select_test.lua
        :language: lua
        :lines: 43-52
        :dedent:

#.  Create **secondary indexes**:

    ..  literalinclude:: /code_snippets/test/indexes/index_select_test.lua
        :language: lua
        :lines: 33-37
        :dedent:

#.  Create a **multi-part index** with two parts:

    ..  literalinclude:: /code_snippets/test/indexes/index_select_test.lua
        :language: lua
        :lines: 40
        :dedent:

There are the following SELECT variations:

*   The search can use **comparisons** other than equality:

    ..  literalinclude:: /code_snippets/test/indexes/index_select_test.lua
        :language: lua
        :lines: 98-106
        :dedent:

    The :ref:`comparison operators <box_index-iterator-types>` are:

    *   ``LT`` for "less than"
    *   ``LE`` for "less than or equal"
    *   ``GT`` for "greater"
    *   ``GE`` for "greater than or equal"
    *   ``EQ`` for "equal"
    *   ``REQ`` for "reversed equal"

    Value comparisons make sense if and only if the index type is TREE.
    The iterator types for other types of indexes are slightly different and work
    differently. See details in section :ref:`Iterator types <box_index-iterator-types>`.

    Note that we don't use the name of the index, which means we use primary index here.

    This type of search may return more than one tuple. The tuples will be sorted
    in descending order by key if the comparison operator is LT or LE or REQ.
    Otherwise they will be sorted in ascending order.

*   The search can use a **secondary index**.

    ..  literalinclude:: /code_snippets/test/indexes/index_select_test.lua
        :language: lua
        :lines: 62-68
        :dedent:

    .. _partial_key_search:

*   **Partial key search:** The search may be for some key parts starting with
    the prefix of the key. Note that partial key searches are available
    only in TREE indexes.

    ..  literalinclude:: /code_snippets/test/indexes/index_select_test.lua
        :language: lua
        :lines: 78-86
        :dedent:


*   The search can be for all fields, using a table as the value:

    ..  literalinclude:: /code_snippets/test/indexes/index_select_test.lua
        :language: lua
        :lines: 70-76
        :dedent:


..  admonition:: Tip
    :class: fact

    You can also add, drop, or alter the definitions at runtime, with some
    restrictions. Read more about index operations in reference for
    :doc:`box.index submodule </reference/reference_lua/box_index>`.
