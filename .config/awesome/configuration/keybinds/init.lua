local awful = require("awful")
local gears = require("gears")

-- Mouse Bindings
awful.mouse.append_global_mousebindings({
    awful.button({}, 4, awful.tag.viewprev),
    awful.button({}, 5, awful.tag.viewnext)
})

root.keys(gears.table.join(
  require("configuration.keys.apps"),
  require("configuration.keys.awesome"),
  require("configuration.keys.client"),
  require("configuration.keys.layout"),
  require("configuration.keys.media"),
  require("configuration.keys.scratchpad"),
  require("configuration.keys.screen"),
  require("configuration.keys.tabs"),
  require("configuration.keys.tag")
))