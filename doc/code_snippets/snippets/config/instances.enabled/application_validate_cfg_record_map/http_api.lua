-- http_api.lua --
log = require('log').new("http_api")
schema = require('experimental.config.utils.schema')

listen_address_schema = schema.new('listen_address', schema.record({
    scheme = schema.enum({ 'http', 'https' }),
    host = schema.scalar({ type = 'string' }),
    port = schema.scalar({ type = 'integer' }),
    query_params = schema.map({ key = schema.scalar({ type = 'string' }),
                                value = schema.scalar({ type = 'integer' }) })
}))

local function validate(cfg)
    listen_address_schema:validate(cfg)
end

local function apply(cfg)
    local scheme = listen_address_schema:get(cfg, 'scheme')
    local host = listen_address_schema:get(cfg, 'host')
    local port = listen_address_schema:get(cfg, 'port')
    local query_params = listen_address_schema:get(cfg, 'query_params')
    local query_string = ''
    for name, value in pairs(query_params) do
        query_string = query_string .. name .. '=' .. value .. '&'
    end
    local query_string_without_amp = string.gsub(query_string, "&$", "")
    log.info("HTTP API endpoint: %s://%s:%d?%s", scheme, host, port, query_string_without_amp)
end

local function stop()
    log.info("The 'http_api' role is stopped")
end

return {
    validate = validate,
    apply = apply,
    stop = stop,
}
