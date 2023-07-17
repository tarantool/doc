..  _box_space-format:

===============================================================================
space_object:format()
===============================================================================

..  class:: space_object

    ..  method:: format([format-clause])

        Declare field names and :ref:`types <index-box_data-types>`.

        :param space_object space_object: an :ref:`object reference
                                          <app_server-object_reference>`
        :param table format-clause: a list of field names and types

        :return: ``nil``, unless format-clause is omitted

        **Possible errors:**

        * ``space_object`` does not exist
        * field names are duplicated
        * type is not legal

        .. NOTE::

          If you need to make a schema migration, see section :ref:`Migrations <migrations>`.

        Ordinarily Tarantool allows unnamed untyped fields.
        But with ``format`` users can, for example, document
        that the Nth field is the surname field and must contain strings.
        It is also possible to specify a format clause in
        :doc:`box.schema.space.create() </reference/reference_lua/box_schema/space_create>`.

        The format clause contains, for each field, a definition within braces:
        ``{name='...',type='...'[,is_nullable=...]}``, where:

        * The ``name`` value may be any string, provided that two fields do not
          have the same name.
        * The ``type`` value may be any of allowed types: any | unsigned | string |
          integer | number | varbinary | boolean | double | decimal | uuid | array |
          map | scalar, but for creating an index use only
          :ref:`indexed fields <index-box_indexed-field-types>`;
        * (Optional) The ``is_nullable`` boolean value specifies whether ``nil`` can be used as a field value.
          See also: :ref:`key_part.is_nullable <key_part_is_nullable>`.
        * (Optional) The ``collation`` string value specifies the :ref:`collation <index-collation>` used to compare field values.
          See also: :ref:`key_part.collation <key_part_collation>`.
        * (Optional) The ``constraints`` table specifies the :ref:`constraints <index-constraints>` that the field value must satisfy.
        * (Optional) The ``foreign_key`` table specifies the :ref:`foreign key <index-box_foreign_keys>` for the field.

        It is not legal for tuples to contain values that have the wrong type.
        The example below will cause an error:

        ..  code-block:: lua

            --This example will cause an error.
            box.space.tester:format({{' ',type='number'}})
            box.space.tester:insert{'string-which-is-not-a-number'}

        It is not legal for tuples to contain null values if ``is_nullable=false``,
        which is the default. The example below will cause an error:

        ..  code-block:: lua

            --This example will cause an error.
            box.space.tester:format({{' ',type='number',is_nullable=false}})
            box.space.tester:insert{nil,2}


        It is legal for tuples to have more fields than are described by a format
        clause. The way to constrain the number of fields is to specify a space's
        :doc:`field_count </reference/reference_lua/box_space/field_count>` member.

        It is legal for tuples to have fewer fields than are described by a format
        clause, if the omitted trailing fields are described with ``is_nullable=true``.
        For example, the request below will not cause a format-related error:

        ..  code-block:: lua

            box.space.tester:format({{'a',type='number'},{'b',type='number',is_nullable=true}})
            box.space.tester:insert{2}


        It is legal to use ``format`` on a space that already has a format,
        thus replacing any previous definitions,
        provided that there is no conflict with existing data or index definitions.

        It is legal to use ``format`` to change the ``is_nullable`` flag.
        The example below will not cause an error -- and will not cause
        rebuilding of the space.

        ..  code-block:: lua

            box.space.tester:format({{' ',type='scalar',is_nullable=false}})
            box.space.tester:format({{' ',type='scalar',is_nullable=true}})

        But going the other way and changing ``is_nullable`` from ``true``
        to ``false`` might cause rebuilding and might cause an error if there
        are existing tuples with nulls.


        **Example:**

        ..  code-block:: lua

            box.space.tester:format({{name='surname',type='string'},{name='IDX',type='array'}})
            box.space.tester:format({{name='surname',type='string',is_nullable=true}})


        There are legal variations of the format clause:

        * omitting both 'name=' and 'type=',
        * omitting 'type=' alone,
        * adding extra braces.

        The following examples show all the variations,
        first for one field named 'x', second for two fields named 'x' and 'y'.

        ..  code-block:: lua

            box.space.tester:format({{name='x',type='scalar'}})
            box.space.tester:format({{name='x',type='scalar'},{name='y',type='unsigned'}})

            box.space.tester:format({{'x'}})
            box.space.tester:format({{'x'},{'y'}})

            -- types
            box.space.tester:format({{name='x'}})
            box.space.tester:format({{name='x'},{name='y'}})

            box.space.tester:format({{'x',type='scalar'}})
            box.space.tester:format({{'x',type='scalar'},{'y',type='unsigned'}})

            box.space.tester:format({{'x','scalar'}})
            box.space.tester:format({{'x','scalar'},{'y','unsigned'}})

        The following example shows how to create a space, format it with all
        possible types, and insert into it.

        ..  code-block:: tarantoolsession

            tarantool> box.schema.space.create('t')
            ---
            - engine: memtx
              before_replace: 'function: 0x4019c488'
              on_replace: 'function: 0x4019c460'
              ck_constraint: []
              field_count: 0
              temporary: false
              index: []
              is_local: false
              enabled: false
              name: t
              id: 534
            - created
            ...
            tarantool> ffi = require('ffi')
            ---
            ...
            tarantool> decimal = require('decimal')
            ---
            ...
            tarantool> uuid = require('uuid')
            ---
            ...
            tarantool> box.space.t:format({{name = '1', type = 'any'},
                     >                     {name = '2', type = 'unsigned'},
                     >                     {name = '3', type = 'string'},
                     >                     {name = '4', type = 'number'},
                     >                     {name = '5', type = 'double'},
                     >                     {name = '6', type = 'integer'},
                     >                     {name = '7', type = 'boolean'},
                     >                     {name = '8', type = 'decimal'},
                     >                     {name = '9', type = 'uuid'},
                     >                     {name = 'a', type = 'scalar'},
                     >                     {name = 'b', type = 'array'},
                     >                     {name = 'c', type = 'map'}})
            ---
            ...
            tarantool> box.space.t:create_index('i',{parts={2, type = 'unsigned'}})
            ---
            - unique: true
              parts:
              - type: unsigned
                is_nullable: false
                fieldno: 2
              id: 0
              space_id: 534
              type: TREE
              name: i
            ...
            tarantool> box.space.t:insert{{'a'}, -- any
                     >                    1, -- unsigned
                     >                    'W?', -- string
                     >                    5.5, -- number
                     >                    ffi.cast('double', 1), -- double
                     >                    -0, -- integer
                     >                    true, -- boolean
                     >                    decimal.new(1.2), -- decimal
                     >                    uuid.new(), -- uuid
                     >                    true, -- scalar
                     >                    {{'a'}}, -- array
                     >                    {val=1}} -- map
            ---
            - [['a'], 1, 'W?', 5.5, 1, 0, true, 1.2, 1f41e7b8-3191-483d-b46e-1aa6a4b14557, true, [['a']], {'val': 1}]
            ...

        Names specified with the format clause can be used in
        :doc:`/reference/reference_lua/box_space/get` and in
        :doc:`/reference/reference_lua/box_space/create_index` and in
        :doc:`/reference/reference_lua/box_tuple/field_name` and in
        :doc:`/reference/reference_lua/box_tuple/field_path`.

        If the format clause is omitted, then the returned value is the
        table that was used in a previous :samp:`{space_object}:format({format-clause})`
        invocation. For example, after ``box.space.tester:format({{'x','scalar'}})``,
        ``box.space.tester:format()`` will return ``[{'name': 'x', 'type': 'scalar'}]``.

        Formatting or reformatting a large space will cause occasional
        :ref:`yields <app-yields>`
        so that other requests will not be blocked.
        If the other requests cause an illegal situation such as a field value
        of the wrong type, the formatting or reformatting will fail.


        **Note regarding storage engine:** vinyl supports formatting of non-empty
        spaces. Primary index definition cannot be formatted.
