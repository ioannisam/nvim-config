function _G.MyQFTF()
	local out = {}
	local items = vim.fn.getqflist()
	for _, item in ipairs(items) do
		out[#out + 1] = item.text
	end
	return out
end

vim.go.quickfixtextfunc = "v:lua.MyQFTF"

return {
	{
		"rcarriga/nvim-notify",
		lazy = false,
		config = function()
			local notify = require("notify")
			notify.setup({
				timeout = 1500,
				stages = "fade_in_slide_out",
				fps = 60,
				icons = {
					DEBUG = "",
					ERROR = "",
					INFO = "",
					TRACE = "✎",
					WARN = "",
				},
				level = 2, -- 1 = DEBUG, 2 = INFO, 3 = WARN, 4 = ERROR
				time_formats = {
					notification = "%H:%M",
					notification_history = "%Y-%m-%dT%H:%M",
				},
				background_colour = "#000000",
				top_down = true,
				render = "default",
			})

			vim.notify = notify
			vim.keymap.set("n", "<Esc>", function()
				if vim.v.hlsearch == 1 then
					vim.cmd("nohlsearch")
				end

				notify.dismiss({ silent = true, pending = true })
			end, { desc = "Esc: clear highlights and dismiss notifications" })

			vim.keymap.set("n", "<leader>xn", function()
				local notify = require("notify")
				local history = notify.history()

				local items = {}
				local type_map = { DEBUG = "N", INFO = "I", WARN = "W", ERROR = "E", TRACE = "N" }
				local icon_map = { DEBUG = "", ERROR = "", INFO = "", TRACE = "✎", WARN = "" }

				for _, notif in ipairs(history) do
					-- normalize level (number or string)
					local raw = notif.level
					local lvl
					if type(raw) == "number" then
						lvl = ({
							[vim.log.levels.TRACE] = "TRACE",
							[vim.log.levels.DEBUG] = "DEBUG",
							[vim.log.levels.INFO] = "INFO",
							[vim.log.levels.WARN] = "WARN",
							[vim.log.levels.ERROR] = "ERROR",
						})[raw]
					elseif type(raw) == "string" then
						lvl = raw:upper()
					end
					lvl = lvl or "INFO"

					local qftype = type_map[lvl]
					local icon = icon_map[lvl] or ""
					local time = os.date("%H:%M", notif.time)
					local msg = notif.message

					if type(msg) == "table" then
						msg = table.concat(
							vim.tbl_map(function(m)
								return (type(m) == "string" and m) or vim.inspect(m)
							end, msg),
							"\n"
						)
					end

					-- wrap+split into lines
					local max_len = 150
					local lines = {}
					for line in msg:gmatch("[^\n]+") do
						while #line > max_len do
							local pos = line:sub(1, max_len):find("%s[^%s]*$") or max_len
							table.insert(lines, line:sub(1, pos))
							line = line:sub(pos + 1)
						end
						table.insert(lines, line)
					end

					-- scratch buffer for preview
					local buf = vim.api.nvim_create_buf(false, true)
					vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

					for i, line in ipairs(lines) do
						local hl_group
						if lvl == "ERROR" then
							hl_group = "QFError"
						elseif lvl == "WARN" then
							hl_group = "QFWarn"
						elseif lvl == "INFO" then
							hl_group = "QFInfo"
						elseif lvl == "DEBUG" then
							hl_group = "QFDebug"
						elseif lvl == "TRACE" then
							hl_group = "QFArrowTrace"
						end

						if hl_group then
							vim.api.nvim_buf_add_highlight(buf, -1, hl_group, i - 1, 0, -1)
						end

						-- Optionally highlight the icon at the start of the line
						local icons = {
							[""] = "QFIconError",
							[""] = "QFIconWarn",
							[""] = "QFIconInfo",
							[""] = "QFIconDebug",
							["✎"] = "QFIconTrace",
						}
						local icon_match = line:match("^([%z\1-\127\194-\244][\128-\191]*)")
						if icon_match and icons[icon_match] then
							vim.api.nvim_buf_add_highlight(buf, -1, icons[icon_match], i - 1, 0, #icon_match)
						end
					end

					local summary = lines[1] or ""
					table.insert(items, {
						bufnr = buf,
						lnum = 1,
						col = 1,
						text = string.format("%s | %s %-5s ▶ %s", time, icon, lvl, summary),
						type = qftype,
					})
				end

				vim.fn.setqflist({}, "r", { title = "Notifications", items = items })

				local qf_open = false
				for _, win in ipairs(vim.api.nvim_list_wins()) do
					if vim.bo[vim.api.nvim_win_get_buf(win)].buftype == "quickfix" then
						qf_open = true
						break
					end
				end

				if not qf_open then
					vim.cmd("copen")
					-- Trigger syntax highlighting immediately
					vim.schedule(function()
						vim.cmd("call SetQFSyntax()")
					end)
				else
					vim.cmd("cclose")
				end
			end, { desc = "Toggle Notifications History in quickfix (for bqf)" })
		end,
	},
}
