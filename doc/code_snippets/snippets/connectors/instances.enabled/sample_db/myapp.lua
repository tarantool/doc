-- Create a space --
box.schema.space.create('bands')

-- Specify field names and types --
box.space.bands:format({
    { name = 'id', type = 'unsigned' },
    { name = 'band_name', type = 'string' },
    { name = 'year', type = 'unsigned' }
})

-- Create indexes --
box.space.bands:create_index('primary', { parts = { 'id' } })
box.space.bands:create_index('band', { parts = { 'band_name' } })
box.space.bands:create_index('year_band', { parts = { { 'year' }, { 'band_name' } } })

-- Create a stored function --
box.schema.func.create('get_bands_older_than', {
    body = [[
    function(year)
        return box.space.bands.index.year_band:select({ year }, { iterator = 'LT', limit = 10 })
    end
    ]]
})
