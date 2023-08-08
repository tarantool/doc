function get_argument_type(value)
    checks('number|string')
    return type(value)
end
--[[
get_argument_type(1)
-- returns 'number'

get_argument_type('key1')
-- returns 'string'

get_argument_type(true)
-- raises an error: bad argument #1 to nil (number|string expected, got boolean)
--]]

-- Tests
local luatest = require('luatest')
local test_group = luatest.group()
test_group.test_checks = function()
    luatest.assert_equals(get_argument_type(1), 'number')
    luatest.assert_equals(get_argument_type('key1'), 'string')
    luatest.assert_error_msg_contains('bad argument #1 to nil (number|string expected, got boolean)', get_argument_type, true)
end
