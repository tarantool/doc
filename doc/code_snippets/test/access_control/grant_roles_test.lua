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

g.after_all(function(cg)
    cg.server:drop()
    fio.rmtree(cg.server.workdir)
end)

g.test_role_granted_revoked = function(cg)
    cg.server:exec(function()
        box.schema.user.create('testuser', { password = 'foobar' })

        -- Create roles --
        box.schema.role.create('books_space_manager')
        box.schema.role.create('writers_space_reader')
        -- End: Create roles --

        -- Grant read/write privileges to a role --
        box.schema.role.grant('books_space_manager', 'read,write', 'space', 'books')
        -- Grant write privileges to a role --
        box.schema.role.grant('writers_space_reader', 'read', 'space', 'writers')
        -- End: Grant privileges to roles --

        -- Grant a role to a role --
        box.schema.role.create('all_spaces_manager')
        box.schema.role.grant('all_spaces_manager', 'books_space_manager')
        box.schema.role.grant('all_spaces_manager', 'writers_space_reader')
        -- End: Grant a role to a role --

        -- Grant a role to a user --
        box.schema.user.grant('testuser', 'books_space_manager')
        box.schema.user.grant('testuser', 'writers_space_reader')
        -- End: Grant a role to a user --

        -- Test removing a tuple from 'writers' --
        box.session.su('testuser')
        local _, delete_writer_error = pcall(function()
            box.space.writers:delete(3)
        end)
        t.assert_equals(delete_writer_error:unpack().message, "Write access to space 'writers' is denied for user 'testuser'")
        box.session.su('admin')

        -- Revoking a role from a user  --
        box.schema.user.revoke('testuser', 'execute', 'role', 'writers_space_reader')
        -- End: Revoking a role from a user --

        -- Test selecting data from 'writers' --
        box.session.su('testuser')
        local _, select_writer_error = pcall(function()
            box.space.writers:select(3)
        end)
        t.assert_equals(select_writer_error:unpack().message, "Read access to space 'writers' is denied for user 'testuser'")
        box.session.su('admin')

        -- Dropping a role  --
        box.schema.role.drop('writers_space_reader')
        -- End: Dropping a role  --

        -- Test roles exist --
        t.assert_equals(box.schema.role.exists('books_space_manager'), true)
        t.assert_equals(box.schema.role.exists('all_spaces_manager'), true)
        t.assert_equals(box.schema.role.exists('writers_space_reader'), false)
    end)
end
