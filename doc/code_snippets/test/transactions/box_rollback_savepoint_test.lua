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
    cg.server:stop()
    cg.server:drop()
end)

g.test_space_is_updated_partially = function(cg)
    cg.server:exec(function()
        -- Insert test data --
        box.space.bands:insert { 1, 'Roxette', 1986 }
        box.space.bands:insert { 2, 'Scorpions', 1965 }
        box.space.bands:insert { 3, 'Ace of Base', 1987 }

        -- Rollback the transaction to a savepoint --
        box.begin()
        box.space.bands:insert { 4, 'The Beatles', 1960 }
        save1 = box.savepoint()
        box.space.bands:replace { 1, 'Pink Floyd', 1965 }
        box.rollback_to_savepoint(save1)
        box.commit()

        t.assert_equals(box.space.bands:count(), 4)
        t.assert_equals(box.space.bands:select { 1 }[1], { 1, 'Roxette', 1986 })
    end)
end