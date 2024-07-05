local httpd

local function apply()
    if httpd then
        httpd:stop()
    end

    -- Expose Prometheus metrics --
    httpd = require('http.server').new('127.0.0.1', 8080)
    httpd:route({
        method = 'GET',
        path = '/metrics/prometheus'
    }, function()
        local prometheus_plugin = require('metrics.plugins.prometheus')
        local prometheus_metrics = prometheus_plugin.collect_http()
        return prometheus_metrics
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
