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

g.test_foreign_keys = function(cg)
    cg.server:exec(function()

        -- Parent space --
        customers = box.schema.space.create('customers')
        customers:format{
            {name = 'id', type = 'number'},
            {name = 'name', type = 'string'}
        }

        customers:create_index('primary', { parts = { 1 } })
        customers:create_index('name', { parts = { 2 } })
        customers:create_index('id_name', { parts = { 1, 2 } })

        customers:insert({1, 'Alice'})

        -- Create a space with a field foreign key --
        box.schema.space.create('orders')

        box.space.orders:format({
            {name = 'id',   type = 'number'},
            {name = 'customer_id', foreign_key = {space = 'customers', field = 'id'}},
            {name = 'price_total',  type = 'number'},
        })

        orders = box.space.orders
        orders:create_index('primary', { parts = { 1 } })

        orders:insert({1, 1, 100})

        t.assert_equals(orders:count(), 1)
        t.assert_equals(orders:get(1), {1, 1, 100})

        -- Failed foreign key check --
        t.assert_error_msg_contains("Foreign key constraint 'customers' failed for field '2 (customer_id)': foreign tuple was not found",
                function() orders:insert{2, 10, 200} end)

    end)
end