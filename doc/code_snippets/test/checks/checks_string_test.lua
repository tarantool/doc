function greet(name)
    checks('string')
    return 'Hello, ' .. name
end
--[[
greet('John')
-- returns 'Hello, John'

greet(123)
-- raises an error: bad argument #1 to nil (string expected, got number)
--]]

-- Tests
local luatest = require('luatest')
local test_group = luatest.group()
test_group.test_checks = function()
    luatest.assert_equals(greet('John'), 'Hello, John')
    luatest.assert_error_msg_contains('bad argument #1 to nil (string expected, got number)', greet, 123)
end
