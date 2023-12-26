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

g.test_json_path_index = function(cg)
    cg.server:exec(function()
        box.schema.space.create('space1')
        box.space.space1:create_index('primary', { parts = { { field = 1,
                                                               type = 'scalar',
                                                               path = 'age' } } })
        box.space.space1:insert({ { age = 44 } })
        box.space.space1:select(44)

        box.schema.space.create('space2')
        box.space.space2:format({ { 'id', 'unsigned' }, { 'data', 'map' } })
        box.space.space2:create_index('info', { parts = { { 'data.full_name["firstname"]', 'str' },
                                                          { 'data.full_name["surname"]', 'str' } } })
        box.space.space2:insert({ 1, { full_name = { firstname = 'John', surname = 'Doe' } } })
        box.space.space2:select { 'John' }

        -- Tests --
        json = require('json')
        t.assert_equals(json.encode(box.space.space1:select(44)[1][1]), "{\"age\":44}")
        t.assert_equals(json.encode(box.space.space2:select { 'John' }[1][2]), "{\"full_name\":{\"surname\":\"Doe\",\"firstname\":\"John\"}}")
    end)
end