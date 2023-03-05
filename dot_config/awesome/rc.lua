local gears = require("gears")
local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local naughty = require("naughty")
local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup").widget
local dpi = require("beautiful.xresources").apply_dpi
local lain = require("lain")
local spotify_widget = require("awesome-wm-widgets.spotify-widget.spotify")
local appmenu = require("appmenu")

require("awful.autofocus")

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = tostring(err) })
        in_error = false
    end)
end
-- }}}

-- {{{ Variable definitions
-- Themes define colours, icons, font and wallpapers.
beautiful.init(os.getenv("HOME") .. "/.config/awesome/themes/setrofim/theme.lua")

-- This is used later as the default terminal and editor to run.
terminal = "kitty"
editor = os.getenv("EDITOR") or "nvim"
editor_cmd = terminal .. " -e " .. editor

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
awful.layout.layouts = {
    awful.layout.suit.tile,
    awful.layout.suit.tile.left,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.tile.top,
    awful.layout.suit.fair,
    awful.layout.suit.fair.horizontal,
    awful.layout.suit.spiral,
    awful.layout.suit.spiral.dwindle,
    awful.layout.suit.max,
    awful.layout.suit.max.fullscreen,
    awful.layout.suit.magnifier,
    awful.layout.suit.corner.nw,
    awful.layout.suit.floating,
    -- awful.layout.suit.corner.ne,
    -- awful.layout.suit.corner.sw,
    -- awful.layout.suit.corner.se,
}
-- }}}

-- {{{ Helper functions
local function client_menu_toggle_fn()
    local instance = nil

    return function ()
        if instance and instance.wibox.visible then
            instance:hide()
            instance = nil
        else
            instance = awful.menu.clients({ theme = { width = 250 } })
        end
    end
end
-- }}}
--

