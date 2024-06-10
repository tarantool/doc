-- byeer.lua --
local log = require('log').new("byeer")

return {
    dependencies = { 'greeter' },
    validate = function() end,
    apply = function() log.info("Bye from the 'byeer' role!") end,
    stop = function() end,
}
