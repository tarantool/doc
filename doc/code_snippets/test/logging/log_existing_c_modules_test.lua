local fio = require('fio')
local server = require('luatest.server')
local t = require('luatest')
local g = t.group()

g.before_each(function(cg)
    cg.server = server:new {
        workdir = fio.cwd() .. '/tmp',
        box_cfg = { log_level = 'warn',
                    log_modules = { tarantool = 'info' } }
    }
    cg.server:start()
    cg.server:exec(function()
        ffi = require('ffi')

        -- Prints 'info' messages --
        ffi.C._say(ffi.C.S_INFO, nil, 0, nil, 'Info message from C module')
        --[[
        [6024] main/103/interactive I> Info message from C module
        ---
        ...
        --]]

        -- Swallows 'debug' messages --
        ffi.C._say(ffi.C.S_DEBUG, nil, 0, nil, 'Debug message from C module')
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
    find_in_log(cg, 'Info message from C module', true)
    find_in_log(cg, 'Debug message from C module', false)
end
