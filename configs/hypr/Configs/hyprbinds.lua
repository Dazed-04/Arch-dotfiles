-------------------
--- KEYBINDINGS ---
-------------------

local mainMod = "SUPER" -- Sets "Windows" key as main modifier
local music = "bash $HOME/.config/hypr/scripts/toggleMusic.sh"

-- Example binds, see https://wiki.hypr.land/Configuring/Binds/ for more
hl.bind(mainMod .. " + Q", hl.dsp.exec_cmd(terminal or "kitty"))
local closeWindowBind = hl.bind(mainMod .. " + K", hl.dsp.window.close())
-- closeWindowBind:set_enabled(false)
hl.bind(mainMod .. " + SPACE", hl.dsp.exec_raw(menu))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + F", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + F", hl.dsp.window.resize({ x = 1200, y = 800 }))
hl.bind(mainMod .. " + F", hl.dsp.window.center())
hl.bind(mainMod .. " + SHIFT + F", hl.dsp.window.fullscreen({ "fullscreen", "toggle" }))
hl.bind(mainMod .. " + J", hl.dsp.layout("togglesplit"))
hl.bind(mainMod .. " + L", hl.dsp.exec_cmd("hyprlock"))
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())
hl.bind(mainMod .. " + R", hl.dsp.exec_raw("bash $HOME/.config/hypr/scripts/toggleRefreshRate.sh"))
hl.bind(mainMod .. " + T", hl.dsp.exec_raw("bash $HOME/.local/bin/myScripts/utilities/emoji_launcher.sh"))
hl.bind(mainMod .. " + U", hl.dsp.exec_raw("bash $HOME/.local/bin/myScripts/utilities/utility_menu.sh"))
hl.bind(mainMod .. " + V", hl.dsp.exec_raw("bash $HOME/.local/bin/myScripts/clipboard/clipboard.sh"))

-- For qbit, seanime and stremio
hl.bind(mainMod .. " + A", hl.dsp.exec_raw("bash $HOME/.local/bin/myScripts/streaming/seanime.sh"))
hl.bind(mainMod .. " + D", hl.dsp.exec_raw("bash $HOME/.local/bin/myScripts/streaming/qbittorrent.sh"))
hl.bind(mainMod .. " + S", hl.dsp.exec_cmd("stremio-enhanced"))

-- Open wlogout menu
hl.bind("ALT + F4", hl.dsp.exec_raw("bash $HOME/.local/bin/myScripts/wlogout/wlogout.sh"))

-- Move focus with mainMod + arrow keys
hl.bind(mainMod .. " + SHIFT + H", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + SHIFT + L", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + SHIFT + K", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + SHIFT + J", hl.dsp.focus({ direction = "down" }))
hl.bind(mainMod .. " + Tab", hl.dsp.window.cycle_next({}))

-- Move windows
hl.bind(mainMod .. " + CTRL + H", hl.dsp.window.move({ direction = "left" }))
hl.bind(mainMod .. " + CTRL + L", hl.dsp.window.move({ direction = "right" }))
hl.bind(mainMod .. " + CTRL + K", hl.dsp.window.move({ direction = "up" }))
hl.bind(mainMod .. " + CTRL + J", hl.dsp.window.move({ direction = "down" }))

-- Resize windows
hl.bind(mainMod .. " + ALT + H", hl.dsp.window.resize({ x = -15, y = 0, "true" }))
hl.bind(mainMod .. " + ALT + L", hl.dsp.window.resize({ x = 15, y = 0, "true" }))
hl.bind(mainMod .. " + ALT + K", hl.dsp.window.resize({ x = 0, y = -15, "true" }))
hl.bind(mainMod .. " + ALT + J", hl.dsp.window.resize({ x = 0, y = 15, "true" }))

-- Switch focus on windows in Column
hl.bind(mainMod .. " + period", hl.dsp.layout("move +col"))
hl.bind(mainMod .. " + comma", hl.dsp.layout("move -col"))

-- Swap windows in column
hl.bind(mainMod .. " + SHIFT + period", hl.dsp.layout("swapcol r"))
hl.bind(mainMod .. " + SHIFT + comma", hl.dsp.layout("swapcol l"))

-- Center current window
hl.bind(mainMod .. " + C", hl.dsp.window.center())

-- Open Wallpaper selector
hl.bind(mainMod .. " + W", hl.dsp.exec_raw("bash $HOME/.local/bin/myScripts/wallpaperRelated/wallpaperSelect.sh"))

-- Take Screenshots using grim + slurp
hl.bind(mainMod .. " + Y", hl.dsp.exec_raw("bash $HOME/.local/bin/myScripts/screenshots/screenshot.sh --smart")) -- Save without edit
hl.bind(
	mainMod .. " + SHIFT + Y",
	hl.dsp.exec_raw("bash $HOME/.local/bin/myScripts/screenshots/screenshot.sh --smart --edit")
) -- Save and exit
hl.bind(
	mainMod .. " + PRINT",
	hl.dsp.exec_raw("bash $HOME/.local/bin/myScripts/screenshots/screenshot.sh --fullscreen")
) -- fullscreen

-- Switch workspaces with mainMod + [0-9]
-- Move active window to a workspace with mainMod + SHIFT + [0-9]
for i = 1, 10 do
	local key = i % 10 -- 10 maps to key 0
	hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }))
	hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Special workspace for Music
-- binds {
--     workspace_back_and_forth = true
--    hide_special_on_workspace_change = true
--}

-- Special workspace for music
hl.bind(mainMod .. " + N", hl.dsp.exec_raw(music))
hl.bind(mainMod .. " + SHIFT + N", hl.dsp.window.move({ workspace = "special:music" }))

-- Special workspace for scratchpad
hl.bind(mainMod .. " + M", hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + M", hl.dsp.window.move({ workspace = "special:magic" }))

-- Move between workspaces using keyboard keys
hl.bind(mainMod .. " + SHIFT + right", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + SHIFT + left", hl.dsp.focus({ workspace = "e+1" }))

-- Scroll through existing workspaces with mainMod + scroll
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

-- Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = "true" })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = "true" })

-- Laptop multimedia keys for volume and LCD brightness
hl.bind(
	"XF86AudioRaiseVolume",
	hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioLowerVolume",
	hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioMute",
	hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioMicMute",
	hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),
	{ locked = true, repeating = true }
)
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"), { locked = true, repeating = true })

-- Requires playerctl
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })
