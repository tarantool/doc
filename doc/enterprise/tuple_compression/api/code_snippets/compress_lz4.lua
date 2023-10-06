local lz4_compressor = require('compress.lz4').new({
    acceleration = 1000,
    decompress_buffer_size = 2097152
})

compressed_data = lz4_compressor:compress('Hello world!')
decompressed_data = lz4_compressor:decompress(compressed_data)
print(decompressed_data)
