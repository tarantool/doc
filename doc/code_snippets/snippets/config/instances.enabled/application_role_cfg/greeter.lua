-- greeter.lua --
local log = require('log').new("greeter")
local schema = require('experimental.config.utils.schema')

local greeter_schema = schema.new('greeter', schema.record({
    greeting = schema.scalar({
        type = 'string',
        allowed_values = { 'Hi', 'Hello' }
    })
}))

local function validate(cfg)
    greeter_schema:validate(cfg)
end

local function apply(cfg)
    log.info("%s from the 'greeter' role!", greeter_schema:get(cfg, 'greeting'))
end

local function stop()
    log.info("The 'greeter' role is stopped")
end

return {
    validate = validate,
    apply = apply,
    stop = stop,
}
