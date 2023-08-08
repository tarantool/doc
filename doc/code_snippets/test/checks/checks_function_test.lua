function checkers.positive(value)
    return (type(value) == 'number') and (value > 0)
end

function get_doubled_number(value)
    checks('positive')
    return value * 2
end
--[[
get_doubled_number(10)
-- returns 20

get_doubled_number(-5)
-- raises an error: bad argument #1 to nil (positive expected, got number)
--]]

-- Tests
local luatest = require('luatest')
local test_group = luatest.group()
test_group.test_checks = function()
    luatest.assert_equals(get_doubled_number(10), 20)
    luatest.assert_error_msg_contains('bad argument #1 to nil (positive expected, got number)', get_doubled_number, -5)
end
