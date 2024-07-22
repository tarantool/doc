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

g.test_default_func = function(cg)
    cg.server:exec(function()

        -- create_no_arg_function_start
        box.schema.func.create('current_year', {
            language = 'Lua',
            body = "function() return require('datetime').now().year end"
        })
        -- create_no_arg_function_end

        -- format_space_default_func_start
        local books = box.schema.space.create('books')
        books:format({
            { name = 'id', type = 'unsigned' },
            { name = 'isbn', type = 'string' },
            { name = 'title', type = 'string' },
            { name = 'year', type = 'unsigned', default_func = 'current_year' }
        })
        books:create_index('primary', { parts = { 1 } })
        -- format_space_default_func_end

        -- insert_ok_start
        books:insert { 1, '978000', 'Thinking in Java' }
        -- insert_ok_end

        -- create_arg_function_start
        box.schema.func.create('randomize', {
            language = 'Lua',
            body = "function(limit) return math.random(limit.min, limit.max) end"
        })
        -- create_arg_function_end

        -- reformat_space_start
        books:format({
            { name = 'id', type = 'unsigned', default_func= 'randomize', default = {min = 0, max = 1000} },
            { name = 'isbn', type = 'string' },
            { name = 'title', type = 'string' },
            { name = 'year', type = 'unsigned', default_func = 'current_year' }
        })
        -- reformat_space_end

        books:insert { nil, '978001', 'How to code in Go' }

        -- Tests --
        t.assert_equals(books:count(), 2)
        t.assert_equals(books:get(1), { 1, '978000','Thinking in Java', 2024 })
    end)
end