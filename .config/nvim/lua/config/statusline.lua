local function set_highlights()
  local colors = {
    StGitBranch = "#d3c6aa",
    StGitAdd = "#a7c080",
    StGitChange = "#dbbc7f",
    StGitDelete = "#e67e81",
    FileModifiedIcon = "#83a598",
    ErrorHl = "#e67e81",
    WarningHl = "#dbbc7f",
    HintsHl = "#A5E9DD",
    InfoHl = "#B0BA99",
    RecordingHl = "#e67e81",
    LazyCheckHl = "#F7F1DE",
  }

  for group, color in pairs(colors) do
    vim.api.nvim_set_hl(0, group, { fg = color, bg = "NONE" })
  end

  local modes = {
    StModeNormal = "#83a598",
    StModeInsert = "#d5c4a1",
    StModeVisual = "#d699b6",
    StModeOther = "#e67e81",
  }

  for group, color in pairs(modes) do
    vim.api.nvim_set_hl(0, group, {
      fg = "#2d353b",
      bg = color,
      bold = true,
    })
  end

  vim.api.nvim_set_hl(0, "StBase", { fg = "#d3c6aa", bg = "NONE" })
end

set_highlights()
vim.api.nvim_create_autocmd("ColorScheme", {
  callback = set_highlights,
})

vim.opt.laststatus = 3
vim.opt.showmode = false

local function get_lazy_updates()
	local lazy_status = require("lazy.status")
	local has_updates = lazy_status.has_updates()
	if has_updates == false then
		return ""
	end
	local updates = lazy_status.updates()
	return "%#LazyCheckHl#" .. " " .. updates .. " " .. "%#StBase#"
end

local function get_mode()
	local mode_map = {
		n = { " ✦ ", "StModeNormal" },
		i = { " i ", "StModeInsert" },
		v = { " v ", "StModeVisual" },
		V = { " v-line ", "StModeVisual" },
		["\22"] = { " v-block ", "StModeVisual" },
		c = { " c ", "StModeOther" },
		r = { " r ", "StModeOther" },
		R = { " R ", "StModeOther" },
		t = { " t ", "StModeOther" },
	}
	local mode = vim.api.nvim_get_mode().mode
	local m = mode_map[mode] or { " " .. mode .. " ", "StModeOther" }
	return "%#" .. m[2] .. "#" .. m[1] .. "%#StBase#"
end

local function get_git()
	local dict = vim.b.gitsigns_status_dict
	if not dict then
		return ""
	end

	local branch = dict.head and ("%#StGitBranch#  " .. dict.head .. " ") or ""
	local added = dict.added and dict.added > 0 and ("%#StGitAdd#+" .. dict.added .. " ") or ""
	local changed = dict.changed and dict.changed > 0 and ("%#StGitChange#~" .. dict.changed .. " ") or ""
	local removed = dict.removed and dict.removed > 0 and ("%#StGitDelete#-" .. dict.removed .. " ") or ""

	local diff = added .. changed .. removed
	if branch == "" and diff == "" then
		return ""
	end
	return diff .. branch .. ""
end

local function get_lsp_diagnostic_count()
	local counts = vim.diagnostic.count(0)

	local errors = counts[vim.diagnostic.severity.ERROR] or 0
	local warnings = counts[vim.diagnostic.severity.WARN] or 0
	local hints = counts[vim.diagnostic.severity.HINT] or 0
	local info = counts[vim.diagnostic.severity.INFO] or 0

	local error_icon = errors > 0 and "  " .. errors or ""
	local warnings_icon = warnings > 0 and "  " .. warnings or ""
	local hints_icon = hints > 0 and " 󰌵 " .. hints or ""
	local info_icon = info > 0 and "  " .. info or ""

	return "%#ErrorHl#"
		.. error_icon
		.. "%#WarningHl#"
		.. warnings_icon
		.. "%#HintsHl#"
		.. hints_icon
		.. "%#InfoHl#"
		.. info_icon
end

local has_devicons, devicons = pcall(require, "nvim-web-devicons")
local function get_icon()
	if not has_devicons then
		return ""
	end
	local icon, icon_hl = devicons.get_icon(vim.fn.expand("%:t"), vim.fn.expand("%:e"))
	if not icon then
		return ""
	end
	return "%#" .. icon_hl .. "# " .. icon .. " %#StBase#"
end

local blink_icon = true
local blink_timer = nil

local function get_macro_reading()
	local is_rec = vim.fn.reg_recording()
	if is_rec == "" then
		if blink_timer then
			blink_timer:stop()
			blink_timer:close()
			blink_timer = nil
		end
		return ""
	end
	if not blink_timer then
		blink_timer = vim.uv.new_timer()
		blink_timer:start(
			0,
			500,
			vim.schedule_wrap(function()
				blink_icon = not blink_icon
				vim.cmd("redrawstatus")
			end)
		)
	end
	local icon = blink_icon and "" or " "
	return "%#RecordingHl#" .. icon .. "%#StBase#" .. " Rec @"
end

function _G.CustomStatusLine()
	local is_active = vim.g.statusline_winid == vim.fn.win_getid()
	local is_modified = vim.api.nvim_get_option_value("modified", { buf = 0 })
	local modified_icon = is_modified and "●" or ""
	local filename = " %t"
	local space = "%="
	if not is_active then
		return "%#StBase#" .. filename .. space
	end
	return "%#StBase# "
		.. "%#FileModifiedIcon#"
		.. modified_icon
		.. "%#StBase#"
		.. filename
		.. " "
		.. get_lsp_diagnostic_count()
		.. "%#StBase#"
		.. space
		.. get_macro_reading()
		.. space
		.. get_lazy_updates()
		.. get_git()
		.. get_mode()
		.. get_icon()
end

vim.opt.statusline = "%!v:lua.CustomStatusLine()"

vim.cmd("redrawstatus") -- no need if not using any floating window from dashboard

vim.api.nvim_create_autocmd({ "InsertEnter", "InsertLeave", "CmdlineLeave" }, {
	callback = function()
		vim.schedule(function()
			vim.cmd("redrawstatus")
		end)
	end,
})

vim.api.nvim_create_autocmd("User", {
	pattern = { "GitSignsUpdate", "LazyCheck" },
	callback = function()
		vim.cmd("redrawstatus")
	end,
})
