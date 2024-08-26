-- http_api.lua --
local log = require('log').new("http_api")
local schema = require('experimental.config.utils.schema')

local scheme_node = schema.enum({ 'http', 'https' })
local host_node = schema.scalar({ type = 'string' })
local port_node = schema.scalar({ type = 'integer' })

local scheme_from_env = schema.fromenv('HTTP_SCHEME', os.getenv('HTTP_SCHEME'), scheme_node)
local host_from_env = schema.fromenv('HTTP_HOST', os.getenv('HTTP_HOST'), host_node)
local port_from_env = schema.fromenv('HTTP_PORT', os.getenv('HTTP_PORT'), port_node)

local listen_address_schema = schema.new('listen_address', schema.record({
    scheme = scheme_node,
    host = host_node,
    port = port_node
}))

local function validate(cfg)
    listen_address_schema:set(cfg, 'scheme', scheme_from_env)
    listen_address_schema:set(cfg, 'host', host_from_env)
    listen_address_schema:set(cfg, 'port', port_from_env)
    listen_address_schema:validate(cfg)
end

local function apply(cfg)
    local scheme = listen_address_schema:get(cfg, 'scheme')
    local host = listen_address_schema:get(cfg, 'host')
    local port = listen_address_schema:get(cfg, 'port')
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
