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
            CREATE TABLE plays (user_id INTEGER PRIMARY KEY, scores ARRAY);
        ]])
        box.execute([[
            INSERT INTO plays VALUES (1, [23, 17, 55, 48]);
        ]])
        box.execute([[
            INSERT INTO plays VALUES (2, [12, 8, 20, 33]);
        ]])
        local result = box.execute([[
            SELECT scores[2] FROM plays;
            /* ---
              rows:
              - [17]
              - [8]
            ... */
        ]])

        t.assert_equals(result.rows[1], {17})
        t.assert_equals(result.rows[2], {8})
    end)
end
