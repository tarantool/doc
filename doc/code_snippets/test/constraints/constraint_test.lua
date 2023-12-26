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

g.test_constraints = function(cg)
    cg.server:exec(function()

        -- Define a tuple constraint function --
        box.schema.func.create('check_person', {
            language = 'LUA',
            is_deterministic = true,
            body = 'function(t, c) return (t.age >= 0 and #(t.name) > 3) end'
        })

        -- Create a space with a tuple constraint --
        customers = box.schema.space.create('customers', {constraint = 'check_person'})

        -- Define a field constraint function --
        box.schema.func.create('check_age', {
            language = 'LUA',
            is_deterministic = true,
            body = 'function(f, c) return (f >= 0 and f < 150) end'
        })

        -- Specify format with a field constraint --
        box.space.customers:format({
            {name = 'id', type = 'number'},
            {name = 'name', type = 'string'},
            {name = 'age',  type = 'number', constraint = 'check_age'},
        })

        box.space.customers:create_index('primary', { parts = { 1 } })

        box.space.customers:insert{1, "Alice", 30}

        -- Tests --
        t.assert_equals(customers:count(), 1)
        t.assert_equals(customers:get(1), {1, "Alice", 30})

        -- Failed contstraint --
        t.assert_error_msg_contains("Check constraint 'check_person' failed for a tuple",
                function() customers:insert{2, "Bob", 230} end)

        -- Create one more tuple constraint --
        box.schema.func.create('another_constraint',
            {language = 'LUA', is_deterministic = true, body = 'function(t, c) return true end'})

        -- Set two constraints with optional names --
        box.space.customers:alter{
            constraint = { check1 = 'check_person', check2 = 'another_constraint'}
        }
    end)
end