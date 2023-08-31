local fio = require('fio')
local server = require('luatest.server')
local t = require('luatest')
local treegen = require('test.treegen')
local justrun = require('test.justrun')
local g = t.group()

g.before_all(function()
    treegen.init(g)
end)

g.after_all(function()
    treegen.clean(g)
end)

g.before_each(function(cg)
    cg.server = server:new {
        box_cfg = {},
        workdir = fio.cwd() .. '/tmp'
    }
    cg.server:start()
    cg.server:exec(function()
        box.schema.space.create('bands')
        box.space.bands:format({
            { name = 'id', type = 'unsigned' },
            { name = 'band_name', type = 'string' },
            { name = 'year', type = 'unsigned' }
        })
        box.space.bands:create_index('primary', { parts = { 'id' } })
    end)
end)

g.after_each(function(cg)
    cg.server:stop()
    cg.server:drop()
end)

g.test_config_option = function()
    local dir = treegen.prepare_directory(g, {}, {})
    local file_config = [[
        log:
          level: 7

        memtx:
          min_tuple_size: 32
          memory: 100000000

        groups:
          group-001:
            replicasets:
              replicaset-001:
                instances:
                  instance-001: {}
    ]]
    treegen.write_script(dir, 'config.yaml', file_config)

    local script = [[
        print(box.cfg.memtx_min_tuple_size)
        print(box.cfg.memtx_memory)
        print(box.cfg.log_level)
        os.exit(0)
    ]]
    treegen.write_script(dir, 'main.lua', script)

    local env = {TT_LOG_LEVEL = 0}
    local opts = {nojson = true, stderr = false}
    local args = {'--name', 'instance-001', '--config', 'config.yaml',
                  'main.lua'}
    local res = justrun.tarantool(dir, env, args, opts)
    t.assert_equals(res.exit_code, 0)
    t.assert_equals(res.stdout, table.concat({32, 100000000, 0}, "\n"))
end