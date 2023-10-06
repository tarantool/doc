local zlib_compressor = require('compress.zlib').new({
    level = 5,
    mem_level = 5,
    strategy = 'filtered'
})

compressed_data = zlib_compressor:compress('Hello world!')
decompressed_data = zlib_compressor:decompress(compressed_data)
print(decompressed_data)
