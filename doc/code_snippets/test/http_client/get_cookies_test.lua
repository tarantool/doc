local http_client = require('http.client').new()
local response = http_client:get('https://httpbin.org/cookies/set?session_id=abc123&csrftoken=u32t4o&', {follow_location = false})
print("'session_id' cookie value: "..response.cookies['session_id'][1])

local luatest = require('luatest')
local test_group = luatest.group()
test_group.test_returns_cookie = function()
    luatest.assert_equals(response.cookies['session_id'][1], 'abc123')
end
