local http_client = require('http.client').new()
local response = http_client:get('https://httpbin.org/get')
print('Status: '..response.status..' '.. response.reason)

local luatest = require('luatest')
local test_group = luatest.group()
test_group.test_returns_status = function()
    luatest.assert_equals(response.status, 200)
end
