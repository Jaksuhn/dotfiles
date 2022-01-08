local awful = require("awful")
local gears = require("gears")

local keys = gears.table.join(
    awful.key(
        {modkey}, "s",
        function() awesome.emit_signal("scratch::music")
        end,
        {
            description = "open music",
            group = "scratchpad"
        }),
    awful.key(
        {modkey}, "v",
        function() awesome.emit_signal("scratch::chat")
        end,
        {
            description = "open chats",
            group = "scratchpad"
        }),
)

return keys
