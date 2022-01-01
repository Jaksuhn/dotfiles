local awful = require "awful"
terminal = "kitty"
editor = os.getenv "EDITOR" or "micro"
editor_cmd = terminal .. " -e " .. editor
modkey = "Mod4"

require "configuration.ruled"
require "configuration.bound"
require "configuration.layout"
