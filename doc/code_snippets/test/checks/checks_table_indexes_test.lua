function configure_connection(options)
    checks({ 'string', 'number' })
    local ip_address = options[1] or '127.0.0.1'
    local port = options[2] or 3301
    return ip_address .. ':' .. port
end
--[[
configure_connection({'0.0.0.0', 3303})
-- returns '0.0.0.0:3303'

configure_connection({'0.0.0.0', '3303'})
-- raises an error: bad argument options[2] to nil (number expected, got string)
--]]

-- Tests
local luatest = require('luatest')
local test_group = luatest.group()
test_group.test_checks = function()
    luatest.assert_equals(configure_connection({ '0.0.0.0', 3303 }), '0.0.0.0:3303')
    luatest.assert_error_msg_contains('bad argument options[2] to nil (number expected, got string)', configure_connection, { '0.0.0.0', '3303' })
end
