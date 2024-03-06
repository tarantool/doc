local vshard = require('vshard')
local crud = require('crud')
local log = require('log')
local fiber = require('fiber')

local M = {}

function M.validate()
end

function M.bootstrap_f()
    for i = 1, 10 do
        local rc, err = vshard.router.bootstrap()
        log.info("Attempt to bootstrap vshard cluster")
        log.info(rc)
        if rc == nil then
            if string.find(tostring(err), "is already bootstrapped") ~= nil then
                break
            end
            log.info(err)
        end
        if rc ~= nil then
            break
        end
        fiber.sleep(1)
    end
end

function M.apply(cfg)
    M.bootstrap_fiber = fiber.create(M.bootstrap_f, cfg)

    crud.init_router()
end

function M.stop()
    crud.stop_router()
end

return M
