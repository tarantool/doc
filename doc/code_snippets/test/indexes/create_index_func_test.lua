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

g.test_func_index = function(cg)
    cg.server:exec(function()
        box.schema.space.create('tester')
        box.space.tester:create_index('i', { parts = { { field = 1, type = 'string' } } })
        function_code = [[function(tuple) return {string.sub(tuple[2],1,1)} end]]
        box.schema.func.create('my_func',
                { body = function_code, is_deterministic = true, is_sandboxed = true })
        box.space.tester:create_index('func_index', { parts = { { field = 1, type = 'string' } },
                                                      func = 'my_func' })
        box.space.tester:insert({ 'a', 'wombat' })
        box.space.tester:insert({ 'b', 'rabbit' })
        box.space.tester.index.func_index:select('w')
        box.space.tester.index.func_index:select(box.func.my_func:call({ { 'tester', 'wombat' } }))

        -- Tests --
        t.assert_equals(box.space.tester.index.func_index:select('w')[1], { 'a', 'wombat' })
        t.assert_equals(box.space.tester.index.func_index:select(box.func.my_func:call({ { 'tester', 'wombat' } }))[1], { 'a', 'wombat' })
    end)
end