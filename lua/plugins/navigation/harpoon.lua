return {
	"ThePrimeagen/harpoon",
	branch = "harpoon2",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-telescope/telescope.nvim",
		"rcarriga/nvim-notify",
	},
	config = function()
		local harpoon = require("harpoon")

		harpoon:setup({
			settings = {
				save_on_toggle = true,
				sync_on_ui_close = true,
				key = function()
					return vim.loop.cwd()
				end,
			},
		})

		vim.keymap.set("n", "<leader>ha", function()
			harpoon:list():add()
			vim.notify("Harpooned file", vim.log.levels.INFO, { title = "Harpoon 󰛢" })
		end, { desc = "Harpoon Add File" })
		vim.keymap.set("n", "<leader>hm", function()
			harpoon.ui:toggle_quick_menu(harpoon:list(), {
				title = "󰛢 Harpoon Menu",
				border = "rounded",
			})
		end, { desc = "Harpoon Menu" })
		vim.keymap.set("n", "<leader>hc", function()
			harpoon:list():clear()
		end, { desc = "Clear all Harpoon marks" })

		require("telescope").load_extension("harpoon")
		vim.keymap.set("n", "<leader>ht", function()
			require("telescope").extensions.harpoon.marks()
		end, { desc = "Harpoon via Telescope" })

		for i = 1, 9 do
			vim.keymap.set("n", "h" .. i, function()
				harpoon:list():select(i)
				vim.notify("Harpoon" .. i, vim.log.levels.INFO, { title = "Harpoon 󰛢" })
			end, { desc = "Harpoon go to file " .. i })
		end

		for i = 1, 9 do
			vim.keymap.set("n", "<leader>hd" .. i, function()
				harpoon:list():remove_at(i)
				vim.notify("Deleted harpoon", vim.log.levels.INFO, { title = "Harpoon 󰛢" })
			end, { desc = "Harpoon remove file " .. i })
		end
	end,
}
