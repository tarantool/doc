local msgpack = require('msgpack')

-- Create a MsgPack object from a Lua object of any type
local mp_from_number = msgpack.object(123)
local mp_from_string = msgpack.object('hello world')
local mp_from_array = msgpack.object({ 10, 20, 30 })
local mp_from_table = msgpack.object({ band_name = 'The Beatles', year = 1960 })
local mp_from_tuple = msgpack.object(box.tuple.new{1, 'The Beatles', 1960})

-- Create a MsgPack object from a raw MsgPack string
local raw_mp_string = msgpack.encode({ 10, 20, 30 })
local mp_from_mp_string = msgpack.object_from_raw(raw_mp_string)

-- Create a MsgPack object from a raw MsgPack string using buffer
local buffer = require('buffer')
local ibuf = buffer.ibuf()
msgpack.encode({ 10, 20, 30 }, ibuf)
local mp_from_mp_string_pt = msgpack.object_from_raw(ibuf.buf, ibuf:size())

-- Decode MsgPack data
local mp_number_decoded = mp_from_number:decode() -- Returns 123
local mp_string_decoded = mp_from_string:decode() -- Returns 'hello world'

local luatest = require('luatest')
local test_group = luatest.group()
test_group.test_msgpack_decode = function()
    luatest.assert_equals(mp_from_mp_string:decode(), { 10, 20, 30 })
    luatest.assert_equals(mp_from_mp_string_pt:decode(), { 10, 20, 30 })
    luatest.assert_equals(mp_number_decoded, 123)
    luatest.assert_equals(mp_string_decoded, 'hello world')
end
