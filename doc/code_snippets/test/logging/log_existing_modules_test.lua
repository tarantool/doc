local fio = require('fio')
local server = require('luatest.server')
local t = require('luatest')
local g = t.group()

local run_before_cfg = [[
    module1 = require('test.logging.module1')
    module2 = require('test.logging.module2')
]]

g.before_each(function(cg)
    cg.server = server:new {
        env = {
            ['TARANTOOL_RUN_BEFORE_BOX_CFG'] = run_before_cfg,
        },
        workdir = fio.cwd() .. '/tmp',
        box_cfg = { log_modules = {
            ['test.logging.module1'] = 'verbose',
            ['test.logging.module2'] = 'error' }
        }
    }
    cg.server:start()
    cg.server:exec(function()
        -- Prints 'info' messages --
        module1.say_hello()
        --[[
        [92617] main/103/interactive/test.logging.module1 I> Info message from module1
        ---
        ...
        --]]

        -- Swallows 'info' messages --
        module2.say_hello()
        --[[
        ---
        ...
        --]]
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
    find_in_log(cg, 'Info message from module1', true)
    find_in_log(cg, 'Info message from module2', false)
end
