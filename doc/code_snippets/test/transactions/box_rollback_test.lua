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
    cg.server:exec(function()
        box.schema.space.create('bands')
        box.space.bands:format({
            { name = 'id', type = 'unsigned' },
            { name = 'band_name', type = 'string' },
            { name = 'year', type = 'unsigned' }
        })
        box.space.bands:create_index('primary', { parts = { 'id' } })
    end)
end)

g.after_each(function(cg)
    cg.server:drop()
    fio.rmtree(cg.server.workdir)
end)

g.test_space_is_not_updated = function(cg)
    cg.server:exec(function()
        -- Insert test data --
        box.space.bands:insert { 1, 'Roxette', 1986 }
        box.space.bands:insert { 2, 'Scorpions', 1965 }
        box.space.bands:insert { 3, 'Ace of Base', 1987 }

        -- Rollback the transaction --
        box.begin()
        box.space.bands:insert { 4, 'The Beatles', 1960 }
        box.space.bands:replace { 1, 'Pink Floyd', 1965 }
        box.rollback()

        t.assert_equals(box.space.bands:count(), 3)
        t.assert_equals(box.space.bands:select { 1 }[1], { 1, 'Roxette', 1986 })
    end)
end