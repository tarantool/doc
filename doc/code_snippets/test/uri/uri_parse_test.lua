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

parsed_uri11 = uri.parse({'foo.bar?x=1&x=2'})
parsed_uri12 = uri.parse({uri = 'foo.bar?x=1&x=2'})
--[[
---
- host: foo.bar
  params:
    x:
    - '1'
    - '2'
  query: x=1&x=2
...
--]]

formatted_uri1 = uri.format(parsed_uri12)
--[[
---
- foo.bar?x=1&x=2
...
--]]

parsed_uri21 = uri.parse({'foo.bar?x=1', params = {x = 2, y = 3}})
parsed_uri22 = uri.parse({uri = 'foo.bar?x=1', params = {x = 2, y = 3}})
--[[
---
- host: foo.bar
  params:
    y:
    - '3'
    x:
    - '2'
  query: x=1
...
--]]

formatted_uri2 = uri.format(parsed_uri21)
--[[
---
- foo.bar?y=3&x=2
...
--]]

test_group.test_uri_parsing2 = function()
    luatest.assert_equals(parsed_uri11, parsed_uri12)
    luatest.assert_equals(parsed_uri11.host, 'foo.bar')
    luatest.assert_equals(parsed_uri11.query, 'x=1')
    luatest.assert_equals(parsed_uri11.params, {x = {'1', '2'}})
    luatest.assert_equals(formatted_uri1, 'foo.bar?x=1&x=2')

    luatest.assert_equals(parsed_uri21, parsed_uri22)
    luatest.assert_equals(parsed_uri21.host, 'foo.bar')
    luatest.assert_equals(parsed_uri21.query, 'x=1')
    luatest.assert_equals(parsed_uri21.params, {x = {'2'}, y = {'3'}})
    luatest.assert_equals(formatted_uri2, 'foo.bar?y=3&x=2')
end
