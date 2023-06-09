local http_client = require('http.client').new()
local response = http_client:get('https://httpbin.org/headers', {
    headers = {
        ['User-Agent'] = 'Tarantool HTTP client',
        ['Authorization'] = 'Bearer abc123'
    }
})
print('Authorization: '..response:decode()['headers']['Authorization'])

local luatest = require('luatest')
local test_group = luatest.group()
test_group.test_returns_header = function()
    luatest.assert_equals(response:decode()['headers']['User-Agent'], 'Tarantool HTTP client')
    luatest.assert_equals(response:decode()['headers']['Authorization'], 'Bearer abc123')
end
