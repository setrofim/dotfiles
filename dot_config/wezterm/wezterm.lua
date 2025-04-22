local wezterm = require 'wezterm'
local config = wezterm.config_builder()

config.color_scheme = 'Dark Pastel'

config.window_background_opacity = 0.8
config.window_padding = {
    top = 0,
    bottom = 0,
    left = 0,
    right = 0,
}

config.cursor_blink_rate = 100
config.cursor_thickness = '10%'

config.font = wezterm.font 'Source Code Pro'
config.font_size = 10

config.hide_tab_bar_if_only_one_tab = true
config.tab_bar_at_bottom = true

return config

-- vim: set et sts=4 sw=4:
