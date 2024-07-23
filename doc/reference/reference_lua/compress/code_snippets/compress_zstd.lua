local zstd_compressor = require('compress.zstd').new({
    level = 5
})

compressed_data = zstd_compressor:compress('Hello world!')
decompressed_data = zstd_compressor:decompress(compressed_data)
print(decompressed_data)
