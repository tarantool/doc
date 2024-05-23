-- greeter.lua --
local log = require('log').new("greeter")

local function validate_config(cfg)
    if cfg.greeting then
        assert(type(cfg.greeting) == "string", "'greeting' should be a string")
        assert(cfg.greeting == "Hi" or cfg.greeting == "Hello", "'greeting' should be 'Hi' or 'Hello'")
    end
end

local function apply_config(cfg)
    log.info("%s from the 'greeter' role!", cfg.greeting)
end

local function stop_role()
    log.info("The 'greeter' role is stopped")
end

return {
    validate = validate_config,
    apply = apply_config,
    stop = stop_role,
}
