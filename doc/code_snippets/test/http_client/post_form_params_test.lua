local http_client = require('http.client').new()
local response = http_client:post('https://httpbin.org/anything', nil, {
    params = { user_id = 123, user_name = 'John Smith' },
})
print('User ID: '..response:decode()['form']['user_id'])

local luatest = require('luatest')
local test_group = luatest.group()
test_group.test_returns_form_data = function()
    luatest.assert_equals(response:decode()['form'], {user_id = "123", user_name = "John Smith"})
end
