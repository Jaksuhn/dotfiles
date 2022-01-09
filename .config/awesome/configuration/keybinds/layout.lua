local awful = require("awful")
local gears = require("gears")
local machi = require("module.layout-machi")

local keys = gears.table.join(
    awful.key(
        {modkey}, "l",
        function() awful.tag.incmwfact(0.05)
        end,
        {
            description = "increase master width factor",
            group = "layout"}),
    awful.key(
        {modkey}, "h",
        function() awful.tag.incmwfact(-0.05)
        end,
        {
            description = "decrease master width factor",
            group = "layout"}),
    awful.key(
        {modkey, "Shift"}, "h",
        function() awful.tag.incnmaster(1, nil, true) end,
        {
            description = "increase the number of master clients",
            group = "layout"
        }),
    awful.key({modkey, "Shift"}, "l",
        function() awful.tag.incnmaster(-1, nil, true)
        end,
        {
            description = "decrease the number of master clients",
            group = "layout"
        }),
    awful.key({modkey, "Control"}, "h",
        function() awful.tag.incncol(1, nil, true) end,
        {
            description = "increase the number of columns",
            group = "layout"
        }),
    awful.key(
        {modkey, "Control"}, "l",
        function() awful.tag.incncol(-1, nil, true)
        end,
        {
            description = "decrease the number of columns",
            group = "layout"
        }),
    awful.key(
        {modkey}, "space",
        function() awful.layout.inc(1)
        end,
        {
             description = "select next",
             group = "layout"
        }),
    awful.key(
        {modkey, "Shift"}, "space",
        function() awful.layout.inc(-1)
        end,
        {
            description = "select previous",
            group = "layout"
        }),
    -- Machi
    awful.key(
        {modkey}, ".",
        function() machi.default_editor.start_interactive()
        end,
        {
            description = "edit the current layout if it is a machi layout",
            group = "layout"
        }),
    awful.key(
        {modkey}, "/",
        function() machi.switcher.start(client.focus)
        end,
        {
            description = "switch between windows for a machi layout",
            group = "layout"
        }),
    awful.key {
        modifiers = {modkey},
        keygroup = "numpad",
        description = "select layout directly",
        group = "layout",
        on_press = function(index)
            local t = awful.screen.focused().selected_tag
            if t then t.layout = t.layouts[index] or t.layout end
    end}
)

return keys
