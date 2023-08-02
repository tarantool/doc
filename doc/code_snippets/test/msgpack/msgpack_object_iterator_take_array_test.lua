local msgpack = require('msgpack')

local mp_array = msgpack.object({ 10, 20, 30, 40 })
local mp_array_iterator = mp_array:iterator()

local size = mp_array_iterator:decode_array_header()  -- returns 4
local first = mp_array_iterator:decode()              -- returns 10
local mp_array_new = mp_array_iterator:take_array(2)
local mp_array_new_decoded = mp_array_new:decode()    -- returns {20, 30}
local fourth = mp_array_iterator:decode()             -- returns 40

local luatest = require('luatest')
local test_group = luatest.group()
test_group.test_iterator_take_array = function()
    luatest.assert_equals(size, 4)
    luatest.assert_equals(first, 10)
    luatest.assert_equals(mp_array_new_decoded, {20, 30})
    luatest.assert_equals(fourth, 40)
end
