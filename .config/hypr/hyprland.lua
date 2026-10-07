-- Hyprland + Noctalia. Vesper colors from ~/.config/kitty/kitty.conf.
-- Keybinding reference and migration notes: README.md.

local mainMod = "SUPER"
local terminal = "kitty"
local fileManager = "dolphin"
local ipc = "noctalia msg "

-- Displays: keep the laptop on, extend external displays to the right.
hl.monitor({ output = "eDP-1", mode = "2880x1920@120", position = "0x0", scale = 2 })
-- Match the physical LG, but use its previous mode/scale while diagnosing 5K output.
hl.monitor({
	output = "desc:LG Electronics LG ULTRAFINE 509NTFAL1091",
	mode = "preferred",
	position = "auto-right",
	scale = 1.1,
})
hl.monitor({ output = "", mode = "preferred", position = "auto-right", scale = "auto" })

-- Resolution-based profiles work with either house's monitor on any connector.
-- Only adjust recognized native resolutions; unknown displays use the fallback.
-- 5/3 replaces the old 1.67 scale with an exact fractional scale.
local function configureExternalMonitors()
	for _, monitor in ipairs(hl.get_monitors()) do
		local scale
		if monitor.serial == "509NTFAL1091" then
			-- The explicit LG profile wins; do not reapply the experimental 5K scale.
		elseif monitor.width == 5120 and monitor.height == 1440 then
			scale = 1.25
		elseif monitor.width == 5120 and monitor.height == 2160 then
			scale = 5 / 3
		end
		if scale and math.abs(monitor.scale - scale) > 0.001 then
			hl.monitor({ output = monitor.name, mode = "highres", position = "auto-right", scale = scale })
		end
	end
end

configureExternalMonitors()
hl.on("monitor.added", configureExternalMonitors)
hl.on("monitor.layout_changed", configureExternalMonitors)

-- Noctalia stores wallpaper paths by connector. Resolve the physical identity
-- in a separate process on hotplug; never run blocking IPC in compositor callbacks.
local function applyMonitorWallpapers()
	hl.exec_cmd('python "$HOME/.config/hypr/scripts/monitor-wallpaper.py"')
end
hl.on("monitor.added", applyMonitorWallpapers)
hl.on("monitor.removed", applyMonitorWallpapers)

-- Noctalia owns the bar, wallpaper, notifications, clipboard, lock and polkit.
hl.on("hyprland.start", function()
	hl.exec_cmd("noctalia")
end)

hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")
-- Compatibility for older Electron applications; modern versions use Wayland automatically.
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")
-- No QT_QPA_PLATFORMTHEME override: qt5ct/qt6ct are not installed.

hl.config({
	general = {
		gaps_in = 0,
		gaps_out = 0,
		border_size = 1,
		col = {
			active_border = "rgba(ffc799ee)",
			inactive_border = "rgba(282828aa)",
		},
		layout = "dwindle",
		allow_tearing = false,
		resize_on_border = true,
	},
	decoration = {
		rounding = 0,
		active_opacity = 1,
		inactive_opacity = 1,
		shadow = { enabled = true, range = 4, render_power = 3, color = 0xee101010 },
		blur = { enabled = true, size = 3, passes = 1, vibrancy = 0.1696 },
	},
	animations = { enabled = true },
	dwindle = { preserve_split = true },
	input = {
		kb_layout = "us,es",
		kb_options = "grp:win_space_toggle",
		follow_mouse = 1,
		sensitivity = 0,
		touchpad = { natural_scroll = false },
	},
	misc = {
		-- From hypr.conf-old: follow activation requests, e.g. terminal links opening in a browser.
		focus_on_activate = true,
		force_default_wallpaper = 1,
		disable_hyprland_logo = true,
		background_color = "rgb(101010)",
	},
})

-- Preserve the old animation timings and curve.
hl.curve("myBezier", { type = "bezier", points = { { 0.05, 0.9 }, { 0.1, 1.05 } } })
hl.animation({ leaf = "windows", enabled = true, speed = 7, bezier = "myBezier" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 7, bezier = "default", style = "popin 80%" })
hl.animation({ leaf = "border", enabled = true, speed = 10, bezier = "default" })
hl.animation({ leaf = "borderangle", enabled = true, speed = 8, bezier = "default" })
hl.animation({ leaf = "fade", enabled = true, speed = 7, bezier = "default" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 6, bezier = "default" })

hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })

-- Small helpers keep all shortcuts described in `hyprctl binds`.
local function bind(key, dispatcher, description, flags)
	flags = flags or {}
	flags.description = description
	hl.bind(key, dispatcher, flags)
end

local function shellBind(key, command, description, flags)
	bind(key, hl.dsp.exec_cmd(ipc .. command), description, flags)
end

-- Familiar app/session shortcuts. Super+Space remains the keyboard-layout toggle.
bind(mainMod .. " + Return", hl.dsp.exec_cmd(terminal), "Open Kitty")
bind(mainMod .. " + Q", hl.dsp.window.close(), "Close window")
bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager), "Open Dolphin")
shellBind(mainMod .. " + R", "panel-toggle launcher", "App launcher")
shellBind(mainMod .. " + L", "session lock", "Lock session")
shellBind(mainMod .. " + CTRL + E", "panel-toggle session", "Session menu (replaces immediate exit)")
shellBind(mainMod .. " + A", "panel-toggle control-center", "Control center")
shellBind(mainMod .. " + I", "settings-toggle", "Noctalia settings")
shellBind(mainMod .. " + CTRL + V", "panel-toggle clipboard", "Clipboard history")
shellBind(mainMod .. " + N", "panel-toggle control-center notifications", "Notification history")
shellBind(mainMod .. " + CTRL + N", "notification-dnd-toggle", "Toggle Do Not Disturb")
shellBind(mainMod .. " + CTRL + C", "caffeine-toggle", "Toggle idle inhibition")
shellBind("ALT + Tab", "window-switcher hold", "Window switcher")

-- Window controls. Avoid hijacking Kitty/Neovim's Ctrl+H/J/K/L navigation.
bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }), "Toggle floating")
bind(mainMod .. " + SHIFT + V", hl.dsp.window.center(), "Center floating window")
bind(mainMod .. " + F", hl.dsp.window.fullscreen({ mode = "fullscreen" }), "Toggle fullscreen")
bind(mainMod .. " + SHIFT + F", hl.dsp.window.fullscreen({ mode = "maximized" }), "Toggle maximized")
bind(mainMod .. " + backslash", hl.dsp.layout("togglesplit"), "Toggle dwindle split direction")

local directions = {
	{ key = "left", vim = "H", direction = "l", x = -40, y = 0 },
	{ key = "right", vim = "L", direction = "r", x = 40, y = 0 },
	{ key = "up", vim = "K", direction = "u", x = 0, y = -40 },
	{ key = "down", vim = "J", direction = "d", x = 0, y = 40 },
}

for _, d in ipairs(directions) do
	bind(mainMod .. " + " .. d.key, hl.dsp.focus({ direction = d.direction }), "Focus " .. d.key)
	bind(mainMod .. " + ALT + " .. d.vim, hl.dsp.focus({ direction = d.direction }), "Focus " .. d.key .. " (Vim)")
	bind(mainMod .. " + SHIFT + " .. d.key, hl.dsp.window.move({ direction = d.direction }), "Move window " .. d.key)
	bind(mainMod .. " + CTRL + " .. d.key,
		hl.dsp.window.resize({ x = d.x, y = d.y, relative = true }), "Resize window " .. d.key, { repeating = true })
end

-- Workspaces: retain the old move-and-follow behavior and add silent moves.
for i = 1, 10 do
	local key = i % 10
	bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }), "Workspace " .. i)
	bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i, follow = true }), "Move to workspace " .. i)
	bind(mainMod .. " + CTRL + SHIFT + " .. key, hl.dsp.window.move({ workspace = i, follow = false }), "Send to workspace " .. i)
end

bind(mainMod .. " + Tab", hl.dsp.focus({ workspace = "previous" }), "Previous workspace")
bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }), "Next existing workspace")
bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }), "Previous existing workspace")
bind(mainMod .. " + Page_Down", hl.dsp.focus({ workspace = "e+1" }), "Next existing workspace")
bind(mainMod .. " + Page_Up", hl.dsp.focus({ workspace = "e-1" }), "Previous existing workspace")

