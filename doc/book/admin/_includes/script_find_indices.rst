local fiber = require('fiber')
local decimal = require('decimal')

local function isnan(val)
    return type(val) == 'number' and val ~= val
end

local function isinf(val)
    return val == math.huge or val == -math.huge
end

local function vinyl(id)
    return box.space[id].engine == 'vinyl'
end

require_rebuild = {}
local iters = 0
for _, v in box.space._index:pairs({512, 0}, {iterator='GE'}) do
    local id = v[1]
    iters = iters + 1
    if iters % 1000 == 0 then
        fiber.yield()
    end
    if vinyl(id) then
        local format = v[6]
        local check_fields = {}
        for _, fmt in pairs(v[6]) do
            if fmt[2] == 'number' or fmt[2] == 'scalar' then
                table.insert(check_fields,  fmt[1] + 1)
            end
        end
        local have_decimal = {}
        local have_nan = {}
        if #check_fields > 0 then
            for k, tuple in box.space[id]:pairs() do
                for _, i in pairs(check_fields) do
                    iters = iters + 1
                    if iters % 1000 == 0 then
                        fiber.yield()
                    end
                    have_decimal[i] = have_decimal[i] or
                                    decimal.is_decimal(tuple[i])
                    have_nan[i] = have_nan[i] or isnan(tuple[i]) or
                                isinf(tuple[i])
                    if have_decimal[i] and have_nan[i] then
                        table.insert(require_rebuild, v)
                        goto out
                    end
                end
            end
        end
    end
    ::out::
end
