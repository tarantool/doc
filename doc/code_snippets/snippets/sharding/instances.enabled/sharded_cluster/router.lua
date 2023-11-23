local vshard = require('vshard')

vshard.router.bootstrap()

function put(id, band_name, year)
    local bucket_id = vshard.router.bucket_id_mpcrc32({ id })
    vshard.router.callrw(bucket_id, 'put', { id, bucket_id, band_name, year })
end

function get(id)
    local bucket_id = vshard.router.bucket_id_mpcrc32({ id })
    return vshard.router.callro(bucket_id, 'get', { id })
end

function insert_data()
    put(1, 'Roxette', 1986)
    put(2, 'Scorpions', 1965)
    put(3, 'Ace of Base', 1987)
    put(4, 'The Beatles', 1960)
    put(5, 'Pink Floyd', 1965)
    put(6, 'The Rolling Stones', 1962)
    put(7, 'The Doors', 1965)
    put(8, 'Nirvana', 1987)
    put(9, 'Led Zeppelin', 1968)
    put(10, 'Queen', 1970)
end
