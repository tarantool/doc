-- myapp.lua --
local log = require('log').new("myapp")
local config = require('config')
log.info("%s from app, %s!", config:get('app.cfg.greeting'), box.info.name)
