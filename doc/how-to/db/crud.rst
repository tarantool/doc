.. _box_space_examples:

CRUD operation examples
=======================


.. _box_space-operations-detailed-examples:

-------------------------------------------------------------------------------
Using data operations
-------------------------------------------------------------------------------

This example demonstrates all legal scenarios -- as well as typical errors --
for each :ref:`data operation <index-box_data-operations>` in Tarantool:
:ref:`INSERT <box_space-operations-insert>`,
:ref:`DELETE <box_space-operations-delete>`,
:ref:`UPDATE <box_space-operations-update>`,
:ref:`UPSERT <box_space-operations-upsert>`,
:ref:`REPLACE <box_space-operations-replace>`, and
:ref:`SELECT <box_space-operations-select>`.

.. code-block:: lua

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

:ref:`insert <box_space-insert>` accepts a well-formatted tuple and checks all keys for duplicates.


.. code-block:: tarantoolsession

    -- Unique indexes: ok --
    tarantool> bands:insert{1, 'Scorpions', 1965}
    ---
    - [1, 'Scorpions', 1965]
    ...
    -- Conflicting primary key: error --
    tarantool> bands:insert{1, 'Scorpions', 1965}
    ---
    - error: Duplicate key exists in unique index "primary" in space "bands" with old
        tuple - [1, "Scorpions", 1965] and new tuple - [1, "Scorpions", 1965]
    ...
    -- Conflicting unique secondary key: error --
    tarantool> bands:insert{2, 'Scorpions', 1965}
    ---
    - error: Duplicate key exists in unique index "band" in space "bands" with old tuple
        - [1, "Scorpions", 1965] and new tuple - [2, "Scorpions", 1965]
    ...
    tarantool> -- Key {1} exists in sk_non_uniq index, but it is not unique: ok --
    tarantool> bands:insert{2, 'Pink Floyd', 1965}
    ---
    - [2, 'Pink Floyd', 1965]
    ...
    tarantool> bands:truncate()
    ---
    ...

.. _box_space-operations-delete:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
DELETE
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

``delete`` accepts a full key of any unique index.

``space:delete`` is an alias for "delete by primary key".

.. code-block:: tarantoolsession

    tarantool> -- Insert some test data --
    tarantool> s:insert{3, 4, 5}
    ---
    - [3, 4, 5]
    ...
    tarantool> s:insert{6, 7, 8}
    ---
    - [6, 7, 8]
    ...
    tarantool> s:insert{9, 10, 11}
    ---
    - [9, 10, 11]
    ...
    tarantool> s:insert{12, 13, 14}
    ---
    - [12, 13, 14]
    ...
    tarantool> -- Nothing done here: no {4} key in pk index --
    tarantool> s:delete{4}
    ---
    ...
    tarantool> s:select{}
    ---
    - - [3, 4, 5]
      - [6, 7, 8]
      - [9, 10, 11]
      - [12, 13, 14]
    ...
    tarantool> -- Delete by a primary key: ok --
    tarantool> s:delete{3}
    ---
    - [3, 4, 5]
    ...
    tarantool> s:select{}
    ---
    - - [6, 7, 8]
      - [9, 10, 11]
      - [12, 13, 14]
    ...
    tarantool> -- Explicitly delete by a primary key: ok --
    tarantool> s.index.pk:delete{6}
    ---
    - [6, 7, 8]
    ...
    tarantool> s:select{}
    ---
    - - [9, 10, 11]
      - [12, 13, 14]
    ...
    tarantool> -- Delete by a unique secondary key: ok --
    s.index.sk_uniq:delete{10}
    ---
    - [9, 10, 11]
    ...
    s:select{}
    ---
    - - [12, 13, 14]
    ...
    tarantool> -- Delete by a non-unique secondary index: error --
    tarantool> s.index.sk_non_uniq:delete{14}
    ---
    - error: Get() doesn't support partial keys and non-unique indexes
    ...
    tarantool> s:select{}
    ---
    - - [12, 13, 14]
    ...
    tarantool> s:truncate()
    ---
    ...

The key must be full: ``delete`` cannot work with partial keys.

.. code-block:: tarantoolsession

    tarantool> s2 = box.schema.create_space('test2')
    ---
    ...
    tarantool> pk2 = s2:create_index('pk2', {parts = {{1, 'unsigned'}, {2, 'unsigned'}}})
    ---
    ...
    tarantool> s2:insert{1, 1}
    ---
    - [1, 1]
    ...
    tarantool> -- Delete by a partial key: error --
    tarantool> s2:delete{1}
    ---
    - error: Invalid key part count in an exact match (expected 2, got 1)
    ...
    tarantool> -- Delete by a full key: ok --
    tarantool> s2:delete{1, 1}
    ---
    - [1, 1]
    ...
    tarantool> s2:select{}
    ---
    - []
    ...
    tarantool> s2:drop()
    ---
    ...

