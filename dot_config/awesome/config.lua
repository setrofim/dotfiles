local awful = require("awful")
local gears = require("gears")
------------------------------------------------------------------------------
--
-- environment-specific configuration
--
-- These will need to be adjusted for every new system, and, hopefully, rc.lua
-- can remain unchanged.
--
------------------------------------------------------------------------------

-- {{{ misc config

-- Directory containing wallpapers reference inside screen configs.
local wallpaper_base = '/usr/share/wallpapers/'

-- Audio output name to be used the volume widget. Can use
--
--      pactl list sinks | grep Name
--
-- to get a list. Leave as nil to use the pactl default.
local audio_output = nil

-- File system mounts to show in the fs widget. This is a list of mount groups.
-- Each mount groups is a list of mounts to be shown in a single widget (i.e.
-- available/used space will be tracked for the mount group as a whole).
local fs_mounts = {
    { '/' },
}

-- }}}

-- {{{ applications
-- terminal application
local terminal = "wezterm"

-- editor application
local editor = os.getenv("EDITOR") or "nvim"

-- web browser application
local browser = "qutebrowser"

-- file manager application
local file_manager = "thunar"
-- }}}

-- {{{ screen config

--  Configuration tables for individual screens. There should be one for each
--  physical display present in a setup. These then get mapped onto the
--  "standard" layout using the "screens" table below.
--  note: do not explicitly specify screen in the tag configs below -- that
--  will be done automatically.
local main_screen = {
    index = 1,
    wallpaper  = 'cyberpunk_city_21.jpg',
    tags = {
            {
                    "term",
                    {
                            layout = awful.layout.suit.tile,
                            selected = true,
                    }
            },
            {
                    "www",
                    {
                            layout = awful.layout.suit.tile,
                    }
            },
            {
                    "files",
                    {
                            layout = awful.layout.suit.tile,
                    }
            },
            {
                    "misc",
                    {
                            layout = awful.layout.suit.tile,
                    }
            },
        },
}

local left_screen = {
    index = 2,
    wallpaper  = 'cyberpunk_city_09.jpg',
    tags = {
            {
                    "www",
                    {
                            layout = awful.layout.suit.tile.left,
                            selected = true,
                    }
            },
        },
}

local right_screen_veritical = {
    index = 3,
    wallpaper  = 'cyberpunk_city_12_vertical.jpg',
    tags = {
            {
                    "telegram",
                    {
                            layout = awful.layout.suit.tile.bottom,
                            selected = true,
                    }
            },
            {
                    "slack",
                    {
                            layout = awful.layout.suit.tile.bottom,
                    }
            },
            {
                    "zulip",
                    {
                            layout = awful.layout.suit.tile.bottom,
                    }
            },
            {
                    "www",
                    {
                            layout = awful.layout.suit.tile.bottom,
                    }
            },
            {
                    "misc",
                    {
                            layout = awful.layout.suit.tile.bottom,
                    }
            },
            {
                    "spotify",
                    {
                            layout = awful.layout.suit.tile.bottom,
                    }
            },
        },
}

-- rc.lua expects there to always be four screens:
--
--                          ┌──────────────────┐
--                          │                  │
--                          │                  │
--                          │       aux        │
--                          │                  │
--                          │                  │
--                          └──────────────────┘
--
--    ┌──────────────────┐  ┌──────────────────┐  ┌─────────────────┐
--    │                  │  │                  │  │                 │
--    │                  │  │                  │  │                 │
--    │       left       │  │       main       │  │      right      │
--    │                  │  │                  │  │                 │
--    │                  │  │                  │  │                 │
--    └──────────────────┘  └──────────────────┘  └─────────────────┘
--
--    Specifically, there is assumed to be the central screen designated as
--    "main", with other screens surrounding it. The "main" screen is the one
--    that gets the systray.
--
--    There a shortcut letter associated with each screen:
--
--      left  - j
--      main  - k
--      right - l
--      aux   - i
--
--   shortcuts inside rc.lua are assigned based on these letters :
--
--      Mod+Ctrl+<S>: switch to screen
--      Mod+Shift+<S>: move selected client to screen
--
--   where <S> is the shortcut letter associated with the screen.
--
--   In order to avoid getting errors, all four screens should be assigned a
--   config. If the actual setup does not correspond to the existing layout,
--   config for one of the existing screens should be re-used instead of the
--   missing ones. E.g. on a two screen setup, where the right screen is the
--   one that is mainly used, "main", "right", and "aux" entries below might
--   be assigned to the same config.
--
local screens = {
    main  = main_screen,
    left  = left_screen,
    right = right_screen_veritical,
    aux   = main_screen,
}
-- }}}

