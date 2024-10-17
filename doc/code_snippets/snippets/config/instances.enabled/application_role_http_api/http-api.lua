-- http-api.lua --
local httpd
local json = require('json')
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
    if httpd then
        httpd:stop()
    end
    local cfg_with_defaults = listen_address_schema:apply_default(cfg)
    local host = listen_address_schema:get(cfg_with_defaults, 'host')
    local port = listen_address_schema:get(cfg_with_defaults, 'port')
    httpd = require('http.server').new(host, port)
    local response_headers = { ['content-type'] = 'application/json' }
    httpd:route({ path = '/band/:id', method = 'GET' }, function(req)
        local id = req:stash('id')
        local band_tuple = box.space.bands:get(tonumber(id))
        if not band_tuple then
            return { status = 404, body = 'Band not found' }
        else
            local band = { id = band_tuple['id'],
                           band_name = band_tuple['band_name'],
                           year = band_tuple['year'] }
            return { status = 200, headers = response_headers, body = json.encode(band) }
        end
    end)
    httpd:route({ path = '/band', method = 'GET' }, function(req)
        local limit = req:query_param('limit')
        if not limit then
            limit = 5
        end
        local band_tuples = box.space.bands:select({}, { limit = tonumber(limit) })
        local bands = {}
        for _, tuple in pairs(band_tuples) do
            local band = { id = tuple['id'],
                           band_name = tuple['band_name'],
                           year = tuple['year'] }
            table.insert(bands, band)
        end
        return { status = 200, headers = response_headers, body = json.encode(bands) }
    end)
    httpd:start()
end

local function stop()
    httpd:stop()
end

local function init()
    require('data'):add_sample_data()
end

init()

return {
    validate = validate,
    apply = apply,
    stop = stop,
}