.. _box_space-operations-update:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
UPDATE
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Similarly to ``delete``, ``update`` accepts a full key of any unique index,
and also the operations to execute.

``space:update`` is an alias for "update by primary key".

.. code-block:: tarantoolsession

    tarantool> -- Insert some test data --
    tarantool> s:insert{3, 4, 5}
    ---
    - [3, 4, 5]
    ...
    tarantool> s:insert{6, 7, 8}
    ---
    - [6, 7, 8]
    ...
    tarantool> s:insert{9, 10, 11}
    ---
    - [9, 10, 11]
    ...
    tarantool> s:insert{12, 13, 14}
    ---
    - [12, 13, 14]
    ...
    tarantool> -- Nothing done here: no {4} key in pk index --
    s:update({4}, {{'=', 2, 400}})
    ---
    ...
    tarantool> s:select{}
    ---
    - - [3, 4, 5]
      - [6, 7, 8]
      - [9, 10, 11]
      - [12, 13, 14]
    ...
    tarantool> -- Update by a primary key: ok --
    tarantool> s:update({3}, {{'=', 2, 400}})
    ---
    - [3, 400, 5]
    ...
    tarantool> s:select{}
    ---
    - - [3, 400, 5]
      - [6, 7, 8]
      - [9, 10, 11]
      - [12, 13, 14]
    ...
    tarantool> -- Explicitly update by a primary key: ok --
    tarantool> s.index.pk:update({6}, {{'=', 2, 700}})
    ---
    - [6, 700, 8]
    ...
    tarantool> s:select{}
    ---
    - - [3, 400, 5]
      - [6, 700, 8]
      - [9, 10, 11]
      - [12, 13, 14]
    ...
    tarantool> -- Update by a unique secondary key: ok --
    tarantool> s.index.sk_uniq:update({10}, {{'=', 2, 1000}})
    ---
    - [9, 1000, 11]
    ...
    tarantool> s:select{}
    ---
    - - [3, 400, 5]
      - [6, 700, 8]
      - [9, 1000, 11]
      - [12, 13, 14]
    ...
    tarantool> -- Update by a non-unique secondary key: error --
    tarantool> s.index.sk_non_uniq:update({14}, {{'=', 2, 1300}})
    ---
    - error: Get() doesn't support partial keys and non-unique indexes
    ...
    tarantool> s:select{}
    ---
    - - [3, 400, 5]
      - [6, 700, 8]
      - [9, 1000, 11]
      - [12, 13, 14]
    ...
    tarantool> s:truncate()
    ---
    ...

.. _box_space-operations-upsert:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
UPSERT
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

``upsert`` accepts a well-formatted tuple and update operations.

If an old tuple is found by the primary key of the specified tuple,
then the update operations are applied to the old tuple,
and the new tuple is ignored.

If no old tuple is found, then the new tuple is inserted, and the
update operations are **ignored**.

Indexes have no ``upsert`` method - this is a method of a space.

.. code-block:: tarantoolsession

    tarantool> s.index.pk.upsert == nil
    ---
    - true
    ...
    tarantool> s.index.sk_uniq.upsert == nil
    ---
    - true
    ...
    tarantool> s.upsert ~= nil
    ---
    - true
    ...
    tarantool> -- As the first argument, upsert accepts --
    tarantool> -- a well-formatted tuple, NOT a key! --
    tarantool> s:insert{1, 2, 3}
    ---
    - [1, 2, 3]
    ...
    tarantool> s:upsert({1}, {{'=', 2, 200}})
    ---
    - error: Tuple field 2 required by space format is missing
    ...
    tarantool> s:select{}
    ---
    - - [1, 2, 3]
    ...
    tarantool> s:delete{1}
    ---
    - [1, 2, 3]
    ...

``upsert`` turns into ``insert`` when no old tuple is found by the primary key.

.. code-block:: tarantoolsession

    tarantool> s:upsert({1, 2, 3}, {{'=', 2, 200}})
    ---
    ...
    tarantool> -- As you can see, {1, 2, 3} were inserted, --
    tarantool> -- and the update operations were not applied. --
    s:select{}
    ---
    - - [1, 2, 3]
    ...
    tarantool> -- Performing another upsert with the same primary key, --
    tarantool> -- but different values in the other fields. --
    s:upsert({1, 20, 30}, {{'=', 2, 200}})
    ---
    ...
    tarantool> -- The old tuple was found by the primary key {1} --
    tarantool> -- and update operations were applied. --
    tarantool> -- The new tuple was ignored. --
    tarantool> s:select{}
    ---
    - - [1, 200, 3]
    ...