-- {{{ rules
-- client placement rules that depend on the screen and tag configurations
local rules = {
    { rule = { class = "Raven Reader" },
      properties = { screen = screens.main.index, tag = "feed" } },
    { rule = { class = "TelegramDesktop" },
      properties = { screen = screens.right.index, tag = "telegram" } },
    { rule = { class = "Slack" },
      properties = { screen = screens.right.index, tag = "slack" } },
    { rule = { class = "Zulip" },
      properties = { screen = screens.right.index, tag = "zulip" } },
    { rule = { class = "irc" },
      properties = { screen = screens.right.index, tag = "irc" } },
    { rule = { class = "KeePassXC" },
      properties = { screen = screens.right.index, tag = "misc", switchtotag = true } },
    { rule = { class = "Pavucontrol" },
      properties = { screen = screens.main.index, tag = "misc", switchtotag = true } },
    { rule = { class = "Spotify" },
      properties = { maximized = true, screen = screens.right.index, tag = "spotify" } },
    { rule = { class = "krita" },
      properties = { screen = screens.main.index, tag = "art", switchtotag = true } },
    { rule = { class = "Gimp" },
      properties = { screen = screens.main.index, tag = "art", switchtotag = true } },
    { rule = { class = "Inkscape" },
      properties = { screen = screens.main.index, tag = "art", switchtotag = true } },
    { rule = { class = "qutebrowser" },
      properties = { tag = "www" } },
}
-- }}}

-- {{{ global keys
---@diagnostic disable-next-line: lowercase-global
globalkeys = gears.table.join(
    ---@diagnostic disable-next-line: undefined-global
    awful.key({ modkey }, "Pause",
        function ()
                awful.util.spawn_with_shell("/home/setrofim/.local/bin/lockscreen")
        end)
)
--- }}}

-- {{{ client keys
---@diagnostic disable-next-line: lowercase-global
clientkeys = gears.table.join()
-- }}}

