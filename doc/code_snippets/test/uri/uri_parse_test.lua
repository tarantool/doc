local uri = require('uri')

parsed_uri = uri.parse('https://www.tarantool.io/doc/latest/reference/reference_lua/http/#api-reference')
--[[
---
- host: www.tarantool.io
  fragment: api-reference
  scheme: https
  path: /doc/latest/reference/reference_lua/http/
...
--]]

formatted_uri = uri.format({ scheme = 'https',
                             host = 'www.tarantool.io',
                             path = '/doc/latest/reference/reference_lua/http/',
                             fragment = 'api-reference' })
--[[
---
- https://www.tarantool.io/doc/latest/reference/reference_lua/http/#api-reference
...
--]]

local luatest = require('luatest')
local test_group = luatest.group()
test_group.test_uri_parsing = function()
    luatest.assert_equals(parsed_uri.scheme, 'https')
    luatest.assert_equals(parsed_uri.host, 'www.tarantool.io')
    luatest.assert_equals(parsed_uri.path, '/doc/latest/reference/reference_lua/http/')
    luatest.assert_equals(parsed_uri.fragment, 'api-reference')
    luatest.assert_equals(formatted_uri, 'https://www.tarantool.io/doc/latest/reference/reference_lua/http/#api-reference')
end
