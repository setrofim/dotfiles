-------------------------------
--  "setrofim" awesome theme  --
--    By Adrian C. (anrxc)   --
-------------------------------

local themes_path = "/home/setrofim/.config/awesome/themes/"
local dpi = require("beautiful.xresources").apply_dpi

-- {{{ Main
local theme = {}
theme.wallpaper = themes_path .. "setrofim/zenburn-background.png"
-- }}}

-- {{{ Styles
theme.font      = "Liberation Sans 10"

-- {{{ Colors
theme.fg_normal  = "#DDDDFF"
theme.fg_focus   = "#46A8C3"
theme.fg_urgent  = "#CC9393"
theme.bg_normal  = "#3F3F3F"
theme.bg_focus   = "#1E2320"
theme.bg_urgent  = "#3F3F3F"
theme.bg_systray = theme.bg_normal
-- }}}

-- {{{ Borders
theme.useless_gap   = dpi(1)
theme.border_width  = dpi(1)
theme.border_normal = "#3F3F3F"
theme.border_focus  = "#46A8C3"
theme.border_marked = "#CC9393"
-- }}}

-- {{{ Titlebars
theme.titlebar_bg_focus  = "#4F4F5F"
theme.titlebar_bg_normal = "#3F3F3F"
-- }}}

-- There are other variable sets
-- overriding the default one when
-- defined, the sets are:
-- [taglist|tasklist]_[bg|fg]_[focus|urgent|occupied|empty|volatile]
-- titlebar_[normal|focus]
-- tooltip_[font|opacity|fg_color|bg_color|border_width|border_color]
-- Example:
--theme.taglist_bg_focus = "#CC9393"
-- }}}

-- {{{ Widgets
-- You can add as many variables as
-- you wish and access them by using
-- beautiful.variable in your rc.lua
--theme.fg_widget        = "#AECF96"
--theme.fg_center_widget = "#88A175"
--theme.fg_end_widget    = "#FF5656"
--theme.bg_widget        = "#494B4F"
--theme.border_widget    = "#3F3F3F"
theme.widget_ac                     = themes_path .. "setrofim/icons/ac.png"
theme.widget_battery                = themes_path .. "setrofim/icons/battery.png"
theme.widget_battery_low            = themes_path .. "setrofim/icons/battery_low.png"
theme.widget_battery_empty          = themes_path .. "setrofim/icons/battery_empty.png"
theme.widget_mem                    = themes_path .. "setrofim/icons/mem.png"
theme.widget_cpu                    = themes_path .. "setrofim/icons/cpu.png"
theme.widget_temp                   = themes_path .. "setrofim/icons/temp.png"
theme.widget_net                    = themes_path .. "setrofim/icons/net_wired.png"
theme.widget_hdd                    = themes_path .. "setrofim/icons/hdd.png"
theme.widget_music                  = themes_path .. "setrofim/icons/note.png"
theme.widget_music_on               = themes_path .. "setrofim/icons/note_on.png"
theme.widget_vol                    = themes_path .. "setrofim/icons/vol.png"
theme.widget_vol_low                = themes_path .. "setrofim/icons/vol_low.png"
theme.widget_vol_no                 = themes_path .. "setrofim/icons/vol_no.png"
theme.widget_vol_mute               = themes_path .. "setrofim/icons/vol_mute.png"
theme.widget_mail                   = themes_path .. "setrofim/icons/mail.png"
theme.widget_mail_on                = themes_path .. "setrofim/icons/mail_on.png"
-- }}}

-- {{{ Mouse finder
theme.mouse_finder_color = "#CC9393"
-- mouse_finder_[timeout|animate_timeout|radius|factor]
-- }}}

-- {{{ Menu
-- Variables set for theming the menu:
-- menu_[bg|fg]_[normal|focus]
-- menu_[border_color|border_width]
theme.menu_height = dpi(25)
theme.menu_width  = dpi(200)
-- }}}

