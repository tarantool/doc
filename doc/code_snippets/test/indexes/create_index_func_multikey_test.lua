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

g.test_func_multikey_index = function(cg)
    cg.server:exec(function()
        tester = box.schema.space.create('withdata')
        tester:format({ { name = 'name', type = 'string' },
                        { name = 'address', type = 'string' } })
        name_index = tester:create_index('name', { parts = { { field = 1, type = 'string' } } })
        function_code = [[function(tuple)
               local address = string.split(tuple[2])
               local ret = {}
               for _, v in pairs(address) do
                 table.insert(ret, {utf8.upper(v)})
               end
               return ret
             end]]
        box.schema.func.create('address',
                { body = function_code,
                  is_deterministic = true,
                  is_sandboxed = true,
                  is_multikey = true })
        addr_index = tester:create_index('addr', { unique = false,
                                                   func = 'address',
                                                   parts = { { field = 1, type = 'string',
                                                          collation = 'unicode_ci' } } })
        tester:insert({ "James", "SIS Building Lambeth London UK" })
        tester:insert({ "Sherlock", "221B Baker St Marylebone London NW1 6XE UK" })
        addr_index:select('Uk')

        -- Tests --
        t.assert_equals(addr_index:select('Uk'), {
            { 'James', 'SIS Building Lambeth London UK' },
            { 'Sherlock', '221B Baker St Marylebone London NW1 6XE UK' },
        })
    end)
end