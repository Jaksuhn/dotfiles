local gears = require("gears")

-- Mouse Bindings
awful.mouse.append_global_mousebindings({
    awful.button({}, 4, awful.tag.viewprev),
    awful.button({}, 5, awful.tag.viewnext)
})

root.keys(gears.table.join(
  require("configuration.keybinds.apps"),
  require("configuration.keybinds.awesome"),
  require("configuration.keybinds.client"),
  require("configuration.keybinds.layout"),
  require("configuration.keybinds.media"),
  require("configuration.keybinds.scratchpad"),
  require("configuration.keybinds.screen"),
  require("configuration.keybinds.tabs"),
  require("configuration.keybinds.tag"),
))