-- Convert illegal type names in a space format that were
-- allowed before tarantool 2.10.4.

local log = require('log')
local json = require('json')

local transforms = {
    [''] = 'num',
    ['n'] = 'num',
    ['nu'] = 'num',
    ['s'] = 'str',
    ['st'] = 'str',
}

-- The helper for before_replace().
local function transform_field_def(name, field_def, field, new_type)
    local field_def_old_str = json.encode(field_def)
    field_def[field] = new_type
    local field_def_new_str = json.encode(field_def)

    local msg = 'Transform a field def in a _space entry %q: %s -> %s'
    log.info(msg:format(name, field_def_old_str, field_def_new_str))
end

-- _space trigger.
local function before_replace(_, tuple)
    if tuple == nil then return tuple end

    local name = tuple[3]
    local format = tuple[7]

    -- Update format if necessary.
    local is_format_changed = false
    for i, field_def in ipairs(format) do
        local new_type = transforms[field_def.type]
        if new_type ~= nil then
            transform_field_def(name, field_def, 'type', new_type)
            is_format_changed = true
        end

        local new_type = transforms[field_def[2]]
        if new_type ~= nil then
            transform_field_def(name, field_def, 2, new_type)
            is_format_changed = true
        end
    end

    -- No changed: skip.
    if not is_format_changed then return tuple end

    -- Rebuild the tuple.
    local new_tuple = tuple:transform(7, 1, format)
    log.info(('Transformed _space entry %s to %s'):format(
        json.encode(tuple), json.encode(new_tuple)))
    return new_tuple
end

-- on_schema_init trigger to set before_replace().
local function on_schema_init()
    box.space._space:before_replace(before_replace)
end

-- Set the trigger on _space.
box.ctl.on_schema_init(on_schema_init)