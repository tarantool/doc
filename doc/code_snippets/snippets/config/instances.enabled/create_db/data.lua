function create_space()
    box.schema.space.create('bands')
    box.space.bands:format({
        { name = 'id', type = 'unsigned' },
        { name = 'band_name', type = 'string' },
        { name = 'year', type = 'unsigned' }
    })
    box.space.bands:create_index('primary', { parts = { 'id' } })
    box.space.bands:create_index('secondary', { parts = { 'band_name' } })
    box.schema.user.grant('guest', 'read,write,execute', 'universe')
end

function load_data()
    box.space.bands:insert { 1, 'Roxette', 1986 }
    box.space.bands:insert { 2, 'Scorpions', 1965 }
    box.space.bands:insert { 3, 'Ace of Base', 1987 }
    box.space.bands:insert { 4, 'The Beatles', 1960 }
    box.space.bands:insert { 5, 'Pink Floyd', 1965 }
    box.space.bands:insert { 6, 'The Rolling Stones', 1962 }
    box.space.bands:insert { 7, 'The Doors', 1965 }
    box.space.bands:insert { 8, 'Nirvana', 1987 }
    box.space.bands:insert { 9, 'Led Zeppelin', 1968 }
    box.space.bands:insert { 10, 'Queen', 1970 }
end

function select_data()
    box.space.bands:select { 3 }
    box.space.bands.index.secondary:select{'Scorpions'}
end