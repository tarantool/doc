local status, err = pcall(function()
    -- snippet_start
    box.error(box.error.NO_SUCH_USER, 'John')
    --[[
    ---
    - error: User 'John' is not found
    ...
    --]]
    -- snippet_end
end)

-- Tests
local luatest = require('luatest')
local test_group = luatest.group()
test_group.test_tarantool_error_is_raised = function()
    luatest.assert_equals(err:unpack().message, "User 'John' is not found")
end
