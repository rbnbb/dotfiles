---@module 'hl'

-- Hyprland Configuration
-- https://wiki.hypr.land/Configuring/

-- ==================
-- MONITOR CONFIG
-- ==================
-- Monitors from existing configuration

-- use integer scaling for good font rendering, e.g., sioyek
hl.monitor({
    output   = "eDP-1",
    mode     = "2880x1800@60",
    position = "0x0",
    scale    = 2.0,
})

-- hl.monitor({
--     output   = "desc:Samsung Electric Company U28E850 HTPKA00080",
--     mode     = "3840x2160@60",
--     position = "1920x0",
--     scale    = 1.5,
-- })

-- hyprctl monitors -> see available modes for a quick patch
hl.monitor({
    output   = "HDMI-A-1",
    mode     = "2560x1440@144.00",
    position = "1440x0",
    scale    = 1.00,
})

-- ==================
-- ENVIRONMENT VARS
-- ==================

hl.env("QT_QPA_PLATFORM", "wayland")
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")
hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")
hl.env("QT_QPA_PLATFORMTHEME_QT6", "qt6ct")
hl.env("TERMINAL", "kitty")

-- ensure dolphin can select apps
hl.env("XDG_MENU_PREFIX", "arch-")

-- for compatibility with KDE/other apps
hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")

-- ==================
-- STARTUP APPS
-- ==================

hl.on("hyprland.start", function()
    hl.exec_cmd("wl-paste --watch cliphist store &")
    hl.exec_cmd("dms run")
    hl.exec_cmd("/usr/lib/mate-polkit/polkit-mate-authentication-agent-1")
end)

-- ==================
-- INPUT CONFIG
-- ==================

hl.config({
    input = {
        kb_layout          = "us",
        kb_variant         = "qwerty-fr",
        kb_options         = "caps:escape",
        numlock_by_default = true,

        follow_mouse       = 1,

        touchpad = {
            natural_scroll       = true,
            disable_while_typing = true,
            scroll_factor        = 0.5,
        },

        sensitivity = 0, -- -1.0 - 1.0, 0 means no modification.
    },
})

-- ==================
-- GENERAL LAYOUT
-- ==================

hl.config({
    general = {
        gaps_in     = 5,
        gaps_out    = 5,
        border_size = 0, -- off in niri

        col = {
            active_border   = "rgba(707070ff)",
            inactive_border = "rgba(d0d0d0ff)",
        },

        layout = "dwindle",
    },
})

-- DMS writes matugen colors to ./dms/colors.lua. To let it drive the border
-- colors instead of the two values above, add: require("dms.colors")

-- ==================
-- DECORATION
-- ==================

hl.config({
    decoration = {
        rounding         = 12,

        active_opacity   = 1.0,
        inactive_opacity = 0.95,

        shadow = {
            enabled      = true,
            range        = 30,
            render_power = 5,
            offset       = { 0, 5 },
            color        = "rgba(00000070)",
        },
    },
})

-- ==================
-- ANIMATIONS
-- ==================
-- hl.animation requires a `bezier` or `spring`; "default" is the builtin bezier.

hl.config({
    animations = {
        enabled = true,
    },
})

hl.animation({ leaf = "windowsIn",   enabled = true, speed = 3, bezier = "default" })
hl.animation({ leaf = "windowsOut",  enabled = true, speed = 3, bezier = "default" })
hl.animation({ leaf = "workspaces",  enabled = true, speed = 5, bezier = "default" })
hl.animation({ leaf = "windowsMove", enabled = true, speed = 4, bezier = "default" })
hl.animation({ leaf = "fade",        enabled = true, speed = 3, bezier = "default" })
hl.animation({ leaf = "border",      enabled = true, speed = 3, bezier = "default" })

-- ==================
-- LAYOUTS
-- ==================

hl.config({
    dwindle = {
        preserve_split = true,
    },

    master = {
        mfact = 0.5,
    },
})

-- ==================
-- MISC
-- ==================

hl.config({
    misc = {
        disable_hyprland_logo    = true,
        disable_splash_rendering = true,
        vrr                      = 1,
    },
})

-- ==================
-- WINDOW RULES
-- ==================
-- `match` holds the props (RE2 regexes for class/title); everything else in the
-- table is an effect. See https://wiki.hypr.land/Configuring/Basics/Window-Rules/

hl.window_rule({ match = { class = "^(org\\.wezfurlong\\.wezterm)" }, tile = true })

hl.window_rule({ match = { class = "^(org\\.gnome\\.)" }, rounding = 12 })
-- hl.window_rule({ match = { class = "^(org\\.gnome\\.)" }, border_size = 0 })