-- Monitor navigation: comma = left, period = right.
for _, m in ipairs({ { key = "comma", direction = "l" }, { key = "period", direction = "r" } }) do
	bind(mainMod .. " + " .. m.key, hl.dsp.focus({ monitor = m.direction }), "Focus monitor " .. m.direction)
	bind(mainMod .. " + SHIFT + " .. m.key, hl.dsp.window.move({ monitor = m.direction, follow = true }), "Move window to monitor " .. m.direction)
end

-- Cycle the current workspace between connected monitors, following it.
bind(mainMod .. " + S", function()
	local monitors = hl.get_monitors()
	local current = hl.get_active_monitor()
	if not current or #monitors < 2 then
		return
	end
	table.sort(monitors, function(a, b) return a.id < b.id end)
	for i, monitor in ipairs(monitors) do
		if monitor.id == current.id then
			local target = monitors[i % #monitors + 1]
			hl.dispatch(hl.dsp.workspace.move({ monitor = target }))
			hl.dispatch(hl.dsp.focus({ monitor = target }))
			return
		end
	end
end, "Move workspace to next monitor and follow")

-- Frozen region selector: Ctrl+C copies only, Ctrl+S saves only, Enter does both.
shellBind(mainMod .. " + P", "screenshot-region", "Region screenshot (Ctrl+C copy / Ctrl+S save)")
shellBind(mainMod .. " + CTRL + P", "screenshot-region", "Region screenshot (Ctrl+S to save)")
shellBind("Print", "screenshot-region", "Region screenshot")
shellBind("SHIFT + Print", "screenshot-fullscreen", "Screenshot focused monitor")
shellBind("CTRL + Print", "screenshot-fullscreen all", "Screenshot all monitors")
shellBind(mainMod .. " + SHIFT + P", "screenshot-annotate", "Screenshot and annotate")

bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), "Drag window", { mouse = true })
bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), "Resize window", { mouse = true })

-- Native controls provide Noctalia OSDs; volume and brightness work when locked.
for _, media in ipairs({
	{ "XF86AudioRaiseVolume", "volume-up", "Volume up", true },
	{ "XF86AudioLowerVolume", "volume-down", "Volume down", true },
	{ "XF86AudioMute", "volume-mute", "Mute output" },
	{ "XF86AudioMicMute", "mic-mute", "Mute microphone" },
	{ "XF86MonBrightnessUp", "brightness-up", "Brightness up", true },
	{ "XF86MonBrightnessDown", "brightness-down", "Brightness down", true },
	{ "XF86AudioNext", "media next", "Next track" },
	{ "XF86AudioPrev", "media previous", "Previous track" },
	{ "XF86AudioPause", "media toggle", "Play/pause" },
	{ "XF86AudioPlay", "media toggle", "Play/pause" },
	{ "XF86AudioStop", "media stop", "Stop playback" },
}) do
	shellBind(media[1], media[2], media[3], { locked = true, repeating = media[4] or false })
end

-- Only Kitty should ignore maximize requests (as in the old config).
-- Count visible windows, including floating ones; restore the normal border at 2+.
hl.window_rule({
	name = "single-window-no-border",
	match = { workspace = "w[v1]" },
	border_size = 0,
})
hl.window_rule({ name = "kitty-no-maximize", match = { class = "^(kitty|kitty-test)$" }, suppress_event = "maximize" })
hl.window_rule({
	name = "fix-xwayland-drags",
	match = { class = "^$", title = "^$", xwayland = true, float = true, fullscreen = false, pin = false },
	no_focus = true,
})
hl.window_rule({
	name = "noctalia-settings",
	match = { class = "^dev\\.noctalia\\.Noctalia$" },
	float = true,
	size = { 1000, 800 },
})
hl.layer_rule({
	name = "noctalia",
	match = { namespace = "^noctalia-(bar-.+|notification|dock|panel|attached-panel|osd|window-switcher)$" },
	no_anim = true,
	ignore_alpha = 0.5,
	blur = true,
	blur_popups = true,
})
