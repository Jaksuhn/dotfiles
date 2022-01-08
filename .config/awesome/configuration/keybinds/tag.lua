local awful = require("awful")
local gears = require("gears")

local keys = gears.table.join(
    awful.key(
        {modkey, "Control"}, "w",
        function() awful.layout.set(awful.layout.suit.max)
        end,
        {
            description = "set max layout",
            group = "tag"
        }),
    awful.key(
        {modkey}, "s",
        function() awful.layout.set(awful.layout.suit.tile)
        end,
        {
            description = "set tile layout",
            group = "tag"
        }),
    awful.key(
        {modkey, shift}, "s",
        function() awful.layout.set(awful.layout.suit.floating)
        end,
        {
            description = "set floating layout",
            group = "tag"
        }),
    awful.key {
        modifiers = {modkey},
        keygroup = "numrow",
        description = "only view tag",
        group = "tag",
        on_press = function(index)
            local screen = awful.screen.focused()
            local tag = screen.tags[index]
            if tag then tag:view_only() end
    end},
    awful.key {
        modifiers = {modkey, "Control"},
        keygroup = "numrow",
        description = "toggle tag",
        group = "tag",
        on_press = function(index)
            local screen = awful.screen.focused()
            local tag = screen.tags[index]
            if tag then awful.tag.viewtoggle(tag) end
    end},
    awful.key {
        modifiers = {modkey, "Shift"},
        keygroup = "numrow",
        description = "move focused client to tag",
        group = "tag",
        on_press = function(index)
            if client.focus then
                local tag = client.focus.screen.tags[index]
                if tag then client.focus:move_to_tag(tag) end
            end
    end},
    awful.key {
        modifiers = {modkey, "Control", "Shift"},
        keygroup = "numrow",
        description = "toggle focused client on tag",
        group = "tag",
        on_press = function(index)
            if client.focus then
                local tag = client.focus.screen.tags[index]
                if tag then client.focus:toggle_tag(tag) end
            end
    end}
)

return keys
