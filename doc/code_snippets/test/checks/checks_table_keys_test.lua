function configure_connection_opts(options)
    checks({ ip_address = 'string', port = 'number' })
    local ip_address = options.ip_address or '127.0.0.1'
    local port = options.port or 3301
    return ip_address .. ':' .. port
end
--[[
configure_connection_opts({ip_address = '0.0.0.0', port = 3303})
-- returns '0.0.0.0:3303'

configure_connection_opts({ip_address = '0.0.0.0', port = '3303'})
-- raises an error: bad argument options.port to nil (number expected, got string)

configure_connection_opts({login = 'testuser', ip_address = '0.0.0.0', port = 3303})
-- raises an error: unexpected argument options.login to nil
--]]

-- Tests
local luatest = require('luatest')
local test_group = luatest.group()
test_group.test_checks = function()
    luatest.assert_equals(configure_connection_opts({ ip_address = '0.0.0.0', port = 3303 }), '0.0.0.0:3303')
    luatest.assert_error_msg_contains('bad argument options.port to nil (number expected, got string)', configure_connection_opts, { ip_address = '0.0.0.0', port = '3303' })
    luatest.assert_error_msg_contains('unexpected argument options.login to nil', configure_connection_opts, { login = 'testuser', ip_address = '0.0.0.0', port = 3303 })
end
