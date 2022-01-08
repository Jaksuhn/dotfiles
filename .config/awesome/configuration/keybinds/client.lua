local gears = require("gears")
local awful = require("awful")
local bling = require("module.bling")

return gears.table.join(
    awful.key(
        {modkey}, "Up",
        function()
        awful.client.focus.bydirection("up") bling.module.flash_focus.flashfocus(client.focus)
        end,
        {
            description = "focus up",
            group = "client"
        }),
    awful.key(
        {modkey}, "Left",
        function()
        awful.client.focus.bydirection("left")
        bling.module.flash_focus.flashfocus(client.focus)
        end, {
            description = "focus left",
            group = "client"
        }),
    awful.key(
        {modkey}, "Right",
        function() awful.client.focus.bydirection("right") bling.module.flash_focus.flashfocus(client.focus)
        end,
        {
            description = "focus right",
            group = "client"
        }),
    awful.key(
        {modkey}, "j",
        function() awful.client.focus.byidx(1)
        end,
              {description = "focus next by index", group = "client"
        }),
    awful.key(
        {modkey}, "k",
        function() awful.client.focus.byidx(-1)
        end,
        {
            description = "focus previous by index", group = "client"
        }),
    awful.key(
        {modkey, "Shift"}, "j",
        function() awful.client.swap.byidx(1)
        end,
        {
            description = "swap with next client by index",
            group = "client"
        }),
    awful.key(
        {modkey, "Shift"}, "k",
        function() awful.client.swap.byidx(-1)
        end,
        {
            description = "swap with previous client by index",
            group = "client"
        }),
    awful.key(
        {modkey}, "u",
        awful.client.urgent.jumpto,
        {
            description = "jump to urgent client",
            group = "client"
        }),
    awful.key(
        {altkey}, "Tab",
        function() awesome.emit_signal("bling::window_switcher::turn_on")
        end,
        {
            description = "Window Switcher",
            group = "client"
        }),
    awful.key(
        {modkey}, "z",
        function() require("ui.pop.peek").run()
        end,
        {
            description = "peek",
            group = "client"
        }),
    awful.key(
        {modkey, "Control"}, "n",
        function() local c = awful.client.restore()
            if c then
                c:emit_signal("request::activate", "key.unminimize", {raise = true})
            end
        end,
        {
            description = "restore minimized",
            group = "client"
        }),
    awful.key(
        {modkey, "Shift"}, "f",
        function(c)
            c.fullscreen = not c.fullscreen
            c:raise()
        end,
        {
            description = "toggle fullscreen",
            group = "client"
        }),
    awful.key(
        {modkey}, "q",
        function(c) c:kill() end,
        {
            description = "close",
            group = "client"
        }),
    awful.key(
        {modkey, "Control"}, "space",
        awful.client.floating.toggle,
        {
            description = "toggle floating",
            group = "client"
        }),
    awful.key(
        {modkey, "Control"}, "Return",
        function(c) c:swap(awful.client.getmaster()) end,
        {
            description = "move to master",
            group = "client"
        }),
    awful.key(
        {modkey}, "o",
        function(c) c:move_to_screen()
        end,
        {
            description = "move to screen",
            group = "client"
        }),
    awful.key(
        {modkey, shift}, "b",
        function(c)
            c.floating = not c.floating
            c.width = 400
            c.height = 200
            awful.placement.bottom_right(c)
            c.sticky = not c.sticky
        end,
        {
            description = "toggle keep on top",
            group = "client"
        }),

    awful.key(
        {modkey}, "n",
        function(c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end,
        {
            description = "minimize",
            group = "client"
        }),
    awful.key(
        {modkey}, "m",
        function(c)
            c.maximized = not c.maximized
            c:raise()
        end,
        {
            description = "(un)maximize",
            group = "client"
        }),
    awful.key(
        {modkey, "Control"}, "m",
        function(c)
            c.maximized_vertical = not c.maximized_vertical
            c:raise()
        end,
        {
            description = "(un)maximize vertically",
            group = "client"
        }),
    awful.key(
        {modkey, "Shift"}, "m",
        function(c)
            c.maximized_horizontal = not c.maximized_horizontal
            c:raise()
        end,
        {
            description = "(un)maximize horizontally",
            group = "client"
        }),
    client.connect_signal("request::default_mousebindings", function()
    awful.mouse.append_client_mousebindings({
        awful.button({}, 1, function(c)
            c:activate{context = "mouse_click"}
        end), awful.button({modkey}, 1, function(c)
            c:activate{context = "mouse_click", action = "mouse_move"}
        end), awful.button({modkey}, 3, function(c)
            c:activate{context = "mouse_click", action = "mouse_resize"}
        end)
        })
    end)
)