-- {{{ Menu
-- Create a launcher widget and a main menu
myawesomemenu = {
   { "hotkeys", function() return false, hotkeys_popup.show_help end, "/usr/share/icons/Arc/devices/24/input-keyboard.png" },
   { "manual", terminal .. " -e man awesome", "/usr/share/icons/Arc/actions/24/help-about.png" },
   { "edit config", editor_cmd .. " " .. awesome.conffile, "/usr/share/icons/Arc/categories/24/applications-system.png" },
   { "restart", awesome.restart, "/usr/share/icons/Arc/actions/24/media-playlist-repeat.png" },
   { "quit", function() awesome.quit() end, "/usr/share/icons/Arc/actions/24/application-exit.png" }
}

mymainmenu = awful.menu({ items = {
    { "open terminal", terminal, '/usr/share/icons/breeze-dark/apps/64/utilities-terminal.svg' },
    { "applications", appmenu.Appmenu, '/usr/share/icons/breeze-dark/categories/32/applications-all.svg' },
    { "awesome", myawesomemenu, beautiful.awesome_icon }
  }
})

mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,
                                     menu = mymainmenu })

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

-- Keyboard map indicator and switcher
mykeyboardlayout = awful.widget.keyboardlayout()

-- {{{ Wibar
-- Create a textclock widget
mytextclock = wibox.widget.textclock()


local widget_separator = wibox.widget.textbox(" ")
local arrow_separator = lain.util.separators.arrow_left(beautiful.bg_focus, beautiful.bg_normal)
local revers_arrow_separator = lain.util.separators.arrow_right(beautiful.bg_normal, beautiful.bg_focus)
local keyboard_icon = wibox.widget.textbox("⌨")

local music_icon = wibox.widget.textbox("♫")
music_icon.font = 'Liberation Sans 10'

local cpu_icon = wibox.widget.imagebox(beautiful.widget_cpu)
local cpu_widget = lain.widget.cpu({
    settings = function()
        local color = "green"
        if cpu_now.usage > 75 then
            color = "red"
        end
        widget:set_markup("<span foreground=\"" .. color .. "\">" .. string.format("%02d", cpu_now.usage) .. "%</span>")
    end
})

local mem_icon = wibox.widget.imagebox(beautiful.widget_mem)
local mem_widget = lain.widget.mem({
    settings = function()
        local color = "green"
        if mem_now.perc > 75 then
            color = "red"
        end
        widget:set_markup("<span foreground=\"" .. color .. "\">" .. string.format("%02d", mem_now.perc) .. "%</span>")
    end
})

local fs_icon = wibox.widget.imagebox(beautiful.widget_hdd)
local fs_widget = lain.widget.fs({
    options = '--exclude-type=tempfs',
    partition = '/data',
    notification_preset = { fg = beautiful.fg_normal, bg = beautiful.bg_normal, font = "Liberation Mono 10" },
    settings = function()
        local color = "green"
        if type(fs_now.used) == "number" then
            if fs_now.used > 80 then
                color = "red"
            elseif fs_now.used > 60 then
                color = "amber"
            end
            widget:set_markup("<span foreground=\"" .. color .. "\">" .. string.format("%2d", fs_now.used) .. "%</span>")
        else
            color = "red"
            widget:set_markup("<span foreground=\"" .. color .. "\">" .. fs_now.used .. "%</span>")
        end
    end
})

local net_icon = wibox.widget.imagebox(beautiful.widget_net)
local net_widget = lain.widget.net({
    iface = "eth0",
    settings = function()
        widget:set_markup('<span font="Liberation Mono 10" foreground="#7AC82E">⬇' .. string.format('%06d', math.ceil(net_now.received)) .. '</span>'
                          ..  ' <span font="Liberation Mono 10" foreground="#46A8C3">⬆' .. string.format('%06d', math.ceil(net_now.sent)) .. '</span>')
    end
})

local cal_widget = lain.widget.calendar({
    cal = '/usr/bin/cal -h',
    attach_to = {mytextclock},
    followtag = true,
    notification_preset = {
        font = "Liberation Mono 10",
        fg   = "#FFFFFF",
        bg   = "#1E2320"
    }
})

-- Create a wibox for each screen and add it
local taglist_buttons = awful.util.table.join(
                    awful.button({ }, 1, function(t) t:view_only() end),
                    awful.button({ modkey }, 1, function(t)
                                              if client.focus then
                                                  client.focus:move_to_tag(t)
                                              end
                                          end),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, function(t)
                                              if client.focus then
                                                  client.focus:toggle_tag(t)
                                              end
                                          end),
                    awful.button({ }, 4, function(t) awful.tag.viewnext(t.screen) end),
                    awful.button({ }, 5, function(t) awful.tag.viewprev(t.screen) end)
                )

local tasklist_buttons = awful.util.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                              else
                                                  -- Without this, the following
                                                  -- :isvisible() makes no sense
                                                  c.minimized = false
                                                  if not c:isvisible() and c.first_tag then
                                                      c.first_tag:view_only()
                                                  end
                                                  -- This will also un-minimize
                                                  -- the client, if needed
                                                  client.focus = c
                                                  c:raise()
                                              end
                                          end),
                     awful.button({ }, 3, client_menu_toggle_fn()),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                          end))

systray = wibox.widget.systray()

-- wallpaper_base = os.getenv("HOME") ..  '/Pictures/wallpapers'
wallpaper_base = '/usr/share/wallpapers/'

