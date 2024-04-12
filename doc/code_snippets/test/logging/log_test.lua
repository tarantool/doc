local fio = require('fio')
local server = require('luatest.server')
local t = require('luatest')
local g = t.group()

g.before_each(function(cg)
    cg.server = server:new {
        workdir = fio.cwd() .. '/tmp',
        box_cfg = {}
    }
    cg.server:start()
    cg.server:exec(function()
        local log = require('log')
        log.cfg { level = 'verbose' }
        log.warn('Warning message')
        log.info('Tarantool version: %s', box.info.version)
        log.error({ 500, 'Internal error' })
        log.debug('Debug message')
    end)
end)

g.after_each(function(cg)
    cg.server:drop()
    fio.rmtree(cg.server.workdir)
end)

local function find_in_log(cg, str, must_be_present)
    t.helpers.retrying({ timeout = 0.3, delay = 0.1 }, function()
        local found = cg.server:grep_log(str) ~= nil
        t.assert(found == must_be_present)
    end)
end

g.test_log_contains_messages = function(cg)
    find_in_log(cg, 'Warning message', true)
    find_in_log(cg, 'Tarantool version:', true)
    find_in_log(cg, 'Internal error', true)
    find_in_log(cg, 'Debug message', false)
end