hl.window_rule({ match = { class = "^(gnome-control-center)$" },   tile = true })
hl.window_rule({ match = { class = "^(pavucontrol)$" },            tile = true })
hl.window_rule({ match = { class = "^(nm-connection-editor)$" },   tile = true })

hl.window_rule({ match = { class = "^(gnome-calculator)$" },       float = true })
hl.window_rule({ match = { class = "^(galculator)$" },             float = true })
hl.window_rule({ match = { class = "^(blueman-manager)$" },        float = true })
hl.window_rule({ match = { class = "^(org\\.gnome\\.Nautilus)$" }, float = true })
hl.window_rule({ match = { class = "^(steam)$" },                  float = true })
hl.window_rule({ match = { class = "^(xdg-desktop-portal)$" },     float = true })

-- hl.window_rule({ match = { class = "^(org\\.wezfurlong\\.wezterm)$" }, border_size = 0 })
-- hl.window_rule({ match = { class = "^(Alacritty)$" },                  border_size = 0 })
-- hl.window_rule({ match = { class = "^(zen)$" },                        border_size = 0 })
-- hl.window_rule({ match = { class = "^(com\\.mitchellh\\.ghostty)$" },  border_size = 0 })
-- hl.window_rule({ match = { class = "^(kitty)$" },                      border_size = 0 })

hl.window_rule({
    match = { class = "^(firefox)$", title = "^(Picture-in-Picture)$" },
    float = true,
})
hl.window_rule({ match = { class = "^(zoom)$" }, float = true })

-- restrict to workspaces
hl.window_rule({ match = { class = "^(firefox)$" }, workspace = "name:F" })

-- hl.window_rule({ match = { float = false, focus = false }, opacity = "0.9 0.9" })

-- hl.layer_rule({ match = { namespace = "^(quickshell)$" }, no_anim = true })

-- ==================
-- KEYBINDINGS
-- ==================

local mod    = "SUPER"
local navmod = "ALT"

--- The Lua resize dispatcher takes pixel numbers only, so the percentages used
--- by the old hyprlang `resizeactive` binds are resolved here against the
--- logical size of the focused monitor.
---@param px number fraction of monitor width
---@param py number fraction of monitor height
---@param relative? boolean defaults to true (delta); false resizes to an exact size
local function resize_pct(px, py, relative)
    return function()
        local m = hl.get_active_monitor()
        if m == nil then
            return
        end
        local scale = (m.scale and m.scale > 0) and m.scale or 1
        hl.dispatch(hl.dsp.window.resize({
            x        = math.floor(m.width / scale * px),
            y        = math.floor(m.height / scale * py),
            relative = relative ~= false,
        }))
    end
end

-- === Application Launchers ===
hl.bind(mod .. " + Q",        hl.dsp.exec_cmd("kitty --single-instance"))
hl.bind(navmod .. " + space", hl.dsp.exec_cmd("dms ipc call spotlight toggle"))
hl.bind(mod .. " + V",        hl.dsp.exec_cmd("dms ipc call clipboard toggle"))
hl.bind(mod .. " + M",        hl.dsp.exec_cmd("dms ipc call processlist toggle"))
hl.bind(mod .. " + comma",    hl.dsp.exec_cmd("dms ipc call settings toggle"))
hl.bind(mod .. " + N",        hl.dsp.exec_cmd("dms ipc call notifications toggle"))
-- hl.bind(mod .. " + SHIFT + N", hl.dsp.exec_cmd("dms ipc call notepad toggle"))
hl.bind(mod .. " + Y",        hl.dsp.exec_cmd("dms ipc call dankdash wallpaper"))
hl.bind(mod .. " + TAB",      hl.dsp.exec_cmd("dms ipc call hypr toggleOverview"))

-- === Security ===
hl.bind(mod .. " + SHIFT + L", hl.dsp.exec_cmd("dms ipc call lock lock"))
hl.bind("CTRL + ALT + Delete", hl.dsp.exec_cmd("dms ipc call processlist toggle"))

-- === Audio Controls ===
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("dms ipc call audio increment 3"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("dms ipc call audio decrement 3"), { locked = true, repeating = true })
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("dms ipc call audio mute"),        { locked = true })
hl.bind("XF86AudioMicMute",     hl.dsp.exec_cmd("dms ipc call audio micmute"),     { locked = true })

