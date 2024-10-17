-- http_api.lua --
local log = require('log').new("http_api")
local schema = require('experimental.config.utils.schema')

local function validate_host(host, w)
    local host_pattern = "^(%d+)%.(%d+)%.(%d+)%.(%d+)$"
    if not host:match(host_pattern) then
        w.error("'host' should be a string containing a valid IP address, got %q", host)
    end
end

local function validate_port(port, w)
    if port <= 1 or port >= 65535 then
        w.error("'port' should be between 1 and 65535, got %d", port)
    end
end

local listen_address_schema = schema.new('listen_address', schema.record({
    scheme = schema.scalar({
        type = 'string',
        allowed_values = { 'http', 'https' },
        default = 'http',
    }),
    host = schema.scalar({
        type = 'string',
        validate = validate_host,
        default = '127.0.0.1',
    }),
    port = schema.scalar({
        type = 'integer',
        validate = validate_port,
        default = 8080,
    }),
}))

local function validate(cfg)
    listen_address_schema:validate(cfg)
end

local function apply(cfg)
    local cfg_with_defaults = listen_address_schema:apply_default(cfg)
    local scheme = listen_address_schema:get(cfg_with_defaults, 'scheme')
    local host = listen_address_schema:get(cfg_with_defaults, 'host')
    local port = listen_address_schema:get(cfg_with_defaults, 'port')
    log.info("HTTP API endpoint: %s://%s:%d", scheme, host, port)
end

local function stop()
    log.info("The 'http_api' role is stopped")
end

return {
    validate = validate,
    apply = apply,
    stop = stop,
}
