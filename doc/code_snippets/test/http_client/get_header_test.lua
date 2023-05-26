local http_client = require('http.client').new()
local response = http_client:get('https://httpbin.org/etag/7c876b7e')
print('ETag header value: '..response.headers['etag'])

local luatest = require('luatest')
local test_group = luatest.group()
test_group.test_returns_etag_header = function()
    luatest.assert_equals(response.headers['etag'], '7c876b7e')
end
