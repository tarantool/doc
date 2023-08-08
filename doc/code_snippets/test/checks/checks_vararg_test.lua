function extra_arguments_num(a, b, ...)
    checks('string', 'number')
    return select('#', ...)
end
--[[
extra_arguments_num('a', 2, 'c')
-- returns 1

extra_arguments_num('a', 'b', 'c')
-- raises an error: bad argument #1 to nil (string expected, got number)
--]]

-- Tests
local luatest = require('luatest')
local test_group = luatest.group()
test_group.test_checks = function()
    luatest.assert_equals(extra_arguments_num('a', 2, 'c'), 1)
    luatest.assert_error_msg_contains('bad argument #2 to nil (number expected, got string)', extra_arguments_num, 'a', 'b', 'c')
end
