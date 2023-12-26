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
        box.space.bands:create_index('primary', { parts = { 'id' } })

        -- Create a unique secondary index --
        box.space.bands:create_index('band', { parts = { 'band_name' } })

        -- Create a non-unique secondary index --
        box.space.bands:create_index('year', { parts = { { 'year' } }, unique = false })

        -- Create a multi-part index --
        box.space.bands:create_index('year_band', { parts = { { 'year' }, { 'band_name' } } })

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

        -- Count the number of tuples that match the full key value
        count = box.space.bands.index.year:count(1965)
        --[[
        ---
        - 3
        ...
        --]]

        -- Count the number of tuples that match the partial key value
        count_partial = box.space.bands.index.year_band:count(1965)
        --[[
        ---
        - 3
        ...
        --]]

        -- Find the minimum value in the specified index
        min = box.space.bands.index.year:min()
        --[[
        ---
        - [4, 'The Beatles', 1960]
        ...
        --]]

        -- Find the minimum value that matches the partial key value
        min_partial = box.space.bands.index.year_band:min(1965)
        --[[
        ---
        - [5, 'Pink Floyd', 1965]
        ...
        --]]

        -- Find the maximum value in the specified index
        max = box.space.bands.index.year:max()
        --[[
        ---
        - [8, 'Nirvana', 1987]
        ...
        --]]

        -- Find the maximum value that matches the partial key value
        max_partial = box.space.bands.index.year_band:max(1965)
        --[[
        ---
        - [7, 'The Doors', 1965]
        ...
        --]]

        -- Tests --
        t.assert_equals(count, 3)
        t.assert_equals(count_partial, 3)
        t.assert_equals(min, { 4, 'The Beatles', 1960 })
        t.assert_equals(min_partial, { 5, 'Pink Floyd', 1965 })
        t.assert_equals(max, { 8, 'Nirvana', 1987 })
        t.assert_equals(max_partial, { 7, 'The Doors', 1965 })
    end)
end
