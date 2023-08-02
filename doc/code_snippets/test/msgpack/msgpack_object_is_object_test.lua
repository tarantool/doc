local msgpack = require('msgpack')

local mp_from_string = msgpack.object('hello world')

-- Check if the given argument is a MsgPack object
local mp_is_object = msgpack.is_object(mp_from_string) -- Returns true
local string_is_object = msgpack.is_object('hello world') -- Returns false

local luatest = require('luatest')
local test_group = luatest.group()
test_group.test_is_object = function()
    luatest.assert_equals(mp_is_object, true)
    luatest.assert_equals(string_is_object, false)
end
