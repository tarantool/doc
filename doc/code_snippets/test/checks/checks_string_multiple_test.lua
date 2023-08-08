function greet_fullname(firstname, lastname)
    checks('string', 'string')
    return 'Hello, ' .. firstname .. ' ' .. lastname
end
--[[
greet_fullname('John', 'Smith')
-- returns 'Hello, John Smith'

greet_fullname('John', 1)
-- raises an error: bad argument #2 to nil (string expected, got number)
--]]

-- Tests
local luatest = require('luatest')
local test_group = luatest.group()
test_group.test_checks = function()
    luatest.assert_equals(greet_fullname('John', 'Smith'), 'Hello, John Smith')
    luatest.assert_error_msg_contains('bad argument #2 to nil (string expected, got number)', greet_fullname, 'John', 1)
end
