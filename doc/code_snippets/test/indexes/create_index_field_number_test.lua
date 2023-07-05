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
        bands = box.schema.space.create('bands')

        -- Specify field names and types --
        box.space.bands:format({
            { name = 'id', type = 'unsigned' },
            { name = 'band_name', type = 'string' },
            { name = 'year', type = 'unsigned' }
        })

        -- Create a primary index --
        box.space.bands:create_index('primary', { parts = { 1 } })

        -- Create a unique secondary index --
        box.space.bands:create_index('band', { parts = { 2 } })

        -- Create a non-unique secondary index --
        box.space.bands:create_index('year', { parts = { { 3 } }, unique = false })

        -- Create a multi-part index --
        box.space.bands:create_index('year_band', { parts = { 3, 2 } })

        -- Insert test data --
        box.space.bands:insert { 1, 'Roxette', 1986 }
        box.space.bands:insert { 2, 'Scorpions', 1965 }
        box.space.bands:insert { 3, 'Ace of Base', 1987 }
        box.space.bands:insert { 4, 'The Beatles', 1960 }
        box.space.bands:insert { 5, 'Pink Floyd', 1965 }
        box.space.bands:insert { 6, 'The Rolling Stones', 1962 }
        box.space.bands:insert { 7, 'The Doors', 1965 }
        box.space.bands:insert { 8, 'Nirvana', 1987 }
        box.space.bands:insert { 9, 'Led Zeppelin', 1968 }
        box.space.bands:insert { 10, 'Queen', 1970 }

        select_all = bands.index.band:select()
        select_one = bands.index.year_band:select { 1960, 'The Beatles' }
        select_limit = bands.index.year:select({ 1965 }, { iterator = 'GT', limit = 3 })
        select_after_tuple = bands.index.primary:select({}, { after = { 4, 'The Beatles', 1960 }, limit = 3 })

        result, position = bands.index.primary:select({}, { limit = 3, fetch_pos = true })
        select_after_position = bands.index.primary:select({}, { limit = 3, after = position })

        -- Tests --
        t.assert_equals(select_all[1], { 3, 'Ace of Base', 1987 })
        t.assert_equals(select_one[1], {4, 'The Beatles', 1960})
        t.assert_equals(select_limit, { { 9, 'Led Zeppelin', 1968 }, { 10, 'Queen', 1970 }, { 1, 'Roxette', 1986 } })
        t.assert_equals(select_after_tuple, { { 5, 'Pink Floyd', 1965 }, { 6, 'The Rolling Stones', 1962 }, { 7, 'The Doors', 1965 } })
        t.assert_equals(select_after_position, { { 4, 'The Beatles', 1960 }, { 5, 'Pink Floyd', 1965 }, { 6, 'The Rolling Stones', 1962 } })
    end)
end