-- {{{ Screen config
S_MAIN = 1
S_LEFT = 3
S_RIGHT_V = 2
S_WALL = 4

screen_config = {
    tags = {
            -- Main screen
            {
                    "term",
                    {
                            layout = awful.layout.suit.tile,
                            screen = S_MAIN,
                            selected = true
                    }
            },
            {
                    "www",
                    {
                            layout = awful.layout.suit.tile,
                            screen = S_MAIN
                    }
            },
            {
                    "feed",
                    {
                            layout = awful.layout.suit.tile,
                            screen = S_MAIN
                    }
            },
            {
                    "art",
                    {
                            layout = awful.layout.suit.tile,
                            screen = S_MAIN
                    }
            },
            {
                    "files",
                    {
                            layout = awful.layout.suit.tile,
                            screen = S_MAIN
                    }
            },
            {
                    "steam",
                    {
                            layout = awful.layout.suit.floating,
                            screen = S_MAIN
                    }
            },
            -- Left screen
            {
                    "www",
                    {
                            layout = awful.layout.suit.tile.left,
                            screen = S_LEFT,
                            selected = true
                    }
            },
            -- Right screen (vertical)
            {
                    "telegram",
                    {
                            layout = awful.layout.suit.tile.bottom,
                            screen = S_RIGHT_V,
                            selected = true
                    }
            },
            {
                    "slack",
                    {
                            layout = awful.layout.suit.tile.bottom,
                            screen = S_RIGHT_V
                    }
            },
            {
                    "discord",
                    {
                            layout = awful.layout.suit.tile.bottom,
                            screen = S_RIGHT_V
                    }
            },
            {
                    "irc",
                    {
                            layout = awful.layout.suit.tile.bottom,
                            screen = S_RIGHT_V
                    }
            },
            {
                    "www",
                    {
                            layout = awful.layout.suit.tile.bottom,
                            screen = S_RIGHT_V
                    }
            },
            {
                    "zulip",
                    {
                            layout = awful.layout.suit.tile.bottom,
                            screen = S_RIGHT_V
                    }
            },
            {
                    "misc",
                    {
                            layout = awful.layout.suit.tile.bottom,
                            screen = S_RIGHT_V
                    }
            },
            -- Wall screen
            {
                    "video",
                    {
                            layout = awful.layout.suit.tile.bottom,
                            screen = S_WALL,
                            selected = true
                    }
            },
            {
                    "spotify",
                    {
                            layout = awful.layout.suit.tile.bottom,
                            screen = S_WALL
                    }
            }
        },
    wallpapers  = {
        'cyberpunk_city_21.jpg',
        'cyberpunk_city_12_vertical.jpg',
        'cyberpunk_city_09.jpg',
        'cyberpunk_city_20.jpg'
    },
}
-- }}}

for i, td in ipairs(screen_config.tags) do
    awful.tag.add(td[1], td[2])
end

local function set_wallpaper(s)
    gears.wallpaper.maximized(wallpaper_base .. '/' .. screen_config.wallpapers[s.index], s.index, true)
end

-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", set_wallpaper)

