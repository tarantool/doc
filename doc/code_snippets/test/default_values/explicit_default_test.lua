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
    cg.server:drop()
    fio.rmtree(cg.server.workdir)
end)

g.test_default_values = function(cg)
    cg.server:exec(function()
        -- configure_space_start
        local books = box.schema.space.create('books')
        books:format({
            { name = 'id', type = 'number' },
            { name = 'name', type = 'string' },
            { name = 'year', type = 'number', default = 2024 },
        })
        books:create_index('primary', { parts = { 1 } })
        -- configure_space_end

        -- insert_ok_start
        books:insert { 1, 'Thinking in Java' }
        books:insert { 2, 'How to code in Go', nil }
        -- insert_ok_end

        -- Tests --
        t.assert_equals(books:count(), 2)
        t.assert_equals(books:get(1), { 1, 'Thinking in Java', 2024 })
    end)
end