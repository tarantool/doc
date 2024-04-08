module1 = require('test.module1')
module2 = require('test.module2')

-- Prints 'info' messages --
module1.say_hello()
--[[
[92617] main/103/interactive/test.logging.module1 I> Info message from module1
---
...
--]]

-- Swallows 'info' messages --
module2.say_hello()
--[[
---
...
--]]
