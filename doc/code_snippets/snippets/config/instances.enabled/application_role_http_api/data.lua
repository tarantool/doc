local data = {}

data.add_sample_data =  function()
    box.watch('box.status', function()
        if box.info.ro then
            return
        end

        box.schema.space.create('bands', { if_not_exists = true })
        box.space.bands:format({
            { name = 'id', type = 'unsigned' },
            { name = 'band_name', type = 'string' },
            { name = 'year', type = 'unsigned' }
        })
        box.space.bands:create_index('primary', { parts = { 'id' } })
        box.space.bands:create_index('band', { parts = { 'band_name' } })
        box.space.bands:create_index('year_band', { parts = { { 'year' }, { 'band_name' } } })

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
    end)
end

return data
