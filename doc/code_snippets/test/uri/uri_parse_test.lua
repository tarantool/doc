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

formatted_uri3_e = uri.format({
    login = uri.escape('replic@ator'),
    password = uri.escape(':::'),
    host = 'foo.bar',
    params = {x = uri.escape('sec ret?', uri.FORM_URLENCODED)}
    },
    true
)
--[[
---
- replic%40ator:%3A%3A%3A@foo.bar?x=sec+ret%3F
...
]]--

parsed_uri3_e = uri.parse(formatted_uri3_e)
--[[
---
- password: '%3A%3A%3A'
  login: replic%40ator
  query: x=sec+ret%3F
  params:
    x:
    - sec+ret%3F
  host: foo.bar
...
]]--

parsed_uri3 = {
    login = uri.unescape(parsed_uri3_e.login),
    password = uri.unescape(parsed_uri3_e.password),
    host = parsed_uri3_e.host,
    params = {x = {uri.unescape(parsed_uri3_e.params.x[1], uri.FORM_URLENCODED)}},
}
--[[
---
- password: ':::'
  params:
    x:
    - sec ret?
  host: foo.bar
  login: replic@ator
...
]]--

test_group.test_uri_parsing3 = function()
    luatest.assert_equals(formatted_uri3_e, 'replic%40ator:%3A%3A%3A@foo.bar?x=sec+ret%3F')
    luatest.assert_equals(parsed_uri3_e.login, 'replic%40ator')
    luatest.assert_equals(parsed_uri3_e.password, '%3A%3A%3A')
    luatest.assert_equals(parsed_uri3_e.host, 'foo.bar')
    luatest.assert_equals(parsed_uri3_e.query, 'x=sec+ret%3F')
    luatest.assert_equals(parsed_uri3_e.params, {x = {'sec+ret%3F'}})

    luatest.assert_equals(parsed_uri3.login, 'replic@ator')
    luatest.assert_equals(parsed_uri3.password, ':::')
    luatest.assert_equals(parsed_uri3.host, 'foo.bar')
    luatest.assert_equals(parsed_uri3.params, {x = {'sec ret?'}})
end
