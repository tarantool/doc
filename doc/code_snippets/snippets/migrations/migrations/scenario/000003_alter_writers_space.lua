local function apply_scenario()
    local space = box.space['writers']
    local new_format = {
        {name = 'id', type = 'number'},
        {name = 'bucket_id', type = 'number'},
        {name = 'first_name', type = 'string'},
        {name = 'last_name', type = 'string'},
        {name = 'age', type = 'number'},
    }
    box.space.writers.index.age:drop()

    box.schema.func.create('_writers_split_name', {
        language = 'lua',
        is_deterministic = true,
        body = [[
        function(t)
            local name = t[3]

            local split_data = {}
            local split_regex = '([^%s]+)'
            for v in string.gmatch(name, split_regex) do
                table.insert(split_data, v)
            end

            local first_name = split_data[1]
            assert(first_name ~= nil)

            local last_name = split_data[2]
            assert(last_name ~= nil)

            return {t[1], t[2], first_name, last_name, t[4]}
        end
        ]],
    })

    local future = space:upgrade({
        func = '_writers_split_name',
        format = new_format,
    })

    future:wait()
end

return {
    apply = {
        scenario = apply_scenario,
    },
}