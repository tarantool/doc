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
    end)
end)

g.after_each(function(cg)
    cg.server:stop()
    cg.server:drop()
end)

g.test_space_is_updated = function(cg)
    cg.server:exec(function()
        -- Create an index with the specified sequence --
        box.schema.sequence.create('id_sequence', { min = 1 })
        box.space.bands:create_index('primary', { parts = { 'id' }, sequence = 'id_sequence' })

        -- Insert test data --
        box.space.bands:insert { 1, 'Roxette', 1986 }
        box.space.bands:insert { 2, 'Scorpions', 1965 }
        box.space.bands:insert { 3, 'Ace of Base', 1987 }

        -- Define a function --
        local function insert_band(band_name, year)
            box.space.bands:insert { nil, band_name, year }
        end

        -- Begin and commit the transaction implicitly --
        box.atomic(insert_band, 'The Beatles', 1960)

        -- Begin the transaction with the specified isolation level --
        box.atomic({ txn_isolation = 'read-committed' },
                insert_band, 'The Rolling Stones', 1962)

        t.assert_equals(box.space.bands:count(), 5)
        t.assert_equals(box.space.bands:select { 5 }[1], { 5, 'The Rolling Stones', 1962 })
    end)
end