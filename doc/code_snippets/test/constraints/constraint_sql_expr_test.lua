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
        -- create_constraint_start
        box.schema.func.create('check_person', {
            language = 'SQL_EXPR',
            is_deterministic = true,
            body = [["age" > 21 AND "name" != 'Admin']]
        })
        -- create_constraint_end

        -- configure_space_start
        local customers = box.schema.space.create('customers', { constraint = 'check_person' })
        customers:format({
            { name = 'id', type = 'number' },
            { name = 'name', type = 'string' },
            { name = 'age', type = 'number' },
        })
        customers:create_index('primary', { parts = { 1 } })
        -- configure_space_end

        -- insert_ok_start
        customers:insert { 1, "Alice", 30 }
        -- insert_ok_end

        local _, age_err = pcall(function()
            -- insert_age_error_start
            customers:insert { 2, "Bob", 18 }
            -- error: Check constraint 'check_person' failed for tuple
            -- insert_age_error_end
        end)

        local _, name_err = pcall(function()
            -- insert_name_error_start
            customers:insert { 3, "Admin", 25 }
            -- error: Check constraint 'check_person' failed for tuple
            -- insert_name_error_end
        end)

        -- Tests --
        t.assert_equals(customers:count(), 1)
        t.assert_equals(customers:get(1), { 1, "Alice", 30 })
        t.assert_equals(age_err:unpack().message, 'Check constraint \'check_person\' failed for a tuple')
        t.assert_equals(name_err:unpack().message, 'Check constraint \'check_person\' failed for a tuple')
    end)
end
