local msgpack = require('msgpack')

local mp_array = msgpack.object({ 10, 20, 30 })
local mp_array_iterator = mp_array:iterator()

local size = mp_array_iterator:decode_array_header()  -- returns 3
local first = mp_array_iterator:decode()              -- returns 10
mp_array_iterator:skip()                              -- returns none, skips 20
local mp_value_under_cursor = mp_array_iterator:take()
local third = mp_value_under_cursor:decode()          -- returns 30

local luatest = require('luatest')
local test_group = luatest.group()
test_group.test_iterator_take = function()
    luatest.assert_equals(size, 3)
    luatest.assert_equals(first, 10)
    luatest.assert_equals(third, 30)
end
