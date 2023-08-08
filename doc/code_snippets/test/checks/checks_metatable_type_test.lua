local blue = setmetatable({ 0, 0, 255 }, { __type = 'color' })
function get_blue_value(color)
    checks('color')
    return color[3]
end
--[[
get_blue_value(blue)
-- returns 255

get_blue_value({0, 0, 255})
-- raises an error: bad argument #1 to nil (color expected, got table)
--]]

-- Tests
local luatest = require('luatest')
local test_group = luatest.group()
test_group.test_checks = function()
    luatest.assert_equals(get_blue_value(blue), 255)
    luatest.assert_error_msg_contains('bad argument #1 to nil (color expected, got table)', get_blue_value, { 0, 0, 255 })
end