awful.screen.connect_for_each_screen(function(s)
    -- Wallpaper
    set_wallpaper(s)

    -- Create a textclock widget
    s.mytextclock = wibox.widget.textclock()

    s.month_cal =  awful.widget.calendar_popup.month()
    s.month_cal.screen = s
    s.month_cal:attach(s.mytextclock, "tr")


    -- Create a promptbox for each screen
    s.mypromptbox = awful.widget.prompt()
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    s.mylayoutbox = awful.widget.layoutbox(s)
    s.mylayoutbox:buttons(awful.util.table.join(
                           awful.button({ }, 1, function () awful.layout.inc( 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(-1) end),
                           awful.button({ }, 4, function () awful.layout.inc( 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(-1) end)))

    -- Create a taglist widget
    --s.mytaglist = awful.widget.taglist(s, awful.widget.taglist.filter.all, taglist_buttons)
    s.mytaglist = awful.widget.taglist {
            screen  = s,
            filter  = awful.widget.taglist.filter.all,
            widget_template = {
                {
                    {
                        {
                            {
                                {
                                    id     = 'index_role',
                                    widget = wibox.widget.textbox,
                                },
                                widget  = wibox.container.margin,
                            },
                            bg     = nil,
                            widget = wibox.container.background,
                        },
                        {
                            {
                                id     = 'icon_role',
                                widget = wibox.widget.imagebox,
                            },
                            margins = 0,
                            widget  = wibox.container.margin,
                        },
                        {
                            id     = 'text_role',
                            widget = wibox.widget.textbox,
                        },
                        layout = wibox.layout.fixed.horizontal,
                    },
                    left  = 5,
                    right = 5,
                    widget = wibox.container.margin
                },
                id     = 'background_role',
                widget = wibox.container.background,
                -- Add support for hover colors and an index label
                create_callback = function(self, c3, index, objects) --luacheck: no unused args
                    self.index = index
                    self:get_children_by_id('index_role')[1].markup = '<b> '..index..' </b>'
                    self:connect_signal('mouse::enter', function()
                        if self.bg ~= beautiful.bg_focus then
                            self.backup     = self.bg
                            self.has_backup = true
                        end
                        self.bg = beautiful.bg_focus
                    end)
                    self:connect_signal('mouse::leave', function()
                        -- if the tag was selected, then the backed up background would be out of date.
                        if s.tags[self.index].selected then
                            self.backup = beautiful.bg_focus
                        end
                        if self.has_backup then
                                self.bg = self.backup
                        end
                    end)
                end,
                update_callback = function(self, c3, index, objects) --luacheck: no unused args
                    self.index = index
                    self:get_children_by_id('index_role')[1].markup = '<b> '..index..' </b>'
                end,
            },
            buttons = taglist_buttons
        }

    -- Create a tasklist widget
    s.mytasklist = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, tasklist_buttons)

    -- Create the wibox
    s.mywibox = awful.wibar({ position = "top", screen = s })

    -- Add widgets to the wibox
    if s.index == 1 then
            s.mywibox:setup {
                layout = wibox.layout.align.horizontal,
                { -- Left widgets
                    layout = wibox.layout.fixed.horizontal,
                    mylauncher,
                    s.mytaglist,
                    s.mypromptbox,
                    revers_arrow_separator,
                    arrow_separator,
                },
                s.mytasklist, -- Middle widget
                { -- Right widgets
                    layout = wibox.layout.fixed.horizontal,
                    revers_arrow_separator,
                    arrow_separator,
                    music_icon,
                    widget_separator,
                    spotify_widget({
                        font = 'Liberation Sans 10',
                        max_length = 25,
                        dim_when_paused = true,
                        dim_opacity = 0.5
                    }),
                    widget_separator,
                    widget_separator,
                    cpu_icon,
                    cpu_widget,
                    widget_separator,
                    mem_icon,
                    mem_widget,
                    widget_separator,
                    widget_separator,
                    net_icon,
                    net_widget,
                    widget_separator,
                    widget_separator,
                    keyboard_icon,
                    mykeyboardlayout,
                    widget_separator,
                    wibox.widget.systray(),
                    widget_separator,
                    s.mytextclock,
                    s.mylayoutbox,
                },
            }
        systray.set_screen(s)
    else
            s.mywibox:setup {
                layout = wibox.layout.align.horizontal,
                { -- Left widgets
                    layout = wibox.layout.fixed.horizontal,
                    mylauncher,
                    s.mytaglist,
                    s.mypromptbox,
                    revers_arrow_separator,
                    arrow_separator,
                },
                s.mytasklist, -- Middle widget
                { -- Right widgets
                    layout = wibox.layout.fixed.horizontal,
                    revers_arrow_separator,
                    arrow_separator,
                    s.mytextclock,
                    s.mylayoutbox,
                },
            }
    end
end)
-- }}}
--
--
-- {{{ Mouse bindings
root.buttons(gears.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end)
))
-- }}}

