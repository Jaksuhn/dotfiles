local awful = require("awful")
local gears = require("gears")
local helpers = require("helpers")

local keys = gears.table.join(
    awful.key(
        {modkey, "Control"}, "j",
        function() awful.screen.focus_relative(1)
        end,
        {
            description = "focus the next screen", group = "screen"
        }),
    awful.key(
        {modkey, "Control"}, "k",
        function() awful.screen.focus_relative(-1)
        end,
        {
            description = "focus the previous screen",
            group = "screen"
        }),
    -- On the fly padding change
    awful.key(
        {modkey, shift}, "=",
        function() helpers.resize_padding(5)
        end,
        {
            description = "add padding",
            group = "screen"
        }),
    awful.key(
        {modkey, shift}, "-",
        function() helpers.resize_padding(-5)
        end,
        {
            description = "subtract padding",
            group = "screen"
        }),
    -- On the fly useless gaps change
    awful.key(
        {modkey}, "=",
        function() helpers.resize_gaps(5)
        end,
        {
            description = "add gaps",
            group = "screen"
        }),
    awful.key(
        {modkey}, "-",
        function() helpers.resize_gaps(-5)
        end,
        {
            description = "subtract gaps",
            group = "screen"
        }),
    -- Single tap: Center client
    -- Double tap: Center client + Floating + Resize
    awful.key(
        {modkey}, "c",
        function(c)
        awful.placement.centered(c, {
            honor_workarea = true,
            honor_padding = true
        })
        helpers.single_double_tap(nil, function()
            helpers.float_and_resize(c, screen_width * 0.25, screen_height * 0.28)
        end)
    end)
)

return keys
