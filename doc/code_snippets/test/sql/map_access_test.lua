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

g.test_space_is_updated = function(cg)
    cg.server:exec(function()
        box.execute([[SET SESSION "sql_seq_scan" = true;]])
        box.execute([[
            CREATE TABLE bands (id INTEGER PRIMARY KEY, info MAP);
        ]])
        box.execute([[
            INSERT INTO bands VALUES (1, {'name': 'The Beatles', 'year': 1960});
        ]])
        box.execute([[
            INSERT INTO bands VALUES (2, {'name': 'The Doors', 'year': 1965});
        ]])
        local result = box.execute([[
            SELECT info['name'] FROM bands;
            /* ---
              rows:
              - ['The Beatles']
              - ['The Doors']
            ... */
        ]])

        t.assert_equals(result.rows[1], {'The Beatles'})
        t.assert_equals(result.rows[2], {'The Doors'})
    end)
end
