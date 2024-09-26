local function apply_scenario()
    local space = box.space['writers']

    space:create_index('age', {parts = {'age'}})
end

return {
    apply = {
        scenario = apply_scenario,
    },
}