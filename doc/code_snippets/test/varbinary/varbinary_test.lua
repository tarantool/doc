local varbinary = require('varbinary')

local bin = varbinary.new('data')
varbinary.is(bin) -- true
varbinary.is(100) -- false
varbinary.is('data') -- false

print(bin == 'data') -- true
print(bin == varbinary.new('data')) -- true
print(bin == 'data1') -- false
print(bin ~= 'data1') -- true

print(#bin) -- 4
print(#varbinary.new('\xFF\xFE')) -- 2

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
