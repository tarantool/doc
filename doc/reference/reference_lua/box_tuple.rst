.. _box_tuple:

-------------------------------------------------------------------------------
                            Submodule `box.tuple`
-------------------------------------------------------------------------------

The ``box.tuple`` submodule provides read-only access for the ``tuple``
userdata type. It allows, for a single :ref:`tuple <index-box_tuple>`: selective
retrieval of the field contents, retrieval of information about size, iteration
over all the fields, and conversion to a `Lua table <https://www.lua.org/pil/2.5.html>`_.

Below is a list of all ``box.tuple`` functions.

.. container:: table

    .. rst-class:: left-align-column-1
    .. rst-class:: left-align-column-2

    +--------------------------------------+---------------------------------+
    | Name                                 | Use                             |
    +======================================+=================================+
    | :ref:`box.tuple.new()                | Create a tuple                  |
    | <box_tuple-new>`                     |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`#tuple_object                  | Count tuple fields              |
    | <box_tuple-count_fields>`            |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`tuple_object:bsize()           | Get count of bytes in a tuple   |
    | <box_tuple-bsize>`                   |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`tuple_object[field-number]     | Get a tuple's field by          |
    | <box_tuple-field_number>`            | specifying a number             |
    +--------------------------------------+---------------------------------+
    | :ref:`tuple_object[field-name]       | Get a tuple's field by          |
    | <box_tuple-field_name>`              | specifying a name               |
    +--------------------------------------+---------------------------------+
    | :ref:`tuple_object[field-path]       | Get a tuple's fields or parts   |
    | <box_tuple-field_path>`              | by specifying a path            |
    +--------------------------------------+---------------------------------+
    | :ref:`tuple_object:find()            | Get the number of the first     |
    | <box_tuple-find>`                    | field matching the search value |
    +--------------------------------------+---------------------------------+
    | :ref:`tuple_object:findall()         | Get the number of all fields    |
    | <box_tuple-find>`                    | matching the search value       |
    +--------------------------------------+---------------------------------+
    | :ref:`tuple_object:next()            | Get the next field value from   |
    | <box_tuple-next>`                    | tuple                           |
    +--------------------------------------+---------------------------------+
    | :ref:`tuple_object:ipairs()          | Prepare for iterating           |
    | <box_tuple-pairs>`                   |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`tuple_object:pairs()           | Prepare for iterating           |
    | <box_tuple-pairs>`                   |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`tuple_object:totable()         | Get a tuple's fields as a table |
    | <box_tuple-totable>`                 |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`tuple_object:tomap()           | Get a tuple's fields as a table |
    | <box_tuple-tomap>`                   | along with key:value pairs      |
    +--------------------------------------+---------------------------------+
    | :ref:`tuple_object:transform()       | Remove (and replace) a tuple's  |
    | <box_tuple-transform>`               | fields                          |
    +--------------------------------------+---------------------------------+
    | :ref:`tuple_object:unpack()          | Get a tuple's fields            |
    | <box_tuple-unpack>`                  |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`tuple_object:update()          | Update a tuple                  |
    | <box_tuple-update>`                  |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`tuple_object:upsert()          | Update a tuple ignoring errors  |
    | <box_tuple-upsert>`                  |                                 |
    +--------------------------------------+---------------------------------+

.. toctree::
    :hidden:

    box_tuple/box_tuple_new
    box_tuple/box_tuple_count_fields
    box_tuple/box_tuple_bsize
    box_tuple/box_tuple_field_number
    box_tuple/box_tuple_field_name
    box_tuple/box_tuple_field_path
    box_tuple/box_tuple_find
    box_tuple/box_tuple_next
    box_tuple/box_tuple_pairs
    box_tuple/box_tuple_totable
    box_tuple/box_tuple_tomap
    box_tuple/box_tuple_transform
    box_tuple/box_tuple_unpack
    box_tuple/box_tuple_update
    box_tuple/box_tuple_upsert


===========================================================
How to convert tuples to/from Lua tables
===========================================================

This function will illustrate how to convert tuples to/from Lua tables and lists
of scalars:

.. code-block:: lua

    tuple = box.tuple.new({scalar1, scalar2, ... scalar_n}) -- scalars to tuple
    lua_table = {tuple:unpack()}                            -- tuple to Lua table
    lua_table = tuple:totable()                             -- tuple to Lua table
    scalar1, scalar2, ... scalar_n = tuple:unpack()         -- tuple to scalars
    tuple = box.tuple.new(lua_table)                        -- Lua table to tuple

Then it will find the field that contains 'b', remove that field from the tuple,
and display how many bytes remain in the tuple. The function uses Tarantool
``box.tuple`` functions ``new()``, ``unpack()``, ``find()``, ``transform()``,
``bsize()``.

.. code-block:: lua

    function example()
      local tuple1, tuple2, lua_table_1, scalar1, scalar2, scalar3, field_number
      local luatable1 = {}
      tuple1 = box.tuple.new({'a', 'b', 'c'})
      luatable1 = tuple1:totable()
      scalar1, scalar2, scalar3 = tuple1:unpack()
      tuple2 = box.tuple.new(luatable1[1],luatable1[2],luatable1[3])
      field_number = tuple2:find('b')
      tuple2 = tuple2:transform(field_number, 1)
      return 'tuple2 = ' , tuple2 , ' # of bytes = ' , tuple2:bsize()
    end

... And here is what happens when one invokes the function:

.. code-block:: tarantoolsession

    tarantool> example()
    ---
    - tuple2 =
    - ['a', 'c']
    - ' # of bytes = '
    - 5
    ...
