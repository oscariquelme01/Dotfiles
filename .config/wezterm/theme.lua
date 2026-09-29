-- Vesper theme for WezTerm
-- Source: https://github.com/raunofreiberg/vesper

local wezterm = require("wezterm")
local utils = require("utils")

local font_family = utils.is_mac and "GeistMono Nerd Font" or "FiraCode Nerd Font"

local M = {}

function M.apply(config)
	-- Font
	config.font = wezterm.font_with_fallback({
		{
			family = font_family,
			weight = "Regular",
			style = "Normal",
		},
	})
	config.font_size = 14.0 and utils.is_mac or 12.0

	-- Change inactive pane brightness
	config.inactive_pane_hsb = {
		saturation = 0.9,
		brightness = 0.5,
	}

	-- Explicit font variants (bold, italic, bold italic)
	config.font_rules = {
		{
			intensity = "Bold",
			italic = false,
			font = wezterm.font({
				family = font_family,
				weight = "Bold",
				style = "Normal",
			}),
		},
		{
			intensity = "Normal",
			italic = true,
			font = wezterm.font({
				family = font_family,
				weight = "Regular",
				style = "Italic",
			}),
		},
		{
			intensity = "Bold",
			italic = true,
			font = wezterm.font({
				family = font_family,
				weight = "Bold",
				style = "Italic",
			}),
		},
	}

	-- Colors
	config.color_scheme = "Vesper"
end

return M
