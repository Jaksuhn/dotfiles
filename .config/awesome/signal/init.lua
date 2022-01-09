-- These daemons are props to elenapan (except battery).
-- https://github.com/elenapan/dotfiles

-- there might be a better way of going about this.
-- awesome will not compile if there isn't a battery and this module is invoked.
local cmd = io.popen("upower -e | grep battery | wc -l")
local cmd_output = cmd:read("*a")
cmd:close()

if (tonumber(cmd_output) >= 1) then require("signal.battery") end
require("signal.volume")
require("signal.brightness")
require("signal.ram")
require("signal.cpu")
require("signal.temp")
require("signal.disk")
