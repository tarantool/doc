ffi = require('ffi')

-- Prints 'info' messages --
ffi.C._say(ffi.C.S_INFO, nil, 0, nil, 'Info message from C module')
--[[
[6024] main/103/interactive I> Info message from C module
---
...
--]]

-- Swallows 'debug' messages --
ffi.C._say(ffi.C.S_DEBUG, nil, 0, nil, 'Debug message from C module')
--[[
---
...
--]]
