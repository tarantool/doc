local msgpack = require('msgpack')

local mp_from_array = msgpack.object({ 10, 20, 30 })
local mp_from_table = msgpack.object({ band_name = 'The Beatles', year = 1960 })
local mp_from_tuple = msgpack.object(box.tuple.new(1, 'The Beatles', 1960))

-- Get MsgPack data by the specified index or key
local mp_array_get_by_index = mp_from_array[1] -- Returns 10
local mp_table_get_by_key = mp_from_table['band_name'] -- Returns 'The Beatles'
local mp_table_get_by_nonexistent_key = mp_from_table['rating'] -- Returns nil
local mp_tuple_get_by_index = mp_from_tuple[3] -- Returns 1960

local luatest = require('luatest')
local test_group = luatest.group()
test_group.test_index = function()
    luatest.assert_equals(mp_array_get_by_index, 10)
    luatest.assert_equals(mp_table_get_by_key, 'The Beatles')
    luatest.assert_equals(mp_table_get_by_nonexistent_key, nil)
    luatest.assert_equals(mp_tuple_get_by_index, 1960)
end
