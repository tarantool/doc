local status, err = pcall(function()
    -- Create an error: start
    local custom_error = box.error.new({ code = 500,
                                         reason = 'Internal server error',
                                         type = 'CustomInternalError' })
    -- Create an error: end

    -- Raise the error: start
    box.error(custom_error)
    --[[
    ---
    - error: Internal server error
    ...
    --]]
    -- Raise the error: end

    -- Get the last error: start
    box.error.last()
    --[[
    ---
    - error: Internal server error
    ...
    --]]
    -- Get the last error: end

    -- Get error details: start
    box.error.last():unpack()
    --[[
    ---
    - code: 500
      base_type: CustomError
      type: CustomInternalError
      custom_type: CustomInternalError
      message: Internal server error
      trace:
      - file: '[string "custom_error = box.error.new({ code = 500,..."]'
        line: 1
    ...
    --]]
    -- Get error details: end

    -- Clear the errors: start
    box.error.clear()
    --[[
    ---
    ...
    --]]
    box.error.last()
    --[[
    ---
    - null
    ...
    --]]
    -- Clear the errors: end
end)

-- Tests
local luatest = require('luatest')
local test_group = luatest.group()
test_group.test_error_is_raised = function()
    luatest.assert_equals(err:unpack().type, 'CustomInternalError')
    luatest.assert_equals(err:unpack().message, 'Internal server error')
end
