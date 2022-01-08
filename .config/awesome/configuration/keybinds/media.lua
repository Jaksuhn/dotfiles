local gears = require("gears")
local awful = require("awful")

return gears.table.join(
    awful.key(
        {}, "XF86AudioRaiseVolume",
        function() awful.spawn("pamixer -i 3")
        end,
        {
            description = "increase volume",
            group = "media"
    }),
    awful.key(
        {}, "XF86AudioLowerVolume",
        function() awful.spawn("pamixer -d 3")
        end,
        {
            description = "decrease volume",
            group = "media"
        }),
    awful.key(
        {}, "XF86AudioMute", function() awful.spawn("pamixer -t")
        end,
        {
            description = "mute volume",
            group = "media"
        }), -- Media Control
    awful.key(
        {}, "XF86AudioPlay",
        function() awful.spawn("playerctl play-pause")
        end,
        {
            description = "toggle volume",
            group = "media"
        }),
    awful.key(
        {}, "XF86AudioPrev",
        function() awful.spawn("playerctl previous")
        end,
        {
            description = "previous track",
            group = "media"
        }),
    awful.key(
        {}, "XF86AudioNext", function() awful.spawn("playerctl next")
        end,
        {
            description = "next track",
            group = "media"
        }),
    awful.key(
        { }, "XF86MonBrightnessUp",
        function() awful.spawn("brightnessctl s +5%")
        end,
        {
            description = "increase brightness",
            group = "media"
        }),
    awful.key(
        { }, "XF86MonBrightnessDown"
        function() awful.spawn("brightnessctl s 5%-")
        end,
        {
            description = "decrease brightness",
            group = "media"
        }),
)
