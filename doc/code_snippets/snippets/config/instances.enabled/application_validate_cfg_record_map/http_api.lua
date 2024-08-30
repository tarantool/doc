-- http_api.lua --
local log = require('log').new("http_api")
local schema = require('experimental.config.utils.schema')

local listen_address_schema = schema.new('listen_address', schema.record({
    scheme = schema.enum({ 'http', 'https' }),
    host = schema.scalar({ type = 'string' }),
    port = schema.scalar({ type = 'integer' }),
    endpoints = schema.map({ key = schema.scalar({ type = 'string' }),
                             value = schema.scalar({ type = 'boolean' }) })
}))

local function validate(cfg)
    listen_address_schema:validate(cfg)
end

local function apply(cfg)
    local scheme = listen_address_schema:get(cfg, 'scheme')
    local host = listen_address_schema:get(cfg, 'host')
    local port = listen_address_schema:get(cfg, 'port')
    local endpoints = listen_address_schema:get(cfg, 'endpoints')
    for name, value in pairs(endpoints) do
        if value then
            log.info("HTTP API endpoint: %s://%s:%d/%s", scheme, host, port, name)
        end
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
