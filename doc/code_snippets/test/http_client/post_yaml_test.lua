local http_client = require('http.client').new()
local response = http_client:post('https://httpbin.org/anything', {
    user_id = 123,
    user_name = 'John Smith'
}, {
    headers = {
        ['Content-Type'] = 'application/yaml',
    }
})
print('Posted data:\n'..response:decode()['data'])

local luatest = require('luatest')
local test_group = luatest.group()
test_group.test_returns_yaml = function()
    luatest.assert_equals(response:decode()['data'], "---\
user_id: 123\
user_name: John Smith\
...\
")
end
