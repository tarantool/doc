local http_client = require('http.client').new()
local json = require('json')

local io = http_client:get('https://httpbin.org/stream/5', {chunked = true})
local chunk_ids = ''
while data ~= '' do
    local data = io:read('\n')
    if data == '' then break end
    local decoded_data = json.decode(data)
    chunk_ids = chunk_ids..decoded_data['id']..' '
end
print('IDs of received chunks: '..chunk_ids)
io:finish()

local luatest = require('luatest')
local test_group = luatest.group()
test_group.test_returns_chunk_ids = function()
    luatest.assert_equals(chunk_ids, '0 1 2 3 4 ')
end
