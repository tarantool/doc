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

g.test_indexes = function(cg)
    cg.server:exec(function()
        -- Create a space --
        box.schema.space.create('tester')

        -- Use the 'unicode' collation --
        box.space.tester:create_index('unicode', { parts = { { field = 1,
                                                                type = 'string',
                                                                collation = 'unicode' } } })

        -- Use the 'unicode_ci' collation --
        box.space.tester:create_index('unicode_ci', { parts = { { field = 1,
                                                                type = 'string',
                                                                collation = 'unicode_ci' } } })

        -- Insert test data --
        box.space.tester:insert { 'ЕЛЕ' }
        box.space.tester:insert { 'елейный' }
        box.space.tester:insert { 'ёлка' }

        -- Returns nil --
        select_unicode = box.space.tester.index.unicode:select({ 'ЁлКа' })
        -- Returns 'ёлка' --
        select_unicode_ci = box.space.tester.index.unicode_ci:select({ 'ЁлКа' })

        -- Tests --
        t.assert_equals(select_unicode[1], nil)
        t.assert_equals(select_unicode_ci[1], { 'ёлка' })
    end)
end
