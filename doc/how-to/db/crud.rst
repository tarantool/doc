.. _box_space_examples:

CRUD operation examples
=======================


.. _box_space-operations-detailed-examples:

-------------------------------------------------------------------------------
Using data operations
-------------------------------------------------------------------------------

This section shows basic usage scenarios and typical errors for each
:ref:`data operation <index-box_data-operations>` in Tarantool:
:ref:`INSERT <box_space-operations-insert>`,
:ref:`DELETE <box_space-operations-delete>`,
:ref:`UPDATE <box_space-operations-update>`,
:ref:`UPSERT <box_space-operations-upsert>`,
:ref:`REPLACE <box_space-operations-replace>`, and
:ref:`SELECT <box_space-operations-select>`.
Before trying out the examples, you need to bootstrap a Tarantool instance as shown below.

.. code-block:: tarantoolsession

    -- Run a server --
    tarantool> box.cfg{}

    -- Create a space --
    tarantool> bands = box.schema.space.create('bands')

    -- Specify field names and types --
    tarantool> bands:format({
                   {name = 'id', type = 'unsigned'},
                   {name = 'band_name', type = 'string'},
                   {name = 'year', type = 'unsigned'}
               })

    -- Create a primary index --
    tarantool> bands:create_index('primary', {parts = {'id'}})

    -- Create a unique secondary index --
    tarantool> bands:create_index('band', {parts = {'band_name'}})

    -- Create a non-unique secondary index --
    tarantool> bands:create_index('year', {parts = {{'year'}}, unique = false})

    -- Create a multi-part index --
    tarantool> bands:create_index('band_year', {parts = {{'band_name'}, {'year'}}})


.. _box_space-operations-insert:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
INSERT
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The :ref:`space_object.insert <box_space-insert>` method accepts a well-formatted tuple.

.. code-block:: tarantoolsession

    -- Insert a tuple with a unique primary key --
    tarantool> bands:insert{1, 'Scorpions', 1965}
    ---
    - [1, 'Scorpions', 1965]
    ...


``insert`` also checks all the keys for duplicates.

.. code-block:: tarantoolsession

    -- Try to insert a tuple with a duplicate primary key --
    tarantool> bands:insert{1, 'Scorpions', 1965}
    ---
    - error: Duplicate key exists in unique index "primary" in space "bands" with old
        tuple - [1, "Scorpions", 1965] and new tuple - [1, "Scorpions", 1965]
    ...

    -- Try to insert a tuple with a duplicate secondary key --
    tarantool> bands:insert{2, 'Scorpions', 1965}
    ---
    - error: Duplicate key exists in unique index "band" in space "bands" with old tuple
        - [1, "Scorpions", 1965] and new tuple - [2, "Scorpions", 1965]
    ...

    -- Insert a second tuple with unique primary and secondary keys --
    tarantool> bands:insert{2, 'Pink Floyd', 1965}
    ---
    - [2, 'Pink Floyd', 1965]
    ...

    -- Delete all tuples --
    tarantool> bands:truncate()
    ---
    ...

.. _box_space-operations-delete:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
DELETE
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

:ref:`space_object.delete <box_space-delete>` allows you to delete a tuple identified by the primary key.

.. code-block:: tarantoolsession

    -- Insert test data --
    tarantool> bands:insert{1, 'Roxette', 1986}
               bands:insert{2, 'Scorpions', 1965}
               bands:insert{3, 'Ace of Base', 1987}
               bands:insert{4, 'The Beatles', 1960}

    -- Delete a tuple with an existing key --
    tarantool> bands:delete{4}
    ---
    - [4, 'The Beatles', 1960]
    ...
    tarantool> bands:select()
    ---
    - - [1, 'Roxette', 1986]
      - [2, 'Scorpions', 1965]
      - [3, 'Ace of Base', 1987]
    ...

You can also use :ref:`index_object.delete <box_index-delete>` to delete a tuple by the specified unique index.

.. code-block:: tarantoolsession

    -- Delete a tuple by the primary index --
    tarantool> bands.index.primary:delete{3}
    ---
    - [3, 'Ace of Base', 1987]
    ...
    tarantool> bands:select()
    ---
    - - [1, 'Roxette', 1986]
      - [2, 'Scorpions', 1965]
    ...

    -- Delete a tuple by a unique secondary index --
    tarantool> bands.index.band:delete{'Scorpions'}
    ---
    - [2, 'Scorpions', 1965]
    ...
    tarantool> bands:select()
    ---
    - - [1, 'Roxette', 1986]
    ...

    -- Try to delete a tuple by a non-unique secondary index --
    tarantool> bands.index.year:delete(1986)
    ---
    - error: Get() doesn't support partial keys and non-unique indexes
    ...
    tarantool> bands:select()
    ---
    - - [1, 'Roxette', 1986]
    ...

    -- Try to delete a tuple by a partial key --
    tarantool> bands.index.band_year:delete('Roxette')
    ---
    - error: Invalid key part count in an exact match (expected 2, got 1)
    ...

    -- Delete a tuple by a full key --
    tarantool> bands.index.band_year:delete{'Roxette', 1986}
    ---
    - [1, 'Roxette', 1986]
    ...
    tarantool> bands:select()
    ---
    - []
    ...

    -- Delete all tuples --
    tarantool> bands:truncate()
    ---
    ...


