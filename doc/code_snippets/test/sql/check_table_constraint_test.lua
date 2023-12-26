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
        box.execute([[
            -- create_author_table_start
            CREATE TABLE author (
                id INTEGER PRIMARY KEY,
                name STRING,
                CONSTRAINT check_name_length CHECK (CHAR_LENGTH(name) > 4)
            );
            -- create_author_table_end
        ]])
        box.execute([[
            -- insert_authors_start
            INSERT INTO author VALUES (1, 'Leo Tolstoy'),
                                      (2, 'Fyodor Dostoevsky');
            -- insert_authors_end
        ]])
        local _, insert_author_err = box.execute([[
            -- insert_short_name_start
            INSERT INTO author VALUES (3, 'Alex');
            /*
            - Check constraint 'CHECK_NAME_LENGTH' failed for tuple
            */
            -- insert_short_name_end
        ]])

        -- Tests
        t.assert_equals(insert_author_err:unpack().message, "Check constraint 'CHECK_NAME_LENGTH' failed for tuple")
    end)
end