-- {{{ applications menu
--  TODO: figure out some way to populate this dynamically...
local appmenu = {}

appmenu.Art = {
    { 'drawio', '/opt/drawio/drawio', '/usr/share/icons/hicolor/720x720/apps/drawio.png' },
    { 'GIMP', 'gimp-2.10', '/usr/share/icons/hicolor/22x22/apps/gimp.png' },
    { 'Inkscape', 'inkscape', '/usr/share/icons/hicolor/22x22/apps/org.inkscape.Inkscape.png' },
    { 'Krita', 'krita', '/usr/share/icons/hicolor/22x22/apps/krita.png' },
    { 'LibreOffice Draw', 'libreoffice --draw', '/usr/share/icons/hicolor/22x22/apps/libreoffice-draw.png' },
    { 'QGIS Desktop', 'qgis', '/usr/share/icons/hicolor/22x22/apps/qgis.png' },
}

appmenu.Browsers = {
    { 'Chromium', '/usr/bin/chromium', '/usr/share/icons/hicolor/128x128/apps/chromium.png' },
    { 'ELinks', 'kitty /usr/bin/elinks' },
    { 'Firefox', '/usr/lib/firefox/firefox', '/usr/share/icons/hicolor/22x22/apps/firefox.png' },
    { 'qutebrowser', 'qutebrowser --untrusted-args', '/usr/share/icons/hicolor/128x128/apps/qutebrowser.png' },
}

appmenu.Cad = {
    { 'Anycubic Photon Workshop', 'env WINEPREFIX="/home/setrofim/.wine" wine C:\\\\ProgramData\\\\Microsoft\\\\Windows\\\\Start\\ Menu\\\\Programs\\\\AnycubicPhotonWorkshop\\\\AnycubicPhotonWorkshop.lnk' },
    { 'Blender', 'blender', '/usr/share/icons/hicolor/scalable/apps/blender.svg' },
    { 'FreeCAD', 'FreeCAD', '/usr/share/icons/hicolor/scalable/apps/org.freecadweb.FreeCAD.svg' },
    { 'OpenSCAD', 'openscad', '/usr/share/icons/hicolor/128x128/apps/openscad.png' },
    { 'Qidi Print', 'kitty qidi-print' },
}

appmenu.Comms = {
    { 'Discord', '/usr/bin/discord', '/usr/share/pixmaps/discord.png' },
    { 'Slack', '/usr/bin/slack -s', '/usr/share/pixmaps/slack.png' },
    { 'Telegram Desktop', 'telegram-desktop --', '/usr/share/icons/hicolor/128x128/apps/telegram.png' },
    { 'Zoom', '/usr/bin/zoom', '/usr/share/pixmaps/Zoom.png' },
    { 'Zulip', 'zulip', '/usr/share/icons/hicolor/128x128/apps/zulip.png' },
}

appmenu.Files = {
    { 'Archive Manager', 'file-roller', '/usr/share/icons/hicolor/scalable/apps/org.gnome.FileRoller.svg' },
    { 'Document Viewer', 'evince', '/usr/share/icons/hicolor/scalable/apps/org.gnome.Evince.svg' },
    { 'gImageReader', 'gimagereader-gtk', '/usr/share/icons/hicolor/128x128/apps/gimagereader.png' },
    { 'nomacs Image Viewer', 'nomacs', '/usr/share/icons/hicolor/scalable/apps/org.nomacs.ImageLounge.svg' },
    { 'PCManFM File Manager', 'pcmanfm', '/usr/share/icons/breeze-dark/apps/64/system-file-manager.svg' },
    { 'ranger', 'kitty ranger' },
    { 'Scans to PDF', 'scans2pdf-gui', '/usr/share/icons/hicolor/128x128/apps/com.github.unrud.djpdf.png' },
    { 'Thunar File Manager', 'thunar', '/usr/share/icons/hicolor/128x128/apps/org.xfce.thunar.png' },
}

appmenu.Office = {
    { 'drawio', '/opt/drawio/drawio', '/usr/share/icons/hicolor/720x720/apps/drawio.png' },
    { 'Evince', 'evince', '/usr/share/icons/hicolor/scalable/apps/org.gnome.Evince.svg' },
    { 'FBReader', 'FBReader' },
    { 'LibreOffice Base', 'libreoffice --base', '/usr/share/icons/hicolor/22x22/apps/libreoffice-base.png' },
    { 'LibreOffice Calc', 'libreoffice --calc', '/usr/share/icons/hicolor/22x22/apps/libreoffice-calc.png' },
    { 'LibreOffice Draw', 'libreoffice --draw', '/usr/share/icons/hicolor/22x22/apps/libreoffice-draw.png' },
    { 'LibreOffice Impress', 'libreoffice --impress', '/usr/share/icons/hicolor/22x22/apps/libreoffice-impress.png' },
    { 'LibreOffice Math', 'libreoffice --math', '/usr/share/icons/hicolor/22x22/apps/libreoffice-math.png' },
    { 'LibreOffice Start Center', 'libreoffice', '/usr/share/icons/hicolor/22x22/apps/libreoffice-startcenter.png' },
    { 'LibreOffice Writer', 'libreoffice --writer', '/usr/share/icons/hicolor/22x22/apps/libreoffice-writer.png' },
    { 'Obsidian', '/usr/bin/obsidian', '/usr/share/pixmaps/obsidian.png' },
    { 'StarDict', 'stardict' },
}

appmenu.Development = {
    { 'CMake', 'cmake-gui', '/usr/share/icons/hicolor/128x128/apps/CMakeSetup.png' },
    { 'Electron 18', 'electron18', '/usr/share/pixmaps/electron18.png' },
    { 'IPython', 'kitty ipython', '/usr/share/pixmaps/ipython.png' },
    { 'Jupyter Notebook', 'kitty jupyter-notebook', '/usr/share/icons/hicolor/scalable/apps/notebook.svg' },
    { 'KDiff3', 'kdiff3', '/usr/share/icons/hicolor/22x22/apps/kdiff3.png' },
    { 'KingstVIS', '/opt/kingstvis/KingstVIS', '/usr/share/icons/hicolor/48x48/KingstVIS.png' },
    { 'Meld', 'meld', '/usr/share/icons/hicolor/scalable/apps/org.gnome.Meld.svg' },
    { 'PulseView', 'pulseview', '/usr/share/icons/hicolor/48x48/apps/pulseview.png' },
    { 'Qt Assistant', 'assistant', '/usr/share/icons/hicolor/128x128/apps/assistant.png' },
    { 'Qt Designer', 'designer', '/usr/share/icons/hicolor/128x128/apps/QtProject-designer.png' },
    { 'Qt Linguist', 'linguist', '/usr/share/icons/hicolor/128x128/apps/linguist.png' },
    { 'Qt QDBusViewer', 'qdbusviewer', '/usr/share/icons/hicolor/128x128/apps/qdbusviewer.png' },
    { 'Slic3r', 'slic3r', '/usr/bin/vendor_perl/var/Slic3r_128px.png' },
}

appmenu.Science = {
    { 'IPython', 'kitty ipython', '/usr/share/pixmaps/ipython.png' },
    { 'Jupyter Notebook', 'kitty jupyter-notebook', '/usr/share/icons/hicolor/scalable/apps/notebook.svg' },
    { 'LibreOffice Math', 'libreoffice --math', '/usr/share/icons/hicolor/22x22/apps/libreoffice-math.png' },
    { 'QGIS Desktop', 'qgis', '/usr/share/icons/hicolor/22x22/apps/qgis.png' },
}


appmenu.Accessories = {
    { 'AllTray 0.7.5.1dev', 'alltray -a', '/usr/share/pixmaps/alltray.png' },
    { 'Archive Manager', 'file-roller', '/usr/share/icons/hicolor/scalable/apps/org.gnome.FileRoller.svg' },
    { 'Bulk Rename', 'thunar --bulk-rename', '/usr/share/icons/hicolor/128x128/apps/org.xfce.thunar.png' },
    { 'ClipIt', 'clipit', '/usr/share/icons/hicolor/scalable/apps/clipit-trayicon-offline.svg' },
    { 'File Manager PCManFM', 'pcmanfm' },
    { 'HP Device Manager', 'hp-toolbox', '/usr/share/hplip/data/images/128x128/hp_logo.png' },
    { 'KeePassXC', 'keepassxc', '/usr/share/icons/hicolor/256x256/apps/keepassxc.png' },
    { 'Neovim', 'kitty nvim', '/usr/share/icons/hicolor/128x128/apps/nvim.png' },
    { 'Protontricks', 'protontricks --no-term --gui' },
    { 'StarDict', 'stardict' },
    { 'TVRenamer', 'tvrenamer' },
    { 'Winetricks', 'winetricks --gui', '/usr/share/icons/hicolor/scalable/apps/winetricks.svg' },
    { 'picom', 'picom' },
}

appmenu.Internet = {
    { 'Avahi SSH Server Browser', '/usr/bin/bssh', '/usr/share/pixmaps/avahi.png' },
    { 'Avahi VNC Server Browser', '/usr/bin/bvnc', '/usr/share/pixmaps/avahi.png' },
    { 'Dropbox', 'dropbox', '/usr/share/pixmaps/dropbox.svg' },
    { 'Liferea', 'liferea', '/usr/share/icons/hicolor/48x48/apps/net.sourceforge.liferea.png' },
    { 'Private Internet Access', '/opt/piavpn/bin/pia-client', '/usr/share/pixmaps/piavpn.png' },
    { 'Raven Reader', '/opt/raven-reader/raven-reader', '/usr/share/icons/hicolor/1024x1024/apps/raven-reader.png' },
    { 'TigerVNC Viewer', '/usr/bin/vncviewer', '/usr/share/icons/hicolor/22x22/apps/tigervnc.png' },
    { 'Transmission Remote', 'transmission-remote-gtk', '/usr/share/icons/hicolor/22x22/apps/transmission-remote-gtk.png' },
    { 'WeeChat', 'kitty weechat', '/usr/share/icons/hicolor/128x128/apps/weechat.png' },
}

appmenu.MultiMedia = {
    { 'Audacity', 'env UBUNTU_MENUPROXY=0 audacity', '/usr/share/icons/hicolor/22x22/audacity.png' },
    { 'Avidemux', 'avidemux3_qt5', '/usr/share/icons/hicolor/128x128/apps/org.avidemux.Avidemux.png' },
    { 'Cheese', 'cheese', '/usr/share/icons/hicolor/scalable/apps/org.gnome.Cheese.svg' },
    { 'HandBrake', 'ghb', '/usr/share/icons/hicolor/scalable/apps/fr.handbrake.ghb.svg' },
    { 'Kdenlive', 'kdenlive', '/usr/share/icons/hicolor/22x22/apps/kdenlive.png' },
    { 'Lyrebird', '/usr/bin/lyrebird', '/usr/share/lyrebird/icon.png' },
    { 'MP3info', 'gmp3info' },
    { 'MediaInfo', 'mediainfo-gui', '/usr/share/icons/hicolor/256x256/apps/mediainfo.png' },
    { 'MusicBrainz Picard', 'picard', '/usr/share/icons/hicolor/128x128/apps/org.musicbrainz.Picard.png' },
    { 'PulseAudio Equalizer', 'pulseaudio-equalizer-gtk' },
    { 'PulseAudio Manager', 'paman' },
    { 'PulseAudio System Tray', 'pasystray', '/usr/share/icons/hicolor/scalable/apps/pasystray.svg' },
    { 'PulseAudio Volume Control', 'pavucontrol' },
    { 'Qt V4L2 test Utility', 'qv4l2', '/usr/share/icons/hicolor/32x32/apps/qv4l2.png' },
    { 'Qt V4L2 video capture utility', 'qvidcap', '/usr/share/icons/hicolor/32x32/apps/qvidcap.png' },
    { 'Spotify', 'spotify --uri=' },
    { 'mpv Media Player', 'mpv --player-operation-mode=pseudo-gui --', '/usr/share/icons/hicolor/128x128/apps/mpv.png' },
}

appmenu.Settings = {
    { 'Advanced Network Config', 'nm-connection-editor', '/usr/share/icons/breeze-dark/devices/64/network-rj45-female.svg' },
    { 'IBus Preferences', 'ibus-setup', '/usr/share/icons/hicolor/scalable/apps/ibus-setup.svg' },
    { 'LightDM GTK+ Greeter', 'lightdm-gtk-greeter-settings-pkexec', '/usr/share/icons/hicolor/48x48/apps/lightdm-gtk-greeter-settings.png' },
    { 'lxappearance', 'lxappearance' },
    { 'NVIDIA Settings', '/usr/bin/nvidia-settings' },
    { 'PCManFM Desktop Prefs', 'pcmanfm --desktop-pref', '/usr/share/icons/Adwaita/22x22/places/user-desktop.png' },
    { 'PulseAudio Preferences', 'paprefs' },
    { 'PulseAudio Volume', 'pavucontrol' },
    { 'Qt5 Settings', 'qt5ct' },
    { 'Removable Media', 'thunar-volman-settings', '/usr/share/icons/hicolor/128x128/apps/org.xfce.volman.png' },
    { 'Thunar Settings', 'thunar-settings', '/usr/share/icons/hicolor/128x128/apps/org.xfce.thunar.png' },
}

appmenu.System = {
    { 'Avahi Zeroconf Browser', '/usr/bin/avahi-discover' },
    { 'Disk Usage Analyzer', 'baobab', '/usr/share/icons/hicolor/scalable/apps/org.gnome.baobab.svg' },
    { 'Hardware Locality lstopo', 'lstopo' },
    { 'Htop', 'kitty htop', '/usr/share/icons/hicolor/scalable/apps/htop.svg' },
    { 'Manage Printing', '/usr/bin/xdg-open http://localhost:631/', '/usr/share/icons/hicolor/128x128/apps/cups.png' },
    { 'Oracle VM VirtualBox', 'VirtualBox', '/usr/share/icons/hicolor/128x128/mimetypes/virtualbox.png' },
    { 'VeraCrypt', 'veracrypt' },
    { 'kitty', 'kitty', '/usr/share/icons/hicolor/256x256/apps/kitty.png' },
}

appmenu.Appmenu = {
    { 'Accessories', appmenu.Accessories, '/usr/share/icons/breeze-dark/categories/32/applications-utilities.svg' },
    { 'Browsers', appmenu.Browsers, '/usr/share/icons/breeze-dark/mimetypes/64/application-vnd.oasis.opendocument.web-template.svg' },
    { 'CAD (3D)', appmenu.Cad, '/usr/share/icons/breeze-dark/categories/32/applications-engineering.svg' },
    { 'Comms', appmenu.Comms, '/usr/share/icons/breeze-dark/apps/48/org.kde.neochat.svg' },
    { 'Development', appmenu.Development, '/usr/share/icons/breeze-dark/categories/32/applications-development.svg' },
    { 'Files', appmenu.Files, '/usr/share/icons/breeze-dark/places/64/folder.svg' },
    { 'Graphics (2D)', appmenu.Art, '/usr/share/icons/breeze-dark/categories/32/applications-graphics.svg' },
    { 'Internet', appmenu.Internet, '/usr/share/icons/breeze-dark/categories/32/applications-internet.svg' },
    { 'MultiMedia', appmenu.MultiMedia, '/usr/share/icons/breeze-dark/categories/32/applications-multimedia.svg' },
    { 'Office', appmenu.Office, '/usr/share/icons/breeze-dark/categories/32/applications-office.svg' },
    { 'Science', appmenu.Science, '/usr/share/icons/breeze-dark/categories/32/applications-science.svg' },
    { 'Settings', appmenu.Settings, '/usr/share/icons/breeze-dark/apps/64/sharedlib.svg' },
    { 'System', appmenu.System, '/usr/share/icons/breeze-dark/categories/32/applications-system.svg' },
}
-- }}}

------------------------------------------------------------------------------
--
-- end of environment-specific configuration
--
------------------------------------------------------------------------------

-- {{{ return
return  {
    terminal = terminal,
    editor = editor,
    browser = browser,
    file_manager = file_manager,
    wallpaper_base = wallpaper_base,
    screens = screens,
    rules = rules,
    appmenu = appmenu,
    audio_output = audio_output,
    globalkeys = globalkeys,
    clientkeys = clientkeys,
    fs_mounts = fs_mounts,
}
-- }}}

-- vim: set et sts=4 sw=4 foldmethod=marker:
