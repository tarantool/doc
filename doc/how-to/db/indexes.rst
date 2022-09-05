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

..  _index-box_index-operations:

Index operations
----------------

Index operations are automatic: if a data manipulation request changes a tuple,
then it also changes the index keys defined for the tuple.

#.  Let's create a sample space named ``tester`` and
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
