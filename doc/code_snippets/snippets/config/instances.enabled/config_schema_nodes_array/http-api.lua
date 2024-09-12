-- http_api.lua --
local log = require('log').new("http_api")
local schema = require('experimental.config.utils.schema')

local listen_address_schema = schema.new('listen_address', schema.array({
    items = schema.record({
        scheme = schema.enum({ 'http', 'https' }),
        host = schema.scalar({ type = 'string' }),
        port = schema.scalar({ type = 'integer' })
    })
}))

local function validate(cfg)
    listen_address_schema:validate(cfg)
end

local function apply(cfg)
    for _, uri in ipairs(cfg) do
        local scheme = uri.scheme
        local host = uri.host
        local port = uri.port
        log.info("HTTP API endpoint: %s://%s:%d", scheme, host, port)
    end
end

local function stop()
    log.info("The 'http_api' role is stopped")
end

return {
    validate = validate,
    apply = apply,
    stop = stop,
}
