local http_client = require('http.client').new()
local response = http_client:get('https://httpbin.org/get', {
    params = { page = 1 },
})
print('URL: '..response.url)

local luatest = require('luatest')
local test_group = luatest.group()
test_group.test_returns_url_with_params = function()
    luatest.assert_equals(response:decode()['url'], 'https://httpbin.org/get?page=1')
end
