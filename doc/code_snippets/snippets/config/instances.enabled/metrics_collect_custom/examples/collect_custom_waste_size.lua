local function apply()
    -- Collect a custom metric when the data collected by metrics is requested --
    local metrics = require('metrics')
    local bands_waste_size = metrics.gauge('bands_waste_size', 'The size of memory wasted due to internal fragmentation')
    metrics.register_callback(function()
        bands_waste_size:set(box.space.bands:stat()['tuple']['memtx']['waste_size'])
    end)
    -- End --
end

return {
    validate = function()
    end,
    apply = apply,
    stop = function()
    end,
}
