local status, err = pcall(function()
    -- snippet_start
    box.error { code = 500,
                reason = 'Custom server error' }
    --[[
    ---
    - error: Custom server error
    ...
    --]]
    -- snippet_end
end)

-- Tests
local luatest = require('luatest')
local test_group = luatest.group()
test_group.test_error_is_raised = function()
    luatest.assert_equals(err:unpack().message, 'Custom server error')
end
