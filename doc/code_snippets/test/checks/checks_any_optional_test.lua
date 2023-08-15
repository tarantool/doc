function greet_fullname_any(firstname, lastname)
    checks('string', '?')
    return 'Hello, ' .. firstname .. ' ' .. tostring(lastname)
end
--[[
greet_fullname_any('John', 'Doe')
-- returns 'Hello, John Doe'

greet_fullname_any('John', 1)
-- returns 'Hello, John 1'
--]]

-- Tests
local luatest = require('luatest')
local test_group = luatest.group()
test_group.test_checks = function()
    luatest.assert_equals(greet_fullname_any('John', 'Doe'), 'Hello, John Doe')
    luatest.assert_equals(greet_fullname_any('John', 1), 'Hello, John 1')
end