-- === Keyboard Backlight ===
hl.bind("XF86KbdBrightnessUp",   hl.dsp.exec_cmd("kbdbrite.sh up"),   { locked = true, repeating = true })
hl.bind("XF86KbdBrightnessDown", hl.dsp.exec_cmd("kbdbrite.sh down"), { locked = true, repeating = true })

-- === Brightness Controls ===
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("dms ipc call brightness increment 5"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("dms ipc call brightness decrement 5"), { locked = true, repeating = true })

-- === Wallpaper Control ===
hl.bind(mod .. " + F12",         hl.dsp.exec_cmd("~/.local/bin/wallpaper-switcher next"))
hl.bind(mod .. " + SHIFT + F12", hl.dsp.exec_cmd("~/.local/bin/wallpaper-switcher prev"))
hl.bind(mod .. " + CTRL + F12",  hl.dsp.exec_cmd("~/.local/bin/wallpaper-switcher mode"))

-- === Window Management ===
hl.bind(mod .. " + C",         hl.dsp.window.close())
hl.bind(navmod .. " + comma",  hl.dsp.window.fullscreen({ mode = "maximized" }))
hl.bind(mod .. " + SHIFT + F", hl.dsp.window.fullscreen({ mode = "fullscreen" }))
hl.bind(mod .. " + SHIFT + T", hl.dsp.window.float())
hl.bind(mod .. " + W",         hl.dsp.group.toggle())

-- === Focus Navigation ===
hl.bind(navmod .. " + H", hl.dsp.focus({ direction = "l" }))
hl.bind(navmod .. " + J", hl.dsp.focus({ direction = "d" }))
hl.bind(navmod .. " + K", hl.dsp.focus({ direction = "u" }))
hl.bind(navmod .. " + L", hl.dsp.focus({ direction = "r" }))

-- === Window Movement ===
hl.bind(navmod .. " + SHIFT + H", hl.dsp.window.move({ direction = "l" }))
hl.bind(navmod .. " + SHIFT + J", hl.dsp.window.move({ direction = "d" }))
hl.bind(navmod .. " + SHIFT + K", hl.dsp.window.move({ direction = "u" }))
hl.bind(navmod .. " + SHIFT + L", hl.dsp.window.move({ direction = "r" }))

-- === Column Navigation ===
-- NOTE: carried over from the niri config. "first"/"last" are not valid
-- Hyprland window selectors (those are class:/title:/pid:/address:/tag:/
-- activewindow/floating/tiled), so these two binds were no-ops in the .conf
-- too. Left commented out rather than silently doing nothing.
-- hl.bind(mod .. " + Home", hl.dsp.focus({ window = "first" }))
-- hl.bind(mod .. " + End",  hl.dsp.focus({ window = "last" }))

-- === Monitor Navigation ===
hl.bind(navmod .. " + TAB",   hl.dsp.focus({ last = true }))
hl.bind(mod .. " + CTRL + H", hl.dsp.focus({ monitor = "l" }))
hl.bind(mod .. " + CTRL + J", hl.dsp.focus({ monitor = "d" }))
hl.bind(mod .. " + CTRL + K", hl.dsp.focus({ monitor = "u" }))
hl.bind(mod .. " + CTRL + L", hl.dsp.focus({ monitor = "r" }))

-- === Move to Monitor ===
hl.bind(navmod .. " + SHIFT + TAB",   hl.dsp.workspace.move({ monitor = "+1" }))
hl.bind(mod .. " + SHIFT + CTRL + H", hl.dsp.window.move({ monitor = "l" }))
hl.bind(mod .. " + SHIFT + CTRL + J", hl.dsp.window.move({ monitor = "d" }))
hl.bind(mod .. " + SHIFT + CTRL + K", hl.dsp.window.move({ monitor = "u" }))
hl.bind(mod .. " + SHIFT + CTRL + L", hl.dsp.window.move({ monitor = "r" }))

-- === Workspace Navigation ===
hl.bind(mod .. " + Page_Down",   hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mod .. " + Page_Up",     hl.dsp.focus({ workspace = "e-1" }))
hl.bind(mod .. " + U",           hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mod .. " + I",           hl.dsp.focus({ workspace = "e-1" }))
hl.bind(mod .. " + CTRL + down", hl.dsp.window.move({ workspace = "e+1" }))
hl.bind(mod .. " + CTRL + up",   hl.dsp.window.move({ workspace = "e-1" }))
hl.bind(mod .. " + CTRL + U",    hl.dsp.window.move({ workspace = "e+1" }))
hl.bind(mod .. " + CTRL + I",    hl.dsp.window.move({ workspace = "e-1" }))

