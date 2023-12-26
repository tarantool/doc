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
                name STRING NOT NULL
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
            -- insert_duplicate_author_start
            INSERT INTO author VALUES (2, 'Alexander Pushkin');
            /*
            - Duplicate key exists in unique index "pk_unnamed_AUTHOR_1" in space "AUTHOR" with
              old tuple - [2, "Fyodor Dostoevsky"] and new tuple - [2, "Alexander Pushkin"]
            */
            -- insert_duplicate_author_end
        ]])
        box.execute([[
            -- create_book_table_start
            CREATE TABLE book (
                id INTEGER,
                title STRING NOT NULL,
                PRIMARY KEY (id, title)
            );
            -- create_book_table_end
        ]])
        box.execute([[
            -- insert_books_start
            INSERT INTO book VALUES (1, 'War and Peace'),
                                    (2, 'Crime and Punishment');
            -- insert_books_end
        ]])
        local _, insert_book_err = box.execute([[
            -- insert_duplicate_book_start
            INSERT INTO book VALUES (2, 'Crime and Punishment');
            /*
            - Duplicate key exists in unique index "pk_unnamed_BOOK_1" in space "BOOK" with old
              tuple - [2, "Crime and Punishment"] and new tuple - [2, "Crime and Punishment"]
            */
            -- insert_duplicate__book_end
        ]])

        -- Tests
        t.assert_equals(insert_author_err:unpack().message, "Duplicate key exists in unique index \"pk_unnamed_AUTHOR_1\" in space \"AUTHOR\" with old tuple - [2, \"Fyodor Dostoevsky\"] and new tuple - [2, \"Alexander Pushkin\"]")
        t.assert_equals(insert_book_err:unpack().message, "Duplicate key exists in unique index \"pk_unnamed_BOOK_1\" in space \"BOOK\" with old tuple - [2, \"Crime and Punishment\"] and new tuple - [2, \"Crime and Punishment\"]")
    end)
end
