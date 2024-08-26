-- http_api.lua --
local log = require('log').new("http_api")
local schema = require('experimental.config.utils.schema')

local http_api_schema = schema.new('http_api', schema.scalar({ type = 'string' }))

local function validate(cfg)
    http_api_schema:validate(cfg)
end

local function apply(cfg)
    local http_api_cfg = http_api_schema:get(cfg)
    log.info("HTTP API endpoint: %s", http_api_cfg)
end

local function stop()
    log.info("The 'http_api' role is stopped")
end

return {
    validate = validate,
    apply = apply,
    stop = stop,
}