``upsert`` searches for an old tuple by the primary index,
NOT by a secondary index. This can lead to a duplication error
if the new tuple ruins the uniqueness of a secondary index.

.. code-block:: tarantoolsession

    tarantool> s:upsert({2, 200, 3}, {{'=', 3, 300}})
    ---
    - error: Duplicate key exists in unique index 'sk_uniq' in space 'test'
    ...
    s:select{}
    ---
    - - [1, 200, 3]
    ...
    tarantool> -- But this works, when uniqueness is preserved. --
    tarantool> s:upsert({2, 0, 0}, {{'=', 3, 300}})
    ---
    ...
    tarantool> s:select{}
    ---
    - - [1, 200, 3]
      - [2, 0, 0]
    ...
    tarantool> s:truncate()
    ---
    ...

.. _box_space-operations-replace:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
REPLACE
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

``replace`` accepts a well-formatted tuple and searches for an old tuple
by the primary key of the new tuple.

If the old tuple is found, then it is deleted, and the new tuple is inserted.

If the old tuple was not found, then just the new tuple is inserted.

.. code-block:: tarantoolsession

    tarantool> s:replace{1, 2, 3}
    ---
    - [1, 2, 3]
    ...
    tarantool> s:select{}
    ---
    - - [1, 2, 3]
    ...
    tarantool> s:replace{1, 3, 4}
    ---
    - [1, 3, 4]
    ...
    tarantool> s:select{}
    ---
    - - [1, 3, 4]
    ...
    tarantool> s:truncate()
    ---
    ...

``replace`` can ruin unique constraints, like ``upsert`` does.

.. code-block:: tarantoolsession

    tarantool> s:insert{1, 1, 1}
    ---
    - [1, 1, 1]
    ...
    tarantool> s:insert{2, 2, 2}
    ---
    - [2, 2, 2]
    ...
    tarantool> -- This replace fails, because if the new tuple {1, 2, 0} replaces --
    tarantool> -- the old tuple by the primary key from 'pk' index {1, 1, 1}, --
    tarantool> -- this results in a duplicate unique secondary key in 'sk_uniq' index: --
    tarantool> -- key {2} is used both in the new tuple and in {2, 2, 2}. --
    tarantool> s:replace{1, 2, 0}
    ---
    - error: Duplicate key exists in unique index 'sk_uniq' in space 'test'
    ...
    tarantool> s:truncate()
    ---
    ...

.. _box_space-operations-select:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
SELECT
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

``select`` works with any indexes (primary/secondary) and with any keys
(unique/non-unique, full/partial).

If a key is partial, then ``select`` searches by all keys, where the prefix
matches the specified key part.

.. code-block:: tarantoolsession

    tarantool> s:insert{1, 2, 3}
    ---
    - [1, 2, 3]
    ...
    tarantool> s:insert{4, 5, 6}
    ---
    - [4, 5, 6]
    ...
    tarantool> s:insert{7, 8, 9}
    ---
    - [7, 8, 9]
    ...
    tarantool> s:insert{10, 11, 9}
    ---
    - [10, 11, 9]
    ...
    tarantool> s:select{1}
    ---
    - - [1, 2, 3]
    ...
    tarantool> s:select{}
    ---
    - - [1, 2, 3]
      - [4, 5, 6]
      - [7, 8, 9]
      - [10, 11, 9]
    ...
    tarantool> s.index.pk:select{4}
    ---
    - - [4, 5, 6]
    ...
    tarantool> s.index.sk_uniq:select{8}
    ---
    - - [7, 8, 9]
    ...
    tarantool> s.index.sk_non_uniq:select{9}
    ---
    - - [7, 8, 9]
      - [10, 11, 9]
    ...



-------------------------------------------------------------------------------
Using box.space functions to read _space tuples
-------------------------------------------------------------------------------

This function will illustrate how to look at all the spaces, and for each
display: approximately how many tuples it contains, and the first field of
its first tuple. The function uses Tarantool ``box.space`` functions ``len()``
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

And here is what happens when one invokes the function:

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

The objective is to display field names and field types of a system space --
using metadata to find metadata.

To begin: how can one select the ``_space`` tuple that describes ``_space``?

A simple way is to look at the constants in ``box.schema``,
which tell us that there is an item named SPACE_ID == 288,
so these statements will retrieve the correct tuple:

.. code-block:: lua

    box.space._space:select{ 288 }
    -- or --
    box.space._space:select{ box.schema.SPACE_ID }

Another way is to look at the tuples in ``box.space._index``,
which tell us that there is a secondary index named 'name' for space
number 288, so this statement also will retrieve the correct tuple:

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
