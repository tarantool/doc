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

g.test_indexes = function(cg)
    cg.server:exec(function()
        -- Example 1 --
        box.schema.space.create('tester1', { engine = 'memtx' })
        box.space.tester1:create_index('index1')
        global_counter = 5

        -- Create a custom function.
        function increase_global_counter()
            global_counter = global_counter + 1
        end

        -- Extend all memtx indexes with the created function.
        box.schema.memtx_index_mt.increase_global_counter = increase_global_counter

        -- Call the 'increase_global_counter' function on 'index1'
        -- to change the 'global_counter' value from 5 to 6.
        box.space.tester1.index.index1:increase_global_counter()

        -- Example 2 --
        box.schema.space.create('tester2', { engine = 'memtx', id = 1000 })
        box.space.tester2:create_index('index2')
        local_counter = 0

        -- Create a custom function.
        function increase_local_counter(i_arg, param)
            local_counter = local_counter + param + i_arg.space_id
        end

        -- Extend only the 'index2' index with the created function.
        box.schema.memtx_index_mt.increase_local_counter = increase_local_counter
        meta = getmetatable(box.space.tester2.index.index2)
        meta.increase_local_counter = increase_local_counter

        -- Call the 'increase_local_counter' function on 'index2'
        -- to change the 'local_counter' value from 0 to 1005.
        box.space.tester2.index.index2:increase_local_counter(5)

        -- Tests --
        t.assert_equals(global_counter, 6)
        t.assert_equals(local_counter, 1005)
    end)
end
