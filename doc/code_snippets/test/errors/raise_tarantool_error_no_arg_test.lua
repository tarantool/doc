local status, err = pcall(function()
    -- snippet_start
    box.error(box.error.READONLY)
    --[[
    ---
    - error: Can't modify data on a read-only instance
    ...
    --]]
    -- snippet_end
end)

-- Tests
local luatest = require('luatest')
local test_group = luatest.group()
test_group.test_tarantool_error_is_raised = function()
    luatest.assert_equals(err:unpack().message, "Can't modify data on a read-only instance")
end
