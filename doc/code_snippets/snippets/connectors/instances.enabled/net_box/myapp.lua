function net_box_session()
    local net_box = require('net.box')
    local conn = net_box.connect('sampleuser:123456@127.0.0.1:3301')
    conn:ping()

    conn.space.bands:insert { 1, 'Roxette', 1986 }
    conn.space.bands:insert { 2, 'Scorpions', 1965 }
    conn.space.bands:insert { 3, 'Ace of Base', 1987 }
    conn.space.bands:insert { 4, 'The Beatles', 1960 }
    --[[
    ---
    ...
    ]]

    conn.space.bands:select(1)
    --[[
    ---
    - - [1, 'Roxette', 1986]
    ...
    ]]

    conn.space.bands.index.band:select('The Beatles')
    --[[
    ---
    - - [4, 'The Beatles', 1960]
    ...
    ]]

    conn.space.bands:update({ 2 }, { { '=', 2, 'Pink Floyd' } })
    --[[
    ---
    - [2, 'Pink Floyd', 1965]
    ...
    ]]

    conn.space.bands:upsert({ 5, 'The Rolling Stones', 1962 }, { { '=', 2, 'The Doors' } })
    --[[
    ---
    ...
    ]]

    conn.space.bands:replace { 1, 'Queen', 1970 }
    --[[
    ---
    - [1, 'Queen', 1970]
    ...
    ]]

    conn.space.bands:delete(5)
    --[[
    ---
    - [5, 'The Rolling Stones', 1962]
    ...
    ]]

    conn:call('get_bands_older_than', { 1966 })
    -- ---
    -- - [[2, 'Pink Floyd', 1965], [4, 'The Beatles', 1960]]
    -- ...

    conn:close()
    --[[
    ---
    ...
    ]]
end
