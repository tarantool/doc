local helpers = require('tt-migrations.helpers')

local function apply_scenario()
    local space = box.schema.space.create('writers')

    space:format({
        {name = 'id', type = 'number'},
        {name = 'bucket_id', type = 'number'},
        {name = 'name', type = 'string'},
        {name = 'age', type = 'number'},
    })

    space:create_index('primary', {parts = {'id'}})
    space:create_index('bucket_id', {parts = {'bucket_id'}})

    helpers.register_sharding_key('writers', {'id'})
end

return {
    apply = {
        scenario = apply_scenario,
    },
}