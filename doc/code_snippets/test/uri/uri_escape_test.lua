local uri = require('uri')

escaped_string = uri.escape('C++')
--[[
---
- C%2B%2B
...
--]]
unescaped_string = uri.unescape('C%2B%2B')
--[[
---
- C++
...
--]]

escaped_string_url_enc = uri.escape('John Smith', uri.FORM_URLENCODED)
--[[
---
- John+Smith
...
--]]
unescaped_string_url_enc = uri.unescape('John+Smith', uri.FORM_URLENCODED)
--[[
---
- John Smith
...
--]]

local escape_opts = {
    plus = true,
    unreserved = uri.unreserved("a-z")
}
escaped_string_custom = uri.escape('Hello World', escape_opts)
--[[
---
- '%48ello+%57orld'
...
--]]
unescaped_string_custom = uri.unescape('%48ello+%57orld', escape_opts)
--[[
---
- Hello World
...
--]]

local luatest = require('luatest')
local test_group = luatest.group()
test_group.test_uri_escaping = function()
    luatest.assert_equals(escaped_string, 'C%2B%2B')
    luatest.assert_equals(unescaped_string, 'C++')
    luatest.assert_equals(escaped_string_url_enc, 'John+Smith')
    luatest.assert_equals(unescaped_string_url_enc, 'John Smith')
    luatest.assert_equals(escaped_string_custom, '%48ello+%57orld')
    luatest.assert_equals(unescaped_string_custom, 'Hello World')
end
