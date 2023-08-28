local status, err = pcall(function()
    -- snippet_start
    box.error('CustomConnectionError', '%s cannot connect to the port %u', 'client', 8080)
    --[[
    ---
    - error: client cannot connect to the port 8080
    ...
    --]]
    -- snippet_end
end)

-- Tests
local luatest = require('luatest')
local test_group = luatest.group()
test_group.test_error_is_raised = function()
    luatest.assert_equals(err:unpack().type, 'CustomConnectionError')
    luatest.assert_equals(err:unpack().message, 'client cannot connect to the port 8080')
end
