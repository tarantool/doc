.. _json_paths-module:

-------------------------------------------------------------------------------
                            JSON paths
-------------------------------------------------------------------------------

===============================================================================
                                   Overview
===============================================================================

Since version :doc:`2.3 </release/2.3>, Tarantool supports JSON path updates.
You can update or upsert formatted :doc:`tuple </reference/reference_lua/box_tuple/update>` /
:ref:`space <box_space-update>` /
:doc:`index </reference/reference_lua/box_index/update>`
fields by name (not only by field number). Updates of nested structures are also supported.

**Example:**

.. code-block:: tarantoolsession

        tarantool> box.cfg{};
                 > format = {};
                 > format[1] = {'field1', 'unsigned'};
                 > format[2] = {'field2', 'map'};
                 > format[3] = {'field3', 'array'};
                 > format[4] = {'field4', 'string', is_nullable = true}
        ---
        ...
        tarantool> s = box.schema.create_space('test', {format = format});
                 > _ = s:create_index('pk')
        ---
        ...
        tarantool> t = {
                 >     1,
                 >     {
                 >         key1 = 'value',
                 >         key2 = 10
                 >     },
                 >     {
                 >         2,
                 >         3,
                 >         {key3 = 20}
                 >     }
                 > }
        ---
        ...
        tarantool> t = s:replace(t)
        ---
        ...
        tarantool> t:update({{'=', 'field2.key1', 'new_value'}})
        ---
        - [1, {'key1': 'new_value', 'key2': 10}, [2, 3, {'key3': 20}]]
        ...
        tarantool> t:update({{'+', 'field3[2]', 1}})
        ---
        - [1, {'key1': 'value', 'key2': 10}, [2, 4, {'key3': 20}]]
        ...
        tarantool> s:update({1}, {{'!', 'field4', 'inserted value'}})
        ---
        - [1, {'key1': 'value', 'key2': 10}, [2, 3, {'key3': 20}], 'inserted value']
        ...
        tarantool> s:update({1}, {{'#', '[2].key2', 1}, {'=', '[3][3].key4', 'value4'}})
        ---
        - [1, {'key1': 'value'}, [2, 3, {'key3': 20, 'key4': 'value4'}], 'inserted value']
        ...
        tarantool> s:upsert({1, {k = 'v'}, {}}, {{'#', '[2].key1', 1}})
        ---
        ...
        tarantool> s:select{}
        ---
        - - [1, {}, [2, 3, {'key3': 20, 'key4': 'value4'}], 'inserted value']
        ...

Notice that field names that look like JSON paths are processed similarly to
:doc:`accessing tuple fields by JSON </reference/reference_lua/box_tuple/field_path>`:
first, the whole path is interpreted as a field name; if such a name does not exist,
then it is treated as a path.

For example, for a field name ``field.name.like.json``, this update

.. cssclass:: highlight
.. parsed-literal::

    :samp:`{object-name}:update({..., 'field.name.like.json', ...})`

will update this field instead of keys ``field`` -> ``name`` ->
``like`` -> ``json``. If you need such a name as part of a bigger
path, then you should wrap it in quotes ``""`` and brackets ``[]``:

.. cssclass:: highlight
.. parsed-literal::

    :samp:`{object-name}:update({..., '["field.name.like.json"].next.fields', ...})`

**There are some rules for JSON updates:**

* Operation ``'!'`` can't be used to create all intermediate nodes of
  a path. For example, ``{'!', 'field1[1].field3', ...}`` can't
  create fields ``'field1'`` and ``'[1]'``, they should exist.

* Operation ``'#'``, when applied to maps, can't delete more than one
  key at once. That is, its argument should be always 1 for maps.

  ``{'#', 'field1.field2', 1}`` is allowed;

  ``{'#', 'field1.field2', 10}`` is not.

  This limitation originates from the problem that keys in a map
  are not ordered anyhow, and ``'#'`` with more than 1 key would lead
  to undefined behavior.

* Operation ``'!'`` on maps can't create a key, if it exists already.

* If a map contains non-string keys (booleans, numbers, maps,
  arrays - anything), then these keys can't be updated via JSON
  paths. But it is still allowed to update string keys in such a
  map.

**Why JSON updates are good, and should be preferred when only a part of a tuple
needs to be updated:**

* They consume less space in WAL, because for an update only its
  keys, operations, and arguments are stored. It is cheaper to
  store an update of one deep field than of the whole tuple.

* They are faster. Firstly, this is because they are implemented
  in C, and have no problems with Lua GC and dynamic typing.
  Secondly, some cases of JSON paths are highly optimized. For
  example, an update with a single JSON path costs O(1) memory
  regardless of how deep that path goes (not counting update
  arguments).

* They are available from remote clients, as well as any other DML. Before JSON
  updates became available in Tarantool, to update one deep part of a tuple, it
  was necessary to download that tuple, update it in memory, and send it back --
  2 network hops. With JSON paths, it can be 1 hop when the update can be described in paths.
