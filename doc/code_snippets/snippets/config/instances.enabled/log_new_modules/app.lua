-- Creates new loggers --
module1_log = require('log').new('module1')
module2_log = require('log').new('module2')

-- Prints 'info' messages --
module1_log.info('Info message from module1')
--[[
[16300] main/103/interactive/module1 I> Info message from module1
---
...
--]]

-- Swallows 'debug' messages --
module1_log.debug('Debug message from module1')
--[[
---
...
--]]

-- Swallows 'info' messages --
module2_log.info('Info message from module2')
--[[
---
...
--]]