.. _box_space-operations-update:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
UPDATE
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

:ref:`space_object.update <box_space-update>` allows you to update a tuple identified by the primary key.
Similarly to ``delete``, the ``update`` method accepts a full key and also an operation to execute.

.. code-block:: tarantoolsession

    -- Insert test data --
    tarantool> bands:insert{1, 'Roxette', 1986}
               bands:insert{2, 'Scorpions', 1965}
               bands:insert{3, 'Ace of Base', 1987}
               bands:insert{4, 'The Beatles', 1960}

    -- Update a tuple with an existing key --
    tarantool> bands:update({2}, {{'=', 2, 'Pink Floyd'}})
    ---
    - [2, 'Pink Floyd', 1965]
    ...

    tarantool> bands:select()
    ---
    - - [1, 'Roxette', 1986]
      - [2, 'Pink Floyd', 1965]
      - [3, 'Ace of Base', 1987]
      - [4, 'The Beatles', 1960]
    ...


:ref:`index_object.update <box_index-update>` updates a tuple identified by the specified unique index.

.. code-block:: tarantoolsession

    -- Update a tuple by the primary index --
    tarantool> bands.index.primary:update({2}, {{'=', 2, 'The Rolling Stones'}})
    ---
    - [2, 'The Rolling Stones', 1965]
    ...

    tarantool> bands:select()
    ---
    - - [1, 'Roxette', 1986]
      - [2, 'The Rolling Stones', 1965]
      - [3, 'Ace of Base', 1987]
      - [4, 'The Beatles', 1960]
    ...

    -- Update a tuple by a unique secondary index --
    tarantool> bands.index.band:update({'The Rolling Stones'}, {{'=', 2, 'The Doors'}})
    ---
    - [2, 'The Doors', 1965]
    ...

    tarantool> bands:select()
    ---
    - - [1, 'Roxette', 1986]
      - [2, 'The Doors', 1965]
      - [3, 'Ace of Base', 1987]
      - [4, 'The Beatles', 1960]
    ...

    -- Try to update a tuple by a non-unique secondary index --
    tarantool> bands.index.year:update({1965}, {{'=', 2, 'Scorpions'}})
    ---
    - error: Get() doesn't support partial keys and non-unique indexes
    ...
    tarantool> bands:select()
    ---
    - - [1, 'Roxette', 1986]
      - [2, 'The Doors', 1965]
      - [3, 'Ace of Base', 1987]
      - [4, 'The Beatles', 1960]
    ...

    -- Delete all tuples --
    tarantool> bands:truncate()
    ---
    ...


.. _box_space-operations-upsert:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
UPSERT
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

:ref:`space_object.upsert <box_space-upsert>` updates an existing tuple or inserts a new one:

*   If the existing tuple is found by the primary key,
    Tarantool applies the update operation to this tuple
    and ignores the new tuple.
*   If no existing tuple is found,
    Tarantool inserts the new tuple and ignores the update operation.

.. code-block:: tarantoolsession

    tarantool> bands:insert{1, 'Scorpions', 1965}
    ---
    - [1, 'Scorpions', 1965]
    ...
    -- As the first argument, upsert accepts a tuple, not a key --
    tarantool> bands:upsert({2}, {{'=', 2, 'Pink Floyd'}})
    ---
    - error: Tuple field 2 (band_name) required by space format is missing
    ...
    tarantool> bands:select()
    ---
    - - [1, 'Scorpions', 1965]
    ...
    tarantool> bands:delete(1)
    ---
    - [1, 'Scorpions', 1965]
    ...

``upsert`` acts as ``insert`` when no existing tuple is found by the primary key.

.. code-block:: tarantoolsession

    tarantool> bands:upsert({1, 'Scorpions', 1965}, {{'=', 2, 'The Doors'}})
    ---
    ...
    -- As you can see, {1, 'Scorpions', 1965} is inserted, --
    -- and the update operation is not applied. --
    tarantool> bands:select()
    ---
    - - [1, 'Scorpions', 1965]
    ...

    -- upsert with the same primary key but different values in other fields --
    -- applies the update operation and ignores the new tuple. --
    tarantool> bands:upsert({1, 'Scorpions', 1965}, {{'=', 2, 'The Doors'}})
    ---
    ...
    tarantool> bands:select()
    ---
    - - [1, 'The Doors', 1965]
    ...

``upsert`` searches for the existing tuple by the primary index,
not by the secondary index. This can lead to a duplication error
if the tuple violates a secondary index uniqueness.

