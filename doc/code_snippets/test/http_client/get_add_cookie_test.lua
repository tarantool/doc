local http_client = require('http.client').new()
local response = http_client:get('https://httpbin.org/cookies', {
    headers = {
        ['Cookie'] = 'session_id=abc123; csrftoken=u32t4o;',
    }
})
print(response.body)

local luatest = require('luatest')
local test_group = luatest.group()
test_group.test_returns_cookie = function()
    luatest.assert_equals(response:decode()['cookies']['session_id'], 'abc123')
end
