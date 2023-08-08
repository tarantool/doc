local decimal = require('decimal')
function sqrt(value)
    checks('decimal')
    return decimal.sqrt(value)
end
--[[
sqrt(decimal.new(16))
-- returns 4

sqrt(16)
-- raises an error: bad argument #1 to nil (decimal expected, got number)
--]]

-- Tests
local luatest = require('luatest')
local test_group = luatest.group()
test_group.test_checks = function()
    luatest.assert_equals(sqrt(decimal.new(16)), 4)
    luatest.assert_error_msg_contains('bad argument #1 to nil (decimal expected, got number)', sqrt, 16)
end
