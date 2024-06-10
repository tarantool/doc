-- http-api.lua --
local httpd
local json = require('json')

local function validate(cfg)
    if cfg.host then
        assert(type(cfg.host) == "string", "'host' should be a string containing a valid IP address")
    end
    if cfg.port then
        assert(type(cfg.port) == "number", "'port' should be a number")
        assert(cfg.port >= 1 and cfg.port <= 65535, "'port' should be between 1 and 65535")
    end
end

local function apply(cfg)
    if httpd then
        httpd:stop()
    end
    httpd = require('http.server').new(cfg.host, cfg.port)
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
