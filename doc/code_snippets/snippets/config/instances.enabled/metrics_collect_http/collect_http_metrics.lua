local httpd

local function apply()
    if httpd then
        httpd:stop()
    end

    -- Collect HTTP metrics for the '/metrics/hello' route --
    httpd = require('http.server').new('127.0.0.1', 8080)
    local metrics = require('metrics')
    metrics.http_middleware.configure_default_collector('summary')
    httpd:route({
        method = 'GET',
        path = '/metrics/hello'
    }, metrics.http_middleware.v1(
            function()
                return { status = 200,
                         headers = { ['content-type'] = 'text/plain' },
                         body = 'Hello from http_middleware!' }
            end))

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
