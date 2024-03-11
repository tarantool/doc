local vshard = require('vshard')
local crud = require('crud')

local M = {}

function M.validate()
end

function M.apply()
    crud.init_router()
end

function M.stop()
    crud.stop_router()
end

return M
