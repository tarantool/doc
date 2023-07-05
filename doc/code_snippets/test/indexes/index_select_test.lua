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

        -- Select a tuple by the specified primary key value --
        select_primary = bands.index.primary:select { 1 }
        --[[
        ---
        - - [1, 'Roxette', 1986]
        ...
        --]]

        -- Select a tuple by the specified secondary key value --
        select_secondary = bands.index.band:select { 'The Doors' }
        --[[
        ---
        - - [7, 'The Doors', 1965]
        ...
        --]]

        -- Select a tuple by the specified multi-part secondary key value --
        select_multipart = bands.index.year_band:select { 1960, 'The Beatles' }
        --[[
        ---
        - - [4, 'The Beatles', 1960]
        ...
        --]]

        -- Select tuples by the specified partial key value --
        select_multipart_partial = bands.index.year_band:select { 1965 }
        --[[
        ---
        - - [5, 'Pink Floyd', 1965]
          - [2, 'Scorpions', 1965]
          - [7, 'The Doors', 1965]
        ...
        --]]

        -- Select maximum 3 tuples by the specified secondary index --
        select_limit = bands.index.band:select({}, { limit = 3 })
        --[[
        ---
        - - [3, 'Ace of Base', 1987]
          - [9, 'Led Zeppelin', 1968]
          - [8, 'Nirvana', 1987]
        ...
        --]]

        -- Select maximum 3 tuples with the key value greater than 1965 --
        select_greater = bands.index.year:select({ 1965 }, { iterator = 'GT', limit = 3 })
        --[[
        ---
        - - [9, 'Led Zeppelin', 1968]
          - [10, 'Queen', 1970]
          - [1, 'Roxette', 1986]
        ...
        --]]

        -- Select maximum 3 tuples after the specified tuple --
        select_after_tuple = bands.index.primary:select({}, { after = { 4, 'The Beatles', 1960 }, limit = 3 })
        --[[
        ---
        - - [5, 'Pink Floyd', 1965]
          - [6, 'The Rolling Stones', 1962]
          - [7, 'The Doors', 1965]
        ...
        --]]

        -- Select first 3 tuples and fetch a last tuple's position --
        result, position = bands.index.primary:select({}, { limit = 3, fetch_pos = true })
        -- Then, pass this position as the 'after' parameter --
        select_after_position = bands.index.primary:select({}, { limit = 3, after = position })
        --[[
        ---
        - - [4, 'The Beatles', 1960]
          - [5, 'Pink Floyd', 1965]
          - [6, 'The Rolling Stones', 1962]
        ...
        --]]

        -- Tests --
        t.assert_equals(select_primary[1], { 1, 'Roxette', 1986 })
        t.assert_equals(select_secondary[1], { 7, 'The Doors', 1965 })
        t.assert_equals(select_multipart[1], { 4, 'The Beatles', 1960 })
        t.assert_equals(select_multipart_partial, { { 5, 'Pink Floyd', 1965 }, { 2, 'Scorpions', 1965 }, { 7, 'The Doors', 1965 } })
        t.assert_equals(select_limit[1], { 3, 'Ace of Base', 1987 })
        t.assert_equals(select_greater, { { 9, 'Led Zeppelin', 1968 }, { 10, 'Queen', 1970 }, { 1, 'Roxette', 1986 } })
        t.assert_equals(select_after_tuple, { { 5, 'Pink Floyd', 1965 }, { 6, 'The Rolling Stones', 1962 }, { 7, 'The Doors', 1965 } })
        t.assert_equals(select_after_position, { { 4, 'The Beatles', 1960 }, { 5, 'Pink Floyd', 1965 }, { 6, 'The Rolling Stones', 1962 } })
    end)
end
