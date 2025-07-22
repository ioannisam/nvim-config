return {
	"folke/persistence.nvim",
	lazy = "BufReadPre",
	opts = {
		dir = vim.fn.stdpath("state") .. "/sessions/",
		options = { "buffers", "curdir", "tabpages", "winsize", "folds" },
		need = 1,
	},
	config = function(_, opts)
		local persistence = require("persistence")
		local config = require("persistence.config")

		vim.fn.mkdir(opts.dir, "p")
		config.options = vim.tbl_deep_extend("force", config.options, opts or {})

		vim.api.nvim_create_user_command("PersistenceClear", function()
			local session_dir = vim.fn.stdpath("state") .. "/sessions/"

			local function get_sessions()
				local files = vim.fn.glob(session_dir .. "*.vim", false, true)
				return vim.tbl_map(function(f)
					return vim.fn.fnamemodify(f, ":t")
				end, files)
			end

			local sessions = get_sessions()

			if #sessions == 0 then
				vim.notify("No sessions to clear!", vim.log.levels.INFO)
				return
			end

			local function pick_and_delete()
				sessions = get_sessions()
				if #sessions == 0 then
					vim.notify("All sessions cleared.", vim.log.levels.INFO)
					return
				end

				vim.ui.select(sessions, { prompt = "Select session to delete (ESC to cancel):" }, function(choice)
					if choice then
						local full_path = session_dir .. choice
						if vim.fn.delete(full_path) == 0 then
							vim.notify("Deleted session: " .. choice, vim.log.levels.INFO)
							pick_and_delete()
						else
							vim.notify("Failed to delete session: " .. choice, vim.log.levels.ERROR)
						end
					end
				end)
			end

			pick_and_delete()
		end, {
			desc = "Clear one or more sessions interactively",
		})

		vim.api.nvim_create_autocmd("VimLeavePre", {
			callback = function()
				persistence.save()
			end,
		})
	end,
}
