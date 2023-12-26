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
                name STRING UNIQUE
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
            INSERT INTO author VALUES (3, 'Leo Tolstoy');
            /*
            - Duplicate key exists in unique index "unique_unnamed_author_2" in space "author"
              with old tuple - [1, "Leo Tolstoy"] and new tuple - [3, "Leo Tolstoy"]
            */
            -- insert_duplicate_author_end
        ]])
        box.execute([[
            -- create_book_table_start
            CREATE TABLE book (
                id INTEGER PRIMARY KEY,
                title STRING NOT NULL,
                author_id INTEGER UNIQUE,
                UNIQUE (title, author_id)
            );
            -- create_book_table_end
        ]])
        box.execute([[
            -- insert_books_start
            INSERT INTO book VALUES (1, 'War and Peace', 1),
                                    (2, 'Crime and Punishment', 2);
            -- insert_books_end
        ]])
        local _, insert_book_err = box.execute([[
            -- insert_duplicate_book_start
            INSERT INTO book VALUES (3, 'War and Peace', 1);
            /*
            - Duplicate key exists in unique index "unique_unnamed_book_2" in space "book" with
              old tuple - [1, "War and Peace", 1] and new tuple - [3, "War and Peace", 1]
            */
            -- insert_duplicate__book_end
        ]])

        -- Tests
        t.assert_equals(insert_author_err:unpack().message, "Duplicate key exists in unique index \"unique_unnamed_author_2\" in space \"author\" with old tuple - [1, \"Leo Tolstoy\"] and new tuple - [3, \"Leo Tolstoy\"]")
        t.assert_equals(insert_book_err:unpack().message, "Duplicate key exists in unique index \"unique_unnamed_book_2\" in space \"book\" with old tuple - [1, \"War and Peace\", 1] and new tuple - [3, \"War and Peace\", 1]")
    end)
end
