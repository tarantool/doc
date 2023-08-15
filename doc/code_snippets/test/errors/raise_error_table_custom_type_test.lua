local status, err = pcall(function()
    -- snippet_start
    box.error { code = 500,
                reason = 'Internal server error',
                type = 'CustomInternalError' }
    --[[
    ---
    - error: Internal server error
    ...
    --]]
    -- snippet_end
end)

-- Tests
local luatest = require('luatest')
local test_group = luatest.group()
test_group.test_error_is_raised = function()
    luatest.assert_equals(err:unpack().type, 'CustomInternalError')
    luatest.assert_equals(err:unpack().message, 'Internal server error')
end
