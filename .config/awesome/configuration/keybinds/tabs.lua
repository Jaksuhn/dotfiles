local gears = require("gears")
local awful = require("awful")
local bling = require("module.bling")

return gears.table.join(
    awful.key(
        {"Mod1"}, "a",
        function() bling.module.tabbed.pick_with_dmenu()
        end,
        {
            description = "pick client to add to tab group",
            group = "tabs"
        }),
    awful.key(
        {"Mod1"}, "s",
        function() bling.module.tabbed.iter()
        end,
        {
            description = "iterate through tabbing group",
            group = "tabs"
        }),
    awful.key(
        {"Mod1"}, "d",
        function() bling.module.tabbed.pop()
        end,
        {
            description = "remove focused client from tabbing group",
            group = "tabs"
        }),
    awful.key(
        {modkey}, "Down",
        function() awful.client.focus.bydirection("down") bling.module.flash_focus.flashfocus(client.focus)
        end,
        {
            description = "focus down",
            group = "client"
        })
)
