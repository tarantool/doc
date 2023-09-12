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

g.test_space_is_updated = function(cg)
    cg.server:exec(function()
        box.execute([[SET SESSION "sql_seq_scan" = true;]])
        box.execute([[
            -- create_parent_start
            CREATE TABLE author (
                id INTEGER PRIMARY KEY,
                name STRING NOT NULL
            );
            -- create_parent_end
        ]])
        box.execute([[
            -- insert_parent_start
            INSERT INTO author VALUES (1, 'Leo Tolstoy'),
                                      (2, 'Fyodor Dostoevsky');
            -- insert_parent_end
        ]])
        box.execute([[
            -- create_child_start
            CREATE TABLE book (
                id INTEGER PRIMARY KEY,
                title STRING NOT NULL,
                author_id INTEGER NOT NULL UNIQUE,
                FOREIGN KEY (author_id)
                    REFERENCES author (id)
            );
            -- create_child_end
        ]])
        box.execute([[
            -- insert_child_start
            INSERT INTO book VALUES (1, 'War and Peace', 1),
                                    (2, 'Crime and Punishment', 2);
            -- insert_child_end
        ]])
        local _, insert_err = box.execute([[
            -- insert_error_start
            INSERT INTO book VALUES (3, 'Eugene Onegin', 3);
            /*
            - 'Foreign key constraint ''fk_unnamed_BOOK_1'' failed: foreign tuple was not found'
            */
            -- insert_error_end
        ]])
        local _, update_err = box.execute([[
            -- update_error_start
            UPDATE book SET author_id = 10 WHERE id = 1;
            /*
            - 'Foreign key constraint ''fk_unnamed_BOOK_1'' failed: foreign tuple was not found'
            */
            -- update_error_end
        ]])
        local _, delete_err = box.execute([[
            -- delete_error_start
            DELETE FROM author WHERE id = 2;
            /*
            - 'Foreign key ''fk_unnamed_BOOK_1'' integrity check failed: tuple is referenced'
            */
            -- delete_error_end
        ]])

        -- Tests
        t.assert_equals(insert_err:unpack().message, "Foreign key constraint 'fk_unnamed_BOOK_1' failed: foreign tuple was not found")
        t.assert_equals(update_err:unpack().message, "Foreign key constraint 'fk_unnamed_BOOK_1' failed: foreign tuple was not found")
        t.assert_equals(delete_err:unpack().message, "Foreign key 'fk_unnamed_BOOK_1' integrity check failed: tuple is referenced")
    end)
end