-- === Move Workspaces ===
hl.bind(mod .. " + SHIFT + Page_Down", hl.dsp.window.move({ workspace = "e+1" }))
hl.bind(mod .. " + SHIFT + Page_Up",   hl.dsp.window.move({ workspace = "e-1" }))
hl.bind(mod .. " + SHIFT + U",         hl.dsp.window.move({ workspace = "e+1" }))
hl.bind(mod .. " + SHIFT + I",         hl.dsp.window.move({ workspace = "e-1" }))

-- === Mouse Wheel Navigation ===
hl.bind(mod .. " + mouse_down",        hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mod .. " + mouse_up",          hl.dsp.focus({ workspace = "e-1" }))
hl.bind(mod .. " + CTRL + mouse_down", hl.dsp.window.move({ workspace = "e+1" }))
hl.bind(mod .. " + CTRL + mouse_up",   hl.dsp.window.move({ workspace = "e-1" }))

-- === Numbered / Named Workspaces ===
-- Named workspaces need the `name:` selector prefix. The .conf wrote
-- `name:"F"`, which made the name literally include the quotes; dropped here
-- (consistently on both the focus and move binds, and the firefox rule above).
local named_workspaces = {
    A = "A",
    E = "E",
    S = "F", -- for firefox
    N = "N",
    Z = "Z",
}

for i = 1, 9 do
    hl.bind(navmod .. " + " .. i,           hl.dsp.focus({ workspace = i }))
    hl.bind(navmod .. " + SHIFT + " .. i,   hl.dsp.window.move({ workspace = i }))
end

for key, ws in pairs(named_workspaces) do
    hl.bind(navmod .. " + " .. key,         hl.dsp.focus({ workspace = "name:" .. ws }))
    hl.bind(navmod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = "name:" .. ws }))
end

-- === Column Management ===
hl.bind(mod .. " + bracketleft",  hl.dsp.layout("preselect l"))
hl.bind(mod .. " + bracketright", hl.dsp.layout("preselect r"))

-- === Sizing & Layout ===
hl.bind(navmod .. " + period", hl.dsp.layout("togglesplit"))
-- was `resizeactive, exact 100%` (a malformed one-arg exact resize); read as
-- "fill the monitor".
hl.bind(mod .. " + CTRL + F",  resize_pct(1.0, 1.0, false))

-- === Move/resize windows with mainMod + LMB/RMB and dragging ===
hl.bind(mod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true, description = "Move window" })
hl.bind(mod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true, description = "Resize window" })

-- === Keyboard Sizing (code:20 = minus, code:21 = equal) ===
hl.bind(mod .. " + code:20", hl.dsp.window.resize({ x = -100, y = 0, relative = true }), { description = "Expand window left" })
hl.bind(mod .. " + code:21", hl.dsp.window.resize({ x = 100, y = 0, relative = true }),  { description = "Shrink window left" })

-- === Manual Sizing ===
hl.bind(navmod .. " + minus",         resize_pct(-0.10, 0),  { repeating = true })
hl.bind(navmod .. " + equal",         resize_pct(0.10, 0),   { repeating = true })
hl.bind(navmod .. " + SHIFT + minus", resize_pct(0, -0.10),  { repeating = true })
hl.bind(navmod .. " + SHIFT + equal", resize_pct(0, 0.10),   { repeating = true })

-- === Screenshots ===
hl.bind("XF86Launch1",          hl.dsp.exec_cmd("grimblast copy area"))
hl.bind("CTRL + XF86Launch1",   hl.dsp.exec_cmd("grimblast copy screen"))
hl.bind("ALT + XF86Launch1",    hl.dsp.exec_cmd("grimblast copy active"))
hl.bind("Print",                hl.dsp.exec_cmd("grimblast copy area"))
hl.bind("CTRL + Print",         hl.dsp.exec_cmd("grimblast copy screen"))
hl.bind("ALT + Print",          hl.dsp.exec_cmd("grimblast copy active"))

-- === System Controls ===
-- hl.bind(mod .. " + SHIFT + P", hl.dsp.dpms({ action = "off" }))

-- ==================
-- CURSOR
-- ==================
-- Was `source = ./dms/cursor.conf`. Lua configs cannot source hyprlang files,
-- and DMS only emits a .lua for colors so far, so its contents are inlined.
-- If DMS starts writing ./dms/cursor.lua, replace this with require("dms.cursor").

hl.env("HYPRCURSOR_THEME", "default")
hl.env("XCURSOR_THEME", "default")
hl.env("HYPRCURSOR_SIZE", "23")
hl.env("XCURSOR_SIZE", "23")
