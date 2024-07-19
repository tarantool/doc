local httpd

local function apply()
    if httpd then
        httpd:stop()
    end

    -- Expose JSON metrics --
    httpd = require('http.server').new('127.0.0.1', 8081)
    httpd:route({
        method = 'GET',
        path = '/metrics/json'
    }, function()
        local json_plugin = require('metrics.plugins.json')
        local json_metrics = json_plugin.export()
        return { status = 200,
                 headers = { ['content-type'] = 'application/json' },
                 body = json_metrics }
    end)
    httpd:start()
end

local function stop()
    httpd:stop()
end

return {
    validate = function()
    end,
    apply = apply,
    stop = stop,
}
