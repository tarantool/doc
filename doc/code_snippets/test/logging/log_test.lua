local fio = require('fio')
local server = require('luatest.server')
local t = require('luatest')
local g = t.group()

g.before_each(function(cg)
    cg.server = server:new {
        workdir = fio.cwd() .. '/tmp',
        box_cfg = { log_level = 'warn' }
    }
    cg.server:start()
    cg.server:exec(function()
        log = require('log')

        -- Prints 'warn' messages --
        log.warn('Warning message')
        --[[
        2023-07-20 11:03:57.029 [16300] main/103/interactive/tarantool [C]:-1 W> Warning message
        ---
        ...
        --]]

        -- Swallows 'debug' messages --
        log.debug('Debug message')
        --[[
        ---
        ...
        --]]
    end)
end)

g.after_each(function(cg)
    cg.server:stop()
    cg.server:drop()
end)

local function find_in_log(cg, str, must_be_present)
    t.helpers.retrying({ timeout = 0.3, delay = 0.1 }, function()
        local found = cg.server:grep_log(str) ~= nil
        t.assert(found == must_be_present)
    end)
end

g.test_log_contains_messages = function(cg)
    find_in_log(cg, 'Warning message', true)
    find_in_log(cg, 'Debug message', false)
end
