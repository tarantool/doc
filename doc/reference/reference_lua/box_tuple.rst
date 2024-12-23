.. _box_tuple:

-------------------------------------------------------------------------------
                            Submodule box.tuple
-------------------------------------------------------------------------------

The ``box.tuple`` submodule provides read-only access for the ``tuple``
userdata type. It allows, for a single :ref:`tuple <index-box_tuple>`: selective
retrieval of the field contents, retrieval of information about size, iteration
over all the fields, and conversion to a `Lua table <https://www.lua.org/pil/2.5.html>`_.

Below is a list of all ``box.tuple`` functions.

..  container:: table

    ..  rst-class:: left-align-column-1
    ..  rst-class:: left-align-column-2

    ..  list-table::
        :widths: 25 75
        :header-rows: 1

        *   - Name
            - Use

        *  - :doc:`./box_tuple/new`
           - Create a tuple

        *  - :doc:`./box_tuple/is`
           - Check whether a given object is a tuple

        *  - :doc:`./box_tuple/count_fields`
           - Count tuple fields

        *  - :doc:`./box_tuple/bsize`
           - Get count of bytes in a tuple

        *  - :doc:`./box_tuple/field_number`
           - Get a tuple's field by specifying a number

        *  - :doc:`./box_tuple/field_name`
           - Get a tuple's field by specifying a name

        *  - :doc:`./box_tuple/field_path`
           - Get a tuple's fields or parts by specifying a path

        *  - :doc:`./box_tuple/find`
           - Get the number of the first field/all fields matching the search value

        *  - :doc:`./box_tuple/format`
           - Get the format of a tuple

        *  - :doc:`./box_tuple/info`
           - Get information about the tuple

        *  - :doc:`./box_tuple/next`
           - Get the next field value from tuple

        *  - :doc:`./box_tuple/pairs`
           - Prepare for iterating

        *  - :doc:`./box_tuple/totable`
           - Get a tuple's fields as a table

        *  - :doc:`./box_tuple/tomap`
           - Get a tuple's fields as a table along with key:value pairs

        *  - :doc:`./box_tuple/transform`
           - Remove (and replace) a tuple's fields

        *  - :doc:`./box_tuple/unpack`
           - Get a tuple's fields

        *  - :doc:`./box_tuple/update`
           - Update a tuple

        *  - :doc:`./box_tuple/upsert`
           - Update a tuple ignoring errors

.. toctree::
    :hidden:

    box_tuple/new
    box_tuple/is
    box_tuple/count_fields
    box_tuple/bsize
    box_tuple/field_number
    box_tuple/field_name
    box_tuple/field_path
    box_tuple/find
    box_tuple/format
    box_tuple/info
    box_tuple/next
    box_tuple/pairs
    box_tuple/totable
    box_tuple/tomap
    box_tuple/transform
    box_tuple/unpack
    box_tuple/update
    box_tuple/upsert

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
