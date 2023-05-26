local http_client = require('http.client').new()
local response = http_client:get('https://httpbin.org/gzip', {accept_encoding = "br, gzip, deflate"})
print('Is response gzipped: '..tostring(response:decode()['gzipped']))

local luatest = require('luatest')
local test_group = luatest.group()
test_group.test_returns_status = function()
    luatest.assert_equals(response:decode()['gzipped'], true)
end
