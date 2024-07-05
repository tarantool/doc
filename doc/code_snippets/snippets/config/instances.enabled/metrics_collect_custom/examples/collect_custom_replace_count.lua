local function apply()
    -- Collect a custom metric at an arbitrary moment in time --
    local metrics = require('metrics')
    local bands_replace_count = metrics.counter('bands_replace_count', 'The number of data operations')
    local trigger = require('trigger')
    trigger.set(
            'box.space.bands.on_replace',
            'update_bands_replace_count_metric',
            function(_, _, _, request_type)
                bands_replace_count:inc(1, { request_type = request_type })
            end
    )
    -- End --
end

return {
    validate = function()
    end,
    apply = apply,
    stop = function()
    end,
}
