..  _index-box-data_schema_description:

Data schema description
=======================

In Tarantool, the use of a data schema is optional.

When creating a :term:`space <space>`, you do not have to define a data schema. In this case,
the tuples store random data. This rule does not apply to indexed fields.
Such fields must contain data of the same type.

You can define a data schema when creating a space. Read more in the description of the
:doc:`/reference/reference_lua/box_schema/space_create` function.
If you have already created a space without specifying a data schema, you can do it later using
:doc:`/reference/reference_lua/box_space/format`.

After the data schema is defined, all the data is validated by type. Before any insert or update,
you will get an error if the data types do not match.

We recommend using a data schema because it helps avoid mistakes.

In Tarantool, you can define a data schema in two different ways.

Data schema description in a code file
--------------------------------------

The code file is usually called ``init.lua`` and contains the following schema description:

..  code:: lua

    box.cfg()

    users = box.schema.create_space('users', { if_not_exists = true })
    users:format({{ name = 'user_id', type = 'number'}, { name = 'fullname', type = 'string'}})

    users:create_index('pk', { parts = { { field = 'user_id', type = 'number'}}})

This is quite simple: when you run tarantool, it executes this code and creates
a data schema. To run this file, use:

..  code:: bash

    tarantool init.lua

However, it may seem complicated if you do not plan to dive deep into the Lua language and its syntax.

Possible difficulty: the snippet above has a function call with a colon: ``users:format``.
It is used to pass the ``users`` variable as the first argument
of the ``format`` function.
This is similar to ``self`` in object-based languages.

So it might be more convenient for you to describe the data schema with YAML.

..  _data-schema-ddl:

Data schema description using the DDL module
--------------------------------------------

The `DDL module <https://github.com/tarantool/ddl>`_ allows you to describe a data schema
in the YAML format in a declarative way.

The schema would look something like this:

..  code-block:: yaml

    spaces:
      users:
        engine: memtx
        is_local: false
        temporary: false
        format:
        - {name: user_id, type: uuid, is_nullable: false}
        - {name: fullname, type: string,  is_nullable: false}
        - {name: bucket_id, type: unsigned, is_nullable: false}
        indexes:
        - name: user_id
          unique: true
          parts: [{path: user_id, type: uuid, is_nullable: false}]
          type: HASH
        - name: bucket_id
          unique: false
          parts: [{path: bucket_id, type: unsigned, is_nullable: false}]
          type: TREE
        sharding_key: [user_id]
        sharding_func: test_module.sharding_func

This alternative is simpler to use, and you do not have to dive deep into Lua.

``DDL`` is a built-in
:doc:`Cartridge </book/cartridge/index>` module.
Cartridge is a cluster solution for Tarantool. In its WebUI, there is a separate tab
called "Code". On this tab, in the ``schema.yml`` file, you can define the schema, check its correctness,
and apply it to the whole cluster.

If you do not use Cartridge, you can still use the DDL module:
put the following Lua code into the file that you use to run Tarantool.
This file is usually called ``init.lua``.

..  code:: lua

    local yaml = require('yaml')
    local ddl = require('ddl')

    box.cfg{}

    local fh = io.open('ddl.yml', 'r')
    local schema = yaml.decode(fh:read('*all'))
    fh:close()
    local ok, err = ddl.check_schema(schema)
    if not ok then
        print(err)
    end
    local ok, err = ddl.set_schema(schema)
    if not ok then
        print(err)
    end

..  WARNING::

    It is forbidden to modify the data schema in DDL after it has been applied.
    For migration, there are different scenarios described in the :ref:`Migrations <migrations>` section.
