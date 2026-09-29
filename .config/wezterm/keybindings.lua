local wezterm = require("wezterm")
local utils = require("utils")

local mod = utils.mod

local M = {}

function M.apply(config)
	config.keys = {
		-- Split vertically
		{
			key = "v",
			mods = mod .. "|ALT",
			action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }),
		},
		-- Split horizontally (I know, names are backward)
		{
			key = "x",
			mods = mod .. "|ALT",
			action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }),
		},
		-- New tab
		{
			key = "t",
			mods = mod .. "|ALT",
			action = wezterm.action.SpawnTab("CurrentPaneDomain"),
		},
		-- New workspace
		{
			key = "w",
			mods = mod .. "|ALT",
			action = wezterm.action.PromptInputLine({
				description = "Enter name for new workspace",
				action = wezterm.action_callback(function(window, pane, line)
					if line then
						window:perform_action(wezterm.action.SwitchToWorkspace({ name = line }), pane)
					end
				end),
			}),
		},
		-- Rename current tab
		{
			key = "t",
			mods = mod .. "|ALT|SHIFT",
			action = wezterm.action.PromptInputLine({
				description = "Enter new tab name",
				action = wezterm.action_callback(function(window, pane, line)
					if line then
						window:active_tab():set_title(line)
					end
				end),
			}),
		},
		-- Rename currrent worksapce
		{
			key = "w",
			mods = mod .. "|ALT|SHIFT", -- Adjust the modifier keys to your preference
			action = wezterm.action.PromptInputLine({
				description = "Enter new name for the workspace:",
				action = wezterm.action_callback(function(window, pane, line)
					if line then
						wezterm.mux.rename_workspace(window:mux_window():get_workspace(), line)
					end
				end),
			}),
		},
		-- Enter copy mode
		{
			key = "c",
			mods = mod .. "|ALT",
			action = wezterm.action.ActivateCopyMode,
		},
		-- Temporal mappings, will delete when I flash my ZMK new corne mappings
		{ key = "1", mods = "ALT", action = wezterm.action.ActivateTab(0) },
		{ key = "2", mods = "ALT", action = wezterm.action.ActivateTab(1) },
		{ key = "3", mods = "ALT", action = wezterm.action.ActivateTab(2) },
		{ key = "4", mods = "ALT", action = wezterm.action.ActivateTab(3) },
		{ key = "5", mods = "ALT", action = wezterm.action.ActivateTab(4) },
		{ key = "6", mods = "ALT", action = wezterm.action.ActivateTab(5) },
		{ key = "7", mods = "ALT", action = wezterm.action.ActivateTab(6) },
		{ key = "8", mods = "ALT", action = wezterm.action.ActivateTab(7) },
		{ key = "9", mods = "ALT", action = wezterm.action.ActivateTab(8) },
		-- Pass keys
		{
			key = "s",
			mods = mod,
			action = wezterm.action.SendKey({ key = "s", mods = mod }),
		},
	}

	-- Mouse smooth scroll (1 line per input)
	config.mouse_bindings = {
		{
			event = { Down = { streak = 1, button = { WheelUp = 1 } } },
			mods = 'NONE',
			action = wezterm.action.ScrollByLine(-3),
		},
		{
			event = { Down = { streak = 1, button = { WheelDown = 1 } } },
			mods = 'NONE',
			action = wezterm.action.ScrollByLine(3),
		},
	}
end

return M
