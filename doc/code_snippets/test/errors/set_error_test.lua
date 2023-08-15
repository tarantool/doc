local status, err = pcall(function()
    -- snippet_start
    -- Create two errors --
    local error1 = box.error.new({ code = 500, reason = 'Custom error 1' })
    local error2 = box.error.new({ code = 505, reason = 'Custom error 2' })

    -- Raise the first error --
    box.error(error1)
    --[[
    ---
    - error: Custom error 1
    ...
    --]]

    -- Get the last error --
    box.error.last()
    --[[
    ---
    - Custom error 1
    ...
    --]]

    -- Set the second error as the last error --
    box.error.set(error2)
    --[[
    ---
    ...
    --]]

    -- Get the last error --
    box.error.last()
    --[[
    ---
    - Custom error 2
    ...
    --]]
    -- snippet_end
end)

-- Tests
local luatest = require('luatest')
local test_group = luatest.group()
test_group.test_error_is_raised = function()
    luatest.assert_equals(err:unpack().message, 'Custom error 1')
end
