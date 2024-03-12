net_box = require('net.box')
--[[
---
...
]]

conn = net_box.connect('sampleuser:123456@127.0.0.1:3301')
--[[
---
...
]]

conn:ping()
--[[
---
- true
...
]]

function net_box_data_operations()
    -- Start net.box session
    conn.space.bands:insert({ 1, 'Roxette', 1986 })
    --[[
    ---
    - - [1, 'Roxette', 1986]
    ...
    ]]
    conn.space.bands:insert({ 2, 'Scorpions', 1965 })
    --[[
    ---
    - [2, 'Scorpions', 1965]
    ...
    ]]
    conn.space.bands:insert({ 3, 'Ace of Base', 1987 })
    --[[
    ---
    - [3, 'Ace of Base', 1987]
    ...
    ]]
    conn.space.bands:insert({ 4, 'The Beatles', 1960 })
    --[[
    ---
    - [4, 'The Beatles', 1960]
    ...
    ]]

    conn.space.bands:select({ 1 })
    --[[
    ---
    - - [1, 'Roxette', 1986]
    ...
    ]]

    conn.space.bands.index.band:select({ 'The Beatles' })
    --[[
    ---
    - - [4, 'The Beatles', 1960]
    ...
    ]]

    conn.space.bands:update({ 2 }, { { '=', 'band_name', 'Pink Floyd' } })
    --[[
    ---
    - [2, 'Pink Floyd', 1965]
    ...
    ]]

    conn.space.bands:upsert({ 5, 'The Rolling Stones', 1962 }, { { '=', 'band_name', 'The Doors' } })
    --[[
    ---
    ...
    ]]

    conn.space.bands:replace({ 1, 'Queen', 1970 })
    --[[
    ---
    - [1, 'Queen', 1970]
    ...
    ]]

    conn.space.bands:delete({ 5 })
    --[[
    ---
    - [5, 'The Rolling Stones', 1962]
    ...
    ]]

    conn:call('get_bands_older_than', { 1966 })
    -- ---
    -- - [[2, 'Pink Floyd', 1965], [4, 'The Beatles', 1960]]
    -- ...
    -- End net.box session
end

function net_box_close_connection()
    conn:close()
    --[[
    ---
    ...
    ]]
    -- Close net.box connection
end
