#!/usr/bin/env tarantool

local xlog = require('xlog')
local json = require('json')

if arg[1] == nil then
    print(('Usage: %s xxxxxxxxxxxxxxxxxxxx.snap'):format(arg[0]))
    os.exit(1)
end

local illegal_types = {
    [''] = true,
    ['n'] = true,
    ['nu'] = true,
    ['s'] = true,
    ['st'] = true,
}

local function report_field_def(name, field_def)
    local msg = 'A field def in a _space entry %q contains an illegal type: %s'
    print(msg:format(name, json.encode(field_def)))
end

local has_broken_format = false

for _, record in xlog.pairs(arg[1]) do
    -- Filter inserts.
    if record.HEADER == nil or record.HEADER.type ~= 'INSERT' then
        goto continue
    end
    -- Filter _space records.
    if record.BODY == nil or record.BODY.space_id ~= 280 then
        goto continue
    end

    local tuple = record.BODY.tuple
    local name = tuple[3]
    local format = tuple[7]

    local is_format_broken = false
    for _, field_def in ipairs(format) do
        if illegal_types[field_def.type] ~= nil then
            report_field_def(name, field_def)
            is_format_broken = true
        end

        if illegal_types[field_def[2]] ~= nil then
            report_field_def(name, field_def)
            is_format_broken = true
        end

    end

    if is_format_broken then
        has_broken_format = true
        local msg = 'The following _space entry contains illegal type(s): %s'
        print(msg:format(json.encode(record)))
    end
    ::continue::
end

if has_broken_format then
    print('')
    print(('%s has an illegal type in a space format'):format(arg[1]))
    print('It is recommended to proceed with the upgrade instruction:')
    print('https://github.com/tarantool/tarantool/wiki/Fix-illegal-field-type-in-a-space-format-when-upgrading-to-2.10.4')
else
    print('Everything looks nice!')
end

os.exit(has_broken_format and 2 or 0)