-- {{{ Key bindings
globalkeys = gears.table.join(
    awful.key({ modkey,           }, "s",      hotkeys_popup.show_help,
              {description="show help", group="awesome"}),
    awful.key({ modkey,           }, "c",      naughty.destroy_all_notifications,
              {description="Clear all notification pop-ups.", group="awesome"}),
    awful.key({ modkey,           }, "Left",   awful.tag.viewprev,
              {description = "view previous", group = "tag"}),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext,
              {description = "view next", group = "tag"}),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore,
              {description = "go back", group = "tag"}),

    awful.key({ modkey,           }, "j",
        function ()
            awful.client.focus.byidx(1)
        end,
        {description = "focus next by index", group = "client"}
    ),
    awful.key({ modkey,           }, "k",
        function ()
            awful.client.focus.byidx(-1)
        end,
        {description = "focus previous by index", group = "client"}
    ),
    awful.key({ modkey,           }, "w", function () mymainmenu:show() end,
              {description = "show main menu", group = "awesome"}),

    -- Layout manipulation
    --awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(S_LEFT)    end,
              --{description = "swap with next client by index", group = "client"}),
    --awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx(S_MAIN)    end,
              --{description = "swap with previous client by index", group = "client"}),

    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus(S_LEFT)    end,
              {description = "focus the next screen", group = "screen"}),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus(S_MAIN)    end,
              {description = "focus the previous screen", group = "screen"}),
    awful.key({ modkey, "Control" }, "l", function () awful.screen.focus(S_RIGHT_V) end,
              {description = "focus the previous screen", group = "screen"}),
    awful.key({ modkey, "Control" }, "i", function () awful.screen.focus(S_WALL)    end,
              {description = "focus the previous screen", group = "screen"}),

    awful.key({ modkey,           }, "`", awful.client.urgent.jumpto,
              {description = "jump to urgent client", group = "client"}),
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end,
        {description = "go back", group = "client"}),

    -- Standard program
    awful.key({ modkey,           }, "Return", function () awful.spawn(terminal) end,
              {description = "open a terminal", group = "launcher"}),
    awful.key({ modkey, "Control" }, "r", awesome.restart,
              {description = "reload awesome", group = "awesome"}),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit,
              {description = "quit awesome", group = "awesome"}),

    -- lain tag management
    awful.key({ modkey, "Shift" }, "n", function () lain.util.add_tag(mypromptbox) end),
    awful.key({ modkey, "Shift" }, "r", function () lain.util.rename_tag(mypromptbox) end),
    awful.key({ modkey, "Shift" }, "Left", function () lain.util.move_tag(-1) end),  -- move to next tag
    awful.key({ modkey, "Shift" }, "Right", function () lain.util.move_tag(1) end), -- move to previous tag
    awful.key({ modkey, "Shift" }, "d", function () lain.util.delete_tag() end),

    awful.key({ modkey, "Shift" }, ".",     function () awful.tag.incmwfact( 0.05)          end,
              {description = "increase master width factor", group = "layout"}),
    awful.key({ modkey, "Shift" }, ",",     function () awful.tag.incmwfact(-0.05)          end,
              {description = "decrease master width factor", group = "layout"}),

    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1, nil, true) end,
              {description = "increase the number of master clients", group = "layout"}),
    --awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1, nil, true) end,
              --{description = "decrease the number of master clients", group = "layout"}),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1, nil, true)    end,
              {description = "increase the number of columns", group = "layout"}),
    --awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1, nil, true)    end,
              --{description = "decrease the number of columns", group = "layout"}),
    awful.key({ modkey,           }, "space", function () awful.layout.inc( 1)                end,
              {description = "select next", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(-1)                end,
              {description = "select previous", group = "layout"}),

    awful.key({ modkey, "Control" }, "n",
              function ()
                  local c = awful.client.restore()
                  -- Focus restored client
                  if c then
                      client.focus = c
                      c:raise()
                  end
              end,
              {description = "restore minimized", group = "client"}),

    -- Screensaver
    awful.key({ modkey }, "Pause",
        function ()
                awful.util.spawn_with_shell("gnome-screensaver-command -l")
        end),

    -- Volume control
    awful.key({ }, "XF86AudioLowerVolume",
        function ()
                awful.util.spawn_with_shell("for s in $(pactl list sinks | grep -B1 RUNNING | cut -f2 -d# | egrep '[0-9]+'); do pactl set-sink-volume $s -1%; done")
        end),
    awful.key({ }, "XF86AudioRaiseVolume",
        function ()
                awful.util.spawn_with_shell("for s in $(pactl list sinks | grep -B1 RUNNING | cut -f2 -d# | egrep '[0-9]+'); do pactl set-sink-volume $s +1%; done")
        end),
    awful.key({ }, "XF86AudioMute",
        function ()
                 awful.util.spawn_with_shell("for s in $(pactl list sinks | grep -B1 RUNNING | cut -f2 -d# | egrep '[0-9]+'); do pactl set-sink-mute $s toggle; done")
        end),
    awful.key({ }, "XF86AudioStop",
        function ()
                awful.util.spawn_with_shell("for s in $(pactl list sources | grep -B1 RUNNING | cut -f2 -d# | egrep '[0-9]+'); do pactl set-source-mute $s toggle; done")
        end),

    awful.key({ }, "#172", -- "XF86AudioPlay",
        function ()
                awful.util.spawn_with_shell("sp play")
        end),
    awful.key({ }, "#173", -- "XF86AudioPrev",
        function ()
                awful.util.spawn_with_shell("sp prev")
        end),
    awful.key({ }, "#171", -- "XF86AudioNext",
        function ()
                awful.util.spawn_with_shell("sp next")
        end),


    -- Launch shortcuts
    awful.key({ modkey,           }, "b",      function () awful.util.spawn_with_shell("/home/setrofim/.local/bin/launch-spotify") end,
              {description="launch spotify", group="launcher"}),

    awful.key({ modkey,           }, "e",      function () awful.util.spawn_with_shell("thunar") end,
              {description="launch thunar", group="launcher"}),

    --awful.key({ }, "XF86AudioStop",      function () awful.util.spawn_with_shell("/home/setrofim/.local/bin/launch-spotify") end,
              --{description="launch spotify", group="launcher"}),

    awful.key({ modkey,           }, "v",      function () awful.spawn("chromium") end,
              {description="launch browser", group="launcher"}),

    -- Prompt
    awful.key({ modkey },            "r",     function () awful.screen.focused().mypromptbox:run() end,
              {description = "run prompt", group = "launcher"}),

    awful.key({ modkey }, "x",
              function ()
                  awful.prompt.run {
                    prompt       = "Run Lua code: ",
                    textbox      = awful.screen.focused().mypromptbox.widget,
                    exe_callback = awful.util.eval,
                    history_path = awful.util.get_cache_dir() .. "/history_eval"
                  }
              end,
              {description = "lua execute prompt", group = "awesome"}),
    -- Menubar
    awful.key({ modkey }, "p", function() menubar.show() end,
              {description = "show the menubar", group = "launcher"})
)

