local fio = require('fio')
local server = require('luatest.server')
local t = require('luatest')
local g = t.group()
g.before_all(function(cg)
    cg.server = server:new {
        box_cfg = {},
        workdir = fio.cwd() .. '/tmp'
    }
    cg.server:start()
    cg.server:exec(function()
        box.schema.space.create('writers')
        box.space.writers:format({
            { name = 'id', type = 'unsigned' },
            { name = 'name', type = 'string' }
        })
        box.space.writers:create_index('primary', { parts = { 'id' } })

        box.schema.space.create('books')
        box.space.books:format({
            { name = 'id', type = 'unsigned' },
            { name = 'title', type = 'string' },
            { name = 'author_id', foreign_key = { space = 'writers', field = 'id' } },
        })
        box.space.books:create_index('primary', { parts = { 'id' } })

        box.space.writers:insert { 1, 'Leo Tolstoy' }
        box.space.writers:insert { 2, 'Fyodor Dostoevsky' }
        box.space.writers:insert { 3, 'Alexander Pushkin' }

        box.space.books:insert { 1, 'War and Peace', 1 }
        box.space.books:insert { 2, 'Anna Karenina', 1 }
        box.space.books:insert { 3, 'Resurrection', 1 }
        box.space.books:insert { 4, 'Crime and Punishment', 2 }
        box.space.books:insert { 5, 'The Idiot', 2 }
        box.space.books:insert { 6, 'The Brothers Karamazov', 2 }
        box.space.books:insert { 7, 'Eugene Onegin', 3 }
        box.space.books:insert { 8, 'The Captain\'s Daughter', 3 }
        box.space.books:insert { 9, 'Boris Godunov', 3 }
        box.space.books:insert { 10, 'Ruslan and Ludmila', 3 }
    end)
end)

g.after_each(function(cg)
    cg.server:exec(function()
        if box.schema.user.exists('testuser') then
            box.schema.user.drop('testuser')
        end
    end)
end)

g.after_all(function(cg)
    cg.server:drop()
    fio.rmtree(cg.server.workdir)
end)

g.test_user_without_password_created = function(cg)
    cg.server:exec(function()
        -- Create a user without a password --
        box.schema.user.create('testuser')
        -- End: Create a user without a password --
        t.assert_equals(box.space._user.index.name:select { 'testuser' }[1][5]['chap-sha1'], nil)
    end)
end

g.test_user_with_password_created = function(cg)
    cg.server:exec(function()
        -- Create a user with a password --
        box.schema.user.create('testuser', { password = 'foobar' })
        -- End: Create a user with a password --
        t.assert_equals(box.space._user.index.name:select { 'testuser' }[1][5]['chap-sha1'], 'm1ADQ7xS4pERcutSrlz0hHYExuU=')
    end)
end

g.test_current_user_password_set = function(cg)
    cg.server:exec(function()
        box.session.su('admin')
        -- Set a password for the current user --
        box.schema.user.passwd('foobar')
        -- End: Set a password for the current user --
        t.assert_equals(box.space._user.index.name:select { 'admin' }[1][5]['chap-sha1'], 'm1ADQ7xS4pERcutSrlz0hHYExuU=')
    end)
end

g.test_specified_user_password_set = function(cg)
    cg.server:exec(function()
        box.schema.user.create('testuser')
        -- Set a password for the specified user --
        box.schema.user.passwd('testuser', 'foobar')
        -- End: Set a password for the specified user --
        t.assert_equals(box.space._user.index.name:select { 'testuser' }[1][5]['chap-sha1'], 'm1ADQ7xS4pERcutSrlz0hHYExuU=')
    end)
end

g.test_grant_revoke_privileges_user = function(cg)
    cg.server:exec(function()
        box.schema.user.create('testuser', { password = 'foobar' })
        box.schema.user.grant('testuser', 'execute', 'universe')
        -- Grant privileges to the specified user --
        box.schema.user.grant('testuser', 'read', 'space', 'writers')
        box.schema.user.grant('testuser', 'read,write', 'space', 'books')
        -- End: Grant privileges to the specified user --
        box.session.su('testuser')
        local _, delete_writer_error = pcall(function()
            box.space.writers:delete(3)
        end)
        t.assert_equals(delete_writer_error:unpack().message, "Write access to space 'writers' is denied for user 'testuser'")

        box.session.su('admin')
        -- Revoke space reading --
        box.schema.user.revoke('testuser', 'write', 'space', 'books')
        -- End: Revoke space reading --
        box.session.su('testuser')
        local _, delete_book_error = pcall(function()
            box.space.books:delete(10)
        end)
        t.assert_equals(delete_book_error:unpack().message, "Write access to space 'books' is denied for user 'testuser'")

        box.session.su('admin')
        -- Revoke session --
        box.schema.user.revoke('testuser', 'session', 'universe')
        -- End: Revoke session --
        local _, change_user_error = pcall(function()
            box.session.su('testuser')
        end)
        t.assert_equals(change_user_error:unpack().message, "Session access to universe '' is denied for user 'testuser'")
    end)
end

g.test_user_dropped = function(cg)
    cg.server:exec(function()
        box.schema.user.create('testuser')
        -- Drop a user --
        box.schema.user.drop('testuser')
        -- End: Drop a user --
        t.assert_equals(box.schema.user.exists('testuser'), false)
    end)
end
