local varbinary = require('varbinary')

-- Create a varbinary object
local bin = varbinary.new('data')
local bin_hex = varbinary.new('\xFF\xFE')

-- Check whether a value is a varbinary object
varbinary.is(bin) -- true
varbinary.is(bin_hex) -- true
varbinary.is(100) -- false
varbinary.is('data') -- false

-- Check varbinary objects equality
print(bin == varbinary.new('data')) -- true
print(bin == 'data') -- true
print(bin ~= 'data1') -- true
print(bin_hex ~= '\xFF\xFE') -- false

-- Check varbinary objects length
print(#bin) -- 4
print(#bin_hex) -- 2

-- Print string representation
print(tostring(bin)) -- data

local bin2 = varbinary.new(ffi.cast('const char *', 'data'), 4)
varbinary.is(bin2) -- true
print(bin2) -- data

local luatest = require('luatest')
local test_group = luatest.group()
test_group.test_varbinary = function()
    luatest.assert_equals(varbinary.is(bin), true)
    luatest.assert_equals(bin, 'data')
    luatest.assert_equals(#bin, 4)
    luatest.assert_equals(#varbinary.new('\xFF\xFE'), 2)
end