clientkeys = gears.table.join(
    awful.key({ modkey,           }, "f",
        function (c)
            c.fullscreen = not c.fullscreen
            c:raise()
        end,
        {description = "toggle fullscreen", group = "client"}),
    awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end,
              {description = "close", group = "client"}),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ,
              {description = "toggle floating", group = "client"}),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end,
              {description = "move to master", group = "client"}),

    awful.key({ modkey, "Shift"   }, "j",      function (c) c:move_to_screen(S_LEFT)    end,
              {description = "move to screen", group = "client"}),
    awful.key({ modkey, "Shift"   }, "k",      function (c) c:move_to_screen(S_MAIN)    end,
              {description = "move to screen", group = "client"}),
    awful.key({ modkey, "Shift"   }, "l",      function (c) c:move_to_screen(S_RIGHT_V) end,
              {description = "move to screen", group = "client"}),
    awful.key({ modkey, "Shift"   }, "i",      function (c) c:move_to_screen(S_WALL)    end,
              {description = "move to screen", group = "client"}),

    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end,
              {description = "toggle keep on top", group = "client"}),
    awful.key({ modkey, "Shift"   }, "t",      function (c) awful.titlebar.toggle(c)        end,
              {description = "toggle title bar", group = "client"}),
    awful.key({ modkey,           }, "n",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end ,
        {description = "minimize", group = "client"}),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized = not c.maximized
            c:raise()
        end ,
        {description = "(un)maximize", group = "client"}),
    awful.key({ modkey, "Control" }, "m",
        function (c)
            c.maximized_vertical = not c.maximized_vertical
            c:raise()
        end ,
        {description = "(un)maximize vertically", group = "client"}),
    awful.key({ modkey, "Shift"   }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c:raise()
        end ,
        {description = "(un)maximize horizontally", group = "client"})
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it work on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
    globalkeys = gears.table.join(globalkeys,
        -- View tag only.
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = awful.screen.focused()
                        local tag = screen.tags[i]
                        if tag then
                           tag:view_only()
                        end
                  end,
                  {description = "view tag #"..i, group = "tag"}),
        -- Toggle tag display.
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = awful.screen.focused()
                      local tag = screen.tags[i]
                      if tag then
                         awful.tag.viewtoggle(tag)
                      end
                  end,
                  {description = "toggle tag #" .. i, group = "tag"}),
        -- Move client to tag.
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:move_to_tag(tag)
                          end
                     end
                  end,
                  {description = "move focused client to tag #"..i, group = "tag"}),
        -- Toggle tag on focused client.
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:toggle_tag(tag)
                          end
                      end
                  end,
                  {description = "toggle focused client on tag #" .. i, group = "tag"})
    )
