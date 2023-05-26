local http_client = require('http.client').new()
local response = http_client:get('https://httpbin.org/json')
local document = response:decode()
print("'title' value: "..document['slideshow']['title'])

local luatest = require('luatest')
local test_group = luatest.group()
test_group.test_returns_json = function()
    luatest.assert_equals(document['slideshow']['title'], 'Sample Slide Show')
end
