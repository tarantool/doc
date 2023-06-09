local http_client = require('http.client').new()
local response = http_client:post('https://httpbin.org/anything', {
    user_id = 123,
    user_name = 'John Smith'
})
print('Posted data: '..response:decode()['data'])

local luatest = require('luatest')
local test_group = luatest.group()
test_group.test_returns_json = function()
    luatest.assert_equals(response:decode()['data'], '{"user_id":123,"user_name":"John Smith"}')
end
