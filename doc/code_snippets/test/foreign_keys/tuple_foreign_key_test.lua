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

        -- Create a space with a tuple foreign key --
        box.schema.space.create("orders", {
            foreign_key = {
                space = 'customers',
                field = {customer_id = 'id', customer_name = 'name'}
            }
        })

        box.space.orders:format({
            {name = "id", type = "number"},
            {name = "customer_id" },
            {name = "customer_name"},
            {name = "price_total", type = "number"},
        })

        orders = box.space.orders
        orders:create_index('primary', { parts = { 1 } })

        orders:insert({1, 1, 'Alice', 100})

        t.assert_equals(orders:count(), 1)
        t.assert_equals(orders:get(1), {1, 1, 'Alice', 100})

        -- Failed foreign key check --
        t.assert_error_msg_contains("Foreign key constraint 'customers' failed: foreign tuple was not found",
                function() orders:insert{2, 10, 'Bob', 200} end)

        -- Set a foreign key with an optional name --
        box.space.orders:alter{
            foreign_key = {
                customer = {
                    space = 'customers',
                    field = { customer_id = 'id', customer_name = 'name'}
                }
            }
        }

        items = box.schema.space.create('items')
        items:format{{name = 'id', type = 'number'}}
        items:create_index('primary', { parts = { 1 } })

        orders:delete{1}
        orders:format({
            {name = "id", type = "number"},
            {name = "customer_id" },
            {name = "customer_name"},
            {name = "item_id", type = "number"},
            {name = "price_total", type = "number"},
        })

        -- Set two foreign keys: names are mandatory --
        box.space.orders:alter{
            foreign_key = {
                customer = {
                    space = 'customers',
                    field = {customer_id = 'id', customer_name = 'name'}
                },
                item = {
                    space = 'items',
                    field = {item_id = 'id'}
                }
            }
        }
    end)
end