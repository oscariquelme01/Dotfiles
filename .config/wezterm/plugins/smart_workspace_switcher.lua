local wezterm = require("wezterm")
local utils = require("utils")
local workspace_switcher =
	wezterm.plugin.require("https://github.com/MLFlexer/smart_workspace_switcher.wezterm")

local M = {}

wezterm.on("smart_workspace_switcher.workspace_switcher.created", function(window, path, label)
  -- `path` is the full directory path, e.g. "/home/user/Projects/Uni/Programming/search-engine"
  -- Extract the last path component
  local basename = string.match(path, "([^/]+)/?$")

  -- Rename the workspace to just the basename
  window:perform_action(
    wezterm.action.SwitchToWorkspace({
      name = basename,
      spawn = { cwd = path },
    }),
    window:active_pane()
  )

  wezterm.mux.rename_workspace(wezterm.mux.get_active_workspace(), basename)
end)

function M.apply(config)
	utils.add_keys(config, {
		{
			key = "s",
			mods = utils.mod .. "|ALT",
			action = workspace_switcher.switch_workspace(),
		},
	})
end

return M