-- {{{ Icons
-- {{{ Taglist
theme.taglist_squares_sel   = themes_path .. "setrofim/taglist/squarefz.png"
theme.taglist_squares_unsel = themes_path .. "setrofim/taglist/squarez.png"
--theme.taglist_squares_resize = "false"
-- }}}

-- {{{ Misc
theme.awesome_icon           = themes_path .. "setrofim/awesome-icon.png"
theme.menu_submenu_icon      = themes_path .. "setrofim/submenu.png"
theme.notification_icon_size = dpi(30)
-- }}}

-- {{{ Layout
theme.layout_tile       = themes_path .. "setrofim/layouts/tile.png"
theme.layout_tileleft   = themes_path .. "setrofim/layouts/tileleft.png"
theme.layout_tilebottom = themes_path .. "setrofim/layouts/tilebottom.png"
theme.layout_tiletop    = themes_path .. "setrofim/layouts/tiletop.png"
theme.layout_fairv      = themes_path .. "setrofim/layouts/fairv.png"
theme.layout_fairh      = themes_path .. "setrofim/layouts/fairh.png"
theme.layout_spiral     = themes_path .. "setrofim/layouts/spiral.png"
theme.layout_dwindle    = themes_path .. "setrofim/layouts/dwindle.png"
theme.layout_max        = themes_path .. "setrofim/layouts/max.png"
theme.layout_fullscreen = themes_path .. "setrofim/layouts/fullscreen.png"
theme.layout_magnifier  = themes_path .. "setrofim/layouts/magnifier.png"
theme.layout_floating   = themes_path .. "setrofim/layouts/floating.png"
theme.layout_cornernw   = themes_path .. "setrofim/layouts/cornernw.png"
theme.layout_cornerne   = themes_path .. "setrofim/layouts/cornerne.png"
theme.layout_cornersw   = themes_path .. "setrofim/layouts/cornersw.png"
theme.layout_cornerse   = themes_path .. "setrofim/layouts/cornerse.png"
-- }}}

-- {{{ Titlebar
theme.titlebar_close_button_focus  = themes_path .. "setrofim/titlebar/close_focus.png"
theme.titlebar_close_button_normal = themes_path .. "setrofim/titlebar/close_normal.png"

theme.titlebar_minimize_button_normal = themes_path .. "default/titlebar/minimize_normal.png"
theme.titlebar_minimize_button_focus  = themes_path .. "default/titlebar/minimize_focus.png"

theme.titlebar_ontop_button_focus_active  = themes_path .. "setrofim/titlebar/ontop_focus_active.png"
theme.titlebar_ontop_button_normal_active = themes_path .. "setrofim/titlebar/ontop_normal_active.png"
theme.titlebar_ontop_button_focus_inactive  = themes_path .. "setrofim/titlebar/ontop_focus_inactive.png"
theme.titlebar_ontop_button_normal_inactive = themes_path .. "setrofim/titlebar/ontop_normal_inactive.png"

theme.titlebar_sticky_button_focus_active  = themes_path .. "setrofim/titlebar/sticky_focus_active.png"
theme.titlebar_sticky_button_normal_active = themes_path .. "setrofim/titlebar/sticky_normal_active.png"
theme.titlebar_sticky_button_focus_inactive  = themes_path .. "setrofim/titlebar/sticky_focus_inactive.png"
theme.titlebar_sticky_button_normal_inactive = themes_path .. "setrofim/titlebar/sticky_normal_inactive.png"

theme.titlebar_floating_button_focus_active  = themes_path .. "setrofim/titlebar/floating_focus_active.png"
theme.titlebar_floating_button_normal_active = themes_path .. "setrofim/titlebar/floating_normal_active.png"
theme.titlebar_floating_button_focus_inactive  = themes_path .. "setrofim/titlebar/floating_focus_inactive.png"
theme.titlebar_floating_button_normal_inactive = themes_path .. "setrofim/titlebar/floating_normal_inactive.png"

theme.titlebar_maximized_button_focus_active  = themes_path .. "setrofim/titlebar/maximized_focus_active.png"
theme.titlebar_maximized_button_normal_active = themes_path .. "setrofim/titlebar/maximized_normal_active.png"
theme.titlebar_maximized_button_focus_inactive  = themes_path .. "setrofim/titlebar/maximized_focus_inactive.png"
theme.titlebar_maximized_button_normal_inactive = themes_path .. "setrofim/titlebar/maximized_normal_inactive.png"
-- }}}
-- }}}

return theme

-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:textwidth=80
