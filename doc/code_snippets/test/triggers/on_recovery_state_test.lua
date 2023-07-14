local fio = require('fio')
local server = require('luatest.server')
local t = require('luatest')
local g = t.group()

local run_before_cfg = [[
    local log = require('log')
    local log_recovery_state = function(state)
        log.info(state .. ' state reached')
    end
    box.ctl.on_recovery_state(log_recovery_state)
]]

g.before_each(function(cg)
    cg.server = server:new {
        workdir = fio.cwd() .. '/tmp',
        env = {
            ['TARANTOOL_RUN_BEFORE_BOX_CFG'] = run_before_cfg,
        }
    }
    cg.server:start()
end)

g.after_each(function(cg)
    cg.server:stop()
    cg.server:drop()
end)

local function find_in_log(cg, str, must_be_present)
    t.helpers.retrying({timeout = 0.3, delay = 0.1}, function()
        local found = cg.server:grep_log(str) ~= nil
        t.assert(found == must_be_present)
    end)
end

g.test_log_contains_reached_states = function(cg)
    find_in_log(cg, 'indexes_built state reached', true)
    find_in_log(cg, 'snapshot_recovered state reached', true)
    find_in_log(cg, 'wal_recovered state reached', true)
    find_in_log(cg, 'synced state reached', true)
end
