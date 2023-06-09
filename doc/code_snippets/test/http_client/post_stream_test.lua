local http_client = require('http.client').new()
local json = require('json')

local io = http_client:post('https://httpbin.org/anything', nil, {chunked = true})
io:write('Data part 1')
io:write('Data part 2')
io:finish()
response = io:read('\r\n')
decoded_data = json.decode(response)
print('Posted data: '..decoded_data['data'])

local luatest = require('luatest')
local test_group = luatest.group()
test_group.test_returns_posted_data = function()
    luatest.assert_equals(decoded_data['data'], 'Data part 1Data part 2')
end
