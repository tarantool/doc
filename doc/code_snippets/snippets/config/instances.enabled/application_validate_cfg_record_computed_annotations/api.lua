-- api.lua --
local log = require('log').new("api")
local schema = require('experimental.config.utils.schema')

local listen_address = schema.record({
    scheme = schema.enum({ 'http', 'https' }),
    host = schema.scalar({ type = 'string' }),
    port = schema.scalar({ type = 'integer' })
}, {
    validate = function(data, w)
        local protocol = w.schema.computed.annotations.protocol
        if protocol == 'iproto' and data.scheme ~= nil then
            w.error("iproto doesn't support 'scheme'")
        end
    end,
})

local http_listen_address_schema = schema.new('http_listen_address', schema.record({
    name = schema.scalar({ type = 'string' }),
    listen_address = listen_address,
}, {
    protocol = 'http',
}))

local iproto_listen_address_schema = schema.new('iproto_listen_address', schema.record({
    name = schema.scalar({ type = 'string' }),
    listen_address = listen_address,
}, {
    protocol = 'iproto',
}))

local function validate(cfg)
    http_listen_address_schema:validate(cfg)
end

local function apply(cfg)
    local scheme = http_listen_address_schema:get(cfg, 'listen_address.scheme')
    local host = http_listen_address_schema:get(cfg, 'listen_address.host')
    local port = http_listen_address_schema:get(cfg, 'listen_address.port')
    log.info("API endpoint: %s://%s:%d", scheme, host, port)
end

local function stop()
    log.info("The 'api' role is stopped")
end

return {
    validate = validate,
    apply = apply,
    stop = stop,
}
