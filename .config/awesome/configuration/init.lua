local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")

-- Set Autostart Applications
require("configuration.autostart")

-- Default Applications
terminal = "kitty"
editor = "code"
editor_cmd = editor
browser = "firefox"
filemanager = "nautilus"
discord = "discord"
launcher = "rofi -show drun"
music = terminal .. " --class music -e ncspot"
emoji_launcher = "rofi -show emoji"

-- Global Vars
screen_width = awful.screen.focused().geometry.width
screen_height = awful.screen.focused().geometry.height

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"
altkey = "Mod1"
shift = "Shift"
ctrl = "Control"

-- Set Wallpaper
screen.connect_signal("request::wallpaper", function(s)
    awful.wallpaper {
        screen = s,
        bg = beautiful.lighter_bg
        --[[
	widget = {
         horizontal_fit_policy = "fit",
         vertical_fit_policy   = "fit",
         image                 = beautiful.wallpaper,
         widget                = wibox.widget.imagebox,
        }]]--
    }
end)

-- Get Bling Config
require("configuration.bling")

-- Get Keybinds
require("configuration.keys")

-- Get Rules
require("configuration.ruled")

-- Layouts and Window Stuff
require("configuration.window")

-- Scratchpad
require("configuration.scratchpad")
