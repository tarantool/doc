-- datetime/interval checkers
local datetime = require('datetime')
local is_datetime = checkers.datetime(datetime.new { day = 1, month = 6, year = 2023 })
local is_interval = checkers.interval(datetime.interval.new { day = 1 })
-- is_datetime/is_interval = true

-- decimal checker
local decimal = require('decimal')
local is_decimal = checkers.decimal(decimal.new(16))
-- is_decimal = true

-- error checker
local server_error = box.error.new({ code = 500, reason = 'Server error' })
local is_error = checkers.error(server_error)
-- is_error = true

-- int64/uint64 checkers
local is_int64 = checkers.int64(-1024)
local is_uint64 = checkers.uint64(2048)
-- is_int64/is_uint64 = true

-- tuple checker
local is_tuple = checkers.tuple(box.tuple.new{1, 'The Beatles', 1960})
-- is_tuple = true

-- uuid checkers
local uuid = require('uuid')
local is_uuid = checkers.uuid(uuid())
local is_uuid_bin = checkers.uuid_bin(uuid.bin())
local is_uuid_str = checkers.uuid_str(uuid.str())
-- is_uuid/is_uuid_bin/is_uuid_str = true

local luatest = require('luatest')
local test_group = luatest.group()
test_group.test_checks = function()
    luatest.assert_equals(is_datetime, true)
    luatest.assert_equals(is_interval, true)
    luatest.assert_equals(is_decimal, true)
    luatest.assert_equals(is_error, true)
    luatest.assert_equals(is_int64, true)
    luatest.assert_equals(is_uint64, true)
    luatest.assert_equals(is_tuple, true)
    luatest.assert_equals(is_uuid, true)
    luatest.assert_equals(is_uuid_bin, true)
    luatest.assert_equals(is_uuid_str, true)
end
