local fio = require('fio')
local server = require('luatest.server')
local t = require('luatest')
local g = t.group()
g.before_each(function(cg)
    cg.server = server:new {
        box_cfg = {},
        workdir = fio.cwd() .. '/tmp'
    }
    cg.server:start()
end)

g.after_each(function(cg)
    cg.server:stop()
    cg.server:drop()
end)

g.test_sequence = function(cg)
    cg.server:exec(function()
        -- Create a sequence --
        box.schema.sequence.create('id_seq',{min=1000, start=1000})
        --[[
        ---
        - step: 1
          id: 1
          min: 1000
          cache: 0
          uid: 1
          cycle: false
          name: id_seq
          start: 1000
          max: 9223372036854775807
        ...
        --]]

        -- Get the next item --
        box.sequence.id_seq:next()
        --[[
        ---
        - 1000
        ...
        --]]

        -- Create a space --
        box.schema.space.create('customers')

        -- Create an index that uses the sequence --
        box.space.customers:create_index('primary',{ sequence = 'id_seq' })
        --[[
        ---
        - parts:
          - type: unsigned
            is_nullable: false
            fieldno: 1
          sequence_id: 1
          id: 0
          space_id: 513
          unique: true
          hint: true
          type: TREE
          name: primary
          sequence_fieldno: 1
        ...
        --]]

        -- Insert a tuple without the primary key value --
        box.space.customers:insert{ nil, 'Adams' }
        --[[
        ---
        - [1001, 'Adams']
        ...
        --]]

        -- Create a space --
        box.schema.space.create('orders')

        -- Create an index that uses an auto sequence --
        box.space.orders:create_index( 'primary', { sequence = true })

        -- Check the connections between spaces and sequences
        box.space._space_sequence:select{}
        --[[
        ---
        - - [512, 1, false, 0, '']
          - [513, 2, true, 0, '']
        ...
        --]]

        -- Tests --
        t.assert_equals(box.sequence.id_seq:next(), 1002)
        t.assert_equals(box.space.customers:insert{ nil, 'Adams' }, {1003, 'Adams'})
        t.assert_equals(box.space.orders:insert{ nil, 'test' }, {1, 'test'})
        t.assert_equals(box.space._space_sequence:select{}, { { 512, 1, false, 0, '' }, { 513, 2, true, 0, '' }})

    end)
end