end

clientbuttons = gears.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = awful.client.focus.filter,
                     raise = true,
                     keys = clientkeys,
                     buttons = clientbuttons,
                     screen = awful.screen.preferred,
                     placement = awful.placement.no_overlap+awful.placement.no_offscreen,
                     size_hints_honor = false
     }
    },

    { rule_any = {
            name = {
                    "Krita - Edit Text",
                    "Krita - Edit Text — Krita",
            },
      },
      properties = {
              floating = true,
              titlebars_enabled = true,
              width = 800,
              height = 600,
              placement = awful.placement.centered
      }
    },

    -- Floating clients.
    { rule_any = {
        instance = {
          "DTA",  -- Firefox addon DownThemAll.
          "copyq",  -- Includes session name in class.
        },
        class = {
          "Arandr",
          "Gpick",
          "Kruler",
          "MessageWin",  -- kalarm.
          "Sxiv",
          "Wpa_gui",
          "pinentry",
          "veromix",
          "xtightvncviewer"},

        name = {
          "Event Tester",  -- xev.
        },
        role = {
          "AlarmWindow",  -- Thunderbird's calendar.
          "pop-up",       -- e.g. Google Chrome's (detached) Developer Tools.
        }
      }, properties = { floating = true }},

    -- Add titlebars to normal clients and dialogs
    --{ rule_any = {type = { "normal", "dialog" }
    { rule_any = {type = { "dialog" }
      },
      properties = {
              titlebars_enabled = true,
              placement = awful.placement.centered
      }
    },

    -- Specific client placement
    --
    { rule = { class = "Raven Reader" },
      properties = { screen = S_MAIN, tag = "feed" } },
    { rule = { class = "TelegramDesktop" },
      properties = { screen = S_RIGHT_V, tag = "telegram" } },
    { rule = { class = "Slack" },
      properties = { screen = S_RIGHT_V, tag = "slack" } },
    { rule = { class = "discord" },
      properties = { screen = S_RIGHT_V, tag = "discord" } },
    { rule = { class = "Zulip" },
      properties = { screen = S_RIGHT_V, tag = "zulip" } },
    { rule = { class = "irc" },
      properties = { screen = S_RIGHT_V, tag = "irc" } },
    { rule = { class = "KeePassXC" },
      properties = { screen = S_RIGHT_V, tag = "misc", switchtotag = true } },
    { rule = { class = "Pavucontrol" },
      properties = { screen = S_RIGHT_V, tag = "misc", switchtotag = true } },
    { rule = { class = "Spotify" },
      properties = { maximized = true, screen = S_WALL, tag = "spotify" } },
    { rule = { class = "krita" },
      properties = { screen = S_MAIN, tag = "art", switchtotag = true } },
    { rule = { class = "krita" },
      properties = { screen = S_MAIN, tag = "art", switchtotag = true } },
    { rule = { class = "Gimp" },
      properties = { screen = S_MAIN, tag = "art", switchtotag = true } },
    { rule = { class = "Gimp" },
      properties = { screen = S_MAIN, tag = "art", switchtotag = true } },
    { rule = { class = "Inkscape" },
      properties = { screen = S_MAIN, tag = "art", switchtotag = true } },
    { rule = { class = "Steam" },
      properties = { screen = S_MAIN, tag = "steam" } },
    { rule = { instance = "qutebrowser-main" }, -- qutebrowser main session window 1
      properties = { screen = S_MAIN, tag = "www" } },
    { rule = { instance = "qutebrowser-social" }, -- qutebrowser main session window 2
      properties = { screen = S_LEFT, tag = "www" } },
    { rule = { class = "qutebrowser" },
      properties = { tag = "www" } },
    { rule = { class = "Vivaldi-stable" },
      properties = { tag = "www" } },
    { rule = { class = "plexmediaplayer" },
      properties = { screen = S_WALL, ag = "video" } },

}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c)
    -- Set the windows at the slave,
    -- i.e. put it at the end of others instead of setting it master.
    -- if not awesome.startup then awful.client.setslave(c) end

    if awesome.startup and
      not c.size_hints.user_position
      and not c.size_hints.program_position then
        -- Prevent clients from being unreachable after screen count changes.
        awful.placement.no_offscreen(c)
    end
