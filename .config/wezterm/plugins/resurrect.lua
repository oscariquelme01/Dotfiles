local wezterm = require("wezterm")
local utils = require("utils")
local resurrect = wezterm.plugin.require("https://github.com/MLFlexer/resurrect.wezterm")

resurrect.state_manager.periodic_save()

local function on_pane_restore(pane_tree)
	if pane_tree.cwd and pane_tree.cwd ~= "" then
		pane_tree.pane:send_text("cd " .. wezterm.shell_quote_arg(pane_tree.cwd) .. "\r\n")
	end
	resurrect.tab_state.default_on_pane_restore(pane_tree)
end

-- loads the state whenever I create a new workspace
wezterm.on("smart_workspace_switcher.workspace_switcher.created", function(window, path, label)
	wezterm.log_info("resurrect: restoring workspace " .. label)
	resurrect.workspace_state.restore_workspace(resurrect.state_manager.load_state(label, "workspace"), {
		window = window,
		relative = true,
		restore_text = true,
		resize_window = false,
		on_pane_restore = on_pane_restore,
	})
end)

-- Saves the state whenever I select a workspace
wezterm.on("smart_workspace_switcher.workspace_switcher.selected", function(window, path, label)
	wezterm.log_info("resurrect: saving workspace " .. label)
	resurrect.state_manager.save_state(resurrect.workspace_state.get_workspace_state())
end)

local M = {}
function M.apply(config)
	utils.add_keys(config, {
		{
			key = "r",
			mods = utils.mod .. "|ALT",
			action = wezterm.action_callback(function(win, pane)
				resurrect.fuzzy_loader.fuzzy_load(win, pane, function(id, label)
					local type = string.match(id, "^([^/]+)")
					id = string.match(id, "([^/]+)$")
					id = string.match(id, "(.+)%..+$")

					if type == "workspace" then
						wezterm.log_info("resurrect: loading workspace " .. id .. " from fuzzy loader")
						win:perform_action(wezterm.action.SwitchToWorkspace({ name = id }), pane)
						wezterm.time.call_after(0.1, function()
							local state = resurrect.state_manager.load_state(id, "workspace")
							local mux_win = nil
							for _, w in ipairs(wezterm.mux.all_windows()) do
								if w:get_workspace() == id then
									mux_win = w
									break
								end
							end
							wezterm.log_info("resurrect: restoring workspace " .. id .. " into existing window")
							resurrect.workspace_state.restore_workspace(state, {
								window = mux_win,
								relative = true,
								restore_text = true,
								resize_window = false,
								on_pane_restore = on_pane_restore,
							})
						end)
					elseif type == "window" then
						local state = resurrect.state_manager.load_state(id, "window")
						resurrect.window_state.restore_window(pane:window(), state, {
							relative = true,
							restore_text = true,
							on_pane_restore = on_pane_restore,
						})
					elseif type == "tab" then
						local state = resurrect.state_manager.load_state(id, "tab")
						resurrect.tab_state.restore_tab(pane:tab(), state, {
							relative = true,
							restore_text = true,
							on_pane_restore = on_pane_restore,
						})
					end
				end)
			end),
		},
		{
			key = "d",
			mods = utils.mod .. "|ALT",
			action = wezterm.action_callback(function(win, pane)
				resurrect.fuzzy_loader.fuzzy_load(win, pane, function(id)
					resurrect.state_manager.delete_state(id)
				end, {
					title = "Delete State",
					description = "Select State to Delete and press Enter = accept, Esc = cancel, / = filter",
					fuzzy_description = "Search State to Delete: ",
					is_fuzzy = true,
				})
			end),
		},
	})
end

return M
