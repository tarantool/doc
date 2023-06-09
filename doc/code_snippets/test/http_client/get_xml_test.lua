local http_client = require('http.client').new()
local xml = require("luarapidxml")

http_client.decoders = {
    ['application/xml'] = function(body, _content_type)
        return xml.decode(body)
    end,
}

local response = http_client:get('https://httpbin.org/xml')
local document = response:decode()
print("'title' value: "..document['attr']['title'])

local luatest = require('luatest')
local test_group = luatest.group()
test_group.test_returns_json = function()
    luatest.assert_equals(document['attr']['title'], 'Sample Slide Show')
end
