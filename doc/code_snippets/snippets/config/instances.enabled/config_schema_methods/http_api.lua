-- http_api.lua --
local log = require('log').new("http_api")
local schema = require('experimental.config.utils.schema')

local listen_address_schema = schema.new(
        "listen_address",
        schema.record(
                {
                    scheme = schema.enum({ "http", "https" }),
                    host = schema.scalar({ type = "string" }),
                    port = schema.scalar({ type = "integer" })
                }
        ),
        {
            methods = {
                format = function(_self, url)
                    return string.format("%s://%s:%d", url.scheme, url.host, url.port)
                end
            }
        }
)

local function validate(cfg)
    listen_address_schema:validate(cfg)
end

local function apply(cfg)
    local url_string = listen_address_schema:format(cfg)
    log.info("HTTP API endpoint: %s", url_string)
end

local function stop()
    log.info("The 'http_api' role is stopped")
end

return {
    validate = validate,
    apply = apply,
    stop = stop,
}
