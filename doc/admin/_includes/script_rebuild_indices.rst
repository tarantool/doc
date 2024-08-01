local log = require('log')

local function rebuild_index(idx)
    local index_name = idx[3]
    local space_name = box.space[idx[1]].name
    log.info("Rebuilding index %s on space %s", index_name, space_name)
    if (idx[2] == 0) then
        log.error("Cannot rebuild primary index %s on space %s. Please, "..
                "recreate the space manually", index_name, space_name)
        return
    end
    log.info("Deleting index %s on space %s", index_name, space_name)
    local v = box.space._index:delete{idx[1], idx[2]}
    if v == nil then
        log.error("Couldn't find index %s on space %s", index_name, space_name)
        return
    end
    log.info("Done")
    log.info("Creating index %s on space %s", index_name, space_name)
    box.space._index:insert(v)
end

for _, idx in pairs(require_rebuild) do
    rebuild_index(idx)
end
