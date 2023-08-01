local fio = require('fio')
local server = require('luatest.server')
local t = require('luatest')
local g = t.group()

g.before_each(function(cg)
    cg.server = server:new {
        workdir = fio.cwd() .. '/tmp',
        box_cfg = { log_level = 'warn',
                    log_modules = {
                        module1 = 'verbose',
                        module2 = 'error' }
        }
    }
    cg.server:start()
    cg.server:exec(function()
        -- Creates new loggers --
        module1_log = require('log').new('module1')
        module2_log = require('log').new('module2')

        -- Prints 'info' messages --
        module1_log.info('Info message from module1')
        --[[
        [16300] main/103/interactive/module1 I> Info message from module1
        ---
        ...
        --]]

        -- Swallows 'debug' messages --
        module1_log.debug('Debug message from module1')
        --[[
        ---
        ...
        --]]

        -- Swallows 'info' messages --
        module2_log.info('Info message from module2')
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
    find_in_log(cg, 'Info message from module1', true)
    find_in_log(cg, 'Debug message from module1', false)
    find_in_log(cg, 'Info message from module2', false)
end
