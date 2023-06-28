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

g.test_space_is_updated = function(cg)
    cg.server:exec(function()
        -- Insert test data --
        box.space.bands:insert { 1, 'Roxette', 1986 }
        box.space.bands:insert { 2, 'Scorpions', 1965 }
        box.space.bands:insert { 3, 'Ace of Base', 1987 }

        -- Define a function called on commit --
        function print_replace_details(iterator)
            for request_number, old_tuple, new_tuple, space_id in iterator() do
                print('request_number: ' .. tostring(request_number))
                print('old_tuple: ' .. tostring(old_tuple))
                print('new_tuple: ' .. tostring(new_tuple))
                print('space_id: ' .. tostring(space_id))
            end
        end

        -- Commit the transaction --
        box.begin()
        box.space.bands:replace { 1, 'The Beatles', 1960 }
        box.space.bands:replace { 2, 'The Rolling Stones', 1965 }
        box.on_commit(print_replace_details)
        box.commit()

        t.assert_equals(box.space.bands:count(), 3)
        t.assert_equals(box.space.bands:select { 1 }[1], { 1, 'The Beatles', 1960 })
        t.assert_equals(box.space.bands:select { 2 }[1], { 2, 'The Rolling Stones', 1965 })
    end)
end