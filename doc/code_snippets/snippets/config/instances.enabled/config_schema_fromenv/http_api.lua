-- http_api.lua --
local log = require('log').new("http_api")
local schema = require('experimental.config.utils.schema')

local listen_address_schema = schema.new('listen_address', schema.record({
    scheme = schema.enum({ 'http', 'https' }, { env = 'HTTP_SCHEME' }),
    host = schema.scalar({ type = 'string', env = 'HTTP_HOST' }),
    port = schema.scalar({ type = 'integer', env = 'HTTP_PORT' })
}))

local function collect_env_cfg()
    local res = {}
    for _, w in listen_address_schema:pairs() do
        local env_var = w.schema.env
        if env_var ~= nil then
            local value = schema.fromenv(env_var, os.getenv(env_var), w.schema)
            listen_address_schema:set(res, w.path, value)
        end
    end
    return res
end

local function validate(cfg)
    local env_cfg = collect_env_cfg()
    local result_cfg = listen_address_schema:merge(cfg, env_cfg)
    listen_address_schema:validate(result_cfg)
end

local function apply(cfg)
    local env_cfg = collect_env_cfg()
    local result_cfg = listen_address_schema:merge(cfg, env_cfg)
    log.info("HTTP API endpoint: %s://%s:%d", result_cfg.scheme, result_cfg.host, result_cfg.port)
end

local function stop()
    log.info("The 'http_api' role is stopped")
end

return {
    validate = validate,
    apply = apply,
    stop = stop,
}
