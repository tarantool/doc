local status, err = pcall(function()
    -- snippet_start
    box.error('CustomConnectionError', 'cannot connect to the given port')
    --[[
    ---
    - error: cannot connect to the given port
    ...
    --]]
    -- snippet_end
end)

-- Tests
local luatest = require('luatest')
local test_group = luatest.group()
test_group.test_error_is_raised = function()
    luatest.assert_equals(err:unpack().type, 'CustomConnectionError')
    luatest.assert_equals(err:unpack().message, 'cannot connect to the given port')
end
