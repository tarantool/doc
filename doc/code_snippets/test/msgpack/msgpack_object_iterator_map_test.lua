local msgpack = require('msgpack')

local mp_map = msgpack.object({ foo = 123 })
local mp_map_iterator = mp_map:iterator()

local size = mp_map_iterator:decode_map_header() -- returns 1
local first = mp_map_iterator:decode()           -- returns 'foo'
local second = mp_map_iterator:decode()          -- returns '123'

local luatest = require('luatest')
local test_group = luatest.group()
test_group.test_iterator_decode = function()
    luatest.assert_equals(size, 1)
    luatest.assert_equals(first, 'foo')
    luatest.assert_equals(second, 123)
end