end)

-- Normally we'd do this with a rule, but Spotify doesn't set its class or name
-- until after it starts up, so we need to catch that signal.
client.connect_signal("property::class", function(c)
        if c.class == "Spotify" then
            -- Check if Spotify is already open
            local spotify = function (c)
                    return awful.rules.match(c, { class = "Spotify" })
            end

            local spotify_count = 0
            for c in awful.client.iterate(spotify) do
                    spotify_count = spotify_count + 1
            end
            -- If Spotify is already open, don't open a new instance
            if spotify_count > 1 then
                c:kill()

                -- Switch to previous instance
                for c in awful.client.iterate(spotify) do
                        c:jump_to(false)
                end
            else
                awful.client.floating.set(c, true)
                awful.titlebar.show(c)

                local s = awful.screen.focused()
                local g = c:geometry()
                g.width = 1600
                g.height = 1200
                g.x = s.geometry.x + (s.geometry.width -  g.width) / 2
                g.y = s.geometry.y + (s.geometry.height -  g.height) / 2
                c:geometry(g)

                c:raise()
            end
        end
end)

-- Add a titlebar if titlebars_enabled is set to true in the rules.
client.connect_signal("request::titlebars", function(c)
    -- buttons for the titlebar
    local buttons = gears.table.join(
        awful.button({ }, 1, function()
            client.focus = c
            c:raise()
            awful.mouse.client.move(c)
        end),
        awful.button({ }, 3, function()
            client.focus = c
            c:raise()
            awful.mouse.client.resize(c)
        end)
    )

    awful.titlebar(c) : setup {
        { -- Left
            awful.titlebar.widget.iconwidget(c),
            buttons = buttons,
            layout  = wibox.layout.fixed.horizontal
        },
        { -- Middle
            { -- Title
                align  = "center",
                widget = awful.titlebar.widget.titlewidget(c)
            },
            buttons = buttons,
            layout  = wibox.layout.flex.horizontal
        },
        { -- Right
            awful.titlebar.widget.floatingbutton (c),
            awful.titlebar.widget.maximizedbutton(c),
            awful.titlebar.widget.stickybutton   (c),
            awful.titlebar.widget.ontopbutton    (c),
            awful.titlebar.widget.closebutton    (c),
            layout = wibox.layout.fixed.horizontal()
        },
        layout = wibox.layout.align.horizontal
    }
end)

-- Enable sloppy focus, so that focus follows mouse.
client.connect_signal("mouse::enter", function(c)
    if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
        and awful.client.focus.filter(c) then
        client.focus = c
    end
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)

---- }}}
----
-- vim: set et sts=4 sw=4:
