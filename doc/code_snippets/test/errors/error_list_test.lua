local status, err = pcall(function()
    -- snippet_start
    local base_server_error = box.error.new({ code = 500,
                                              reason = 'Base server error',
                                              type = 'BaseServerError' })
    local storage_server_error = box.error.new({ code = 507,
                                                 reason = 'Not enough storage',
                                                 type = 'StorageServerError' })

    base_server_error:set_prev(storage_server_error)
    --[[
    ---
    ...
    --]]

    box.error(base_server_error)
    --[[
    ---
    - error: Base server error
    ...
    --]]

    box.error.last().prev:unpack()
    --[[
    ---
    - code: 507
      base_type: CustomError
      type: StorageServerError
      custom_type: StorageServerError
      message: Not enough storage
      trace:
      - file: '[string "storage_server_error = box.error.new({ code =..."]'
        line: 1
    ...
    --]]
    -- snippet_end
end)

-- Tests
local luatest = require('luatest')
local test_group = luatest.group()
test_group.test_error_is_raised = function()
    luatest.assert_equals(err:unpack().type, 'BaseServerError')
    luatest.assert_equals(err:unpack().message, 'Base server error')
    luatest.assert_equals(err.prev:unpack().type, 'StorageServerError')
    luatest.assert_equals(err.prev:unpack().message, 'Not enough storage')
end
