-- greeter.lua --
local log = require('log').new("greeter")

local function validate(cfg)
    if cfg.greeting then
        assert(type(cfg.greeting) == "string", "'greeting' should be a string")
        assert(cfg.greeting == "Hi" or cfg.greeting == "Hello", "'greeting' should be 'Hi' or 'Hello'")
    end
end

local function apply(cfg)
    log.info("%s from the 'greeter' role!", cfg.greeting)
end

local function stop()
    log.info("The 'greeter' role is stopped")
end

return {
    validate = validate,
    apply = apply,
    stop = stop,
}