.. code-block:: tarantoolsession

    tarantool> bands:upsert({2, 'The Doors', 1965}, {{'=', 2, 'Pink Floyd'}})
    ---
    - error: Duplicate key exists in unique index "band" in space "bands" with old tuple
        - [1, "The Doors", 1965] and new tuple - [2, "The Doors", 1965]
    ...
    tarantool> bands:select()
    ---
    - - [1, 'The Doors', 1965]
    ...

    -- This works if uniqueness is preserved. --
    tarantool> bands:upsert({2, 'The Beatles', 1960}, {{'=', 2, 'Pink Floyd'}})
    ---
    ...
    tarantool> bands:select()
    ---
    - - [1, 'The Doors', 1965]
      - [2, 'The Beatles', 1960]
    ...

    -- Delete all tuples --
    tarantool> bands:truncate()
    ---
    ...


.. _box_space-operations-replace:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
REPLACE
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

:ref:`space_object.replace <box_space-replace>` accepts a well-formatted tuple and searches for the existing tuple
by the primary key of the new tuple:

*   If the existing tuple is found, Tarantool deletes it and inserts the new tuple.
*   If no existing tuple is found, Tarantool inserts the new tuple.


.. code-block:: tarantoolsession

    tarantool> bands:replace{1, 'Scorpions', 1965}
    ---
    - [1, 'Scorpions', 1965]
    ...
    tarantool> bands:select()
    ---
    - - [1, 'Scorpions', 1965]
    ...
    tarantool> bands:replace{1, 'The Beatles', 1960}
    ---
    - [1, 'The Beatles', 1960]
    ...
    tarantool> bands:select()
    ---
    - - [1, 'The Beatles', 1960]
    ...
    tarantool> bands:truncate()
    ---
    ...

``replace`` can violate unique constraints, like ``upsert`` does.

.. code-block:: tarantoolsession

    tarantool> bands:insert{1, 'Scorpions', 1965}
    - [1, 'Scorpions', 1965]
    ...
    tarantool> bands:insert{2, 'The Beatles', 1960}
    ---
    - [2, 'The Beatles', 1960]
    ...
    tarantool> bands:replace{2, 'Scorpions', 1965}
    ---
    - error: Duplicate key exists in unique index "band" in space "bands" with old tuple
        - [1, "Scorpions", 1965] and new tuple - [2, "Scorpions", 1965]
    ...
    tarantool> bands:truncate()
    ---
    ...

.. _box_space-operations-select:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
SELECT
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The :ref:`space_object.select <box_space-select>` request searches for a tuple or a set of tuples in the given space
by the primary key.
To search by the specified index, use :ref:`index_object.select <box_index-select>`.
These methods work with any keys, including unique and non-unique, full and partial.
If a key is partial, ``select`` searches by all keys where the prefix matches the specified key part.

.. code-block:: tarantoolsession

    tarantool> bands:insert{1, 'Roxette', 1986}
               bands:insert{2, 'Scorpions', 1965}
               bands:insert{3, 'The Doors', 1965}
               bands:insert{4, 'The Beatles', 1960}

    tarantool> bands:select(1)
    ---
    - - [1, 'Roxette', 1986]
    ...

    tarantool> bands:select()
    ---
    - - [1, 'Roxette', 1986]
      - [2, 'Scorpions', 1965]
      - [3, 'The Doors', 1965]
      - [4, 'The Beatles', 1960]
    ...

    tarantool> bands.index.primary:select(2)
    ---
    - - [2, 'Scorpions', 1965]
    ...

    tarantool> bands.index.band:select('The Doors')
    ---
    - - [3, 'The Doors', 1965]
    ...

    tarantool> bands.index.year:select(1965)
    ---
    - - [2, 'Scorpions', 1965]
      - [3, 'The Doors', 1965]
    ...



-------------------------------------------------------------------------------
Using box.space functions to read _space tuples
-------------------------------------------------------------------------------

This example illustrates how to look at all the spaces, and for each
display: approximately how many tuples it contains, and the first field of
its first tuple. The function uses the Tarantool's ``box.space`` functions ``len()``
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

The output below shows what happens if you invoke this function:

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

-------------------------------------------------------------------------------
Using box.space functions to organize a _space tuple
-------------------------------------------------------------------------------

This examples shows how to display field names and field types of a system space --
using metadata to find metadata.

To begin: how can one select the ``_space`` tuple that describes ``_space``?

A simple way is to look at the constants in ``box.schema``,
which shows that there is an item named SPACE_ID == 288,
so these statements retrieve the correct tuple:

.. code-block:: lua

    box.space._space:select{ 288 }
    -- or --
    box.space._space:select{ box.schema.SPACE_ID }

Another way is to look at the tuples in ``box.space._index``,
which shows that there is a secondary index named 'name' for a space
number 288, so this statement also retrieve the correct tuple:

.. code-block:: lua

    box.space._space.index.name:select{ '_space' }

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
