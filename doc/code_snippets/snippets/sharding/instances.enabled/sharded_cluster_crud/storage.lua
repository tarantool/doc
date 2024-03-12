local crud = require('crud')

local M = {}

function M.validate()
end

function M.apply()
    crud.init_storage()
    if box.info.ro ~= true then
        box.schema.create_space('bands', {
            format = {
                { name = 'id', type = 'unsigned' },
                { name = 'bucket_id', type = 'unsigned' },
                { name = 'band_name', type = 'string' },
                { name = 'year', type = 'unsigned' }
            },
            if_not_exists = true
        })
        box.space.bands:create_index('id', { parts = { 'id' }, if_not_exists = true })
        box.space.bands:create_index('bucket_id', { parts = { 'bucket_id' }, unique = false, if_not_exists = true })
    end
end

function M.stop()
    crud.stop_storage()
end

return M
