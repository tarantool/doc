-- supervised_instance.lua --
return {
    validate = function()
    end,
    apply = function()
        if box.info.ro then
            return
        end
        local func_name = 'failover.execute'
        local opts = { if_not_exists = true }
        box.schema.func.create(func_name, opts)
    end,
    stop = function()
        if box.info.ro then
            return
        end
        local func_name = 'failover.execute'
        if not box.schema.func.exists(func_name) then
            return
        end
        box.schema.func.drop(func_name)
    end,
}
